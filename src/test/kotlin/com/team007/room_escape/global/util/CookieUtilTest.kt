package com.team007.room_escape.global.util

import com.team007.room_escape.global.jwt.JwtProperties
import com.team007.room_escape.global.security.AuthCookieProperties
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test
import org.springframework.http.HttpHeaders
import org.springframework.mock.web.MockHttpServletResponse

class CookieUtilTest {

    private val refreshSeconds = 1_209_600L

    private val jwtProperties = JwtProperties("access-secret", "issuer", 3_600, "refresh-secret", refreshSeconds)

    private fun cookieUtil(secure: Boolean, sameSite: String, path: String = "/") =
        CookieUtil(AuthCookieProperties(secure, sameSite, path), jwtProperties)

    private fun setCookieOf(action: (MockHttpServletResponse) -> Unit): String {
        val response = MockHttpServletResponse()
        action(response)
        return requireNotNull(response.getHeader(HttpHeaders.SET_COOKIE))
    }

    @Test
    fun `쿠키 이름은 refreshToken이다`() {
        assertThat(CookieUtil.REFRESH_TOKEN_COOKIE).isEqualTo("refreshToken")
    }

    @Test
    fun `리프레시 쿠키는 토큰 값과 만료 시간을 담고 HttpOnly로 내려간다`() {
        val cookie = setCookieOf { cookieUtil(secure = false, sameSite = "Lax").addRefreshCookie(it, "header.payload.signature") }

        assertThat(cookie)
            .contains("refreshToken=header.payload.signature")
            .contains("Max-Age=$refreshSeconds")
            .contains("Path=/")
            .contains("HttpOnly")
            .contains("SameSite=Lax")
            .doesNotContain("Secure")
    }

    @Test
    fun `https 환경에서는 Secure와 SameSite=None을 설정값대로 붙인다`() {
        val cookie = setCookieOf { cookieUtil(secure = true, sameSite = "None").addRefreshCookie(it, "token") }

        assertThat(cookie)
            .contains("refreshToken=token")
            .contains("Secure")
            .contains("SameSite=None")
    }

    @Test
    fun `경로도 설정값을 따른다`() {
        val cookie = setCookieOf { cookieUtil(secure = false, sameSite = "Lax", path = "/api/v1/auth").addRefreshCookie(it, "t") }

        assertThat(cookie).contains("Path=/api/v1/auth")
    }

    @Test
    fun `쿠키를 지울 때는 값을 비우고 수명을 0으로 한다`() {
        val cookie = setCookieOf { cookieUtil(secure = false, sameSite = "Lax").clearRefreshCookie(it) }

        assertThat(cookie)
            .startsWith("refreshToken=;")
            .contains("Max-Age=0")
            .contains("HttpOnly")
    }
}
