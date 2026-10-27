package com.team007.room_escape.global.storage

import org.slf4j.LoggerFactory
import org.springframework.scheduling.annotation.Scheduled
import org.springframework.stereotype.Component
import java.time.Duration
import java.time.Instant
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty

@Component
@ConditionalOnProperty(prefix = "storage.cleanup", name = ["enabled"], havingValue = "true", matchIfMissing = true)
class UnusedImageCleanup(private val images: UploadedImageService, private val storage: R2StorageService) {
    private val log = LoggerFactory.getLogger(javaClass)

    @Scheduled(cron = "\${storage.cleanup.cron:0 0 * * * *}")
    fun clean() {
        val cutoff = Instant.now().minus(Duration.ofHours(24))
        images.cleanupKeys(cutoff).forEach { key ->
            try {
                if (images.beginDeletion(key, cutoff)) {
                    images.finishDeletion(key, storage.tryDelete(key))
                }
            } catch (exception: Exception) {
                log.warn("미사용 이미지 정리 실패. 다음 실행에서 재시도 key={}", key, exception)
            }
        }
    }
}
