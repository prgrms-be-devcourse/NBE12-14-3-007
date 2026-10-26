package com.team007.room_escape.domain.festival.service

import com.team007.room_escape.domain.festival.dto.FestivalResponse
import java.util.concurrent.locks.ReentrantLock
import org.springframework.stereotype.Component

/** 동기화가 동시에 두 번 돌지 않게 막는다. 신규 저장이 커밋된 뒤에 잠금을 푼다. */
@Component
class FestivalSyncExecutor(
    private val festivalService: FestivalService
) {
    private val lock = ReentrantLock()

    /** 수동 동기화용: 이미 실행 중이면 기다리지 않고 null을 돌려준다 (컨트롤러가 409로 응답). */
    fun tryRun(): FestivalResponse.SyncResponse? {
        if (!lock.tryLock()) {
            return null
        }
        try {
            return festivalService.syncPublicFestivals()
        } finally {
            lock.unlock() // 예외가 나도 반드시 풀어야 이후 동기화가 막히지 않는다
        }
    }

    /** 스케줄러용: 이미 실행 중이면 끝날 때까지 기다렸다가 이번 회차도 실행한다. */
    fun run(): FestivalResponse.SyncResponse {
        lock.lock()
        try {
            return festivalService.syncPublicFestivals()
        } finally {
            lock.unlock()
        }
    }
}
