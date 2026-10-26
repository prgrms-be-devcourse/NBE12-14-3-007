@file:Suppress("DEPRECATION")

package com.team007.room_escape.global.config

import com.team007.room_escape.global.jwt.JwtProperties
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test

// TODO(java-compat): 아직 Java인 AuthService, EmailVerificationService, FestivalService가 옛 접근자
//  (publicUrl(), expireMinutes() 등)를 쓰는 동안만 필요한 테스트다. 그 서비스를 Kotlin으로 옮기고
//  properties의 deprecated 함수를 지울 때 이 파일도 함께 지운다. ("java-compat"로 검색)
class PropertiesLegacyAccessorTest {

    @Test
    fun `옛 접근자는 새 프로퍼티와 같은 값을 돌려준다`() {
        val r2 = R2Properties("account", "access", "secret", "bucket", "https://img.example.com")
        val mail = AuthMailProperties(5, 60, 30)
        val jwt = JwtProperties("s", "i", 3600, "rs", 7200)

        assertThat(r2.publicUrl()).isEqualTo(r2.publicUrl)
        assertThat(mail.expireMinutes()).isEqualTo(5)
        assertThat(mail.resendCooldownSeconds()).isEqualTo(60)
        assertThat(mail.verifiedValidMinutes()).isEqualTo(30)
        assertThat(mail.cacheRetentionMinutes()).isEqualTo(mail.cacheRetentionMinutes)
        assertThat(jwt.refreshTokenValiditySeconds()).isEqualTo(7200)
    }
}
