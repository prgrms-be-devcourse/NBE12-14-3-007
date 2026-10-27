package com.team007.room_escape.global.storage

import com.team007.room_escape.global.exception.BusinessException
import com.team007.room_escape.global.response.code.StorageExceptionCode
import org.springframework.data.domain.PageRequest
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Propagation
import org.springframework.transaction.annotation.Transactional
import java.time.Instant
import java.util.UUID

@Service
class UploadedImageService(private val repository: UploadedImageRepository) {
    // 업로드/후속 DB 작업 실패 시에도 정리 대상 기록은 남긴다.
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    fun register(key: String, ownerId: UUID) {
        repository.save(UploadedImage(key, ownerId))
    }

    @Transactional(propagation = Propagation.REQUIRES_NEW)
    fun upload(key: String, operation: () -> String): String {
        val image = checkNotNull(repository.findLocked(key))
        if (image.state != UploadState.PENDING) throw BusinessException(StorageExceptionCode.IMAGE_EXPIRED)
        // 업로드 중 정리 작업이 같은 key를 삭제하지 못하도록 잠금을 유지한다.
        return operation()
    }

    /**
     * 글 저장과 함께 이미지를 사용 확정한다.
     *
     * @param attachedKeys 수정 대상에 **이미 붙어 있던** 이미지 key. 요청값이 아니라 저장된 글에서 뽑은 값이어야 한다.
     *   이 이미지는 올린 사람이 달라도 유지할 수 있다. (관리자가 교체한 이미지를 작성자가 그대로 두고 수정하는 경우)
     *   그 밖의 새 이미지는 항상 올린 사람이 저장하는 사람과 같아야 한다.
     */
    @Transactional(propagation = Propagation.MANDATORY)
    fun confirm(keys: Collection<String>, ownerId: UUID, attachedKeys: Set<String> = emptySet()) {
        keys.distinct().sorted().forEach { key ->
            val image = repository.findLocked(key) ?: return@forEach // 기존 이미지는 추적/삭제하지 않는다.
            if (key !in attachedKeys && image.ownerId != ownerId) {
                throw BusinessException(StorageExceptionCode.IMAGE_NOT_OWNED)
            }
            if (image.state == UploadState.DELETING || image.state == UploadState.DELETED) {
                throw BusinessException(StorageExceptionCode.IMAGE_EXPIRED)
            }
            image.activate() // 글 저장과 같은 트랜잭션으로 확정/취소된다.
        }
    }

    @Transactional(readOnly = true)
    fun isTracked(key: String): Boolean = repository.existsById(key)

    @Transactional(readOnly = true)
    fun cleanupKeys(cutoff: Instant): List<String> = repository.cleanupKeys(
        cutoff, UploadState.PENDING, UploadState.DELETING, PageRequest.of(0, 100)
    )

    @Transactional(propagation = Propagation.REQUIRES_NEW)
    fun beginDeletion(key: String, cutoff: Instant): Boolean {
        val image = repository.findLocked(key) ?: return false
        if (image.state == UploadState.DELETING) return true
        if (image.state != UploadState.PENDING || image.uploadedAt > cutoff) return false
        image.beginDeletion()
        return true
    }

    @Transactional(propagation = Propagation.REQUIRES_NEW)
    fun finishDeletion(key: String, success: Boolean) {
        val image = repository.findLocked(key) ?: return
        if (image.state == UploadState.DELETING) image.recordDeletion(success)
    }
}
