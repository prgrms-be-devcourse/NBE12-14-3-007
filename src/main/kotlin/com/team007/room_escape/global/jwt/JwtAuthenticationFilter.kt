package com.team007.room_escape.global.jwt

import com.team007.room_escape.global.exception.BusinessException
import com.team007.room_escape.global.response.code.AuthExceptionCode
import com.team007.room_escape.global.security.CustomUserDetails
import io.jsonwebtoken.Claims
import io.jsonwebtoken.ExpiredJwtException
import io.jsonwebtoken.JwtException
import jakarta.servlet.FilterChain
import jakarta.servlet.http.HttpServletRequest
import jakarta.servlet.http.HttpServletResponse
import org.springframework.beans.factory.annotation.Qualifier
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken
import org.springframework.security.core.context.SecurityContextHolder
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource
import org.springframework.stereotype.Component
import org.springframework.web.filter.OncePerRequestFilter
import org.springframework.web.servlet.HandlerExceptionResolver
import java.util.UUID

/**
 * 요청마다 Authorization Bearer 토큰을 읽어 SecurityContext에 인증을 넣는다.
 * 토큰 없음은 통과(공개 URL은 그대로, 보호 URL은 EntryPoint가 401),
 * 만료/위조는 GlobalExceptionHandler와 같은 ApiResponse로 거절한다.
 */
@Component
class JwtAuthenticationFilter(
    private val jwtProvider: JwtProvider,
    @Qualifier("handlerExceptionResolver") private val resolver: HandlerExceptionResolver,
) : OncePerRequestFilter() {

    override fun shouldNotFilter(request: HttpServletRequest): Boolean =
        SKIPPED_PATHS.any { request.servletPath.startsWith(it) }

    override fun doFilterInternal(
        request: HttpServletRequest,
        response: HttpServletResponse,
        filterChain: FilterChain,
    ) {
        val token = resolveToken(request)
        if (token == null) {
            filterChain.doFilter(request, response)
            return
        }

        try {
            val principal = jwtProvider.parse(token).toPrincipal()
            SecurityContextHolder.getContext().authentication =
                UsernamePasswordAuthenticationToken(principal, null, principal.authorities).apply {
                    details = WebAuthenticationDetailsSource().buildDetails(request)
                }

            filterChain.doFilter(request, response)
        } catch (e: ExpiredJwtException) {
            reject(request, response, AuthExceptionCode.TOKEN_EXPIRED)
        } catch (e: JwtException) {
            reject(request, response, AuthExceptionCode.TOKEN_INVALID)
        } catch (e: IllegalArgumentException) {
            reject(request, response, AuthExceptionCode.TOKEN_INVALID)
        }
    }

    private fun reject(request: HttpServletRequest, response: HttpServletResponse, code: AuthExceptionCode) {
        SecurityContextHolder.clearContext()
        resolver.resolveException(request, response, null, BusinessException(code))
    }

    /** "Bearer "로 시작하는 헤더에서 토큰만 꺼낸다. 비었거나 프론트가 실수로 보낸 null/undefined 문자열이면 토큰이 없는 것으로 본다. */
    private fun resolveToken(request: HttpServletRequest): String? =
        request.getHeader(HEADER)
            ?.takeIf { it.startsWith(PREFIX) }
            // Java String.trim()과 같게 U+0020 이하만 자른다. (Kotlin trim()은 NBSP 등도 자른다)
            ?.removePrefix(PREFIX)?.trim { it <= ' ' }
            ?.takeUnless { it.isEmpty() || it in IGNORED_TOKENS }

    private fun Claims.toPrincipal() = CustomUserDetails(
        UUID.fromString(subject),
        get("nickname", String::class.java),
        get("role", String::class.java),
        get("profileImg", String::class.java),
        null,
    )

    companion object {
        private const val HEADER = "Authorization"
        private const val PREFIX = "Bearer "
        private val SKIPPED_PATHS = listOf("/api/v1/auth/", "/swagger-ui", "/v3/api-docs")
        private val IGNORED_TOKENS = setOf("null", "undefined")
    }
}
