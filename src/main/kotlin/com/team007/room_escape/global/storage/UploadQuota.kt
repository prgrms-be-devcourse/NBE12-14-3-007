package com.team007.room_escape.global.storage

import com.team007.room_escape.global.exception.BusinessException
import com.team007.room_escape.global.response.code.StorageExceptionCode
import org.springframework.beans.factory.annotation.Value
import org.springframework.stereotype.Component
import org.springframework.transaction.annotation.Transactional
import java.time.Duration
import java.time.Instant
import java.util.UUID

/**
 * 회원당 업로드 한도. 업로드마다 R2 비용과 저장 공간이 들어서, 최근 24시간 동안 올린 수를 장부(uploaded_image)로 센다.
 * 동시에 여러 요청이 오면 한도를 조금 넘길 수 있다. 비용 방어가 목적이라 정확한 차단까지는 하지 않는다.
 */
@Component
class UploadQuota(
    private val repository: UploadedImageRepository,
    @Value("\${storage.upload.daily-limit:30}") private val dailyLimit: Int,
) {

    @Transactional(readOnly = true)
    fun requireAvailable(ownerId: UUID) {
        val since = Instant.now().minus(WINDOW)
        if (repository.countByOwnerIdAndUploadedAtAfter(ownerId, since) >= dailyLimit) {
            throw BusinessException(StorageExceptionCode.UPLOAD_LIMIT_EXCEEDED)
        }
    }

    private companion object {
        val WINDOW: Duration = Duration.ofHours(24)
    }
}
