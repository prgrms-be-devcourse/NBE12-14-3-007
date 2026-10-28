package com.team007.room_escape.global.ratelimit

import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test
import java.time.Clock
import java.time.Duration
import java.time.Instant
import java.time.ZoneId
import java.util.concurrent.Callable
import java.util.concurrent.CountDownLatch
import java.util.concurrent.Executors
import java.util.concurrent.TimeUnit

class FixedWindowLimiterTest {

    /** 시간을 마음대로 움직일 수 있는 시계 */
    private class MutableClock(var now: Instant = Instant.parse("2026-10-27T10:00:00Z")) : Clock() {
        override fun getZone(): ZoneId = ZoneId.of("UTC")
        override fun withZone(zone: ZoneId?): Clock = this
        override fun instant(): Instant = now
        fun advance(duration: Duration) {
            now = now.plus(duration)
        }
    }

    private val clock = MutableClock()
    private val limiter = FixedWindowLimiter(maxAttempts = 3, window = Duration.ofMinutes(5), clock = clock)

    @Test
    fun `한도보다 적게 센 key는 막히지 않는다`() {
        limiter.record("a")
        limiter.record("a")

        assertThat(limiter.retryAfter("a")).isNull()
    }

    @Test
    fun `한도만큼 세면 막히고 구간이 끝날 때까지 남은 시간을 알려 준다`() {
        repeat(3) { limiter.record("a") }
        clock.advance(Duration.ofMinutes(2))

        assertThat(limiter.retryAfter("a")).isEqualTo(Duration.ofMinutes(3))
    }

    @Test
    fun `구간이 끝나면 풀리고 횟수는 다시 0부터 센다`() {
        repeat(3) { limiter.record("a") }
        clock.advance(Duration.ofMinutes(5))

        assertThat(limiter.retryAfter("a")).isNull()
        limiter.record("a")
        limiter.record("a")
        assertThat(limiter.retryAfter("a")).isNull()
    }

    @Test
    fun `구간은 첫 시도에서 시작해서 뒤의 시도가 구간을 늘리지 않는다`() {
        limiter.record("a")
        clock.advance(Duration.ofMinutes(4))
        limiter.record("a")
        limiter.record("a")

        assertThat(limiter.retryAfter("a")).isEqualTo(Duration.ofMinutes(1))
    }

    @Test
    fun `key마다 따로 센다`() {
        repeat(3) { limiter.record("a") }

        assertThat(limiter.retryAfter("a")).isNotNull()
        assertThat(limiter.retryAfter("b")).isNull()
    }

    @Test
    fun `reset하면 횟수가 지워진다`() {
        repeat(3) { limiter.record("a") }

        limiter.reset("a")

        assertThat(limiter.retryAfter("a")).isNull()
    }

    @Test
    fun `tryAcquire는 한도까지 허용하고 그 다음부터 거절한다`() {
        assertThat(limiter.tryAcquire("a")).isNull()
        assertThat(limiter.tryAcquire("a")).isNull()
        assertThat(limiter.tryAcquire("a")).isNull()

        assertThat(limiter.tryAcquire("a")).isEqualTo(Duration.ofMinutes(5))
    }

    @Test
    fun `거절된 시도는 횟수를 늘리지 않아서 구간이 끝나면 다시 허용된다`() {
        repeat(3) { limiter.tryAcquire("a") }
        repeat(10) { limiter.tryAcquire("a") } // 거절되는 시도를 아무리 보내도 구간이 늘어나지 않는다.
        clock.advance(Duration.ofMinutes(5))

        assertThat(limiter.tryAcquire("a")).isNull()
    }

    @Test
    fun `동시에 요청해도 허용하는 횟수는 한도를 넘지 않는다`() {
        val concurrent = FixedWindowLimiter(maxAttempts = 5, window = Duration.ofMinutes(5))
        val pool = Executors.newFixedThreadPool(16)
        val start = CountDownLatch(1)
        try {
            val results = (1..64).map {
                pool.submit(Callable {
                    start.await()
                    concurrent.tryAcquire("a")
                })
            }
            start.countDown()
            val allowed = results.count { it.get(10, TimeUnit.SECONDS) == null }

            assertThat(allowed).isEqualTo(5)
        } finally {
            pool.shutdownNow()
        }
    }
}
