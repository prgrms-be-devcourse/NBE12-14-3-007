package com.team007.room_escape.global.security

import com.team007.room_escape.global.exception.BusinessException
import com.team007.room_escape.global.response.code.AuthExceptionCode
import jakarta.servlet.http.HttpServletRequest
import jakarta.servlet.http.HttpServletResponse
import org.springframework.beans.factory.annotation.Qualifier
import org.springframework.security.access.AccessDeniedException
import org.springframework.security.web.access.AccessDeniedHandler
import org.springframework.stereotype.Component
import org.springframework.web.servlet.HandlerExceptionResolver

/**
 * 인증은 됐지만 권한이 부족할 때 403을 만든다.
 * 필터 체인의 AccessDenied를 HandlerExceptionResolver로 넘겨
 * GlobalExceptionHandler가 ACCESS_DENIED를 내려준다.
 */
@Component
class JwtAccessDeniedHandler(
    @Qualifier("handlerExceptionResolver") private val resolver: HandlerExceptionResolver
) : AccessDeniedHandler {

    override fun handle(
        request: HttpServletRequest,
        response: HttpServletResponse,
        accessDeniedException: AccessDeniedException
    ) {
        resolver.resolveException(
            request, response, null,
            BusinessException(AuthExceptionCode.ACCESS_DENIED)
        )
    }
}
