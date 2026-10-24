package com.team007.room_escape.domain.like.controller

import com.team007.room_escape.domain.like.dto.LikeResponse
import com.team007.room_escape.domain.like.service.LikeService
import com.team007.room_escape.global.response.ApiResponse
import com.team007.room_escape.global.security.CustomUserDetails
import io.swagger.v3.oas.annotations.Operation
import org.springframework.http.ResponseEntity
import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.security.core.annotation.AuthenticationPrincipal
import org.springframework.web.bind.annotation.DeleteMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController
import java.util.UUID

@RestController
@RequestMapping("/api/v1")
class LikeController(
    private val likeService: LikeService,
) {

    /** 후기 */
    @Operation(summary = "후기 좋아요 등록", description = "특정 후기에 좋아요를 등록합니다.")
    @PostMapping("/posts/{id}/likes/me")
    @PreAuthorize("hasRole('UNVERIFIED')")
    fun createPostLike(
        @PathVariable id: UUID,
        @AuthenticationPrincipal user: CustomUserDetails,
    ): ResponseEntity<ApiResponse<LikeResponse>> =
        ResponseEntity.ok(ApiResponse.ok(likeService.createPostLike(id, user.id)))

    @Operation(summary = "후기 좋아요 취소", description = "특정 후기에 좋아요를 취소합니다.")
    @DeleteMapping("/posts/{id}/likes/me")
    fun deletePostLike(
        @PathVariable id: UUID,
        @AuthenticationPrincipal user: CustomUserDetails,
    ): ResponseEntity<ApiResponse<LikeResponse>> =
        ResponseEntity.ok(ApiResponse.ok(likeService.deletePostLike(id, user.id)))

    /** 행사 */
    @Operation(summary = "행사 좋아요 등록", description = "특정 행사에 좋아요를 등록합니다.")
    @PostMapping("/festivals/{id}/likes/me")
    @PreAuthorize("hasRole('UNVERIFIED')")
    fun createFestivalLike(
        @PathVariable id: Long,
        @AuthenticationPrincipal user: CustomUserDetails,
    ): ResponseEntity<ApiResponse<LikeResponse>> =
        ResponseEntity.ok(ApiResponse.ok(likeService.createFestivalLike(id, user.id)))

    @Operation(summary = "행사 좋아요 취소", description = "특정 행사에 좋아요를 취소합니다.")
    @DeleteMapping("/festivals/{id}/likes/me")
    fun deleteFestivalLike(
        @PathVariable id: Long,
        @AuthenticationPrincipal user: CustomUserDetails,
    ): ResponseEntity<ApiResponse<LikeResponse>> =
        ResponseEntity.ok(ApiResponse.ok(likeService.deleteFestivalLike(id, user.id)))
}
