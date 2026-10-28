package com.team007.room_escape.domain.auth.controller

import com.team007.room_escape.domain.auth.dto.AuthRequest
import com.team007.room_escape.domain.auth.dto.AuthResponse
import com.team007.room_escape.domain.auth.service.AuthService
import com.team007.room_escape.global.ratelimit.AuthRateLimiter
import com.team007.room_escape.global.response.ApiResponse
import com.team007.room_escape.global.util.CookieUtil
import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.security.SecurityRequirements
import io.swagger.v3.oas.annotations.tags.Tag
import jakarta.servlet.http.HttpServletRequest
import jakarta.servlet.http.HttpServletResponse
import jakarta.validation.Valid
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.CookieValue
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping("/api/v1/auth")
@SecurityRequirements
@Tag(name = "인증 API", description = "회원가입, 로그인 및 토큰 관리")
class AuthController(
    private val authService: AuthService,
    private val cookieUtil: CookieUtil,
    private val rateLimiter: AuthRateLimiter,
) {

    @Operation(summary = "회원가입")
    @PostMapping("/signup")
    fun signup(
        @Valid @RequestBody request: AuthRequest.Signup,
        httpRequest: HttpServletRequest,
    ): ResponseEntity<ApiResponse<Void?>> {
        rateLimiter.requireSignupAllowed(httpRequest)
        authService.signup(request)
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.noContent())
    }

    @Operation(summary = "로그인")
    @PostMapping("/login")
    fun login(
        @Valid @RequestBody request: AuthRequest.Login,
        response: HttpServletResponse,
        httpRequest: HttpServletRequest,
    ): ResponseEntity<ApiResponse<AuthResponse.Token>> {
        val pair = rateLimiter.guardLogin(request.email, httpRequest) { authService.login(request.email, request.password) }
        cookieUtil.addRefreshCookie(response, pair.refreshToken)
        return ResponseEntity.ok(ApiResponse.ok(AuthResponse.Token.bearer(pair.accessToken)))
    }

    @Operation(summary = "Access Token 재발급")
    @PostMapping("/refresh")
    fun refresh(
        @CookieValue(value = CookieUtil.REFRESH_TOKEN_COOKIE, required = false) refreshToken: String?,
    ): ResponseEntity<ApiResponse<AuthResponse.Token>> =
        ResponseEntity.ok(ApiResponse.ok(AuthResponse.Token.bearer(authService.refresh(refreshToken))))

    @Operation(summary = "로그아웃")
    @PostMapping("/logout")
    fun logout(
        @CookieValue(value = CookieUtil.REFRESH_TOKEN_COOKIE, required = false) refreshToken: String?,
        response: HttpServletResponse,
    ): ResponseEntity<ApiResponse<Void?>> {
        authService.logout(refreshToken)
        cookieUtil.clearRefreshCookie(response)
        return ResponseEntity.noContent().build()
    }
}
