package com.team007.room_escape.domain.member.controller

import com.team007.room_escape.domain.member.dto.MemberRequest
import com.team007.room_escape.domain.member.dto.MemberResponse
import com.team007.room_escape.domain.member.service.MemberService
import com.team007.room_escape.global.response.ApiResponse
import com.team007.room_escape.global.security.CustomUserDetails
import com.team007.room_escape.global.util.CookieUtil
import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.tags.Tag
import jakarta.servlet.http.HttpServletResponse
import jakarta.validation.Valid
import org.springframework.http.ResponseEntity
import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.security.core.annotation.AuthenticationPrincipal
import org.springframework.web.bind.annotation.DeleteMapping
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PatchMapping
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@Tag(name = "Member", description = "회원 API")
@RestController
@RequestMapping("/api/v1/members")
class MemberController(
    private val memberService: MemberService,
    private val cookieUtil: CookieUtil,
) {

    @Operation(summary = "마이페이지 조회", description = "로그인한 본인의 정보를 조회한다.")
    @GetMapping("/me")
    @PreAuthorize("isAuthenticated()")
    fun getMyPage(
        @AuthenticationPrincipal principal: CustomUserDetails,
    ): ResponseEntity<ApiResponse<MemberResponse.MyPageInfo>> =
        ResponseEntity.ok(ApiResponse.ok(memberService.getMyPage(principal.id)))

    @Operation(summary = "마이페이지 수정", description = "닉네임·연락처·프로필 이미지를 수정한다. 보낸 필드만 반영된다.")
    @PatchMapping("/me")
    @PreAuthorize("isAuthenticated()")
    fun updateMyPage(
        @AuthenticationPrincipal principal: CustomUserDetails,
        @Valid @RequestBody request: MemberRequest.UpdateMyPage,
    ): ResponseEntity<ApiResponse<MemberResponse.MyPageInfo>> =
        ResponseEntity.ok(ApiResponse.ok(memberService.updateMyPage(principal.id, request)))

    @Operation(summary = "비밀번호 변경 인증 코드 발송", description = "가입 이메일로 6자리 인증 코드를 보낸다.")
    @PostMapping("/me/password/verification-code")
    @PreAuthorize("isAuthenticated()")
    fun sendPasswordChangeCode(
        @AuthenticationPrincipal principal: CustomUserDetails,
    ): ResponseEntity<ApiResponse<Void?>> {
        memberService.sendPasswordChangeCode(principal.id)
        return ResponseEntity.ok(ApiResponse.noContent("인증 코드를 메일로 보냈습니다."))
    }

    @Operation(summary = "비밀번호 변경 인증 코드 확인", description = "메일로 받은 6자리 코드가 맞는지 확인한다.")
    @PostMapping("/me/password/verify")
    @PreAuthorize("isAuthenticated()")
    fun verifyPasswordChangeCode(
        @AuthenticationPrincipal principal: CustomUserDetails,
        @Valid @RequestBody request: MemberRequest.VerifyPassword,
    ): ResponseEntity<ApiResponse<Void?>> {
        memberService.verifyPasswordChangeCode(principal.id, request)
        return ResponseEntity.ok(ApiResponse.noContent("인증되었습니다. 새 비밀번호를 입력해 주세요."))
    }

    @Operation(summary = "비밀번호 변경", description = "인증을 통과한 상태에서 새 비밀번호를 설정한다.")
    @PatchMapping("/me/password")
    @PreAuthorize("isAuthenticated()")
    fun changePassword(
        @AuthenticationPrincipal principal: CustomUserDetails,
        @Valid @RequestBody request: MemberRequest.ChangePassword,
    ): ResponseEntity<ApiResponse<Void?>> {
        memberService.changePassword(principal.id, request)
        return ResponseEntity.ok(ApiResponse.noContent("비밀번호가 변경되었습니다. 다시 로그인해 주세요."))
    }

    @Operation(summary = "[ME] 회원 탈퇴", description = "현재 비밀번호로 본인 확인 후 탈퇴한다.")
    @DeleteMapping("/me")
    @PreAuthorize("isAuthenticated()")
    fun withdraw(
        @AuthenticationPrincipal principal: CustomUserDetails,
        @Valid @RequestBody request: MemberRequest.Withdraw,
        response: HttpServletResponse,
    ): ResponseEntity<ApiResponse<Void?>> {
        memberService.withdraw(principal.id, request)
        // 브라우저에 남은 리프레시 쿠키도 지운다.
        cookieUtil.clearRefreshCookie(response)
        return ResponseEntity.ok(ApiResponse.noContent("탈퇴가 완료되었습니다."))
    }
}
