package com.team007.room_escape.domain.festival.service

import com.team007.room_escape.domain.festival.dto.FestivalResponse
import com.team007.room_escape.global.exception.BusinessException
import java.time.Instant
import java.util.concurrent.Semaphore
import java.util.concurrent.atomic.AtomicReference
import org.slf4j.LoggerFactory
import org.springframework.stereotype.Component

/**
 * 동기화가 동시에 두 번 돌지 않게 막는다. [status]는 수동 동기화(관리자 화면)의 진행 상태만 담고,
 * 스케줄러 실행([run])은 건드리지 않는다 — 같이 건드리면 수동 동기화가 끝나자마자 대기하던
 * 스케줄 실행이 바로 시작되면서 관리자가 보기도 전에 수동 결과를 덮어써 버린다.
 */
@Component
class FestivalSyncExecutor(
    private val festivalService: FestivalService
) {
    private val log = LoggerFactory.getLogger(javaClass)

    // Semaphore는 ReentrantLock과 달리 획득한 스레드가 아니어도 release할 수 있어,
    // tryStart()가 다른 스레드에서 끝나는 비동기 실행과 맞는다.
    private val gate = Semaphore(1)
    private val status = AtomicReference(
        FestivalResponse.SyncStatusResponse(running = false, lastResult = null, lastError = null, finishedAt = null)
    )

    fun status(): FestivalResponse.SyncStatusResponse = status.get()

    /** 수동 동기화용: 이미 실행 중이면 시작하지 않고 false. 아니면 백그라운드에서 돌리고 바로 true를 돌려준다. */
    fun tryStart(): Boolean {
        if (!gate.tryAcquire()) {
            return false
        }
        markRunning()
        Thread({ runAndRelease() }, "festival-sync-manual").start()
        return true
    }

    /**
     * 스케줄러용: 이미 실행 중이면 끝날 때까지 기다렸다가 이번 회차도 실행한다.
     * 관리자 화면이 보는 [status]는 수동 동기화 전용이라 여기서는 바꾸지 않는다.
     */
    fun run(): FestivalResponse.SyncResponse {
        gate.acquire()
        try {
            return festivalService.syncPublicFestivals()
        } finally {
            gate.release()
        }
    }

    private fun runAndRelease() {
        try {
            val result = festivalService.syncPublicFestivals()
            markFinished(result)
        } catch (e: Throwable) {
            // OutOfMemoryError 같은 Error까지 잡아야 한다. Exception만 잡으면 잠금은 풀려도
            // status가 running=true로 남아 관리자 화면이 영원히 "동기화 중…"에 머문다.
            log.error("공공 행사 동기화 실패", e)
            markFailed(e)
        } finally {
            gate.release()
        }
    }

    private fun markRunning() {
        status.set(FestivalResponse.SyncStatusResponse(true, null, null, null))
    }

    private fun markFinished(result: FestivalResponse.SyncResponse) {
        status.set(FestivalResponse.SyncStatusResponse(false, result, null, Instant.now()))
    }

    /**
     * BusinessException은 관리자가 로그 없이 읽어도 이해할 수 있게 이미 다듬어진 메시지라 그대로 쓰고,
     * 그 외 예상치 못한 예외는 기술적인 메시지(스택트레이스 등)가 그대로 노출되지 않게 일반 문구로 바꾼다.
     */
    private fun markFailed(e: Throwable) {
        val message = if (e is BusinessException) e.message else UNEXPECTED_ERROR_MESSAGE
        status.set(FestivalResponse.SyncStatusResponse(false, null, message, Instant.now()))
    }

    companion object {
        private const val UNEXPECTED_ERROR_MESSAGE = "동기화 중 예상치 못한 오류가 발생했어요. 개발팀에 문의해 주세요."
    }
}
