package com.team007.room_escape.global.jwt

import io.jsonwebtoken.Claims
import io.jsonwebtoken.Jwts
import io.jsonwebtoken.security.Keys
import jakarta.annotation.PostConstruct
import org.springframework.stereotype.Component
import java.nio.charset.StandardCharsets
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
    private val properties: JwtProperties
) {

    private lateinit var accessKey: SecretKey
    private lateinit var refreshKey: SecretKey

    @PostConstruct
    fun init() {
        this.accessKey = Keys.hmacShaKeyFor(properties.secret().toByteArray(StandardCharsets.UTF_8))
        this.refreshKey = Keys.hmacShaKeyFor(properties.refreshSecret().toByteArray(StandardCharsets.UTF_8))
    }

    fun createAccessToken(memberId: UUID, nickname: String, role: String, profileImg: String?): String {
        return build(memberId, nickname, role, profileImg, properties.accessTokenValiditySeconds(), accessKey)
    }

    fun createRefreshToken(memberId: UUID, nickname: String, role: String, profileImg: String?): String {
        return build(memberId, nickname, role, profileImg, properties.refreshTokenValiditySeconds(), refreshKey)
    }

    private fun build(
        memberId: UUID,
        nickname: String,
        role: String,
        profileImg: String?,
        validitySeconds: Long,
        key: SecretKey
    ): String {
        val now = Instant.now()
        val builder = Jwts.builder()
            .issuer(properties.issuer())
            .subject(memberId.toString())
            .claim("nickname", nickname)
            .claim("role", role)
            .issuedAt(Date.from(now))
            .expiration(Date.from(now.plusSeconds(validitySeconds)))
            .signWith(key)
        if (profileImg != null) {
            builder.claim("profileImg", profileImg)
        }
        return builder.compact()
    }

    fun parse(token: String): Claims {
        return parseWith(token, accessKey)
    }

    fun parseRefresh(token: String): Claims {
        return parseWith(token, refreshKey)
    }

    private fun parseWith(token: String, key: SecretKey): Claims {
        return Jwts.parser()
            .verifyWith(key)
            .requireIssuer(properties.issuer())
            .build()
            .parseSignedClaims(token)
            .payload
    }
}
