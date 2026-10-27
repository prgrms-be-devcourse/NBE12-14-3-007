package com.team007.room_escape.domain.festival.service

import com.team007.room_escape.domain.festival.dto.FestivalResponse
import com.team007.room_escape.global.exception.BusinessException
import com.team007.room_escape.global.response.code.FestivalExceptionCode
import org.assertj.core.api.Assertions.assertThat
import org.assertj.core.api.Assertions.fail
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
 * FestivalSyncExecutor의 동시 실행 방지와 상태 노출을 검증한다.
 * 동기화 자체(FestivalService)는 목으로 대체하고, "누가 먼저 실행 중일 때 어떻게 되는지"만 확인한다.
 */
@ExtendWith(MockitoExtension::class)
class FestivalSyncExecutorTest {

    @field:Mock
    private lateinit var festivalService: FestivalService

    @field:InjectMocks
    private lateinit var executor: FestivalSyncExecutor

    @Test
    @DisplayName("실행 중이 아니면 tryStart는 즉시 true를 돌려주고, 백그라운드에서 끝낸 결과를 status에 남긴다")
    fun tryStartRunsInBackgroundAndRecordsResult() {
        `when`(festivalService.syncPublicFestivals()).thenReturn(RESULT)

        assertThat(executor.tryStart()).isTrue()

        awaitStatus { !it.running }
        assertThat(executor.status().lastResult).isEqualTo(RESULT)
        assertThat(executor.status().lastError).isNull()
    }

    @Test
    @DisplayName("이미 실행 중이면 tryStart는 기다리지 않고 false를 돌려주고 동기화를 또 실행하지 않는다")
    fun tryStartReturnsFalseWhileAnotherRunIsInProgress() {
        val started = CountDownLatch(1)
        val release = CountDownLatch(1)
        `when`(festivalService.syncPublicFestivals()).thenAnswer {
            started.countDown() // 첫 실행이 시작됐음을 알림
            release.await(5, TimeUnit.SECONDS) // 테스트가 풀어줄 때까지 실행 중인 척 대기
            RESULT
        }

        try {
            assertThat(executor.tryStart()).isTrue()
            assertThat(started.await(5, TimeUnit.SECONDS)).isTrue()

            assertThat(executor.tryStart()).isFalse() // 첫 실행이 잡고 있는 중
            assertThat(executor.status().running).isTrue()
        } finally {
            release.countDown()
        }

        awaitStatus { !it.running }
        verify(festivalService, times(1)).syncPublicFestivals()
    }

    @Test
    @DisplayName("BusinessException이 나면 이미 다듬어진 메시지를 그대로 status.lastError에 남긴다")
    fun recordsBusinessExceptionMessageAsIs() {
        `when`(festivalService.syncPublicFestivals())
            .thenThrow(BusinessException(FestivalExceptionCode.PUBLIC_API_CALL_FAILED))
            .thenReturn(RESULT)

        assertThat(executor.tryStart()).isTrue()
        awaitStatus { !it.running }
        assertThat(executor.status().lastError).isEqualTo(FestivalExceptionCode.PUBLIC_API_CALL_FAILED.message)

        assertThat(executor.tryStart()).isTrue() // 잠금이 풀려서 다음 실행이 막히지 않는다
        awaitStatus { it.lastResult == RESULT }
    }

    @Test
    @DisplayName("예상 못한 예외는 기술적인 메시지 대신 관리자가 읽을 수 있는 일반 문구로 바꿔서 남긴다")
    fun recordsGenericMessageForUnexpectedException() {
        `when`(festivalService.syncPublicFestivals())
            .thenThrow(NullPointerException("Cannot invoke because x is null"))

        assertThat(executor.tryStart()).isTrue()
        awaitStatus { !it.running }
        assertThat(executor.status().lastError)
            .isNotEqualTo("Cannot invoke because x is null")
            .contains("개발팀")
    }

    @Test
    @DisplayName("run(스케줄러용)이 끝나도 status에 남아 있는 수동 동기화 결과를 덮어쓰지 않는다")
    fun scheduledRunDoesNotOverwriteManualStatus() {
        `when`(festivalService.syncPublicFestivals()).thenReturn(RESULT)

        assertThat(executor.tryStart()).isTrue()
        awaitStatus { !it.running }
        val afterManual = executor.status()
        assertThat(afterManual.lastResult).isEqualTo(RESULT)

        executor.run() // 스케줄러가 바로 뒤이어 도는 상황

        assertThat(executor.status()).isEqualTo(afterManual)
    }

    @Test
    @DisplayName("OutOfMemoryError 같은 Error가 나도 상태가 failed로 바뀌고 running에 머물지 않는다")
    fun recordsGenericMessageForError() {
        `when`(festivalService.syncPublicFestivals()).thenThrow(OutOfMemoryError("heap"))

        assertThat(executor.tryStart()).isTrue()
        awaitStatus { !it.running }
        assertThat(executor.status().lastError).contains("개발팀")
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

        assertThat(executor.tryStart()).isTrue() // 수동 실행이 백그라운드에서 시작됨
        assertThat(started.await(5, TimeUnit.SECONDS)).isTrue()

        val pool = Executors.newSingleThreadExecutor()
        try {
            val scheduled: Future<FestivalResponse.SyncResponse> = pool.submit(executor::run)
            Thread.sleep(200) // 스케줄러 쪽이 잠금을 기다리는 상태가 되도록 잠깐 둔다
            assertThat(scheduled.isDone).isFalse() // 아직 기다리는 중

            release.countDown() // 수동 실행 종료
            assertThat(scheduled.get(5, TimeUnit.SECONDS)).isEqualTo(RESULT)
            verify(festivalService, times(2)).syncPublicFestivals() // 건너뛰지 않고 두 번 다 실행
        } finally {
            release.countDown()
            pool.shutdownNow()
        }
    }

    /** 백그라운드 스레드가 status를 다 쓸 때까지 짧게 기다린다. */
    private fun awaitStatus(
        timeoutSeconds: Long = 5,
        predicate: (FestivalResponse.SyncStatusResponse) -> Boolean
    ) {
        val deadline = System.currentTimeMillis() + timeoutSeconds * 1000
        while (System.currentTimeMillis() < deadline) {
            if (predicate(executor.status())) return
            Thread.sleep(10)
        }
        fail<Unit>("상태가 기대한 조건에 도달하지 못함: ${executor.status()}")
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
