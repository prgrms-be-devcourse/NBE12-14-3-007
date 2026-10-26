package com.team007.room_escape.global.security

import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test
import org.springframework.boot.context.properties.bind.Binder
import org.springframework.boot.context.properties.source.MapConfigurationPropertySource

class AuthCookiePropertiesTest {

    @Test
    fun `app-cookie 설정 키가 생성자로 바인딩된다`() {
        val source = MapConfigurationPropertySource(
            mapOf(
                "app.cookie.secure" to "true",
                "app.cookie.same-site" to "None",
                "app.cookie.path" to "/api/v1/auth",
            )
        )

        val properties = Binder(source).bind("app.cookie", AuthCookieProperties::class.java).get()

        assertThat(properties).isEqualTo(AuthCookieProperties(true, "None", "/api/v1/auth"))
    }
}
