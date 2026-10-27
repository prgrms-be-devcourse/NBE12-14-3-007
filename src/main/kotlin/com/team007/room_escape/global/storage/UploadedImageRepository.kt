package com.team007.room_escape.global.storage

import jakarta.persistence.LockModeType
import org.springframework.data.domain.Pageable
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Lock
import org.springframework.data.jpa.repository.Query
import org.springframework.data.repository.query.Param
import java.time.Instant
import java.util.UUID

interface UploadedImageRepository : JpaRepository<UploadedImage, String> {
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("select i from UploadedImage i where i.key = :key")
    fun findLocked(@Param("key") key: String): UploadedImage?

    /** 이 회원이 [since] 이후에 올린 이미지 수. 업로드 한도 계산에 쓴다. */
    fun countByOwnerIdAndUploadedAtAfter(ownerId: UUID, since: Instant): Long

    @Query("""select i.key from UploadedImage i
        where (i.state = :pending and i.uploadedAt <= :cutoff) or i.state = :deleting
        order by i.lastDeleteAttemptAt asc nulls first, i.uploadedAt, i.key""")
    fun cleanupKeys(@Param("cutoff") cutoff: Instant, @Param("pending") pending: UploadState,
                    @Param("deleting") deleting: UploadState, pageable: Pageable): List<String>
}
