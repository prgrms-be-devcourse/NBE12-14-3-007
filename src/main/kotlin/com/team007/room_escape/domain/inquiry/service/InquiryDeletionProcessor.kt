package com.team007.room_escape.domain.inquiry.service

import com.team007.room_escape.domain.deletion.infra.entity.DeletionHistory
import com.team007.room_escape.domain.inquiry.infra.entity.InquiryCategory
import com.team007.room_escape.domain.inquiry.infra.entity.InquiryStatus
import com.team007.room_escape.domain.inquiry.infra.repository.InquiryRepository
import com.team007.room_escape.global.exception.BusinessException
import com.team007.room_escape.global.response.code.InquiryExceptionCode
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Propagation
import org.springframework.transaction.annotation.Transactional
import java.util.UUID

/** 콘텐츠 삭제 트랜잭션 안에서 연결된 신고 한 건만 처리한다. */
@Service
class InquiryDeletionProcessor(
    private val inquiries: InquiryRepository
) {

    @Transactional(propagation = Propagation.MANDATORY)
    fun complete(inquiryId: UUID, deletion: DeletionHistory) {
        val inquiry = inquiries.findForProcessing(inquiryId).orElse(null)
            ?: throw BusinessException(InquiryExceptionCode.INQUIRY_NOT_FOUND)
        if (inquiry.isDeleted()) {
            throw BusinessException(InquiryExceptionCode.INQUIRY_ALREADY_DELETED)
        }
        if (inquiry.isAnswered()) {
            throw BusinessException(InquiryExceptionCode.INQUIRY_ALREADY_ANSWERED)
        }
        val targetType = inquiry.targetType
        if (inquiry.category != InquiryCategory.REPORT || inquiry.status != InquiryStatus.PENDING
            || targetType == null
            || targetType.name != deletion.targetType.name
            || deletion.targetId != deletion.targetType.normalizeId(inquiry.targetId)
        ) {
            throw BusinessException(InquiryExceptionCode.INQUIRY_TARGET_MISMATCH)
        }
        var answer = "신고된 콘텐츠를 삭제했습니다. 사유: ${deletion.reason.description}"
        if (deletion.reasonDetail != null) {
            answer += " — ${deletion.reasonDetail}"
        }
        inquiry.answer(answer)
    }
}
