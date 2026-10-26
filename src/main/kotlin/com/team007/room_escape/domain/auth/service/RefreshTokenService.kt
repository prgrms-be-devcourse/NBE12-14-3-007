package com.team007.room_escape.domain.auth.service

import com.team007.room_escape.domain.auth.infra.entity.RefreshToken
import com.team007.room_escape.domain.auth.infra.repository.RefreshTokenRepository
import com.team007.room_escape.domain.member.infra.entity.Member
import com.team007.room_escape.global.exception.BusinessException
import com.team007.room_escape.global.response.code.AuthExceptionCode
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.security.MessageDigest
import java.time.LocalDateTime
import java.util.HexFormat
import java.util.UUID

/** 리프레시 토큰 저장·검증. 원문은 저장하지 않고 SHA-256 해시만 둔다. 회원당 하나만 유지한다. */
@Service
class RefreshTokenService(
    private val refreshTokenRepository: RefreshTokenRepository,
) {

    @Transactional
    fun save(member: Member, rawToken: String, expiresAt: LocalDateTime) {
        val hash = sha256(rawToken)
        val existing = refreshTokenRepository.findByMemberId(member.id)
        if (existing != null) {
            existing.rotate(hash, expiresAt)
        } else {
            refreshTokenRepository.save(RefreshToken(member, hash, expiresAt))
        }
    }

    @Transactional(readOnly = true)
    fun verify(memberId: UUID, rawToken: String) {
        val stored = refreshTokenRepository.findByMemberId(memberId)
            ?: throw BusinessException(AuthExceptionCode.TOKEN_INVALID)

        if (stored.isExpired) throw BusinessException(AuthExceptionCode.TOKEN_EXPIRED)
        if (!stored.matches(sha256(rawToken))) throw BusinessException(AuthExceptionCode.TOKEN_INVALID)
    }

    @Transactional
    fun deleteByMemberId(memberId: UUID) = refreshTokenRepository.deleteByMemberId(memberId)

    private fun sha256(raw: String): String =
        HexFormat.of().formatHex(MessageDigest.getInstance("SHA-256").digest(raw.toByteArray()))
}
