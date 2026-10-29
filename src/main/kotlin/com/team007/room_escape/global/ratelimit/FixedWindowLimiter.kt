package com.team007.room_escape.global.ratelimit

import com.github.benmanes.caffeine.cache.Caffeine
import java.time.Clock
import java.time.Duration
import java.time.Instant

/**
 * 같은 key의 시도를 일정 시간 안에 [maxAttempts]번까지만 허용하는 고정 구간 제한기.
 * 구간은 첫 시도에서 시작해 [window]가 지나면 끝나고, 그때 횟수가 다시 0부터 시작한다.
 *
 * 횟수는 서버 메모리(Caffeine)에만 있다. 서버를 다시 띄우면 지워지고, 서버를 2대 이상 띄우면 서버마다 따로 센다.
 * 확장이 필요하면 이 클래스만 Redis 같은 공용 저장소로 바꾼다.
 */
class FixedWindowLimiter(
    private val maxAttempts: Int,
    private val window: Duration,
    private val clock: Clock = Clock.systemUTC(),
    maxEntries: Long = MAX_ENTRIES,
) {

    private data class Window(val count: Int, val start: Instant)

    // 오래된 key가 메모리에 쌓이지 않게 지우고, 무작위 key를 대량으로 보내도 크기가 커지지 않게 막는다.
    private val windows = Caffeine.newBuilder()
        .expireAfterWrite(window)
        .maximumSize(maxEntries)
        .build<String, Window>()

    /** 횟수를 올리지 않고, 이 key가 지금 막혀 있는지 본다. 막혀 있으면 풀릴 때까지 남은 시간을 돌려준다. */
    fun retryAfter(key: String): Duration? {
        val current = windows.getIfPresent(key)?.takeIf { isOpen(it) } ?: return null
        return if (current.count >= maxAttempts) remaining(current) else null
    }

    /** 시도 한 번을 세고, 이 구간에서 지금까지 센 횟수를 돌려준다. 막히지 않을 때 쓴다. */
    fun record(key: String): Int =
        checkNotNull(windows.asMap().compute(key) { _, old -> count(old) }).count

    /**
     * 시도를 허용하면 한 번 세고 null을, 이미 한도를 넘었으면 풀릴 때까지 남은 시간을 돌려준다.
     * 확인과 세기를 한 번에 해서 동시에 여러 요청이 와도 한도를 넘지 않는다.
     */
    fun tryAcquire(key: String): Duration? {
        var blockedFor: Duration? = null
        windows.asMap().compute(key) { _, old ->
            val current = old?.takeIf { isOpen(it) }
            if (current != null && current.count >= maxAttempts) {
                blockedFor = remaining(current)
                current
            } else {
                count(old)
            }
        }
        return blockedFor
    }

    /** 이 key의 횟수를 지운다. 로그인에 성공했을 때 쓴다. */
    fun reset(key: String) {
        windows.invalidate(key)
    }

    private fun count(old: Window?): Window {
        val current = old?.takeIf { isOpen(it) }
        return if (current == null) Window(1, clock.instant()) else current.copy(count = current.count + 1)
    }

    private fun isOpen(window: Window): Boolean = clock.instant().isBefore(window.start.plus(this.window))

    private fun remaining(window: Window): Duration = Duration.between(clock.instant(), window.start.plus(this.window))

    private companion object {
        const val MAX_ENTRIES = 10_000L
    }
}
