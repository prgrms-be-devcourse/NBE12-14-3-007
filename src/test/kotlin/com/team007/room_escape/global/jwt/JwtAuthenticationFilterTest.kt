package com.team007.room_escape.global.jwt

import com.team007.room_escape.global.exception.BusinessException
import com.team007.room_escape.global.response.code.AuthExceptionCode
import com.team007.room_escape.global.security.CustomUserDetails
import jakarta.servlet.http.HttpServletRequest
import jakarta.servlet.http.HttpServletResponse
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.AfterEach
import org.junit.jupiter.api.Test
import org.junit.jupiter.params.ParameterizedTest
import org.junit.jupiter.params.provider.ValueSource
import org.mockito.ArgumentCaptor
import org.mockito.ArgumentMatchers.any
import org.mockito.ArgumentMatchers.isNull
import org.mockito.Mockito.mock
import org.mockito.Mockito.never
import org.mockito.Mockito.verify
import org.springframework.mock.web.MockFilterChain
import org.springframework.mock.web.MockHttpServletRequest
import org.springframework.mock.web.MockHttpServletResponse
import org.springframework.security.core.context.SecurityContextHolder
import org.springframework.web.servlet.HandlerExceptionResolver
import java.util.UUID

class JwtAuthenticationFilterTest {

    private fun providerOf(accessSeconds: Long = 3_600) = JwtProvider(
        JwtProperties(
            "access-secret-access-secret-access-secret", "roomescape", accessSeconds,
            "refresh-secret-refresh-secret-refresh-secret", 7_200,
        )
    ).apply { init() }

    private val provider = providerOf()
    private val resolver = mock(HandlerExceptionResolver::class.java)
    private val filter = JwtAuthenticationFilter(provider, resolver)
    private val memberId = UUID.randomUUID()

    @AfterEach
    fun clearSecurityContext() = SecurityContextHolder.clearContext()

    private class Result(val chain: MockFilterChain, val response: MockHttpServletResponse) {
        /** 필터가 다음 필터(컨트롤러)로 요청을 넘겼는지 */
        val passedOn get() = chain.request != null
    }

    private fun run(path: String = "/api/v1/inquiries", authorization: String? = null): Result {
        val request = MockHttpServletRequest().apply {
            servletPath = path
            authorization?.let { addHeader("Authorization", it) }
        }
        val response = MockHttpServletResponse()
        val chain = MockFilterChain()
        filter.doFilter(request, response, chain)
        return Result(chain, response)
    }

    private fun rejectedWith(): AuthExceptionCode {
        val captor = ArgumentCaptor.forClass(Exception::class.java)
        verify(resolver).resolveException(
            any(HttpServletRequest::class.java), any(HttpServletResponse::class.java), isNull<Any>(), captor.capture()
        )
        return (captor.value as BusinessException).exceptionCode as AuthExceptionCode
    }

    private fun neverRejected() = verify(resolver, never()).resolveException(
        any(HttpServletRequest::class.java), any(HttpServletResponse::class.java), isNull<Any>(), any(Exception::class.java)
    )

    @Test
    fun `유효한 토큰이면 로그인한 사용자로 인증하고 요청을 넘긴다`() {
        val token = provider.createAccessToken(memberId, "닉네임", "ROLE_TRUSTED", "profiles/a.png")

        val result = run(authorization = "Bearer $token")

        val principal = SecurityContextHolder.getContext().authentication?.principal as CustomUserDetails
        assertThat(result.passedOn).isTrue()
        assertThat(principal.id).isEqualTo(memberId)
        assertThat(principal.nickname).isEqualTo("닉네임")
        assertThat(principal.role).isEqualTo("ROLE_TRUSTED")
        assertThat(principal.profileImg).isEqualTo("profiles/a.png")
        assertThat(principal.authorities.map { it.authority }).containsExactly("ROLE_TRUSTED")
        neverRejected()
    }

    @Test
    fun `토큰이 없으면 인증 없이 요청을 그대로 넘긴다`() {
        val result = run()

        assertThat(result.passedOn).isTrue()
        assertThat(SecurityContextHolder.getContext().authentication).isNull()
        neverRejected()
    }

    @ParameterizedTest(name = "[{index}] \"{0}\"")
    @ValueSource(strings = ["Bearer ", "Bearer null", "Bearer undefined", "Basic abc", "토큰만"])
    fun `비어 있거나 Bearer 형식이 아닌 헤더는 토큰이 없는 것으로 본다`(header: String) {
        val result = run(authorization = header)

        assertThat(result.passedOn).isTrue()
        assertThat(SecurityContextHolder.getContext().authentication).isNull()
        neverRejected()
    }

    @Test
    fun `만료된 토큰은 TOKEN_EXPIRED로 거절하고 요청을 넘기지 않는다`() {
        val expired = providerOf(accessSeconds = -10).createAccessToken(memberId, "닉네임", "ROLE_UNVERIFIED", null)

        val result = run(authorization = "Bearer $expired")

        assertThat(rejectedWith()).isEqualTo(AuthExceptionCode.TOKEN_EXPIRED)
        assertThat(result.passedOn).isFalse()
        assertThat(SecurityContextHolder.getContext().authentication).isNull()
    }

    @Test
    fun `위조되었거나 형식이 틀린 토큰은 TOKEN_INVALID로 거절한다`() {
        val result = run(authorization = "Bearer not-a-real-token")

        assertThat(rejectedWith()).isEqualTo(AuthExceptionCode.TOKEN_INVALID)
        assertThat(result.passedOn).isFalse()
    }

    @Test
    fun `리프레시 토큰으로는 API를 부를 수 없다`() {
        val refresh = provider.createRefreshToken(memberId, "닉네임", "ROLE_UNVERIFIED", null)

        val result = run(authorization = "Bearer $refresh")

        assertThat(rejectedWith()).isEqualTo(AuthExceptionCode.TOKEN_INVALID)
        assertThat(result.passedOn).isFalse()
    }

    @ParameterizedTest(name = "[{index}] {0}")
    @ValueSource(strings = ["/api/v1/auth/login", "/api/v1/auth/refresh", "/swagger-ui/index.html", "/v3/api-docs/swagger-config"])
    fun `인증 경로와 문서 경로는 토큰이 잘못돼도 검사하지 않고 넘긴다`(path: String) {
        val result = run(path = path, authorization = "Bearer broken-token")

        assertThat(result.passedOn).isTrue()
        neverRejected()
    }
}
