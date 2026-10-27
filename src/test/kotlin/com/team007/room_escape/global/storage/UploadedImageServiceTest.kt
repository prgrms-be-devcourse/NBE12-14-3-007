package com.team007.room_escape.global.storage

import com.team007.room_escape.global.exception.BusinessException
import com.team007.room_escape.global.response.code.StorageExceptionCode
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.assertThrows
import org.mockito.Mockito.*
import java.time.Duration
import java.time.Instant
import java.util.UUID

class UploadedImageServiceTest {
    private val repository = mock(UploadedImageRepository::class.java)
    private val service = UploadedImageService(repository)
    private val owner = UUID.randomUUID()
    private val cutoff = Instant.now().minus(Duration.ofHours(24))
    private fun image() = UploadedImage("posts/$owner/test.png", owner, cutoff.minusSeconds(1))

    @Test
    fun confirmingPreservesActiveImageAndRejectsWrongOwner() {
        val image = image()
        `when`(repository.findLocked(image.key)).thenReturn(image)
        service.confirm(listOf(image.key), owner)
        assertThat(image.state).isEqualTo(UploadState.ACTIVE)
        assertThat(service.beginDeletion(image.key, cutoff)).isFalse()
        val exception = assertThrows<BusinessException> { service.confirm(listOf(image.key), UUID.randomUUID()) }
        assertThat(exception.exceptionCode).isEqualTo(StorageExceptionCode.IMAGE_NOT_OWNED)
    }

    @Test
    fun pendingExpiresButFreshImageDoesNot() {
        val old = image()
        val fresh = UploadedImage("fresh", owner)
        `when`(repository.findLocked(old.key)).thenReturn(old)
        `when`(repository.findLocked(fresh.key)).thenReturn(fresh)
        assertThat(service.beginDeletion(fresh.key, cutoff)).isFalse()
        assertThat(service.beginDeletion(old.key, cutoff)).isTrue()
        val exception = assertThrows<BusinessException> { service.confirm(listOf(old.key), owner) }
        assertThat(exception.exceptionCode).isEqualTo(StorageExceptionCode.IMAGE_EXPIRED)
    }

    @Test
    fun failedDeletionIsRetriedAndSuccessfulDeletionCannotBeReused() {
        val image = image()
        `when`(repository.findLocked(image.key)).thenReturn(image)
        service.beginDeletion(image.key, cutoff)
        service.finishDeletion(image.key, false)
        assertThat(image.state).isEqualTo(UploadState.DELETING)
        assertThat(image.deleteAttempts).isEqualTo(1)
        assertThat(service.beginDeletion(image.key, cutoff)).isTrue()
        service.finishDeletion(image.key, true)
        assertThat(image.state).isEqualTo(UploadState.DELETED)
        assertThat(image.deleteAttempts).isEqualTo(2)
        assertThrows<BusinessException> { service.confirm(listOf(image.key), owner) }
    }

    @Test
    fun legacyKeysAreNotEnrolledInCleanup() {
        service.confirm(listOf("legacy.png"), owner)
        verify(repository, never()).save(any(UploadedImage::class.java))
    }

    @Test
    fun `이 글에 이미 붙어 있던 이미지는 올린 사람이 달라도 유지할 수 있다`() {
        val image = image()
        val author = UUID.randomUUID()
        `when`(repository.findLocked(image.key)).thenReturn(image)
        image.activate()

        service.confirm(listOf(image.key), author, attachedKeys = setOf(image.key))

        assertThat(image.state).isEqualTo(UploadState.ACTIVE)
    }

    @Test
    fun `붙어 있던 목록에 없는 남의 이미지는 ACTIVE여도 붙일 수 없다`() {
        val image = image()
        val someone = UUID.randomUUID()
        `when`(repository.findLocked(image.key)).thenReturn(image)
        image.activate()

        val notOwned = assertThrows<BusinessException> { service.confirm(listOf(image.key), someone) }
        val otherKeyOnly = assertThrows<BusinessException> {
            service.confirm(listOf(image.key), someone, attachedKeys = setOf("posts/$owner/other.png"))
        }

        assertThat(notOwned.exceptionCode).isEqualTo(StorageExceptionCode.IMAGE_NOT_OWNED)
        assertThat(otherKeyOnly.exceptionCode).isEqualTo(StorageExceptionCode.IMAGE_NOT_OWNED)
    }

    @Test
    fun `붙어 있던 이미지라도 삭제 중이거나 삭제됐으면 유지할 수 없다`() {
        val image = image()
        val author = UUID.randomUUID()
        `when`(repository.findLocked(image.key)).thenReturn(image)
        image.beginDeletion()

        val deleting = assertThrows<BusinessException> {
            service.confirm(listOf(image.key), author, attachedKeys = setOf(image.key))
        }
        image.recordDeletion(success = true)
        val deleted = assertThrows<BusinessException> {
            service.confirm(listOf(image.key), author, attachedKeys = setOf(image.key))
        }

        assertThat(deleting.exceptionCode).isEqualTo(StorageExceptionCode.IMAGE_EXPIRED)
        assertThat(deleted.exceptionCode).isEqualTo(StorageExceptionCode.IMAGE_EXPIRED)
    }

    @Test
    fun `붙어 있는데 아직 PENDING인 이미지는 사용 확정해서 정리 대상에서 뺀다`() {
        val image = image()
        val author = UUID.randomUUID()
        `when`(repository.findLocked(image.key)).thenReturn(image)

        service.confirm(listOf(image.key), author, attachedKeys = setOf(image.key))

        assertThat(image.state).isEqualTo(UploadState.ACTIVE)
        assertThat(service.beginDeletion(image.key, cutoff)).isFalse()
    }

    @Test
    fun `새 이미지는 PENDING이어도 올린 사람이 아니면 붙일 수 없다`() {
        val image = image()
        `when`(repository.findLocked(image.key)).thenReturn(image)

        val exception = assertThrows<BusinessException> { service.confirm(listOf(image.key), UUID.randomUUID()) }

        assertThat(exception.exceptionCode).isEqualTo(StorageExceptionCode.IMAGE_NOT_OWNED)
        assertThat(image.state).isEqualTo(UploadState.PENDING)
    }
}
