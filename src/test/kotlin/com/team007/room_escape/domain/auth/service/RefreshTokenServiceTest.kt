package com.team007.room_escape.domain.auth.service

import com.team007.room_escape.domain.auth.infra.entity.RefreshToken
import com.team007.room_escape.domain.auth.infra.repository.RefreshTokenRepository
import com.team007.room_escape.domain.member.infra.entity.Member
import com.team007.room_escape.domain.member.infra.entity.MemberRole
import com.team007.room_escape.global.exception.BusinessException
import com.team007.room_escape.global.response.code.AuthExceptionCode
import org.assertj.core.api.Assertions.assertThat
import org.assertj.core.api.Assertions.assertThatCode
import org.assertj.core.api.Assertions.assertThatThrownBy
import org.junit.jupiter.api.Test
import org.mockito.ArgumentCaptor
import org.mockito.ArgumentMatchers.any
import org.mockito.Mockito.mock
import org.mockito.Mockito.never
import org.mockito.Mockito.verify
import org.mockito.Mockito.`when`
import org.springframework.test.util.ReflectionTestUtils
import java.security.MessageDigest
import java.time.LocalDateTime
import java.util.HexFormat
import java.util.UUID

class RefreshTokenServiceTest {

    private val repository = mock(RefreshTokenRepository::class.java)
    private val service = RefreshTokenService(repository)

    private val memberId = UUID.randomUUID()
    private val member: Member = Member(
        email = "a@example.com",
        password = "pw",
        role = MemberRole.ROLE_UNVERIFIED,
        nickname = "닉네임",
    )
        .also { ReflectionTestUtils.setField(it, "id", memberId) }

    private fun sha256(raw: String) =
        HexFormat.of().formatHex(MessageDigest.getInstance("SHA-256").digest(raw.toByteArray()))

    private fun stored(hash: String, expiresAt: LocalDateTime) = RefreshToken(member, hash, expiresAt)

    private fun org.assertj.core.api.AbstractThrowableAssert<*, *>.isBusiness(code: AuthExceptionCode) {
        isInstanceOfSatisfying(BusinessException::class.java) {
            assertThat(it.exceptionCode).isEqualTo(code)
        }
    }

    @Test
    fun `처음 저장하면 토큰 원문이 아니라 SHA-256 해시를 저장한다`() {
        `when`(repository.findByMemberId(memberId)).thenReturn(null)
        // Kotlin 서비스가 save의 반환값 null을 허용하지 않아서, 저장한 객체를 그대로 돌려주도록 해 둔다.
        `when`(repository.save(any(RefreshToken::class.java))).thenAnswer { it.arguments[0] }
        val expiresAt = LocalDateTime.now().plusDays(14)

        service.save(member, "raw-token", expiresAt)

        val captor = ArgumentCaptor.forClass(RefreshToken::class.java)
        verify(repository).save(captor.capture())
        assertThat(captor.value.member).isSameAs(member)
        assertThat(captor.value.tokenHash).isEqualTo(sha256("raw-token")).isNotEqualTo("raw-token")
        assertThat(captor.value.expiresAt).isEqualTo(expiresAt)
    }

    @Test
    fun `이미 있으면 새로 만들지 않고 기존 행의 해시와 만료 시각을 바꾼다`() {
        val existing = stored(sha256("old"), LocalDateTime.now().plusDays(1))
        `when`(repository.findByMemberId(memberId)).thenReturn(existing)
        val expiresAt = LocalDateTime.now().plusDays(14)

        service.save(member, "new-token", expiresAt)

        verify(repository, never()).save(any(RefreshToken::class.java))
        assertThat(existing.tokenHash).isEqualTo(sha256("new-token"))
        assertThat(existing.expiresAt).isEqualTo(expiresAt)
    }

    @Test
    fun `저장된 토큰과 같으면 통과한다`() {
        `when`(repository.findByMemberId(memberId))
            .thenReturn(stored(sha256("raw"), LocalDateTime.now().plusDays(1)))

        assertThatCode { service.verify(memberId, "raw") }.doesNotThrowAnyException()
    }

    @Test
    fun `저장된 토큰이 없으면 유효하지 않은 토큰이다`() {
        `when`(repository.findByMemberId(memberId)).thenReturn(null)

        assertThatThrownBy { service.verify(memberId, "raw") }.isBusiness(AuthExceptionCode.TOKEN_INVALID)
    }

    @Test
    fun `해시가 다르면 유효하지 않은 토큰이다`() {
        `when`(repository.findByMemberId(memberId))
            .thenReturn(stored(sha256("raw"), LocalDateTime.now().plusDays(1)))

        assertThatThrownBy { service.verify(memberId, "other") }.isBusiness(AuthExceptionCode.TOKEN_INVALID)
    }

    @Test
    fun `만료되었으면 해시가 달라도 만료로 알린다`() {
        `when`(repository.findByMemberId(memberId))
            .thenReturn(stored(sha256("raw"), LocalDateTime.now().minusSeconds(1)))

        assertThatThrownBy { service.verify(memberId, "other") }.isBusiness(AuthExceptionCode.TOKEN_EXPIRED)
    }

    @Test
    fun `회원 ID로 토큰을 지운다`() {
        service.deleteByMemberId(memberId)

        verify(repository).deleteByMemberId(memberId)
    }
}
