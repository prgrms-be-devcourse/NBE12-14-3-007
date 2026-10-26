package com.team007.room_escape.domain.member.dto

import com.team007.room_escape.global.validation.ValidPassword
import com.team007.room_escape.global.validation.ValidPhone
import io.swagger.v3.oas.annotations.media.Schema
import jakarta.validation.constraints.NotBlank
import jakarta.validation.constraints.Pattern
import jakarta.validation.constraints.Size

class MemberRequest private constructor() {

    /** 마이페이지 수정 요청. 보낸 필드만 반영한다. */
    @Schema(name = "MemberUpdateRequest", description = "마이페이지 회원 정보 수정 요청")
    data class UpdateMyPage(

        @field:Size(min = 2, max = 30)
        @field:Schema(description = "닉네임. 생략하면 변경하지 않는다", example = "축제좋아")
        val nickname: String?,

        @field:ValidPhone
        @field:Schema(description = "휴대폰 번호. 숫자만. 빈 문자열이면 지운다", example = "01012345678")
        val phone: String?,

        @field:Size(max = 2048)
        @field:Schema(
            description = "프로필 이미지 key. 빈 문자열이면 지운다",
            example = "profiles/0befc150-badb-4674-a99d-ded96f03814a.png",
        )
        val profileImg: String?,
    )

    /** 비밀번호 변경 1단계: 메일로 받은 인증 코드가 맞는지만 확인한다. */
    @Schema(name = "PasswordVerifyRequest", description = "비밀번호 변경 인증 코드 확인 요청")
    data class VerifyPassword(

        @field:NotBlank
        @field:Pattern(regexp = "^\\d{6}$", message = "인증 코드는 6자리 숫자입니다.")
        @field:Schema(description = "메일로 받은 6자리 인증 코드", example = "042913")
        val code: String?,
    )

    /** 비밀번호 변경 2단계: 인증을 통과한 상태에서 새 비밀번호를 설정한다. */
    @Schema(name = "PasswordChangeRequest", description = "새 비밀번호 설정 요청")
    data class ChangePassword(

        @field:NotBlank
        @field:ValidPassword
        @field:Schema(description = "새 비밀번호. 8~25자이며 영문, 숫자, 특수문자(!@#%^&*)를 포함", example = "NewPassword1!")
        val newPassword: String?,
    )

    /** 회원 탈퇴 요청. 규칙이 바뀌어도 예전 회원이 탈퇴할 수 있게 @ValidPassword는 걸지 않는다. */
    @Schema(name = "MemberWithdrawRequest", description = "회원 탈퇴 요청")
    data class Withdraw(

        @field:NotBlank(message = "비밀번호를 입력해 주세요.")
        @field:Schema(description = "본인 확인용 현재 비밀번호", example = "Password1!")
        val password: String?,
    )
}
