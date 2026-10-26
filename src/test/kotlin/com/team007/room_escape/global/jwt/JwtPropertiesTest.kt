package com.team007.room_escape.global.jwt

import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test
import org.springframework.boot.context.properties.bind.Binder
import org.springframework.boot.context.properties.source.MapConfigurationPropertySource

class JwtPropertiesTest {

    @Test
    fun `jwt 설정 키가 생성자로 바인딩된다`() {
        val source = MapConfigurationPropertySource(
            mapOf(
                "jwt.secret" to "access-secret",
                "jwt.issuer" to "roomescape",
                "jwt.access-token-validity-seconds" to "3600",
                "jwt.refresh-secret" to "refresh-secret",
                "jwt.refresh-token-validity-seconds" to "7200",
            )
        )

        val properties = Binder(source).bind("jwt", JwtProperties::class.java).get()

        assertThat(properties).isEqualTo(JwtProperties("access-secret", "roomescape", 3600, "refresh-secret", 7200))
    }
}
