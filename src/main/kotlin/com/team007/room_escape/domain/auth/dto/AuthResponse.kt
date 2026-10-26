package com.team007.room_escape.domain.auth.dto

import io.swagger.v3.oas.annotations.media.Schema

class AuthResponse private constructor() {

    /** 로그인·재발급 응답. Refresh Token은 쿠키로 보내고 본문에는 Access Token만 담는다. */
    @Schema(name = "AuthToken", description = "Access Token 응답")
    data class Token(

        @field:Schema(description = "Access Token")
        val accessToken: String,

        @field:Schema(description = "토큰 종류", example = "Bearer")
        val tokenType: String,
    ) {

        companion object {

            fun bearer(accessToken: String): Token = Token(accessToken, "Bearer")
        }
    }
}
