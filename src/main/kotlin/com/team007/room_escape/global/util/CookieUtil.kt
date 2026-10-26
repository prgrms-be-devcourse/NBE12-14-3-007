package com.team007.room_escape.global.util

import com.team007.room_escape.global.jwt.JwtProperties
import com.team007.room_escape.global.security.AuthCookieProperties
import jakarta.servlet.http.HttpServletResponse
import org.springframework.http.HttpHeaders
import org.springframework.http.ResponseCookie
import org.springframework.stereotype.Component

/**
 * Refresh Token HttpOnly 쿠키 생성·삭제.
 * SameSite를 위해 jakarta Cookie 대신 Spring ResponseCookie를 쓴다.
 */
@Component
class CookieUtil(
    private val properties: AuthCookieProperties,
    private val jwtProperties: JwtProperties,
) {

    fun addRefreshCookie(response: HttpServletResponse, token: String) =
        addCookie(response, base(token).maxAge(jwtProperties.refreshTokenValiditySeconds))

    fun clearRefreshCookie(response: HttpServletResponse) =
        addCookie(response, base("").maxAge(0))

    private fun addCookie(response: HttpServletResponse, cookie: ResponseCookie.ResponseCookieBuilder) =
        response.addHeader(HttpHeaders.SET_COOKIE, cookie.build().toString())

    private fun base(value: String): ResponseCookie.ResponseCookieBuilder =
        ResponseCookie.from(REFRESH_TOKEN_COOKIE, value)
            .httpOnly(true)
            .secure(properties.secure)
            .sameSite(properties.sameSite)
            .path(properties.path)

    companion object {
        const val REFRESH_TOKEN_COOKIE = "refreshToken"
    }
}
