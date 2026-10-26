package com.team007.room_escape.domain.festival.scheduler

import com.team007.room_escape.domain.festival.service.FestivalSyncExecutor
import org.slf4j.LoggerFactory
import org.springframework.scheduling.annotation.Scheduled
import org.springframework.stereotype.Component

@Component
class FestivalSyncScheduler(
    private val festivalSyncExecutor: FestivalSyncExecutor
) {
    private val log = LoggerFactory.getLogger(javaClass)

    /** yml의 cron 값마다 자동 실행한다. */
    @Scheduled(cron = "\${public-api.culture-info.sync-cron}")
    fun syncFestivals() {
        // 수동 동기화가 진행 중이면 끝날 때까지 기다렸다가 이번 회차도 실행한다.
        festivalSyncExecutor.run()
    }
}
