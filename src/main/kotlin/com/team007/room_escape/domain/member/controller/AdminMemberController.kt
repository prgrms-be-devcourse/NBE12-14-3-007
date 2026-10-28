package com.team007.room_escape.domain.member.controller

import com.team007.room_escape.domain.member.dto.AdminMemberRequest
import com.team007.room_escape.domain.member.dto.MemberResponse
import com.team007.room_escape.domain.member.service.AdminMemberService
import com.team007.room_escape.global.response.ApiResponse
import com.team007.room_escape.global.security.CustomUserDetails
import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.tags.Tag
import jakarta.validation.Valid
import org.springdoc.core.annotations.ParameterObject
import org.springframework.data.domain.Page
import org.springframework.data.domain.Pageable
import org.springframework.data.domain.Sort
import org.springframework.data.web.PageableDefault
import org.springframework.http.ResponseEntity
import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.security.core.annotation.AuthenticationPrincipal
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.ModelAttribute
import org.springframework.web.bind.annotation.PatchMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController
import java.util.UUID

@Tag(name = "Admin Member", description = "관리자 회원 관리 API")
@RestController
@RequestMapping("/api/v1/admin/members")
class AdminMemberController(
    private val adminMemberService: AdminMemberService,
) {

    @Operation(summary = "[ADMIN] 회원 목록 조회", description = "닉네임·이메일 검색어와 등급으로 검색한다.")
    @GetMapping
    @PreAuthorize("hasRole('ADMIN')")
    fun search(
        @ParameterObject @ModelAttribute request: AdminMemberRequest.Search,
        @ParameterObject
        @PageableDefault(size = 20, sort = ["createdAt"], direction = Sort.Direction.DESC)
        pageable: Pageable,
    ): ResponseEntity<ApiResponse<Page<MemberResponse.AdminInfo>>> =
        ResponseEntity.ok(ApiResponse.ok(adminMemberService.search(request, pageable)))

    @Operation(summary = "[ADMIN] 회원 단건 조회", description = "탈퇴 회원도 조회된다.")
    @GetMapping("/{memberId}")
    @PreAuthorize("hasRole('ADMIN')")
    fun get(
        @PathVariable("memberId") memberId: UUID,
    ): ResponseEntity<ApiResponse<MemberResponse.AdminInfo>> =
        ResponseEntity.ok(ApiResponse.ok(adminMemberService.get(memberId)))

    @Operation(
        summary = "[ADMIN] 회원 등급 변경",
        description = "회원의 신뢰 등급을 변경한다. 바꾼 등급은 고정돼서 자정 집계가 덮어쓰지 않는다. " +
            "제재(ROLE_WARNING)로 바꿀 때는 reason(사유)이 필수다. 관리자 관련 변경은 막는다.",
    )
    @PatchMapping("/{memberId}/role")
    @PreAuthorize("hasRole('ADMIN')")
    fun changeRole(
        @PathVariable("memberId") memberId: UUID,
        @AuthenticationPrincipal principal: CustomUserDetails,
        @Valid @RequestBody request: AdminMemberRequest.ChangeRole,
    ): ResponseEntity<ApiResponse<MemberResponse.AdminInfo>> =
        ResponseEntity.ok(ApiResponse.ok(adminMemberService.changeRole(principal.id, memberId, request)))

    @Operation(summary = "[ADMIN] 회원 등급 변경 이력", description = "관리자가 등급을 바꾼 기록을 최근 순으로 조회한다.")
    @GetMapping("/{memberId}/role-history")
    @PreAuthorize("hasRole('ADMIN')")
    fun roleHistory(
        @PathVariable("memberId") memberId: UUID,
        @ParameterObject
        @PageableDefault(size = 20, sort = ["createdAt"], direction = Sort.Direction.DESC)
        pageable: Pageable,
    ): ResponseEntity<ApiResponse<Page<MemberResponse.RoleHistoryItem>>> =
        ResponseEntity.ok(ApiResponse.ok(adminMemberService.roleHistory(memberId, pageable)))
}
