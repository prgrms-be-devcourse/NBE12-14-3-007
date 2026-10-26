package com.team007.room_escape.domain.comment.dto

import com.team007.room_escape.domain.comment.infra.entity.Comment
import com.team007.room_escape.domain.deletion.dto.DeletionHistoryResponse
import com.team007.room_escape.domain.deletion.infra.entity.DeletionHistory
import com.team007.room_escape.domain.member.dto.MemberResponse
import com.team007.room_escape.global.storage.ImageUrlResolver
import io.swagger.v3.oas.annotations.media.Schema
import java.time.LocalDateTime
import java.util.UUID

class CommentResponse private constructor() {

    @Schema(name = "AdminCommentInfo", description = "삭제된 댓글과 최신 삭제 사유를 포함한 관리자용 댓글")
    data class AdminInfo(
        val id: Long,
        val postId: UUID,
        val parentId: Long?,
        val member: MemberResponse.MemberInfo?,
        val content: String,
        val date: LocalDateTime?,
        val deletedAt: LocalDateTime?,
        val parentDeleted: Boolean,
        val deletion: DeletionHistoryResponse.Latest?,
        val replies: List<AdminInfo>,
    ) {
        companion object {

            fun from(
                comment: Comment,
                imageUrlResolver: ImageUrlResolver,
                parentDeleted: Boolean,
                history: DeletionHistory?,
                replies: List<AdminInfo>,
            ): AdminInfo = AdminInfo(
                id = savedId(comment),
                postId = savedPostId(comment),
                parentId = comment.parent?.id,
                member = MemberResponse.MemberInfo.from(comment.member, imageUrlResolver),
                content = comment.content,
                date = comment.createdAt,
                deletedAt = comment.deletedAt,
                parentDeleted = parentDeleted,
                deletion = history?.let { DeletionHistoryResponse.Latest.from(it) },
                replies = replies,
            )
        }
    }

    /** 댓글 응답. 작성·목록·수정에서 함께 쓴다. 목록에서는 일반 댓글 아래에 대댓글이 replies로 붙는다. */
    @Schema(name = "CommentInfo", description = "후기 댓글")
    data class Info(
        @field:Schema(description = "댓글 ID", example = "1")
        val id: Long,

        @field:Schema(description = "후기 ID")
        val postId: UUID,

        @field:Schema(description = "부모 댓글 ID. 일반 댓글이면 null", example = "1", nullable = true)
        val parentId: Long?,

        @field:Schema(description = "삭제 여부. true면 content는 \"삭제된 댓글입니다\", member는 null")
        val deleted: Boolean,

        @field:Schema(description = "작성자. 탈퇴 회원은 닉네임만 \"탈퇴한 사용자\", 삭제된 댓글은 null", nullable = true)
        val member: MemberResponse.MemberInfo?,

        @field:Schema(description = "댓글 내용. 삭제된 댓글은 \"삭제된 댓글입니다\"", example = "행사 정말 재미있었어요!")
        val content: String,

        @field:Schema(description = "댓글 작성 일시", example = "2026-09-16T12:30:00")
        val date: LocalDateTime?,

        @field:Schema(description = "대댓글. 오래된 순. 대댓글 자신과 작성·수정 응답에서는 빈 배열")
        val replies: List<Info>,
    ) {
        companion object {

            fun from(comment: Comment, imageUrlResolver: ImageUrlResolver): Info =
                of(comment, emptyList(), imageUrlResolver)

            fun of(comment: Comment, replies: List<Comment>, imageUrlResolver: ImageUrlResolver): Info {
                val deleted = comment.isDeleted()
                return Info(
                    id = savedId(comment),
                    postId = savedPostId(comment),
                    parentId = comment.parent?.id,
                    deleted = deleted,
                    // 삭제된 댓글은 누가 무엇을 썼는지 내려주지 않는다.
                    member = if (deleted) null else MemberResponse.MemberInfo.from(comment.member, imageUrlResolver),
                    content = if (deleted) DELETED_CONTENT else comment.content,
                    date = comment.createdAt,
                    replies = replies.map { from(it, imageUrlResolver) },
                )
            }
        }
    }

    companion object {
        /** 삭제된 댓글 자리에 내려주는 문구. */
        const val DELETED_CONTENT = "삭제된 댓글입니다"

        /** 응답은 저장된 댓글로만 만든다. 저장 전이면 id가 없으니 바로 알린다. */
        private fun savedId(comment: Comment): Long =
            requireNotNull(comment.id) { "저장되지 않은 댓글은 응답으로 만들 수 없습니다." }

        private fun savedPostId(comment: Comment): UUID =
            requireNotNull(comment.post.id) { "저장되지 않은 후기의 댓글은 응답으로 만들 수 없습니다." }
    }
}
