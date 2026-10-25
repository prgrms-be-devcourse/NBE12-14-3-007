package com.team007.room_escape.global.jwt

import io.jsonwebtoken.Claims
import io.jsonwebtoken.Jwts
import io.jsonwebtoken.security.Keys
import org.springframework.stereotype.Component
import java.time.Instant
import java.util.Date
import java.util.UUID
import javax.crypto.SecretKey

/**
 * JWT 생성·검증.
 * Access와 Refresh는 서로 다른 키로 서명하고, sub에 회원 UUID, 클레임에 nickname/role/profileImg를 넣는다.
 */
@Component
class JwtProvider(
    private val properties: JwtProperties,
) {

    private val accessKey = keyOf(properties.secret())
    private val refreshKey = keyOf(properties.refreshSecret())

    fun createAccessToken(memberId: UUID, nickname: String, role: String, profileImg: String?): String =
        build(memberId, nickname, role, profileImg, properties.accessTokenValiditySeconds(), accessKey)

    fun createRefreshToken(memberId: UUID, nickname: String, role: String, profileImg: String?): String =
        build(memberId, nickname, role, profileImg, properties.refreshTokenValiditySeconds(), refreshKey)

    fun parse(token: String): Claims = parseWith(token, accessKey)

    fun parseRefresh(token: String): Claims = parseWith(token, refreshKey)

    private fun build(
        memberId: UUID,
        nickname: String,
        role: String,
        profileImg: String?,
        validitySeconds: Long,
        key: SecretKey,
    ): String {
        val now = Instant.now()
        return Jwts.builder()
            .issuer(properties.issuer())
            .subject(memberId.toString())
            .claim("nickname", nickname)
            .claim("role", role)
            .apply { profileImg?.let { claim("profileImg", it) } }
            .issuedAt(Date.from(now))
            .expiration(Date.from(now.plusSeconds(validitySeconds)))
            .signWith(key)
            .compact()
    }

    private fun parseWith(token: String, key: SecretKey): Claims =
        Jwts.parser()
            .verifyWith(key)
            .requireIssuer(properties.issuer())
            .build()
            .parseSignedClaims(token)
            .payload

    private fun keyOf(secret: String): SecretKey = Keys.hmacShaKeyFor(secret.toByteArray())
}
