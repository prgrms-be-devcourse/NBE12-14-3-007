package com.team007.room_escape.domain.festival.controller

import com.team007.room_escape.domain.festival.dto.FestivalSubmissionRequest
import com.team007.room_escape.domain.festival.dto.FestivalSubmissionResponse
import com.team007.room_escape.domain.festival.service.FestivalSubmissionService
import com.team007.room_escape.global.response.ApiResponse
import com.team007.room_escape.global.security.CustomUserDetails
import io.swagger.v3.oas.annotations.Operation
import jakarta.validation.Valid
import java.util.UUID
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.security.core.annotation.AuthenticationPrincipal
import org.springframework.web.bind.annotation.DeleteMapping
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PatchMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping("/api/v1")
class FestivalSubmissionController(
    private val festivalSubmissionService: FestivalSubmissionService
) {

    @PostMapping("/festivals/submissions")
    @PreAuthorize("hasRole('UNVERIFIED')")
    @Operation(summary = "행사 정보 등록", description = "로그인한 사용자가 행사 내용을 제보합니다.")
    fun create(
        @AuthenticationPrincipal principal: CustomUserDetails,
        @Valid @RequestBody request: FestivalSubmissionRequest.Upsert
    ): ResponseEntity<ApiResponse<FestivalSubmissionResponse.Create>> {
        val response: FestivalSubmissionResponse.Create =
            festivalSubmissionService.create(principal.id, request)

        return ResponseEntity
            .status(HttpStatus.CREATED)
            .body(ApiResponse.ok(response))
    }

    @GetMapping("/members/me/submissions")
    @PreAuthorize("hasRole('UNVERIFIED')")
    @Operation(summary = "[ME] 내 행사 목록 조회", description = "로그인한 사용자가 제보한 행사 목록을 조회합니다.")
    fun findAllMine(
        @AuthenticationPrincipal principal: CustomUserDetails
    ): ResponseEntity<ApiResponse<List<FestivalSubmissionResponse.ListItem>>> {
        val response: List<FestivalSubmissionResponse.ListItem> =
            festivalSubmissionService.findAllByMemberId(principal.id)

        return ResponseEntity.ok(ApiResponse.ok(response))
    }

    @GetMapping("/members/me/submissions/{submissionId}")
    @PreAuthorize("hasRole('UNVERIFIED')")
    @Operation(summary = "[ME] 내 행사 상세 조회", description = "로그인한 사용자가 자신이 제보한 행사 정보를 상세 조회합니다.")
    fun findMine(
        @AuthenticationPrincipal principal: CustomUserDetails,
        @PathVariable submissionId: UUID
    ): ResponseEntity<ApiResponse<FestivalSubmissionResponse.Detail>> {
        val response: FestivalSubmissionResponse.Detail =
            festivalSubmissionService.findById(principal.id, submissionId)

        return ResponseEntity.ok(ApiResponse.ok(response))
    }

    @PatchMapping("/members/me/submissions/{submissionId}")
    @PreAuthorize("hasRole('UNVERIFIED')")
    @Operation(summary = "[ME] 내 행사 제보 수정", description = "로그인한 사용자가 본인이 등록한 행사 정보와 제보 내용을 수정합니다.")
    fun update(
        @AuthenticationPrincipal principal: CustomUserDetails,
        @PathVariable submissionId: UUID,
        @Valid @RequestBody request: FestivalSubmissionRequest.Upsert
    ): ResponseEntity<ApiResponse<FestivalSubmissionResponse.Detail>> {
        val response: FestivalSubmissionResponse.Detail =
            festivalSubmissionService.update(principal.id, submissionId, request)

        return ResponseEntity.ok(ApiResponse.ok(response))
    }

    @DeleteMapping("/members/me/submissions/{submissionId}")
    @PreAuthorize("hasRole('UNVERIFIED')")
    @Operation(summary = "[ME] 내 행사 제보 삭제", description = "로그인한 사용자가 본인이 등록한 행사 제보를 삭제합니다.")
    fun delete(
        @AuthenticationPrincipal principal: CustomUserDetails,
        @PathVariable submissionId: UUID
    ): ResponseEntity<ApiResponse<Void?>> {
        festivalSubmissionService.delete(principal.id, submissionId)

        return ResponseEntity.ok(ApiResponse.noContent())
    }
}
