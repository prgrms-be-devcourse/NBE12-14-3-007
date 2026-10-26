package com.team007.room_escape.domain.community.dto

import com.team007.room_escape.domain.community.type.CommunityCategory
import io.swagger.v3.oas.annotations.media.Schema
import jakarta.validation.constraints.NotBlank
import jakarta.validation.constraints.NotNull
import jakarta.validation.constraints.Size

// 필드를 nullable로 둬야 값이 빠진 요청도 JSON 변환 오류가 아니라 검증 오류(400)로 답한다.
class CommunityRequest private constructor() {

    @Schema(name = "CommunityPostUpsertRequest", description = "커뮤니티 글 작성·수정 요청")
    data class PostUpsert(
        @field:NotNull
        val category: CommunityCategory?,

        @field:NotBlank
        @field:Size(min = 2, max = 100)
        val title: String?,

        @field:NotBlank
        val content: String?,
    )

    /** 댓글 작성 요청. 수정 때 부모가 바뀌면 안 되므로 parentId는 작성 요청에만 있다. */
    @Schema(name = "CommunityCommentCreateRequest", description = "커뮤니티 댓글 작성 요청")
    data class CommentCreate(
        @field:NotBlank
        @field:Size(max = 500)
        val content: String?,

        @field:Schema(
            description = "답글을 달 댓글 ID. 일반 댓글이면 비운다. 대댓글을 지정하면 그 대댓글의 부모 아래에 붙는다.",
            example = "1",
            nullable = true,
        )
        val parentId: Long? = null,
    )

    @Schema(name = "CommunityCommentUpsertRequest", description = "커뮤니티 댓글 수정 요청")
    data class CommentUpsert(
        @field:NotBlank
        @field:Size(max = 500)
        val content: String?,
    )
}
