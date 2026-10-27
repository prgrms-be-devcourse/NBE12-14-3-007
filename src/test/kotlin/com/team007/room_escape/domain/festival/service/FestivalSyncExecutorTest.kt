package com.team007.room_escape.domain.festival.service

import com.team007.room_escape.domain.festival.dto.FestivalResponse
import org.assertj.core.api.Assertions.assertThat
import org.assertj.core.api.Assertions.assertThatThrownBy
import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.extension.ExtendWith
import org.mockito.InjectMocks
import org.mockito.Mock
import org.mockito.Mockito.times
import org.mockito.Mockito.verify
import org.mockito.Mockito.`when`
import org.mockito.junit.jupiter.MockitoExtension
import java.util.concurrent.CountDownLatch
import java.util.concurrent.Executors
import java.util.concurrent.Future
import java.util.concurrent.TimeUnit

/**
 * FestivalSyncExecutor의 동시 실행 방지를 검증한다.
 * 동기화 자체(FestivalService)는 목으로 대체하고, "누가 먼저 실행 중일 때 어떻게 되는지"만 확인한다.
 */
@ExtendWith(MockitoExtension::class)
class FestivalSyncExecutorTest {

    @field:Mock
    private lateinit var festivalService: FestivalService

    @field:InjectMocks
    private lateinit var executor: FestivalSyncExecutor

    @Test
    @DisplayName("실행 중이 아니면 동기화 결과를 그대로 돌려준다")
    fun tryRunReturnsResultWhenIdle() {
        `when`(festivalService.syncPublicFestivals()).thenReturn(RESULT)

        val result: FestivalResponse.SyncResponse? = executor.tryRun()

        assertThat(result).isEqualTo(RESULT)
    }

    @Test
    @DisplayName("이미 실행 중이면 tryRun은 기다리지 않고 null을 돌려주고 동기화를 또 실행하지 않는다")
    fun tryRunReturnsNullWhileAnotherRunIsInProgress() {
        val started = CountDownLatch(1)
        val release = CountDownLatch(1)
        `when`(festivalService.syncPublicFestivals()).thenAnswer {
            started.countDown() // 첫 실행이 시작됐음을 알림
            release.await(5, TimeUnit.SECONDS) // 테스트가 풀어줄 때까지 실행 중인 척 대기
            RESULT
        }

        val pool = Executors.newSingleThreadExecutor()
        try {
            val first: Future<FestivalResponse.SyncResponse?> = pool.submit(executor::tryRun)
            assertThat(started.await(5, TimeUnit.SECONDS)).isTrue()

            val second = executor.tryRun() // 첫 실행이 잡고 있는 중

            assertThat(second).isNull()
            release.countDown()
            assertThat(first.get(5, TimeUnit.SECONDS)).isEqualTo(RESULT)
            verify(festivalService, times(1)).syncPublicFestivals()
        } finally {
            release.countDown()
            pool.shutdownNow()
        }
    }

    @Test
    @DisplayName("동기화 중 예외가 나도 잠금이 풀려서 다음 실행이 막히지 않는다")
    fun releasesLockWhenSyncThrows() {
        `when`(festivalService.syncPublicFestivals())
            .thenThrow(IllegalStateException("공공 API 실패"))
            .thenReturn(RESULT)

        assertThatThrownBy { executor.tryRun() }.isInstanceOf(IllegalStateException::class.java)

        assertThat(executor.tryRun()).isEqualTo(RESULT)
    }

    @Test
    @DisplayName("run(스케줄러용)은 실행 중이면 끝날 때까지 기다렸다가 자기 회차도 실행한다")
    fun runWaitsForOngoingRunThenExecutes() {
        val started = CountDownLatch(1)
        val release = CountDownLatch(1)
        `when`(festivalService.syncPublicFestivals())
            .thenAnswer {
                started.countDown()
                release.await(5, TimeUnit.SECONDS)
                RESULT
            }
            .thenReturn(RESULT)

        val pool = Executors.newFixedThreadPool(2)
        try {
            val manual: Future<FestivalResponse.SyncResponse?> = pool.submit(executor::tryRun)
            assertThat(started.await(5, TimeUnit.SECONDS)).isTrue()

            val scheduled: Future<FestivalResponse.SyncResponse> = pool.submit(executor::run)
            Thread.sleep(200) // 스케줄러 쪽이 잠금을 기다리는 상태가 되도록 잠깐 둔다
            assertThat(scheduled.isDone).isFalse() // 아직 기다리는 중

            release.countDown() // 수동 실행 종료
            assertThat(manual.get(5, TimeUnit.SECONDS)).isEqualTo(RESULT)
            assertThat(scheduled.get(5, TimeUnit.SECONDS)).isEqualTo(RESULT)
            verify(festivalService, times(2)).syncPublicFestivals() // 건너뛰지 않고 두 번 다 실행
        } finally {
            release.countDown()
            pool.shutdownNow()
        }
    }

    companion object {
        private val RESULT = FestivalResponse.SyncResponse(
            listOf(FestivalResponse.SyncedFestival(1L, "종료된 행사")),
            listOf(FestivalResponse.SyncedFestival(2L, "새 행사")),
            1,
            0,
            false
        )
    }
}
