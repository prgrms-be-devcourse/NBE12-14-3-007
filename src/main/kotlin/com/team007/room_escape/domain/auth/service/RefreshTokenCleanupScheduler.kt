package com.team007.room_escape.domain.auth.service

import com.team007.room_escape.domain.auth.infra.repository.RefreshTokenRepository
import org.slf4j.LoggerFactory
import org.springframework.scheduling.annotation.Scheduled
import org.springframework.stereotype.Component
import org.springframework.transaction.annotation.Transactional
import java.time.LocalDateTime

@Component
class RefreshTokenCleanupScheduler(
    private val refreshTokenRepository: RefreshTokenRepository,
) {

    private val log = LoggerFactory.getLogger(javaClass)

    @Scheduled(cron = "\${jwt.refresh-cleanup-cron:0 0 4 * * *}")
    @Transactional
    fun purgeExpired() {
        refreshTokenRepository.deleteByExpiresAtBefore(LocalDateTime.now())
        log.info("[refresh-token] 만료된 리프레시 토큰 정리 완료")
    }
}
