package com.team007.room_escape.domain.inquiry.service

import com.team007.room_escape.domain.comment.infra.repository.CommentRepository
import com.team007.room_escape.domain.community.infra.repository.CommunityCommentRepository
import com.team007.room_escape.domain.inquiry.dto.AdminInquiryRequest
import com.team007.room_escape.domain.inquiry.dto.AdminInquiryResponse
import com.team007.room_escape.domain.inquiry.infra.entity.Inquiry
import com.team007.room_escape.domain.inquiry.infra.entity.InquiryTargetType
import com.team007.room_escape.domain.inquiry.infra.repository.InquiryRepository
import com.team007.room_escape.global.exception.BusinessException
import com.team007.room_escape.global.response.code.CommonExceptionCode
import com.team007.room_escape.global.response.code.InquiryExceptionCode
import com.team007.room_escape.global.storage.ImageUrlResolver
import org.springframework.data.domain.Page
import org.springframework.data.domain.Pageable
import org.springframework.data.domain.Sort
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.util.UUID

@Service
class AdminInquiryService(
    private val inquiryRepository: InquiryRepository,
    private val commentRepository: CommentRepository,
    private val communityCommentRepository: CommunityCommentRepository,
    private val imageUrlResolver: ImageUrlResolver
) {

    /** 관리자 문의 검색. 조건을 비우면 전체를 조회한다. */
    @Transactional(readOnly = true)
    fun search(request: AdminInquiryRequest.Search, pageable: Pageable): Page<AdminInquiryResponse.ListItem> {
        validateSort(pageable.sort)

        return inquiryRepository.search(
            request.titleOrEmpty(),
            request.status,
            request.category,
            request.includeDeletedOrFalse(),
            pageable
        ).map { inquiry ->
            AdminInquiryResponse.ListItem.from(
                inquiry,
                inquiry.member?.let { imageUrlResolver.resolve(it.profileImg) }
            )
        }
    }

    /**
     * 관리자 문의 상세. 삭제된 문의도 열어볼 수 있다.
     */
    @Transactional(readOnly = true)
    fun findById(inquiryId: UUID): AdminInquiryResponse.Detail {
        return toDetail(findOrThrow(inquiryId))
    }

    /**
     * 관리자 답변을 등록한다. 이미 답변이 있으면 덮어쓴다.
     * 삭제된 문의에는 답변하지 않는다. 작성자가 이미 지운 글이라
     * 답변을 남겨도 작성자에게 보이지 않기 때문이다.
     */
    @Transactional
    fun answer(inquiryId: UUID, request: AdminInquiryRequest.Answer): AdminInquiryResponse.Detail {
        val inquiry = inquiryRepository.findForProcessing(inquiryId).orElse(null)
            ?: throw BusinessException(InquiryExceptionCode.INQUIRY_NOT_FOUND)

        if (inquiry.isDeleted()) {
            throw BusinessException(InquiryExceptionCode.INQUIRY_ALREADY_DELETED)
        }

        inquiry.answer(request.trimmed())

        return toDetail(inquiry)
    }

    private fun findOrThrow(inquiryId: UUID): Inquiry {
        return inquiryRepository.findDetailById(inquiryId).orElse(null)
            ?: throw BusinessException(InquiryExceptionCode.INQUIRY_NOT_FOUND)
    }

    /** 저장된 key를 공개 URL로 바꿔 채운다. 회원이 없으면 프로필 URL도 없다. */
    private fun toDetail(inquiry: Inquiry): AdminInquiryResponse.Detail {
        return AdminInquiryResponse.Detail.from(
            inquiry,
            imageUrlResolver.resolve(inquiry.img),
            inquiry.member?.let { imageUrlResolver.resolve(it.profileImg) },
            findCommentPostId(inquiry)
        )
    }

    /**
     * 댓글에는 따로 볼 화면이 없어서, 관리자가 신고된 댓글을 확인하려면 댓글이 달린 글로 가야 한다.
     * 후기 댓글이면 후기 ID, 커뮤니티 댓글이면 커뮤니티 글 ID를 돌려준다.
     * 목록은 한 번에 여러 건이라 상세에서만 조회한다.
     */
    private fun findCommentPostId(inquiry: Inquiry): UUID? {
        val type = inquiry.targetType
        if (type != InquiryTargetType.COMMENT && type != InquiryTargetType.COMMUNITY_COMMENT) {
            return null
        }
        try {
            val commentId = inquiry.targetId?.toLong() ?: return null
            return if (type == InquiryTargetType.COMMENT)
                commentRepository.findById(commentId)
                    .map { comment -> comment.post.id }
                    .orElse(null)
            else
                communityCommentRepository.findById(commentId)
                    .map { comment -> comment.post.id }
                    .orElse(null)
        } catch (e: NumberFormatException) {
            return null
        }
    }

    private fun validateSort(sort: Sort) {
        val hasUnknownField = sort.any { it.property !in SORTABLE }

        if (hasUnknownField) {
            throw BusinessException(CommonExceptionCode.INVALID_INPUT)
        }
    }

    companion object {
        private val SORTABLE: Set<String> = setOf("createdAt", "status", "category")
    }
}
