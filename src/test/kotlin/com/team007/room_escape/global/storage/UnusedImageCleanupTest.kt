package com.team007.room_escape.global.storage

import org.junit.jupiter.api.Test
import org.mockito.Mockito.*
import org.mockito.ArgumentMatchers.any
import java.time.Instant

class UnusedImageCleanupTest {
    @Test
    fun recordsFailedDeletionForRetryAndSkipsImageClaimedByRegistration() {
        val images = mock(UploadedImageService::class.java)
        val storage = mock(R2StorageService::class.java)
        `when`(images.cleanupKeys(any(Instant::class.java) ?: Instant.EPOCH)).thenReturn(listOf("expired", "claimed"))
        `when`(images.beginDeletion(eq("expired") ?: "expired", any(Instant::class.java) ?: Instant.EPOCH)).thenReturn(true)
        `when`(images.beginDeletion(eq("claimed") ?: "claimed", any(Instant::class.java) ?: Instant.EPOCH)).thenReturn(false)
        `when`(storage.tryDelete("expired")).thenReturn(false)
        UnusedImageCleanup(images, storage).clean()
        verify(images).finishDeletion("expired", false)
        verify(storage, never()).tryDelete("claimed")
    }
}
