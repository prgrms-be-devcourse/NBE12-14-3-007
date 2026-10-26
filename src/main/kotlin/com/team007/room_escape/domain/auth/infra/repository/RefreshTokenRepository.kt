package com.team007.room_escape.domain.auth.infra.repository

import com.team007.room_escape.domain.auth.infra.entity.RefreshToken
import org.springframework.data.jpa.repository.JpaRepository
import java.time.LocalDateTime
import java.util.UUID

interface RefreshTokenRepository : JpaRepository<RefreshToken, Long> {

    fun findByMemberId(memberId: UUID): RefreshToken?

    fun deleteByMemberId(memberId: UUID)

    fun deleteByExpiresAtBefore(time: LocalDateTime)
}
