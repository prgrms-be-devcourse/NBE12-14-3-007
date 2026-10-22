package com.team007.room_escape.global.jwt

import com.team007.room_escape.global.exception.BusinessException
import com.team007.room_escape.global.response.code.AuthExceptionCode
import com.team007.room_escape.global.security.CustomUserDetails
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
    @Qualifier("handlerExceptionResolver") private val resolver: HandlerExceptionResolver
) : OncePerRequestFilter() {

    override fun shouldNotFilter(request: HttpServletRequest): Boolean {
        val path = request.servletPath
        return path.startsWith("/api/v1/auth/")
            || path.startsWith("/swagger-ui")
            || path.startsWith("/v3/api-docs")
    }

    override fun doFilterInternal(
        request: HttpServletRequest,
        response: HttpServletResponse,
        filterChain: FilterChain
    ) {
        val token = resolveToken(request)
        if (token == null) {
            filterChain.doFilter(request, response)
            return
        }

        try {
            val claims = jwtProvider.parse(token)
            val principal = CustomUserDetails(
                UUID.fromString(claims.subject),
                claims.get("nickname", String::class.java),
                claims.get("role", String::class.java),
                claims.get("profileImg", String::class.java),
                null
            )

            val authentication =
                UsernamePasswordAuthenticationToken(principal, null, principal.getAuthorities())
            authentication.details = WebAuthenticationDetailsSource().buildDetails(request)
            SecurityContextHolder.getContext().authentication = authentication

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

    private fun resolveToken(request: HttpServletRequest): String? {
        val header = request.getHeader(HEADER)
        if (header == null || !header.startsWith(PREFIX)) {
            return null
        }
        val token = header.substring(PREFIX.length).trim()
        if (token.isEmpty() || "null" == token || "undefined" == token) {
            return null
        }
        return token
    }

    companion object {
        private const val HEADER = "Authorization"
        private const val PREFIX = "Bearer "
    }
}
