@file:Suppress("DEPRECATION")

package com.team007.room_escape.global.config

import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test

// TODO(java-compat): 아직 Java인 FestivalService가 옛 접근자 publicUrl()을 쓰는 동안만 필요한 테스트다.
//  FestivalService를 Kotlin으로 옮기고 R2Properties의 deprecated 함수를 지울 때 이 파일도 함께 지운다.
//  ("java-compat"로 검색)
class PropertiesLegacyAccessorTest {

    @Test
    fun `옛 접근자는 새 프로퍼티와 같은 값을 돌려준다`() {
        val r2 = R2Properties("account", "access", "secret", "bucket", "https://img.example.com")

        assertThat(r2.publicUrl()).isEqualTo(r2.publicUrl)
    }
}
