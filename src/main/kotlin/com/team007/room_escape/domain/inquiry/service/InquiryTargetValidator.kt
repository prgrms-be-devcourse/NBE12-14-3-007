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
    private val communityCommentRepository: CommunityCommentRepository
) {

    /** 대상이 없는 일반 문의는 통과시킨다. */
    fun validate(type: InquiryTargetType?, targetId: String?) {
        if (type == null) {
            return
        }

        val exists = when (type) {
            InquiryTargetType.FESTIVAL -> festivalRepository.existsByIdAndDeletedAtIsNull(parseLong(targetId))
            InquiryTargetType.POST -> postRepository.existsByIdAndDeletedAtIsNull(parseUuid(targetId))
            // 커뮤니티 글은 @SQLRestriction으로 삭제된 행이 자동으로 빠진다.
            InquiryTargetType.COMMENT -> commentRepository.existsByIdAndDeletedAtIsNull(parseLong(targetId))
            InquiryTargetType.MEMBER -> memberRepository.existsByIdAndDeletedAtIsNull(parseUuid(targetId))
            InquiryTargetType.COMMUNITY_POST -> communityPostRepository.existsById(parseUuid(targetId))
            InquiryTargetType.COMMUNITY_COMMENT ->
                communityCommentRepository.existsByIdAndDeletedAtIsNull(parseLong(targetId))
        }

        if (!exists) {
            throw targetNotFound()
        }
    }

    private fun parseLong(targetId: String?): Long {
        // Java에서는 targetId가 null이면 trim()에서 NPE가 났다. 같은 시점에 예외를 낸다.
        requireNotNull(targetId)
        try {
            return java.lang.Long.valueOf(targetId.trim())
        } catch (e: NumberFormatException) {
            throw targetNotFound()
        }
    }

    private fun parseUuid(targetId: String?): UUID {
        requireNotNull(targetId)
        try {
            return UUID.fromString(targetId.trim())
        } catch (e: IllegalArgumentException) {
            throw targetNotFound()
        }
    }

    private fun targetNotFound(): BusinessException {
        return BusinessException(InquiryExceptionCode.INQUIRY_TARGET_NOT_FOUND)
    }
}
