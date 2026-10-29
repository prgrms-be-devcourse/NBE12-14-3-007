package com.team007.room_escape.global.ratelimit

import com.team007.room_escape.global.exception.BusinessException
import com.team007.room_escape.global.response.code.AuthExceptionCode
import org.assertj.core.api.Assertions.assertThat
import org.assertj.core.api.Assertions.assertThatCode
import org.assertj.core.api.Assertions.assertThatThrownBy
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test
import org.springframework.mock.web.MockHttpServletRequest
import java.time.Duration

class AuthRateLimiterTest {

    private val properties = AuthRateLimitProperties(
        loginMaxFailures = 5, loginWindow = Duration.ofMinutes(5),
        signupMaxAttempts = 5, signupWindow = Duration.ofHours(1),
    )

    private fun limiter(mode: ClientIpMode = ClientIpMode.REMOTE_ADDR) =
        AuthRateLimiter(properties, ClientIpResolver(ClientIpProperties(mode)))

    private fun from(ip: String) = MockHttpServletRequest().apply { remoteAddr = ip }

    private fun wrongPassword(): Nothing = throw BusinessException(AuthExceptionCode.INVALID_CREDENTIALS)

    private fun AuthRateLimiter.failedLoginDetails(email: String, request: MockHttpServletRequest): Map<String, Any>? =
        blockedCode { guardLogin(email, request) { wrongPassword() } }.details

    private fun AuthRateLimiter.failLogin(email: String, request: MockHttpServletRequest) {
        assertThatThrownBy { guardLogin(email, request) { wrongPassword() } }
            .isInstanceOfSatisfying(BusinessException::class.java) {
                assertThat(it.exceptionCode).isEqualTo(AuthExceptionCode.INVALID_CREDENTIALS)
            }
    }

    private fun blockedCode(action: () -> Unit): BusinessException {
        var caught: BusinessException? = null
        try {
            action()
        } catch (e: BusinessException) {
            caught = e
        }
        return checkNotNull(caught) { "예외가 나야 한다" }
    }

    @Nested
    inner class `로그인` {

        @Test
        fun `다섯 번 틀리면 여섯 번째는 비밀번호를 확인하지 않고 막는다`() {
            val limiter = limiter()
            val request = from("203.0.113.5")
            repeat(5) { limiter.failLogin("user@example.com", request) }
            var checked = false

            val blocked = blockedCode { limiter.guardLogin("user@example.com", request) { checked = true } }

            assertThat(blocked.exceptionCode).isEqualTo(AuthExceptionCode.TOO_MANY_LOGIN_ATTEMPTS)
            assertThat(checked).isFalse()
        }

        @Test
        fun `틀릴 때마다 몇 번 더 틀릴 수 있는지 알려 준다`() {
            val limiter = limiter()
            val request = from("203.0.113.5")

            val remaining = (1..5).map {
                limiter.failedLoginDetails("user@example.com", request)?.get(AuthRateLimiter.REMAINING_ATTEMPTS)
            }

            assertThat(remaining).containsExactly(4, 3, 2, 1, 0)
        }

        @Test
        fun `마지막 기회까지 틀리면 다시 시도할 수 있을 때까지의 초도 함께 알려 준다`() {
            val limiter = limiter()
            val request = from("203.0.113.5")
            repeat(4) { limiter.failLogin("user@example.com", request) }

            val details = checkNotNull(limiter.failedLoginDetails("user@example.com", request))

            assertThat(details[AuthRateLimiter.RETRY_AFTER_SECONDS] as Long).isBetween(1L, 300L)
        }

        @Test
        fun `남은 횟수는 틀린 사람의 이메일 기준으로만 센다`() {
            val limiter = limiter()
            val request = from("203.0.113.5")
            repeat(3) { limiter.failLogin("a@example.com", request) }

            val details = limiter.failedLoginDetails("b@example.com", request)

            assertThat(details?.get(AuthRateLimiter.REMAINING_ATTEMPTS)).isEqualTo(4)
        }

        @Test
        fun `막힌 응답에는 다시 시도할 수 있을 때까지의 초를 담는다`() {
            val limiter = limiter()
            val request = from("203.0.113.5")
            repeat(5) { limiter.failLogin("user@example.com", request) }

            val blocked = blockedCode { limiter.guardLogin("user@example.com", request) { } }

            val seconds = blocked.details?.get(AuthRateLimiter.RETRY_AFTER_SECONDS) as Long
            assertThat(seconds).isBetween(1L, 300L)
        }

        @Test
        fun `네 번 틀린 뒤 맞게 로그인하면 횟수가 지워진다`() {
            val limiter = limiter()
            val request = from("203.0.113.5")
            repeat(4) { limiter.failLogin("user@example.com", request) }

            assertThat(limiter.guardLogin("user@example.com", request) { "ok" }).isEqualTo("ok")

            repeat(4) { limiter.failLogin("user@example.com", request) }
            assertThatCode { limiter.guardLogin("user@example.com", request) { "ok" } }.doesNotThrowAnyException()
        }

        @Test
        fun `비밀번호가 틀린 경우가 아닌 실패는 세지 않는다`() {
            val limiter = limiter()
            val request = from("203.0.113.5")

            repeat(10) {
                assertThatThrownBy {
                    limiter.guardLogin("user@example.com", request) { throw BusinessException(AuthExceptionCode.TOKEN_INVALID) }
                }.isInstanceOf(BusinessException::class.java)
            }

            assertThatCode { limiter.guardLogin("user@example.com", request) { "ok" } }.doesNotThrowAnyException()
        }

        @Test
        fun `이메일이 같아도 IP가 다르면 따로 센다`() {
            val limiter = limiter()
            repeat(5) { limiter.failLogin("user@example.com", from("203.0.113.5")) }

            assertThatCode { limiter.guardLogin("user@example.com", from("198.51.100.8")) { "ok" } }
                .doesNotThrowAnyException()
        }

        @Test
        fun `IP가 같아도 이메일이 다르면 따로 센다`() {
            val limiter = limiter()
            repeat(5) { limiter.failLogin("a@example.com", from("203.0.113.5")) }

            assertThatCode { limiter.guardLogin("b@example.com", from("203.0.113.5")) { "ok" } }
                .doesNotThrowAnyException()
        }

        @Test
        fun `이메일의 대소문자와 앞뒤 공백이 달라도 같은 이메일로 센다`() {
            val limiter = limiter()
            val request = from("203.0.113.5")
            limiter.failLogin("User@Example.com", request)
            limiter.failLogin(" user@example.com ", request)
            limiter.failLogin("USER@EXAMPLE.COM", request)
            limiter.failLogin("user@example.com", request)
            limiter.failLogin("user@EXAMPLE.com", request)

            val blocked = blockedCode { limiter.guardLogin("user@example.com", request) { } }

            assertThat(blocked.exceptionCode).isEqualTo(AuthExceptionCode.TOO_MANY_LOGIN_ATTEMPTS)
        }

        @Test
        fun `IP를 쓰지 않는 설정이면 이메일만으로 센다`() {
            val limiter = limiter(ClientIpMode.NONE)
            repeat(5) { limiter.failLogin("user@example.com", from("203.0.113.5")) }

            val blocked = blockedCode { limiter.guardLogin("user@example.com", from("198.51.100.8")) { } }

            assertThat(blocked.exceptionCode).isEqualTo(AuthExceptionCode.TOO_MANY_LOGIN_ATTEMPTS)
        }
    }

    @Nested
    inner class `가입` {

        @Test
        fun `같은 IP는 다섯 번까지 허용하고 여섯 번째부터 막는다`() {
            val limiter = limiter()
            val request = from("203.0.113.5")
            repeat(5) { limiter.requireSignupAllowed(request) }

            val blocked = blockedCode { limiter.requireSignupAllowed(request) }

            assertThat(blocked.exceptionCode).isEqualTo(AuthExceptionCode.TOO_MANY_SIGNUPS)
            val seconds = blocked.details?.get(AuthRateLimiter.RETRY_AFTER_SECONDS) as Long
            assertThat(seconds).isBetween(1L, 3600L)
        }

        @Test
        fun `다른 IP는 영향을 받지 않는다`() {
            val limiter = limiter()
            repeat(5) { limiter.requireSignupAllowed(from("203.0.113.5")) }

            assertThatCode { limiter.requireSignupAllowed(from("198.51.100.8")) }.doesNotThrowAnyException()
        }

        /** IP를 믿을 수 없을 때 연결된 상대의 IP로 세면, 프록시 뒤의 모든 사용자가 한꺼번에 막힌다. */
        @Test
        fun `IP를 쓰지 않는 설정이면 가입을 제한하지 않는다`() {
            val limiter = limiter(ClientIpMode.NONE)

            assertThatCode { repeat(50) { limiter.requireSignupAllowed(from("203.0.113.5")) } }
                .doesNotThrowAnyException()
        }
    }
}
