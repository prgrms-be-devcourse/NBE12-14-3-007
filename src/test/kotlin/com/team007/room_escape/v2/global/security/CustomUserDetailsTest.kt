package com.team007.room_escape.v2.global.security

import com.team007.room_escape.global.security.CustomUserDetails
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test
import org.junit.jupiter.params.ParameterizedTest
import org.junit.jupiter.params.provider.CsvSource
import java.util.UUID

class CustomUserDetailsTest {

    private fun userOf(role: String, password: String? = null) =
        CustomUserDetails(UUID.randomUUID(), "닉네임", role, null, password)

    @Test
    fun `로그인 이름은 닉네임이고 권한은 등급 하나다`() {
        val user = userOf("ROLE_TRUSTED")

        assertThat(user.username).isEqualTo("닉네임")
        assertThat(user.authorities.map { it.authority }).containsExactly("ROLE_TRUSTED")
    }

    @ParameterizedTest(name = "{0} -> 관리자 {1}")
    @CsvSource("ROLE_ADMIN,true", "ROLE_TRUSTED,false", "ROLE_RECOGNIZED,false", "ROLE_UNVERIFIED,false", "ROLE_WARNING,false")
    fun `ROLE_ADMIN일 때만 관리자다`(role: String, admin: Boolean) {
        assertThat(userOf(role).isAdmin()).isEqualTo(admin)
    }

    @Test
    fun `토큰에서 복원한 사용자는 비밀번호가 없다`() {
        assertThat(userOf("ROLE_UNVERIFIED").password).isNull()
        assertThat(userOf("ROLE_UNVERIFIED", "암호화된비밀번호").password).isEqualTo("암호화된비밀번호")
    }

    @Test
    fun `계정은 만료·잠금·비활성 상태가 없다`() {
        val user = userOf("ROLE_UNVERIFIED")

        assertThat(user.isAccountNonExpired).isTrue()
        assertThat(user.isAccountNonLocked).isTrue()
        assertThat(user.isCredentialsNonExpired).isTrue()
        assertThat(user.isEnabled).isTrue()
    }
}
