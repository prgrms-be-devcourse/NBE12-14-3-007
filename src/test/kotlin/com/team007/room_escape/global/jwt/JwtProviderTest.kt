package com.team007.room_escape.global.jwt

import io.jsonwebtoken.ExpiredJwtException
import io.jsonwebtoken.JwtException
import io.jsonwebtoken.security.WeakKeyException
import org.assertj.core.api.Assertions.assertThat
import org.assertj.core.api.Assertions.assertThatThrownBy
import org.junit.jupiter.api.Test
import java.time.Instant
import java.util.UUID

class JwtProviderTest {

    private val accessSecret = "access-secret-access-secret-access-secret"
    private val refreshSecret = "refresh-secret-refresh-secret-refresh-secret"

    private fun providerOf(
        issuer: String = "roomescape",
        accessSeconds: Long = 3_600,
        refreshSeconds: Long = 7_200,
        access: String = accessSecret,
        refresh: String = refreshSecret,
    ) = JwtProvider(JwtProperties(access, issuer, accessSeconds, refresh, refreshSeconds)).apply { init() }

    private val provider = providerOf()
    private val memberId = UUID.randomUUID()

    @Test
    fun `액세스 토큰에는 회원 ID와 닉네임 등급 프로필이 담긴다`() {
        val token = provider.createAccessToken(memberId, "닉네임", "ROLE_TRUSTED", "profiles/a.png")

        val claims = provider.parse(token)
        assertThat(claims.subject).isEqualTo(memberId.toString())
        assertThat(claims.issuer).isEqualTo("roomescape")
        assertThat(claims.get("nickname", String::class.java)).isEqualTo("닉네임")
        assertThat(claims.get("role", String::class.java)).isEqualTo("ROLE_TRUSTED")
        assertThat(claims.get("profileImg", String::class.java)).isEqualTo("profiles/a.png")
    }

    @Test
    fun `프로필 이미지가 없으면 클레임 자체를 넣지 않는다`() {
        val claims = provider.parse(provider.createAccessToken(memberId, "닉네임", "ROLE_UNVERIFIED", null))

        assertThat(claims.containsKey("profileImg")).isFalse()
    }

    @Test
    fun `액세스 토큰은 설정한 유효 시간 뒤에 만료된다`() {
        val claims = provider.parse(provider.createAccessToken(memberId, "닉네임", "ROLE_UNVERIFIED", null))

        val seconds = claims.expiration.toInstant().epochSecond - Instant.now().epochSecond
        assertThat(seconds).isBetween(3_590L, 3_600L)
    }

    @Test
    fun `리프레시 토큰은 별도 유효 시간을 쓴다`() {
        val claims = provider.parseRefresh(provider.createRefreshToken(memberId, "닉네임", "ROLE_UNVERIFIED", null))

        val seconds = claims.expiration.toInstant().epochSecond - Instant.now().epochSecond
        assertThat(seconds).isBetween(7_190L, 7_200L)
    }

    @Test
    fun `액세스와 리프레시는 서로 다른 키로 서명해서 바꿔 쓸 수 없다`() {
        val access = provider.createAccessToken(memberId, "닉네임", "ROLE_UNVERIFIED", null)
        val refresh = provider.createRefreshToken(memberId, "닉네임", "ROLE_UNVERIFIED", null)

        assertThatThrownBy { provider.parse(refresh) }.isInstanceOf(JwtException::class.java)
        assertThatThrownBy { provider.parseRefresh(access) }.isInstanceOf(JwtException::class.java)
    }

    @Test
    fun `만료된 토큰은 만료 예외를 던진다`() {
        val expired = providerOf(accessSeconds = -10)
            .createAccessToken(memberId, "닉네임", "ROLE_UNVERIFIED", null)

        assertThatThrownBy { provider.parse(expired) }.isInstanceOf(ExpiredJwtException::class.java)
    }

    @Test
    fun `다른 키로 서명한 토큰은 거절한다`() {
        val forged = providerOf(access = "another-secret-another-secret-another-secret")
            .createAccessToken(memberId, "닉네임", "ROLE_ADMIN", null)

        assertThatThrownBy { provider.parse(forged) }.isInstanceOf(JwtException::class.java)
    }

    @Test
    fun `발급자가 다른 토큰은 거절한다`() {
        val otherIssuer = providerOf(issuer = "someone-else")
            .createAccessToken(memberId, "닉네임", "ROLE_UNVERIFIED", null)

        assertThatThrownBy { provider.parse(otherIssuer) }.isInstanceOf(JwtException::class.java)
    }

    @Test
    fun `내용을 고친 토큰은 거절한다`() {
        val token = provider.createAccessToken(memberId, "닉네임", "ROLE_UNVERIFIED", null)
        val tampered = token.dropLast(3) + "xyz"

        assertThatThrownBy { provider.parse(tampered) }.isInstanceOf(JwtException::class.java)
    }

    @Test
    fun `토큰 형식이 아닌 문자열은 거절한다`() {
        assertThatThrownBy { provider.parse("not-a-token") }.isInstanceOf(JwtException::class.java)
    }

    @Test
    fun `서명 키가 너무 짧으면 시작할 때 실패한다`() {
        assertThatThrownBy { providerOf(access = "short") }.isInstanceOf(WeakKeyException::class.java)
    }
}
