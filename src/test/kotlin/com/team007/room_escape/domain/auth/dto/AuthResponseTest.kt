package com.team007.room_escape.domain.auth.dto

import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test

class AuthResponseTest {

    @Test
    fun `bearer로 만들면 토큰 종류가 Bearer다`() {
        val token = AuthResponse.Token.bearer("access-token")

        assertThat(token.accessToken).isEqualTo("access-token")
        assertThat(token.tokenType).isEqualTo("Bearer")
    }
}
