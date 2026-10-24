package com.team007.room_escape.global.security

import com.team007.room_escape.global.exception.BusinessException
import com.team007.room_escape.global.response.code.AuthExceptionCode
import jakarta.servlet.http.HttpServletRequest
import jakarta.servlet.http.HttpServletResponse
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test
import org.mockito.ArgumentCaptor
import org.mockito.ArgumentMatchers.any
import org.mockito.ArgumentMatchers.isNull
import org.mockito.Mockito.mock
import org.mockito.Mockito.verify
import org.springframework.mock.web.MockHttpServletRequest
import org.springframework.mock.web.MockHttpServletResponse
import org.springframework.security.access.AccessDeniedException
import org.springframework.security.authentication.BadCredentialsException
import org.springframework.web.servlet.HandlerExceptionResolver

/**
 * 시큐리티 필터 단계의 인증·인가 실패는 컨트롤러 어드바이스가 직접 못 잡는다.
 * 그래서 예외 리졸버로 넘기는데, 그때 넘기는 에러 코드가 맞는지 확인한다.
 */
class SecurityErrorHandlersTest {

    private val resolver = mock(HandlerExceptionResolver::class.java)

    private fun passedToResolver(): BusinessException {
        val captor = ArgumentCaptor.forClass(Exception::class.java)
        verify(resolver).resolveException(
            any(HttpServletRequest::class.java), any(HttpServletResponse::class.java), isNull<Any>(), captor.capture()
        )
        return captor.value as BusinessException
    }

    @Test
    fun `권한이 부족하면 ACCESS_DENIED를 예외 리졸버로 넘긴다`() {
        JwtAccessDeniedHandler(resolver)
            .handle(MockHttpServletRequest(), MockHttpServletResponse(), AccessDeniedException("denied"))

        assertThat(passedToResolver().exceptionCode).isEqualTo(AuthExceptionCode.ACCESS_DENIED)
    }

    @Test
    fun `인증 없이 보호된 경로에 오면 TOKEN_MISSING을 예외 리졸버로 넘긴다`() {
        JwtAuthenticationEntryPoint(resolver)
            .commence(MockHttpServletRequest(), MockHttpServletResponse(), BadCredentialsException("no auth"))

        assertThat(passedToResolver().exceptionCode).isEqualTo(AuthExceptionCode.TOKEN_MISSING)
    }
}
