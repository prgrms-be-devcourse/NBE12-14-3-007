package com.team007.room_escape.global.config

import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test
import org.junit.jupiter.params.ParameterizedTest
import org.junit.jupiter.params.provider.CsvSource
import org.springframework.boot.context.properties.bind.Binder
import org.springframework.boot.context.properties.source.MapConfigurationPropertySource

class AuthMailPropertiesTest {

    @Test
    fun `auth-mail 설정 키가 생성자로 바인딩된다`() {
        val source = MapConfigurationPropertySource(
            mapOf(
                "auth-mail.expire-minutes" to "5",
                "auth-mail.resend-cooldown-seconds" to "60",
                "auth-mail.verified-valid-minutes" to "30",
            )
        )

        val properties = Binder(source).bind("auth-mail", AuthMailProperties::class.java).get()

        assertThat(properties).isEqualTo(AuthMailProperties(5, 60, 30))
    }

    @ParameterizedTest(name = "만료 {0}분 인증 유지 {1}분 -> 캐시 {2}분")
    @CsvSource("5,30,31", "40,30,41", "10,10,11")
    fun `캐시 보관 시간은 두 단계 중 긴 쪽보다 1분 길다`(expire: Long, verified: Long, expected: Long) {
        assertThat(AuthMailProperties(expire, 60, verified).cacheRetentionMinutes).isEqualTo(expected)
    }
}
