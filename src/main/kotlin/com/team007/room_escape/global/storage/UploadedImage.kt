package com.team007.room_escape.global.storage

import jakarta.persistence.*
import java.time.Instant
import java.util.UUID

enum class UploadState { PENDING, ACTIVE, DELETING, DELETED }

@Entity
@Table(name = "uploaded_image")
class UploadedImage(
    @field:Id @field:Column(name = "object_key", length = 1024)
    val key: String,
    @field:Column(name = "owner_id", nullable = false)
    val ownerId: UUID,
    @field:Column(name = "uploaded_at", nullable = false)
    val uploadedAt: Instant = Instant.now()
) {
    @field:Enumerated(EnumType.STRING)
    @field:Column(nullable = false, length = 20)
    var state: UploadState = UploadState.PENDING
        protected set
    @field:Column(name = "delete_attempts", nullable = false)
    var deleteAttempts: Int = 0
        protected set
    @field:Column(name = "last_delete_attempt_at")
    var lastDeleteAttemptAt: Instant? = null
        protected set

    fun activate() { state = UploadState.ACTIVE }
    fun beginDeletion() { state = UploadState.DELETING }
    fun recordDeletion(success: Boolean) {
        deleteAttempts++
        lastDeleteAttemptAt = Instant.now()
        if (success) state = UploadState.DELETED
    }
}
