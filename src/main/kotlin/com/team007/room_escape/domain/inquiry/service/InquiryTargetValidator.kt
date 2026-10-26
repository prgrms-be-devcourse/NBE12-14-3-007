package com.team007.room_escape.domain.inquiry.service

import com.team007.room_escape.domain.comment.infra.repository.CommentRepository
import com.team007.room_escape.domain.community.infra.repository.CommunityCommentRepository
import com.team007.room_escape.domain.community.infra.repository.CommunityPostRepository
import com.team007.room_escape.domain.festival.infra.repository.FestivalRepository
import com.team007.room_escape.domain.inquiry.infra.entity.InquiryTargetType
import com.team007.room_escape.domain.member.infra.repository.MemberRepository
import com.team007.room_escape.domain.post.infra.repository.PostRepository
import com.team007.room_escape.global.exception.BusinessException
import com.team007.room_escape.global.response.code.InquiryExceptionCode
import org.springframework.stereotype.Component
import java.util.UUID

/** 신고·제보 대상이 실제로 있는지 확인한다. targetId는 FK가 아니라 직접 확인해야 한다. */
@Component
class InquiryTargetValidator(
    private val festivalRepository: FestivalRepository,
    private val postRepository: PostRepository,
    private val commentRepository: CommentRepository,
    private val memberRepository: MemberRepository,
    private val communityPostRepository: CommunityPostRepository,
    private val communityCommentRepository: CommunityCommentRepository,
) {

    /** 대상이 없는 일반 문의는 통과시킨다. */
    fun validate(type: InquiryTargetType?, targetId: String?) {
        if (type == null) return

        val exists = when (type) {
            InquiryTargetType.FESTIVAL -> festivalRepository.existsByIdAndDeletedAtIsNull(targetId.asLong())
            InquiryTargetType.POST -> postRepository.existsByIdAndDeletedAtIsNull(targetId.asUuid())
            // 커뮤니티 글은 @SQLRestriction으로 삭제된 행이 자동으로 빠진다.
            InquiryTargetType.COMMENT -> commentRepository.existsByIdAndDeletedAtIsNull(targetId.asLong())
            InquiryTargetType.MEMBER -> memberRepository.existsByIdAndDeletedAtIsNull(targetId.asUuid())
            InquiryTargetType.COMMUNITY_POST -> communityPostRepository.existsById(targetId.asUuid())
            InquiryTargetType.COMMUNITY_COMMENT ->
                communityCommentRepository.existsByIdAndDeletedAtIsNull(targetId.asLong())
        }

        if (!exists) throw targetNotFound()
    }

    // 대상 종류가 있는데 ID가 없는 요청은 요청 검증이 먼저 막는다. 여기까지 오면 프로그래밍 오류다.
    // Java String.trim()과 같은 기준(U+0020 이하)으로 자른다.
    private fun String?.asLong(): Long =
        requireNotNull(this).trim { it <= ' ' }.toLongOrNull() ?: throw targetNotFound()

    private fun String?.asUuid(): UUID {
        val text = requireNotNull(this).trim { it <= ' ' }
        return try {
            UUID.fromString(text)
        } catch (e: IllegalArgumentException) {
            throw targetNotFound()
        }
    }

    private fun targetNotFound() = BusinessException(InquiryExceptionCode.INQUIRY_TARGET_NOT_FOUND)
}
