package com.team007.room_escape.domain.support.controller

import com.team007.room_escape.domain.support.dto.SupportArticleRequest
import com.team007.room_escape.domain.support.dto.SupportArticleResponse
import com.team007.room_escape.domain.support.service.SupportArticleService
import com.team007.room_escape.global.response.ApiResponse
import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.tags.Tag
import jakarta.validation.Valid
import org.springframework.http.ResponseEntity
import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.web.bind.annotation.DeleteMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.PutMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

/** 목록은 공개 API(GET /support/notices, /support/faqs)를 같이 쓴다. 지운 글은 다시 볼 일이 없어서다. */
@Tag(name = "Admin Support", description = "관리자 고객센터 공지사항·자주 묻는 질문 API")
@RestController
@RequestMapping("/api/v1/admin/support/articles")
@PreAuthorize("hasRole('ADMIN')")
class AdminSupportArticleController(
    private val service: SupportArticleService,
) {

    @Operation(summary = "[ADMIN] 고객센터 글 쓰기", description = "공지사항 또는 자주 묻는 질문을 쓴다. 질문의 표시 순서를 비우면 맨 아래에 둔다.")
    @PostMapping
    fun create(
        @Valid @RequestBody request: SupportArticleRequest.Create,
    ): ResponseEntity<ApiResponse<SupportArticleResponse.Item>> =
        ResponseEntity.ok(ApiResponse.ok(service.create(request)))

    @Operation(summary = "[ADMIN] 고객센터 글 수정", description = "제목·본문·표시 순서를 바꾼다. 종류는 바꿀 수 없다.")
    @PutMapping("/{articleId}")
    fun update(
        @PathVariable("articleId") articleId: Long,
        @Valid @RequestBody request: SupportArticleRequest.Update,
    ): ResponseEntity<ApiResponse<SupportArticleResponse.Item>> =
        ResponseEntity.ok(ApiResponse.ok(service.update(articleId, request)))

    @Operation(summary = "[ADMIN] 고객센터 글 삭제", description = "목록에서 내린다. 복구 기능은 없다.")
    @DeleteMapping("/{articleId}")
    fun delete(
        @PathVariable("articleId") articleId: Long,
    ): ResponseEntity<ApiResponse<Void?>> {
        service.delete(articleId)
        return ResponseEntity.ok(ApiResponse.noContent())
    }
}
