package com.team007.room_escape.global.config

import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test
import java.net.URI

class R2ConfigTest {

    private val properties = R2Properties("account123", "access", "secret", "bucket", "https://img.example.com")
    private val client = R2Config(properties).s3Client()

    @Test
    fun `R2 계정 엔드포인트로 접속한다`() {
        assertThat(client.serviceClientConfiguration().endpointOverride().get())
            .isEqualTo(URI.create("https://account123.r2.cloudflarestorage.com"))
    }

    @Test
    fun `리전은 auto를 쓴다`() {
        assertThat(client.serviceClientConfiguration().region().id()).isEqualTo("auto")
    }
}
