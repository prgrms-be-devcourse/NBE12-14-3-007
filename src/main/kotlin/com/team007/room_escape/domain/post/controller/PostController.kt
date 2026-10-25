package com.team007.room_escape.domain.post.controller

import com.team007.room_escape.domain.post.dto.PostRequest
import com.team007.room_escape.domain.post.dto.PostResponse
import com.team007.room_escape.domain.post.service.PostService
import com.team007.room_escape.domain.post.type.PostSearchType
import com.team007.room_escape.global.response.ApiResponse
import com.team007.room_escape.global.security.CustomUserDetails
import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.tags.Tag
import jakarta.validation.Valid
import org.springframework.data.domain.Page
import org.springframework.data.domain.Pageable
import org.springframework.data.domain.Sort
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
import org.springframework.web.bind.annotation.RequestParam
import org.springframework.web.bind.annotation.RestController
import java.util.UUID

@Tag(name = "Post", description = "행사 후기 API")
@RestController
@RequestMapping("/api/v1")
class PostController(
    private val postService: PostService,
) {

    @Operation(summary = "후기 작성", description = "특정 행사에 후기를 작성합니다.")
    @PostMapping("/festivals/{id}/posts")
    @PreAuthorize("hasRole('UNVERIFIED')")
    fun createPost(
        @PathVariable id: Long,
        @Valid @RequestBody request: PostRequest,
        @AuthenticationPrincipal user: CustomUserDetails,
    ): ResponseEntity<ApiResponse<PostResponse.Create>> =
        ResponseEntity.ok(ApiResponse.ok(postService.createPost(id, request, user.id)))

    @Operation(summary = "후기 검색", description = "후기를 검색합니다. sort=likeCount,desc 로 좋아요순 정렬할 수 있습니다.")
    @GetMapping("/posts")
    fun searchPosts(
        @RequestParam(required = false) type: PostSearchType?,
        @RequestParam(required = false) keyword: String?,
        @PageableDefault(size = 9, sort = ["createdAt"], direction = Sort.Direction.DESC) page: Pageable,
    ): ResponseEntity<ApiResponse<Page<PostResponse.ListItem>>> =
        ResponseEntity.ok(ApiResponse.ok(postService.searchPosts(type, keyword, page)))

    @Operation(summary = "관리자 후기 조회", description = "삭제된 후기를 포함하여 후기 목록을 조회하거나 검색합니다.")
    @GetMapping("/admin/posts")
    @PreAuthorize("hasRole('ADMIN')")
    fun searchPostsForAdmin(
        @RequestParam(required = false) type: PostSearchType?,
        @RequestParam(required = false) keyword: String?,
        @PageableDefault(size = 9, sort = ["createdAt"], direction = Sort.Direction.DESC) page: Pageable,
    ): ResponseEntity<ApiResponse<Page<PostResponse.AdminListItem>>> =
        ResponseEntity.ok(ApiResponse.ok(postService.searchPostsForAdmin(type, keyword, page)))

    @Operation(summary = "행사별 후기 다건 조회", description = "행사별 후기를 검색합니다. sort=likeCount,desc 로 좋아요순 정렬할 수 있습니다.")
    @GetMapping("/festivals/{id}/posts")
    fun getPostsByFestival(
        @PathVariable id: Long,
        @PageableDefault(sort = ["createdAt"], direction = Sort.Direction.DESC) page: Pageable,
    ): ResponseEntity<ApiResponse<Page<PostResponse.ListItem>>> =
        ResponseEntity.ok(ApiResponse.ok(postService.getPostsByFestival(id, page)))

    @Operation(summary = "후기 단건 조회", description = "후기 상세 정보를 조회합니다.")
    @GetMapping("/posts/{id}")
    fun getPostDetail(
        @PathVariable id: UUID,
        // 비회원이면 user가 null이다.
        @AuthenticationPrincipal user: CustomUserDetails?,
    ): ResponseEntity<ApiResponse<PostResponse.Detail>> =
        ResponseEntity.ok(ApiResponse.ok(postService.getPostDetail(id, user?.id)))

    @Operation(summary = "후기 수정", description = "본인이 작성한 후기를 수정합니다.")
    @PatchMapping("/posts/{id}")
    @PreAuthorize("hasRole('UNVERIFIED')")
    fun updatePost(
        @PathVariable id: UUID,
        @Valid @RequestBody request: PostRequest,
        @AuthenticationPrincipal user: CustomUserDetails,
    ): ResponseEntity<ApiResponse<PostResponse.Detail>> =
        ResponseEntity.ok(ApiResponse.ok(postService.updatePost(id, request, user.id)))

    @Operation(summary = "후기 삭제", description = "작성자 본인이 삭제합니다. 관리자의 타인 후기 삭제는 공통 관리자 조치 API를 사용합니다.")
    @DeleteMapping("/posts/{id}")
    fun deletePost(
        @PathVariable id: UUID,
        @AuthenticationPrincipal user: CustomUserDetails,
    ): ResponseEntity<ApiResponse<Void?>> {
        postService.deletePost(id, user.id)
        return ResponseEntity.ok(ApiResponse.noContent())
    }
}
