package com.team007.room_escape.domain.festival.service

import com.team007.room_escape.domain.festival.dto.FestivalResponse
import com.team007.room_escape.global.exception.BusinessException
import java.time.Instant
import java.util.concurrent.Semaphore
import java.util.concurrent.atomic.AtomicReference
import org.slf4j.LoggerFactory
import org.springframework.stereotype.Component

/**
 * 동기화가 동시에 두 번 돌지 않게 막는다. 수동 동기화(관리자 화면) 상태는 [SyncState]로,
 * 스케줄러(자동) 상태는 [ScheduledSyncState]로 따로 들고 있는다 — 같은 걸 같이 쓰면 수동
 * 동기화가 끝나자마자 대기하던 스케줄 실행이 바로 시작되면서 관리자가 보기도 전에
 * 수동 결과를 덮어써 버린다.
 *
 * 실제 실행은 [FestivalSyncRunner]에 맡긴다. 여기서 직접 스레드를 만들면 이 프로젝트가 이미
 * 메일 발송에 쓰는 @Async 방식과 따로 놀고, 실행 개수 제한 같은 걸 스프링이 관리해주는
 * 이점도 못 받는다.
 */
@Component
class FestivalSyncExecutor(
    private val syncRunner: FestivalSyncRunner
) {
    private val log = LoggerFactory.getLogger(javaClass)

    // Semaphore는 ReentrantLock과 달리 획득한 스레드가 아니어도 release할 수 있어,
    // tryStart()가 다른 스레드에서 끝나는 비동기 실행과 맞는다.
    private val gate = Semaphore(1)
    private val manualState = AtomicReference<SyncState>(SyncState.Idle)
    private val scheduledState = AtomicReference<ScheduledSyncState>(ScheduledSyncState.Idle)

    /** 내부 상태(SyncState)를 API가 주고받는 평평한 응답 모양으로 바꾼다. */
    fun status(): FestivalResponse.SyncStatusResponse {
        val manual = manualState.get()
        val scheduled = scheduledState.get()
        return FestivalResponse.SyncStatusResponse(
            running = manual is SyncState.Running,
            lastResult = (manual as? SyncState.Succeeded)?.result,
            lastError = (manual as? SyncState.Failed)?.error,
            finishedAt = manual.finishedAtOrNull(),
            lastScheduledResult = (scheduled as? ScheduledSyncState.Succeeded)?.result,
            lastScheduledError = (scheduled as? ScheduledSyncState.Failed)?.error,
            lastScheduledFinishedAt = scheduled.finishedAtOrNull()
        )
    }

    /** 수동 동기화용: 이미 실행 중이면 시작하지 않고 false. 아니면 @Async로 돌리고 바로 true를 돌려준다. */
    fun tryStart(): Boolean {
        if (!gate.tryAcquire()) {
            return false
        }
        manualState.set(SyncState.Running)
        syncRunner.runAsync(
            onFinished = { result -> manualState.set(SyncState.Succeeded(result, Instant.now())) },
            onFailed = { e -> manualState.set(SyncState.Failed(failureMessage(e), Instant.now())) },
            onDone = gate::release
        )
        return true
    }

    /** 스케줄러용: 이미 실행 중이면 끝날 때까지 기다렸다가 이번 회차도 실행하고, 결과를 자동 동기화 전용 상태에 남긴다. */
    fun run(): FestivalResponse.SyncResponse {
        gate.acquire()
        try {
            val result = syncRunner.runSync()
            scheduledState.set(ScheduledSyncState.Succeeded(result, Instant.now()))
            return result
        } catch (e: Throwable) {
            log.error("공공 행사 자동 동기화 실패", e)
            scheduledState.set(ScheduledSyncState.Failed(failureMessage(e), Instant.now()))
            throw e
        } finally {
            gate.release()
        }
    }

    private fun SyncState.finishedAtOrNull(): Instant? = when (this) {
        is SyncState.Succeeded -> finishedAt
        is SyncState.Failed -> finishedAt
        SyncState.Idle, SyncState.Running -> null
    }

    private fun ScheduledSyncState.finishedAtOrNull(): Instant? = when (this) {
        is ScheduledSyncState.Succeeded -> finishedAt
        is ScheduledSyncState.Failed -> finishedAt
        ScheduledSyncState.Idle -> null
    }

    /**
     * BusinessException은 관리자가 로그 없이 읽어도 이해할 수 있게 이미 다듬어진 메시지라 그대로 쓰고,
     * 그 외 예상치 못한 예외는 기술적인 메시지(스택트레이스 등)가 그대로 노출되지 않게 일반 문구로 바꾼다.
     * 예외 종류 이름 정도는 보여줘야 관리자가 같은 문제인지 아닌지라도 구분할 수 있다.
     */
    private fun failureMessage(e: Throwable): String =
        if (e is BusinessException) {
            e.message ?: e.javaClass.simpleName
        } else {
            "${e.javaClass.simpleName} 오류가 발생했어요. 개발팀에 문의해 주세요."
        }
}
