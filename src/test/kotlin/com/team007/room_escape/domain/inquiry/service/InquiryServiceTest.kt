package com.team007.room_escape.domain.inquiry.service

import com.team007.room_escape.domain.inquiry.dto.InquiryRequest
import com.team007.room_escape.domain.inquiry.infra.entity.Inquiry
import com.team007.room_escape.domain.inquiry.infra.entity.InquiryCategory
import com.team007.room_escape.domain.inquiry.infra.entity.InquiryStatus
import com.team007.room_escape.domain.inquiry.infra.entity.InquiryTargetType
import com.team007.room_escape.domain.inquiry.infra.repository.InquiryRepository
import com.team007.room_escape.domain.member.infra.entity.Member
import com.team007.room_escape.domain.member.infra.entity.MemberRole
import com.team007.room_escape.domain.member.service.MemberReader
import com.team007.room_escape.global.config.R2Properties
import com.team007.room_escape.global.exception.BusinessException
import com.team007.room_escape.global.response.code.InquiryExceptionCode
import com.team007.room_escape.global.storage.ImageUrlResolver
import com.team007.room_escape.global.storage.R2StorageService
import org.assertj.core.api.Assertions.assertThat
import org.assertj.core.api.Assertions.assertThatThrownBy
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test
import org.mockito.ArgumentCaptor
import org.mockito.ArgumentMatchers.any
import org.mockito.Mockito.mock
import org.mockito.Mockito.never
import org.mockito.Mockito.verify
import org.mockito.Mockito.`when`
import org.springframework.test.util.ReflectionTestUtils
import java.util.Optional
import java.util.UUID

class InquiryServiceTest {

    private val inquiryRepository = mock(InquiryRepository::class.java)
    private val memberReader = mock(MemberReader::class.java)
    private val targetValidator = mock(InquiryTargetValidator::class.java)
    private val r2StorageService = mock(R2StorageService::class.java)
    private val imageUrlResolver =
        ImageUrlResolver(R2Properties("account", "access", "secret", "bucket", "https://img.example.com"))
    private val service =
        InquiryService(inquiryRepository, memberReader, targetValidator, imageUrlResolver, r2StorageService)

    private val memberId = UUID.randomUUID()
    private val inquiryId = UUID.randomUUID()
    private val member: Member = Member.builder()
        .email("a@example.com").password("pw").nickname("작성자").role(MemberRole.ROLE_UNVERIFIED).build()
        .also { ReflectionTestUtils.setField(it, "id", memberId) }

    private fun stored(
        owner: Member? = member,
        category: InquiryCategory = InquiryCategory.QUESTION,
        img: String? = null,
        answer: String? = null,
        status: InquiryStatus? = InquiryStatus.PENDING,
    ): Inquiry = Inquiry.builder()
        .id(inquiryId).member(owner).category(category).title("제목").content("내용")
        .img(img).answer(answer).status(status).build()

    private fun org.assertj.core.api.AbstractThrowableAssert<*, *>.isBusiness(code: InquiryExceptionCode) {
        isInstanceOfSatisfying(BusinessException::class.java) {
            assertThat(it.exceptionCode).isEqualTo(code)
        }
    }

    @Nested
    inner class `등록` {

        private fun request(
            targetType: InquiryTargetType? = null,
            targetId: String? = null,
            img: String? = null,
        ) = InquiryRequest.Create(InquiryCategory.REPORT, targetType, targetId, "제목", "내용", img)

        private fun saved(): Inquiry {
            val captor = ArgumentCaptor.forClass(Inquiry::class.java)
            verify(inquiryRepository).save(captor.capture())
            return captor.value
        }

        private fun stubSave() {
            `when`(memberReader.getActiveMember(memberId)).thenReturn(member)
            `when`(inquiryRepository.save(any(Inquiry::class.java))).thenAnswer { it.arguments[0] }
        }

        @Test
        fun `대기 상태로 저장하고 응답에는 첨부의 공개 URL을 담는다`() {
            stubSave()

            val response = service.create(memberId, request(img = "inquiries/$memberId/a.png"))

            val inquiry = saved()
            assertThat(inquiry.member).isSameAs(member)
            assertThat(inquiry.status).isEqualTo(InquiryStatus.PENDING)
            assertThat(inquiry.title).isEqualTo("제목")
            assertThat(response.img).isEqualTo("https://img.example.com/inquiries/$memberId/a.png")
        }

        @Test
        fun `대상을 검증하고 첨부가 본인 것인지 확인한다`() {
            stubSave()

            service.create(memberId, request(InquiryTargetType.POST, "post-id", "inquiries/$memberId/a.png"))

            verify(targetValidator).validate(InquiryTargetType.POST, "post-id")
            verify(r2StorageService).requireOwnedBy("inquiries/$memberId/a.png", null, memberId)
        }

        @Test
        fun `빈 문자열 대상 ID와 첨부는 null로 저장한다`() {
            stubSave()

            service.create(memberId, request(InquiryTargetType.POST, "", ""))

            val inquiry = saved()
            assertThat(inquiry.targetId).isNull()
            assertThat(inquiry.img).isNull()
        }

        @Test
        fun `대상이 없으면 저장하지 않는다`() {
            `when`(memberReader.getActiveMember(memberId)).thenReturn(member)
            `when`(targetValidator.validate(InquiryTargetType.POST, "none"))
                .thenThrow(BusinessException(InquiryExceptionCode.INQUIRY_TARGET_NOT_FOUND))

            assertThatThrownBy { service.create(memberId, request(InquiryTargetType.POST, "none")) }
                .isBusiness(InquiryExceptionCode.INQUIRY_TARGET_NOT_FOUND)
            verify(inquiryRepository, never()).save(any(Inquiry::class.java))
        }
    }

    @Nested
    inner class `조회` {

        @Test
        fun `내 문의 목록을 저장소가 돌려준 순서 그대로 항목으로 바꾼다`() {
            `when`(inquiryRepository.findAllByMember_IdAndDeletedAtIsNullOrderByCreatedAtDesc(memberId))
                .thenReturn(listOf(stored(), stored()))

            val list = service.findMine(memberId)

            assertThat(list).hasSize(2)
            assertThat(list.map { it.title }).containsOnly("제목")
        }

        @Test
        fun `내 문의 상세를 첨부 공개 URL과 함께 돌려준다`() {
            `when`(inquiryRepository.findByIdAndDeletedAtIsNull(inquiryId))
                .thenReturn(Optional.of(stored(img = "inquiries/a.png")))

            val detail = service.findMineById(inquiryId, memberId)

            assertThat(detail.id).isEqualTo(inquiryId)
            assertThat(detail.img).isEqualTo("https://img.example.com/inquiries/a.png")
        }

        @Test
        fun `없는 문의와 남의 문의는 같은 오류로 가린다`() {
            `when`(inquiryRepository.findByIdAndDeletedAtIsNull(inquiryId)).thenReturn(Optional.empty())
            assertThatThrownBy { service.findMineById(inquiryId, memberId) }.isBusiness(InquiryExceptionCode.INQUIRY_NOT_FOUND)

            `when`(inquiryRepository.findByIdAndDeletedAtIsNull(inquiryId)).thenReturn(Optional.of(stored()))
            assertThatThrownBy { service.findMineById(inquiryId, UUID.randomUUID()) }
                .isBusiness(InquiryExceptionCode.INQUIRY_NOT_FOUND)
        }
    }

    @Nested
    inner class `수정` {

        private fun stubFound(inquiry: Inquiry) {
            `when`(inquiryRepository.findForProcessing(inquiryId)).thenReturn(Optional.of(inquiry))
        }

        private fun update(title: String? = "새 제목", img: String? = null) =
            InquiryRequest.Update(null, title, null, img)

        @Test
        fun `작성자는 보낸 값만 수정한다`() {
            stubFound(stored())

            val detail = service.update(inquiryId, memberId, update())

            assertThat(detail.title).isEqualTo("새 제목")
            assertThat(detail.content).isEqualTo("내용")
        }

        @Test
        fun `없거나 삭제된 문의는 찾을 수 없다`() {
            `when`(inquiryRepository.findForProcessing(inquiryId)).thenReturn(Optional.empty())
            assertThatThrownBy { service.update(inquiryId, memberId, update()) }.isBusiness(InquiryExceptionCode.INQUIRY_NOT_FOUND)

            stubFound(stored().also { it.delete() })
            assertThatThrownBy { service.update(inquiryId, memberId, update()) }.isBusiness(InquiryExceptionCode.INQUIRY_NOT_FOUND)
        }

        @Test
        fun `작성자가 아니면 수정할 수 없고 관리자도 예외가 아니다`() {
            stubFound(stored())

            assertThatThrownBy { service.update(inquiryId, UUID.randomUUID(), update()) }
                .isBusiness(InquiryExceptionCode.INQUIRY_UPDATE_FORBIDDEN)
        }

        @Test
        fun `답변이 달린 뒤에는 수정할 수 없다`() {
            stubFound(stored(answer = "처리했습니다", status = InquiryStatus.ANSWERED))

            assertThatThrownBy { service.update(inquiryId, memberId, update()) }
                .isBusiness(InquiryExceptionCode.INQUIRY_ALREADY_ANSWERED)
        }

        @Test
        fun `첨부를 바꾸면 새 첨부의 주인을 확인하고 옛 첨부를 지운다`() {
            stubFound(stored(img = "inquiries/$memberId/old.png"))

            service.update(inquiryId, memberId, update(img = "inquiries/$memberId/new.png"))

            verify(r2StorageService).requireOwnedBy("inquiries/$memberId/new.png", "inquiries/$memberId/old.png", memberId)
            verify(r2StorageService).deleteOwnedBy("inquiries/$memberId/old.png", memberId)
        }

        @Test
        fun `첨부를 비우면 옛 첨부를 지운다`() {
            stubFound(stored(img = "inquiries/$memberId/old.png"))

            val detail = service.update(inquiryId, memberId, update(img = ""))

            assertThat(detail.img).isNull()
            verify(r2StorageService).deleteOwnedBy("inquiries/$memberId/old.png", memberId)
        }

        @Test
        fun `첨부를 안 건드리거나 같은 값이면 지우지 않는다`() {
            stubFound(stored(img = "inquiries/$memberId/same.png"))

            service.update(inquiryId, memberId, update(img = null))
            service.update(inquiryId, memberId, update(img = "inquiries/$memberId/same.png"))

            verify(r2StorageService, never()).deleteOwnedBy("inquiries/$memberId/same.png", memberId)
        }
    }

    @Nested
    inner class `삭제` {

        @Test
        fun `작성자는 삭제한다`() {
            val inquiry = stored()
            `when`(inquiryRepository.findForProcessing(inquiryId)).thenReturn(Optional.of(inquiry))

            service.delete(inquiryId, memberId, false)

            assertThat(inquiry.isDeleted()).isTrue()
        }

        @Test
        fun `관리자는 남의 문의도 삭제한다`() {
            val inquiry = stored()
            `when`(inquiryRepository.findForProcessing(inquiryId)).thenReturn(Optional.of(inquiry))

            service.delete(inquiryId, UUID.randomUUID(), true)

            assertThat(inquiry.isDeleted()).isTrue()
        }

        @Test
        fun `작성자도 관리자도 아니면 삭제할 수 없다`() {
            val inquiry = stored()
            `when`(inquiryRepository.findForProcessing(inquiryId)).thenReturn(Optional.of(inquiry))

            assertThatThrownBy { service.delete(inquiryId, UUID.randomUUID(), false) }
                .isBusiness(InquiryExceptionCode.INQUIRY_DELETE_FORBIDDEN)
            assertThat(inquiry.isDeleted()).isFalse()
        }

        @Test
        fun `없거나 이미 삭제된 문의는 찾을 수 없다`() {
            `when`(inquiryRepository.findForProcessing(inquiryId)).thenReturn(Optional.empty())
            assertThatThrownBy { service.delete(inquiryId, memberId, false) }.isBusiness(InquiryExceptionCode.INQUIRY_NOT_FOUND)

            `when`(inquiryRepository.findForProcessing(inquiryId)).thenReturn(Optional.of(stored().also { it.delete() }))
            assertThatThrownBy { service.delete(inquiryId, memberId, true) }.isBusiness(InquiryExceptionCode.INQUIRY_NOT_FOUND)
        }
    }
}
