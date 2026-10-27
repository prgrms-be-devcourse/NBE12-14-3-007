package com.team007.room_escape.domain.support.controller

import com.team007.room_escape.domain.support.dto.SupportArticleResponse
import com.team007.room_escape.domain.support.service.SupportArticleService
import com.team007.room_escape.global.response.ApiResponse
import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.tags.Tag
import org.springdoc.core.annotations.ParameterObject
import org.springframework.data.domain.Page
import org.springframework.data.domain.Pageable
import org.springframework.data.web.PageableDefault
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@Tag(name = "Support", description = "고객센터 공지사항·자주 묻는 질문 API")
@RestController
@RequestMapping("/api/v1/support")
class SupportArticleController(
    private val service: SupportArticleService,
) {

    @Operation(summary = "공지사항 목록", description = "로그인 없이 볼 수 있다. 최신순으로 고정하며 sort 파라미터는 무시한다.")
    @GetMapping("/notices")
    fun notices(
        @ParameterObject @PageableDefault(size = 20) pageable: Pageable,
    ): ResponseEntity<ApiResponse<Page<SupportArticleResponse.Item>>> =
        ResponseEntity.ok(ApiResponse.ok(service.notices(pageable)))

    @Operation(summary = "자주 묻는 질문 목록", description = "로그인 없이 볼 수 있다. 관리자가 정한 표시 순서대로 전체를 돌려준다.")
    @GetMapping("/faqs")
    fun faqs(): ResponseEntity<ApiResponse<List<SupportArticleResponse.Item>>> =
        ResponseEntity.ok(ApiResponse.ok(service.faqs()))
}
