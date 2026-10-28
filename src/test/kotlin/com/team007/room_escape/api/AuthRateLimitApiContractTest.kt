package com.team007.room_escape.api

import org.junit.jupiter.api.Test
import org.springframework.http.HttpHeaders
import org.springframework.http.MediaType
import org.springframework.test.context.TestPropertySource
import org.springframework.test.web.servlet.MockHttpServletRequestDsl
import org.springframework.test.web.servlet.post
import java.util.UUID

/**
 * IP를 읽는 설정(REMOTE_ADDR)을 켠 상태에서 가입 제한을 확인한다.
 * 기본 테스트 설정은 IP를 쓰지 않아서(가입을 제한하지 않음) 따로 컨텍스트를 띄운다.
 * MockMvc 요청은 모두 같은 IP(127.0.0.1)에서 온 것으로 본다.
 */
@TestPropertySource(properties = ["client-ip.mode=REMOTE_ADDR"])
class AuthRateLimitApiContractTest : ApiContractSupport() {

    private fun signup() = mvc.post("/api/v1/auth/signup") {
        val token = UUID.randomUUID().toString().substring(0, 8)
        json("""{"email":"limit-$token@example.com","password":"Password1!","nickname":"제한$token"}""")
    }

    @Test
    fun 같은_IP에서_가입을_여섯_번_하면_여섯_번째는_429로_막는다() {
        repeat(5) {
            signup().andExpect {
                status { isCreated() }
            }
        }

        signup().andExpect {
            status { isTooManyRequests() }
            jsonPath("$.code") { value("AUTH008") }
            jsonPath("$.data.retryAfterSeconds") { isNumber() }
            header { exists(HttpHeaders.RETRY_AFTER) }
        }
    }

    private fun MockHttpServletRequestDsl.json(body: String) {
        contentType = MediaType.APPLICATION_JSON
        content = body
    }
}
