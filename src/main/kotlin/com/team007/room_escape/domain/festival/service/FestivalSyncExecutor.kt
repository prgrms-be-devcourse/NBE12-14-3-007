package com.team007.room_escape.domain.festival.service

import com.team007.room_escape.domain.festival.dto.FestivalResponse
import java.time.Instant
import java.util.concurrent.Semaphore
import java.util.concurrent.atomic.AtomicReference
import org.slf4j.LoggerFactory
import org.springframework.stereotype.Component

/**
 * 동기화가 동시에 두 번 돌지 않게 막고, 지금 상태(진행 중 여부·마지막 결과)를 들고 있는다.
 * 수동 동기화는 오래 걸릴 수 있어 백그라운드로 돌리고, 진행 상태는 [status]로 조회한다.
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

    /** 스케줄러용: 이미 실행 중이면 끝날 때까지 기다렸다가 이번 회차도 실행한다. */
    fun run(): FestivalResponse.SyncResponse {
        gate.acquire()
        markRunning()
        try {
            val result = festivalService.syncPublicFestivals()
            markFinished(result)
            return result
        } catch (e: Exception) {
            markFailed(e)
            throw e
        } finally {
            gate.release()
        }
    }

    private fun runAndRelease() {
        try {
            val result = festivalService.syncPublicFestivals()
            markFinished(result)
        } catch (e: Exception) {
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

    private fun markFailed(e: Exception) {
        status.set(FestivalResponse.SyncStatusResponse(false, null, e.message, Instant.now()))
    }
}
