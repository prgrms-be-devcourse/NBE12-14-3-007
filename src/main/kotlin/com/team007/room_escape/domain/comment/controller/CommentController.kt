package com.team007.room_escape.domain.comment.controller

import com.team007.room_escape.domain.comment.dto.CommentRequest
import com.team007.room_escape.domain.comment.dto.CommentResponse
import com.team007.room_escape.domain.comment.service.CommentService
import com.team007.room_escape.global.response.ApiResponse
import com.team007.room_escape.global.security.CustomUserDetails
import io.swagger.v3.oas.annotations.Operation
import jakarta.validation.Valid
import org.springframework.data.domain.Page
import org.springframework.data.domain.Pageable
import org.springframework.data.web.PageableDefault
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
import java.util.UUID

@RestController
@RequestMapping("/api/v1")
class CommentController(
    private val commentService: CommentService,
) {

    @Operation(summary = "[ADMIN] 후기 댓글 관리 목록", description = "일반 댓글 기준 오래된 순 페이지와 대댓글을 제공합니다. 삭제된 댓글의 원문·작성자·최신 삭제 사유는 관리자에게만 제공합니다.")
    @GetMapping("/admin/posts/{id}/comments")
    @PreAuthorize("hasRole('ADMIN')")
    fun getCommentsForAdmin(
        @PathVariable id: UUID,
        @AuthenticationPrincipal user: CustomUserDetails,
        @PageableDefault(size = 20) page: Pageable,
    ): ResponseEntity<ApiResponse<Page<CommentResponse.AdminInfo>>> =
        ResponseEntity.ok(ApiResponse.ok(commentService.getCommentsForAdmin(id, user.id, page)))

    @Operation(summary = "댓글 작성", description = "특정 후기에 댓글을 작성합니다. parentId를 넣으면 그 댓글의 대댓글이 됩니다.")
    @PostMapping("/posts/{id}/comments")
    @PreAuthorize("hasRole('UNVERIFIED')")
    fun createComment(
        @PathVariable id: UUID,
        @Valid @RequestBody request: CommentRequest.Create,
        @AuthenticationPrincipal user: CustomUserDetails,
    ): ResponseEntity<ApiResponse<CommentResponse.Info>> =
        ResponseEntity.ok(ApiResponse.ok(commentService.createComment(id, request, user.id)))

    @Operation(
        summary = "댓글 목록",
        description = "특정 후기의 댓글을 오래된 순으로 조회합니다. " +
            "페이지는 일반 댓글 기준이고, 대댓글은 각 댓글의 replies에 담깁니다. 삭제된 댓글은 \"삭제된 댓글입니다\"로 내려갑니다.",
    )
    @GetMapping("/posts/{id}/comments")
    fun getComments(
        @PathVariable id: UUID,
        @PageableDefault(size = 20) page: Pageable,
    ): ResponseEntity<ApiResponse<Page<CommentResponse.Info>>> =
        ResponseEntity.ok(ApiResponse.ok(commentService.getComments(id, page)))

    @Operation(summary = "댓글 수정", description = "본인이 작성한 댓글을 수정합니다.")
    @PatchMapping("/comments/{id}")
    @PreAuthorize("hasRole('UNVERIFIED')")
    fun updateComment(
        @PathVariable id: Long,
        @Valid @RequestBody request: CommentRequest.Upsert,
        @AuthenticationPrincipal user: CustomUserDetails,
    ): ResponseEntity<ApiResponse<CommentResponse.Info>> =
        ResponseEntity.ok(ApiResponse.ok(commentService.updateComment(id, request, user.id)))

    @Operation(summary = "댓글 삭제", description = "작성자 본인이 삭제합니다. 관리자의 타인 댓글 삭제는 공통 관리자 조치 API를 사용합니다.")
    @DeleteMapping("/comments/{id}")
    fun deleteComment(
        @PathVariable id: Long,
        @AuthenticationPrincipal user: CustomUserDetails,
    ): ResponseEntity<ApiResponse<Void?>> {
        commentService.deleteComment(id, user.id)

        return ResponseEntity.ok(ApiResponse.noContent())
    }
}
