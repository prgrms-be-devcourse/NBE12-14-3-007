package com.team007.room_escape.domain.festival.service

import com.team007.room_escape.domain.festival.dto.FestivalResponse
import com.team007.room_escape.global.exception.BusinessException
import com.team007.room_escape.global.response.code.FestivalExceptionCode
import org.assertj.core.api.Assertions.assertThat
import org.assertj.core.api.Assertions.assertThatThrownBy
import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.extension.ExtendWith
import org.mockito.ArgumentMatchers
import org.mockito.InjectMocks
import org.mockito.Mock
import org.mockito.Mockito.times
import org.mockito.Mockito.verify
import org.mockito.Mockito.`when`
import org.mockito.junit.jupiter.MockitoExtension
import java.util.concurrent.Executors
import java.util.concurrent.Future
import java.util.concurrent.TimeUnit

/**
 * FestivalSyncExecutor의 동시 실행 방지와 상태 노출을 검증한다.
 * 실제 실행([FestivalSyncRunner])은 목으로 대체하고, "runAsync가 언제 어떤 콜백을 부르느냐에 따라
 * 상태가 어떻게 바뀌는지"만 확인한다. runAsync는 @Async라 여기서는(스프링 컨텍스트 없이) 실제로
 * 비동기로 돌지 않는다 — 진짜 비동기 동작은 FestivalSyncApiContractTest가 보장한다.
 */
@ExtendWith(MockitoExtension::class)
class FestivalSyncExecutorTest {

    @field:Mock
    private lateinit var syncRunner: FestivalSyncRunner

    @field:InjectMocks
    private lateinit var executor: FestivalSyncExecutor

    @Test
    @DisplayName("아무것도 안 돌렸으면 모든 필드가 비어있는 대기 상태다")
    fun initialStatusIsIdle() {
        val status = executor.status()

        assertThat(status.running).isFalse()
        assertThat(status.lastResult).isNull()
        assertThat(status.lastError).isNull()
        assertThat(status.finishedAt).isNull()
        assertThat(status.lastScheduledResult).isNull()
        assertThat(status.lastScheduledError).isNull()
        assertThat(status.lastScheduledFinishedAt).isNull()
    }

    @Test
    @DisplayName("실행 중이 아니면 tryStart는 즉시 true를 돌려주고, runAsync가 넘긴 결과를 status에 남긴다")
    fun tryStartRunsAsyncAndRecordsResult() {
        stubRunAsyncToFinishWith(RESULT)

        assertThat(executor.tryStart()).isTrue()

        assertThat(executor.status().running).isFalse()
        assertThat(executor.status().lastResult).isEqualTo(RESULT)
        assertThat(executor.status().lastError).isNull()
    }

    @Test
    @DisplayName("이미 실행 중이면 tryStart는 false를 돌려주고 runAsync를 또 호출하지 않는다")
    fun tryStartReturnsFalseWhileAnotherRunIsInProgress() {
        stubRunAsyncToHold() // 콜백을 하나도 안 불러서 "계속 실행 중"인 상태를 흉내낸다

        assertThat(executor.tryStart()).isTrue()
        assertThat(executor.status().running).isTrue()

        assertThat(executor.tryStart()).isFalse() // 첫 실행이 잡고 있는 중
        verify(syncRunner, times(1)).runAsync(anyFn {}, anyFn {}, anyFn {})
    }

    @Test
    @DisplayName("BusinessException이 나면 이미 다듬어진 메시지를 그대로 status.lastError에 남긴다")
    fun recordsBusinessExceptionMessageAsIs() {
        stubRunAsyncToFailWith(BusinessException(FestivalExceptionCode.PUBLIC_API_CALL_FAILED))

        assertThat(executor.tryStart()).isTrue()
        assertThat(executor.status().lastError).isEqualTo(FestivalExceptionCode.PUBLIC_API_CALL_FAILED.message)

        stubRunAsyncToFinishWith(RESULT)
        assertThat(executor.tryStart()).isTrue() // 잠금이 풀려서 다음 실행이 막히지 않는다
        assertThat(executor.status().lastResult).isEqualTo(RESULT)
    }

    @Test
    @DisplayName("예상 못한 예외는 기술적인 메시지 대신 관리자가 읽을 수 있는 일반 문구로 바꿔서 남긴다")
    fun recordsGenericMessageForUnexpectedException() {
        stubRunAsyncToFailWith(NullPointerException("Cannot invoke because x is null"))

        assertThat(executor.tryStart()).isTrue()
        assertThat(executor.status().lastError)
            .isNotEqualTo("Cannot invoke because x is null") // 기술적인 상세 메시지는 안 보여줌
            .contains("NullPointerException") // 그래도 무슨 종류인지는 알 수 있게
            .contains("개발팀")
    }

    @Test
    @DisplayName("OutOfMemoryError 같은 Error가 나도 상태가 failed로 바뀌고 running에 머물지 않는다")
    fun recordsGenericMessageForError() {
        stubRunAsyncToFailWith(OutOfMemoryError("heap"))

        assertThat(executor.tryStart()).isTrue()
        assertThat(executor.status().lastError)
            .contains("OutOfMemoryError")
            .contains("개발팀")
    }

    @Test
    @DisplayName("run(스케줄러용)이 끝나도 수동 동기화 결과는 그대로고, 자동 동기화 결과만 따로 채워진다")
    fun scheduledRunDoesNotOverwriteManualStatus() {
        stubRunAsyncToFinishWith(RESULT)
        assertThat(executor.tryStart()).isTrue()
        val afterManual = executor.status()
        assertThat(afterManual.lastResult).isEqualTo(RESULT)
        assertThat(afterManual.lastScheduledResult).isNull() // 아직 스케줄러는 안 돎

        `when`(syncRunner.runSync()).thenReturn(RESULT)
        executor.run() // 스케줄러가 바로 뒤이어 도는 상황

        val afterScheduled = executor.status()
        assertThat(afterScheduled.lastResult).isEqualTo(afterManual.lastResult) // 수동 결과는 그대로
        assertThat(afterScheduled.finishedAt).isEqualTo(afterManual.finishedAt)
        assertThat(afterScheduled.lastScheduledResult).isEqualTo(RESULT) // 자동 결과만 새로 채워짐
        assertThat(afterScheduled.lastScheduledFinishedAt).isNotNull()
    }

    @Test
    @DisplayName("run(스케줄러용)이 실패하면 예외를 다시 던지면서 lastScheduledError에도 남긴다")
    fun recordsScheduledFailureAndRethrows() {
        `when`(syncRunner.runSync()).thenThrow(BusinessException(FestivalExceptionCode.PUBLIC_API_CALL_FAILED))

        assertThatThrownBy { executor.run() }.isInstanceOf(BusinessException::class.java)

        assertThat(executor.status().lastScheduledError)
            .isEqualTo(FestivalExceptionCode.PUBLIC_API_CALL_FAILED.message)
        assertThat(executor.status().lastScheduledResult).isNull()
    }

    @Test
    @DisplayName("run(스케줄러용)은 실행 중이면 끝날 때까지 기다렸다가 자기 회차도 실행한다")
    fun runWaitsForOngoingRunThenExecutes() {
        var capturedOnDone: (() -> Unit)? = null
        `when`(syncRunner.runAsync(anyFn {}, anyFn {}, anyFn {})).thenAnswer { invocation ->
            capturedOnDone = invocation.getArgument(2)
            null
        }
        `when`(syncRunner.runSync()).thenReturn(RESULT)

        assertThat(executor.tryStart()).isTrue() // 수동 실행이 gate를 잡은 채로 "진행 중"

        val pool = Executors.newSingleThreadExecutor()
        try {
            val scheduled: Future<FestivalResponse.SyncResponse> = pool.submit(executor::run)
            Thread.sleep(200) // 스케줄러 쪽이 잠금을 기다리는 상태가 되도록 잠깐 둔다
            assertThat(scheduled.isDone).isFalse() // 아직 기다리는 중

            checkNotNull(capturedOnDone) { "runAsync가 onDone 콜백을 받지 못함" }.invoke() // 수동 실행 종료
            assertThat(scheduled.get(5, TimeUnit.SECONDS)).isEqualTo(RESULT)
            verify(syncRunner, times(1)).runSync() // 스케줄러 쪽만 runSync를 한 번 호출
        } finally {
            pool.shutdownNow()
        }
    }

    /** runAsync 호출 즉시 onFinished와 onDone을 불러서, 성공으로 바로 끝난 것처럼 만든다. */
    private fun stubRunAsyncToFinishWith(result: FestivalResponse.SyncResponse) {
        `when`(syncRunner.runAsync(anyFn {}, anyFn {}, anyFn {})).thenAnswer { invocation ->
            invocation.getArgument<(FestivalResponse.SyncResponse) -> Unit>(0).invoke(result)
            invocation.getArgument<() -> Unit>(2).invoke()
            null
        }
    }

    /** runAsync 호출 즉시 onFailed와 onDone을 불러서, 실패로 바로 끝난 것처럼 만든다. */
    private fun stubRunAsyncToFailWith(e: Throwable) {
        `when`(syncRunner.runAsync(anyFn {}, anyFn {}, anyFn {})).thenAnswer { invocation ->
            invocation.getArgument<(Throwable) -> Unit>(1).invoke(e)
            invocation.getArgument<() -> Unit>(2).invoke()
            null
        }
    }

    /** runAsync가 호출은 되지만 어떤 콜백도 안 불러서, 계속 실행 중인 것처럼 만든다. */
    private fun stubRunAsyncToHold() {
        `when`(syncRunner.runAsync(anyFn {}, anyFn {}, anyFn {})).thenAnswer { null }
    }

    /** Kotlin의 non-null 함수 타입 파라미터에는 Mockito의 any()가 돌려주는 null을 넣을 수 없다. */
    private fun <T> anyFn(placeholder: T): T = ArgumentMatchers.any() ?: placeholder

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
