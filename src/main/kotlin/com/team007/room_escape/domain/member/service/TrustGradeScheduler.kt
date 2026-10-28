package com.team007.room_escape.domain.member.service

import org.slf4j.LoggerFactory
import org.springframework.scheduling.annotation.Scheduled
import org.springframework.stereotype.Component

/** 매일 0시(한국 시간)에 신뢰 등급을 집계한다. 서버가 그 시각에 꺼져 있었다면 그날은 건너뛰고 다음 날 반영한다. */
@Component
class TrustGradeScheduler(
    private val trustGrades: MemberTrustGradeService,
) {

    private val log = LoggerFactory.getLogger(javaClass)

    @Scheduled(cron = "\${trust-grade.cron:0 0 0 * * *}", zone = "Asia/Seoul")
    fun recalculate() {
        val changed = trustGrades.recalculateAll()

        // 배치가 도는지 확인하려고 0명이어도 남긴다.
        if (changed == null) {
            log.info("[trust-grade] 다른 서버가 집계 중이라 건너뜀")
        } else {
            log.info("[trust-grade] 신뢰 등급 자정 집계 완료 {}명 변경", changed)
        }
    }
}
