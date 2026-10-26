package com.team007.room_escape.domain.auth.dto

import com.team007.room_escape.global.validation.ValidPassword
import com.team007.room_escape.global.validation.ValidPhone
import io.swagger.v3.oas.annotations.media.Schema
import jakarta.validation.constraints.Email
import jakarta.validation.constraints.NotBlank
import jakarta.validation.constraints.Size

class AuthRequest private constructor() {

    @Schema(name = "AuthLoginRequest", description = "로그인 요청")
    data class Login(

        @field:NotBlank
        @field:Email
        @field:Schema(description = "회원 이메일", example = "user@example.com")
        val email: String?,

        @field:NotBlank
        @field:Schema(description = "비밀번호", example = "Password1!")
        val password: String?,
    )

    @Schema(name = "AuthSignupRequest", description = "회원가입 요청")
    data class Signup(

        @field:NotBlank
        @field:Email
        @field:Schema(description = "회원 이메일", example = "user@example.com")
        val email: String?,

        @field:NotBlank
        @field:ValidPassword
        @field:Schema(description = "8~25자이며 영문, 숫자, 특수문자(!@#%^&*)를 포함한 비밀번호", example = "Password1!")
        val password: String?,

        @field:NotBlank
        @field:Size(min = 2, max = 30)
        @field:Schema(description = "닉네임", example = "축제좋아")
        val nickname: String?,

        @field:ValidPhone
        @field:Schema(description = "휴대폰 번호. 하이픈 없이 숫자만", example = "01012345678")
        val phone: String?,
    )
}
