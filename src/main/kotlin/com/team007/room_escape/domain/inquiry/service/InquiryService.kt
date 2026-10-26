package com.team007.room_escape.domain.inquiry.service

import com.team007.room_escape.domain.inquiry.dto.InquiryRequest
import com.team007.room_escape.domain.inquiry.dto.InquiryResponse
import com.team007.room_escape.domain.inquiry.infra.entity.Inquiry
import com.team007.room_escape.domain.inquiry.infra.repository.InquiryRepository
import com.team007.room_escape.domain.member.service.MemberReader
import com.team007.room_escape.global.exception.BusinessException
import com.team007.room_escape.global.response.code.InquiryExceptionCode
import com.team007.room_escape.global.storage.ImageUrlResolver
import com.team007.room_escape.global.storage.R2StorageService
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.util.UUID

@Service
class InquiryService(
    private val inquiryRepository: InquiryRepository,
    private val memberReader: MemberReader,
    private val targetValidator: InquiryTargetValidator,
    private val imageUrlResolver: ImageUrlResolver,
    private val r2StorageService: R2StorageService,
) {

    /** 문의 등록. 로그인한 회원이면 등급과 상관없이 쓸 수 있다. */
    @Transactional
    fun create(memberId: UUID, request: InquiryRequest.Create): InquiryResponse.Detail {
        val member = memberReader.getActiveMember(memberId)
        targetValidator.validate(request.targetType, request.targetId)
        r2StorageService.requireOwnedBy(request.img, null, memberId)
        r2StorageService.confirmImages(memberId, attachments = arrayOf(request.img))

        val saved = inquiryRepository.save(request.toEntity(member))

        return toDetail(saved)
    }

    /** 내 문의 목록. 최신순. */
    @Transactional(readOnly = true)
    fun findMine(memberId: UUID): List<InquiryResponse.ListItem> =
        inquiryRepository.findAllByMemberIdAndDeletedAtIsNullOrderByCreatedAtDesc(memberId)
            .map { InquiryResponse.ListItem.from(it) }

    /** 내 문의 상세. 남의 문의는 존재를 숨기려고 404로 응답한다. */
    @Transactional(readOnly = true)
    fun findMineById(inquiryId: UUID, memberId: UUID): InquiryResponse.Detail {
        val inquiry = inquiryRepository.findByIdAndDeletedAtIsNull(inquiryId)
            ?.takeIf { it.isWrittenBy(memberId) }
            ?: throw BusinessException(InquiryExceptionCode.INQUIRY_NOT_FOUND)

        return toDetail(inquiry)
    }

    /** 문의 수정. 답변이 달린 뒤에는 수정할 수 없다. */
    @Transactional
    fun update(inquiryId: UUID, memberId: UUID, request: InquiryRequest.Update): InquiryResponse.Detail {
        val inquiry = findActiveForProcessing(inquiryId)

        // 수정은 관리자도 불가.
        if (!inquiry.isWrittenBy(memberId)) throw BusinessException(InquiryExceptionCode.INQUIRY_UPDATE_FORBIDDEN)
        if (inquiry.isAnswered()) throw BusinessException(InquiryExceptionCode.INQUIRY_ALREADY_ANSWERED)

        r2StorageService.requireOwnedBy(request.img, inquiry.img, memberId)
        r2StorageService.confirmImages(memberId, attachments = arrayOf(request.img))

        val previousImg = inquiry.img
        inquiry.update(request.category, request.title, request.content, request.img)

        deleteReplacedImage(previousImg, inquiry.img, memberId)

        return toDetail(inquiry)
    }

    /** 문의 삭제. 작성자 본인과 관리자가 삭제할 수 있다. */
    @Transactional
    fun delete(inquiryId: UUID, memberId: UUID, isAdmin: Boolean) {
        val inquiry = findActiveForProcessing(inquiryId)

        if (!inquiry.isWrittenBy(memberId) && !isAdmin) {
            throw BusinessException(InquiryExceptionCode.INQUIRY_DELETE_FORBIDDEN)
        }

        inquiry.delete()
    }

    /** 수정·삭제처럼 값을 바꾸는 작업용. 행을 잠그고 가져오며, 삭제된 문의는 없는 것으로 본다. */
    private fun findActiveForProcessing(inquiryId: UUID): Inquiry =
        inquiryRepository.findForProcessing(inquiryId)?.takeUnless { it.isDeleted() }
            ?: throw BusinessException(InquiryExceptionCode.INQUIRY_NOT_FOUND)

    private fun toDetail(inquiry: Inquiry) = InquiryResponse.Detail.from(inquiry, imageUrlResolver.resolve(inquiry.img))

    /** 교체된 옛 첨부를 R2에서 지운다. */
    private fun deleteReplacedImage(previousKey: String?, currentKey: String?, memberId: UUID) {
        if (previousKey == null || previousKey == currentKey) return
        r2StorageService.deleteOwnedBy(previousKey, memberId)
    }
}
