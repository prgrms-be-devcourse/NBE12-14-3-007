package com.team007.room_escape.global.config

import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test
import org.springframework.boot.context.properties.bind.Binder
import org.springframework.boot.context.properties.source.MapConfigurationPropertySource

class R2PropertiesTest {

    @Test
    fun `r2 설정 키가 생성자로 바인딩된다`() {
        val source = MapConfigurationPropertySource(
            mapOf(
                "r2.account-id" to "account123",
                "r2.access-key" to "access",
                "r2.secret-key" to "secret",
                "r2.bucket" to "my-bucket",
                "r2.public-url" to "https://img.example.com",
            )
        )

        val properties = Binder(source).bind("r2", R2Properties::class.java).get()

        assertThat(properties).isEqualTo(
            R2Properties("account123", "access", "secret", "my-bucket", "https://img.example.com")
        )
    }

    @Test
    fun `엔드포인트는 계정 ID로 만든다`() {
        val properties = R2Properties("account123", "access", "secret", "bucket", "https://img.example.com")

        assertThat(properties.endpoint).isEqualTo("https://account123.r2.cloudflarestorage.com")
    }
}
