package com.team007.room_escape.domain.inquiry.controller

import com.team007.room_escape.domain.inquiry.dto.AdminInquiryRequest
import com.team007.room_escape.domain.inquiry.dto.AdminInquiryResponse
import com.team007.room_escape.domain.inquiry.service.AdminInquiryService
import com.team007.room_escape.global.response.ApiResponse
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
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.ModelAttribute
import org.springframework.web.bind.annotation.PatchMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController
import java.util.UUID

@Tag(name = "Admin Inquiry", description = "관리자 문의·신고·제보 API")
@RestController
@RequestMapping("/api/v1/admin/inquiries")
class AdminInquiryController(
    private val adminInquiryService: AdminInquiryService
) {

    @Operation(summary = "[ADMIN] 문의·신고·제보 목록 조회", description = "제목, 답변 상태, 문의 종류로 검색한다. 조건을 비우면 전체를 조회한다")
    @GetMapping
    @PreAuthorize("hasRole('ADMIN')")
    fun search(
        @ParameterObject @ModelAttribute request: AdminInquiryRequest.Search,
        @ParameterObject
        @PageableDefault(size = 20, sort = ["createdAt"], direction = Sort.Direction.DESC)
        pageable: Pageable
    ): ResponseEntity<ApiResponse<Page<AdminInquiryResponse.ListItem>>> {
        val response = adminInquiryService.search(request, pageable)

        return ResponseEntity.ok(ApiResponse.ok(response))
    }

    @Operation(summary = "[ADMIN] 문의·신고·제보 상세 조회", description = "본문, 첨부, 작성자, 답변까지 함께 조회한다")
    @GetMapping("/{inquiryId}")
    @PreAuthorize("hasRole('ADMIN')")
    fun findById(
        @PathVariable("inquiryId") inquiryId: UUID
    ): ResponseEntity<ApiResponse<AdminInquiryResponse.Detail>> {
        val response = adminInquiryService.findById(inquiryId)

        return ResponseEntity.ok(ApiResponse.ok(response))
    }

    @Operation(
        summary = "[ADMIN] 문의·신고·제보 답변 등록",
        description = "답변을 등록하고 상태를 ANSWERED로 바꾼다."
    )
    @PatchMapping("/{inquiryId}/answer")
    @PreAuthorize("hasRole('ADMIN')")
    fun answer(
        @PathVariable("inquiryId") inquiryId: UUID,
        @Valid @RequestBody request: AdminInquiryRequest.Answer
    ): ResponseEntity<ApiResponse<AdminInquiryResponse.Detail>> {
        val response = adminInquiryService.answer(inquiryId, request)

        return ResponseEntity.ok(ApiResponse.ok(response))
    }
}
