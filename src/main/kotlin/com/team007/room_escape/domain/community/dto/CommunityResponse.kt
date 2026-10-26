package com.team007.room_escape.domain.community.dto

import com.team007.room_escape.domain.community.infra.entity.CommunityComment
import com.team007.room_escape.domain.community.infra.entity.CommunityPost
import com.team007.room_escape.domain.community.type.CommunityCategory
import com.team007.room_escape.domain.member.dto.MemberResponse
import com.team007.room_escape.global.storage.ImageUrlResolver
import io.swagger.v3.oas.annotations.media.Schema
import java.time.LocalDateTime
import java.util.UUID

class CommunityResponse private constructor() {

    @Schema(name = "CommunityPostListItem", description = "커뮤니티 글 목록 항목")
    data class PostListItem(
        val id: UUID,
        val category: CommunityCategory,
        val title: String,
        val member: MemberResponse.MemberInfo,
        val viewCount: Long,
        val commentCount: Long,
        val createdAt: LocalDateTime?,
    ) {
        companion object {
            fun from(post: CommunityPost, commentCount: Long, imageUrlResolver: ImageUrlResolver): PostListItem =
                PostListItem(
                    id = savedId(post),
                    category = post.category,
                    title = post.title,
                    member = MemberResponse.MemberInfo.from(post.member, imageUrlResolver),
                    viewCount = post.viewCount,
                    commentCount = commentCount,
                    createdAt = post.createdAt,
                )
        }
    }

    /** 커뮤니티 글 상세. 작성·수정 응답도 같은 모양이다. */
    @Schema(name = "CommunityPostDetail", description = "커뮤니티 글 상세")
    data class PostDetail(
        val id: UUID,
        val category: CommunityCategory,
        val title: String,
        val content: String,
        val member: MemberResponse.MemberInfo,
        val viewCount: Long,
        val commentCount: Long,
        val createdAt: LocalDateTime?,
        val updatedAt: LocalDateTime?,
    ) {
        companion object {
            fun from(post: CommunityPost, commentCount: Long, imageUrlResolver: ImageUrlResolver): PostDetail =
                PostDetail(
                    id = savedId(post),
                    category = post.category,
                    title = post.title,
                    content = post.content,
                    member = MemberResponse.MemberInfo.from(post.member, imageUrlResolver),
                    viewCount = post.viewCount,
                    commentCount = commentCount,
                    createdAt = post.createdAt,
                    updatedAt = post.updatedAt,
                )
        }
    }

    /** 커뮤니티 댓글. 작성·목록·수정에서 함께 쓴다. 목록에서는 일반 댓글 아래에 대댓글이 replies로 붙는다. */
    @Schema(name = "CommunityCommentInfo", description = "커뮤니티 댓글")
    data class CommentInfo(
        val id: Long,
        val postId: UUID,

        @field:Schema(description = "부모 댓글 ID. 일반 댓글이면 null", nullable = true)
        val parentId: Long?,

        @field:Schema(description = "삭제 여부. true면 content는 \"삭제된 댓글입니다\", member는 null")
        val deleted: Boolean,

        @field:Schema(description = "작성자. 삭제된 댓글은 null", nullable = true)
        val member: MemberResponse.MemberInfo?,

        @field:Schema(description = "댓글 내용. 삭제된 댓글은 \"삭제된 댓글입니다\"")
        val content: String,

        val createdAt: LocalDateTime?,
        val updatedAt: LocalDateTime?,

        @field:Schema(description = "대댓글. 오래된 순. 대댓글 자신과 작성·수정 응답에서는 빈 배열")
        val replies: List<CommentInfo>,
    ) {
        companion object {
            fun from(comment: CommunityComment, imageUrlResolver: ImageUrlResolver): CommentInfo =
                of(comment, emptyList(), imageUrlResolver)

            fun of(
                comment: CommunityComment,
                replies: List<CommunityComment>,
                imageUrlResolver: ImageUrlResolver,
            ): CommentInfo {
                val deleted = comment.isDeleted()
                return CommentInfo(
                    id = savedId(comment),
                    postId = savedId(comment.post),
                    parentId = comment.parent?.id,
                    deleted = deleted,
                    // 삭제된 댓글은 누가 무엇을 썼는지 내려주지 않는다.
                    member = if (deleted) null else MemberResponse.MemberInfo.from(comment.member, imageUrlResolver),
                    content = if (deleted) DELETED_COMMENT_CONTENT else comment.content,
                    createdAt = comment.createdAt,
                    updatedAt = comment.updatedAt,
                    replies = replies.map { from(it, imageUrlResolver) },
                )
            }
        }
    }

    companion object {
        /** 삭제된 댓글 자리에 내려주는 문구. */
        const val DELETED_COMMENT_CONTENT = "삭제된 댓글입니다"

        /** 응답은 저장된 글·댓글로만 만든다. 저장 전이면 id가 없으니 바로 알린다. */
        private fun savedId(post: CommunityPost): UUID =
            requireNotNull(post.id) { "저장되지 않은 커뮤니티 글은 응답으로 만들 수 없습니다." }

        private fun savedId(comment: CommunityComment): Long =
            requireNotNull(comment.id) { "저장되지 않은 커뮤니티 댓글은 응답으로 만들 수 없습니다." }
    }
}
