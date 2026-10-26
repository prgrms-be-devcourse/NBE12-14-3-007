package com.team007.room_escape.domain.inquiry.service

import com.team007.room_escape.domain.deletion.infra.entity.DeletionHistory
import com.team007.room_escape.domain.deletion.infra.entity.DeletionReason
import com.team007.room_escape.domain.deletion.infra.entity.DeletionTargetType
import com.team007.room_escape.domain.inquiry.infra.entity.Inquiry
import com.team007.room_escape.domain.inquiry.infra.entity.InquiryCategory
import com.team007.room_escape.domain.inquiry.infra.entity.InquiryStatus
import com.team007.room_escape.domain.inquiry.infra.entity.InquiryTargetType
import com.team007.room_escape.domain.inquiry.infra.repository.InquiryRepository
import com.team007.room_escape.global.exception.BusinessException
import com.team007.room_escape.global.response.code.InquiryExceptionCode
import org.assertj.core.api.Assertions.assertThat
import org.assertj.core.api.Assertions.assertThatThrownBy
import org.junit.jupiter.api.Test
import org.mockito.Mockito.mock
import org.mockito.Mockito.`when`
import java.util.UUID

class InquiryDeletionProcessorTest {

    private val inquiries = mock(InquiryRepository::class.java)
    private val processor = InquiryDeletionProcessor(inquiries)

    private val inquiryId = UUID.randomUUID()

    private fun report(
        category: InquiryCategory = InquiryCategory.REPORT,
        targetType: InquiryTargetType? = InquiryTargetType.POST,
        targetId: String? = "7f1e3c6e-1111-4222-8333-444455556666",
        status: InquiryStatus? = InquiryStatus.PENDING,
        answer: String? = null,
    ) = Inquiry(
        id = inquiryId, member = null, category = category, title = "신고", content = "내용",
        targetType = targetType, targetId = targetId, status = status, answer = answer,
    )

    private fun deletion(
        type: DeletionTargetType = DeletionTargetType.POST,
        id: String = "7f1e3c6e-1111-4222-8333-444455556666",
        reason: DeletionReason = DeletionReason.values().first(),
        detail: String? = null,
    ): DeletionHistory = mock(DeletionHistory::class.java).also {
        `when`(it.targetType).thenReturn(type)
        `when`(it.targetId).thenReturn(id)
        `when`(it.reason).thenReturn(reason)
        `when`(it.reasonDetail).thenReturn(detail)
    }

    private fun org.assertj.core.api.AbstractThrowableAssert<*, *>.isBusiness(code: InquiryExceptionCode) {
        isInstanceOfSatisfying(BusinessException::class.java) {
            assertThat(it.exceptionCode).isEqualTo(code)
        }
    }

    private fun stub(inquiry: Inquiry?) {
        `when`(inquiries.findForProcessing(inquiryId)).thenReturn(inquiry)
    }

    @Test
    fun `신고 대상과 삭제 대상이 같으면 삭제 사유를 담아 답변 완료로 바꾼다`() {
        val inquiry = report()
        stub(inquiry)
        val reason = DeletionReason.values().first()

        processor.complete(inquiryId, deletion(reason = reason))

        assertThat(inquiry.status).isEqualTo(InquiryStatus.ANSWERED)
        assertThat(inquiry.answer).isEqualTo("신고된 콘텐츠를 삭제했습니다. 사유: ${reason.description}")
    }

    @Test
    fun `상세 사유가 있으면 답변 끝에 덧붙인다`() {
        val inquiry = report()
        stub(inquiry)
        val reason = DeletionReason.values().first()

        processor.complete(inquiryId, deletion(reason = reason, detail = "광고성 게시물"))

        assertThat(inquiry.answer).isEqualTo("신고된 콘텐츠를 삭제했습니다. 사유: ${reason.description} — 광고성 게시물")
    }

    @Test
    fun `대상 ID는 형식을 맞춘 뒤 비교한다`() {
        val inquiry = report(targetType = InquiryTargetType.FESTIVAL, targetId = " 12 ")
        stub(inquiry)

        processor.complete(inquiryId, deletion(DeletionTargetType.FESTIVAL, "12"))

        assertThat(inquiry.status).isEqualTo(InquiryStatus.ANSWERED)
    }

    @Test
    fun `없는 문의는 찾을 수 없다`() {
        stub(null)

        assertThatThrownBy { processor.complete(inquiryId, deletion()) }.isBusiness(InquiryExceptionCode.INQUIRY_NOT_FOUND)
    }

    @Test
    fun `삭제된 문의는 처리하지 않는다`() {
        stub(report().also { it.delete() })

        assertThatThrownBy { processor.complete(inquiryId, deletion()) }.isBusiness(InquiryExceptionCode.INQUIRY_ALREADY_DELETED)
    }

    @Test
    fun `이미 답변된 문의는 처리하지 않는다`() {
        stub(report(status = InquiryStatus.ANSWERED, answer = "처리함"))

        assertThatThrownBy { processor.complete(inquiryId, deletion()) }.isBusiness(InquiryExceptionCode.INQUIRY_ALREADY_ANSWERED)
    }

    @Test
    fun `신고가 아니거나 대상 종류가 다르거나 대상 ID가 다르면 불일치다`() {
        val mismatches = listOf(
            report(category = InquiryCategory.TIP) to deletion(),
            report(category = InquiryCategory.QUESTION, targetType = null, targetId = null) to deletion(),
            report(targetType = null, targetId = null) to deletion(),
            report(targetType = InquiryTargetType.COMMENT, targetId = "3") to deletion(),
            report(targetId = "7f1e3c6e-1111-4222-8333-444455556666") to
                deletion(id = "00000000-0000-4000-8000-000000000000"),
        )

        mismatches.forEach { (inquiry, history) ->
            stub(inquiry)
            assertThatThrownBy { processor.complete(inquiryId, history) }.isBusiness(InquiryExceptionCode.INQUIRY_TARGET_MISMATCH)
            assertThat(inquiry.answer).isNull()
        }
    }
}
