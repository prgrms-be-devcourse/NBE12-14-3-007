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
    fun administratorPreservesActiveAuthorImageButCannotClaimOthersPendingImage() {
        val image = image()
        val admin = UUID.randomUUID()
        `when`(repository.findLocked(image.key)).thenReturn(image)
        assertThrows<BusinessException> { service.confirm(listOf(image.key), admin, allowActiveFromOthers = true) }
        service.confirm(listOf(image.key), owner)
        service.confirm(listOf(image.key), admin, allowActiveFromOthers = true)
        assertThat(image.state).isEqualTo(UploadState.ACTIVE)
    }
}
