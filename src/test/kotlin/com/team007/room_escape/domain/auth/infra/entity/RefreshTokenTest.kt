package com.team007.room_escape.domain.auth.infra.entity

import com.team007.room_escape.domain.member.infra.entity.Member
import com.team007.room_escape.domain.member.infra.entity.MemberRole
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test
import java.time.LocalDateTime

class RefreshTokenTest {

    private val member: Member = Member(
        email = "a@example.com",
        password = "pw",
        role = MemberRole.ROLE_UNVERIFIED,
        nickname = "닉네임",
    )

    @Test
    fun `해시가 같을 때만 일치한다`() {
        val token = RefreshToken(member, "hash-a", LocalDateTime.now().plusDays(1))

        assertThat(token.matches("hash-a")).isTrue()
        assertThat(token.matches("hash-b")).isFalse()
    }

    @Test
    fun `만료 시각이 지났으면 만료다`() {
        assertThat(RefreshToken(member, "h", LocalDateTime.now().minusSeconds(1)).isExpired).isTrue()
        assertThat(RefreshToken(member, "h", LocalDateTime.now().plusMinutes(1)).isExpired).isFalse()
    }

    @Test
    fun `교체하면 해시와 만료 시각이 바뀐다`() {
        val token = RefreshToken(member, "old", LocalDateTime.now().minusDays(1))
        val newExpiry = LocalDateTime.now().plusDays(14)

        token.rotate("new", newExpiry)

        assertThat(token.tokenHash).isEqualTo("new")
        assertThat(token.expiresAt).isEqualTo(newExpiry)
        assertThat(token.isExpired).isFalse()
        assertThat(token.matches("old")).isFalse()
    }
}
