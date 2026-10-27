package com.team007.room_escape.domain.like.controller

import com.team007.room_escape.domain.festival.dto.FestivalResponse
import com.team007.room_escape.domain.like.service.MyLikeService
import com.team007.room_escape.domain.post.dto.PostResponse
import com.team007.room_escape.global.response.ApiResponse
import com.team007.room_escape.global.security.CustomUserDetails
import io.swagger.v3.oas.annotations.Operation
import org.springframework.data.domain.Page
import org.springframework.data.domain.Pageable
import org.springframework.data.web.PageableDefault
import org.springframework.http.ResponseEntity
import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.security.core.annotation.AuthenticationPrincipal
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping("/api/v1/members/me/likes")
@PreAuthorize("isAuthenticated()")
class MyLikeController(
    private val service: MyLikeService,
) {

    @GetMapping("/festivals")
    @Operation(
        summary = "내가 좋아요한 행사",
        description = "최근에 좋아요를 누른 행사부터 조회합니다. 삭제된 행사는 빠지며 sort 파라미터는 무시합니다.",
    )
    fun festivals(
        @AuthenticationPrincipal user: CustomUserDetails,
        @PageableDefault(size = 20) page: Pageable,
    ): ResponseEntity<ApiResponse<Page<FestivalResponse.ListItem>>> =
        ResponseEntity.ok(ApiResponse.ok(service.findLikedFestivals(user.id, page)))

    @GetMapping("/posts")
    @Operation(
        summary = "내가 좋아요한 후기",
        description = "최근에 좋아요를 누른 후기부터 조회합니다. 삭제된 후기는 빠지며 sort 파라미터는 무시합니다.",
    )
    fun posts(
        @AuthenticationPrincipal user: CustomUserDetails,
        @PageableDefault(size = 20) page: Pageable,
    ): ResponseEntity<ApiResponse<Page<PostResponse.ListItem>>> =
        ResponseEntity.ok(ApiResponse.ok(service.findLikedPosts(user.id, page)))
}
