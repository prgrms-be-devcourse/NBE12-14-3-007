package com.team007.room_escape.domain.inquiry.infra.entity

import com.team007.room_escape.domain.member.infra.entity.Member
import com.team007.room_escape.domain.member.infra.entity.MemberRole
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test
import org.springframework.test.util.ReflectionTestUtils
import java.util.UUID

class InquiryTest {

    private val writerId = UUID.randomUUID()
    private val writer: Member = Member.builder()
        .email("a@example.com").password("pw").nickname("작성자").role(MemberRole.ROLE_UNVERIFIED).build()
        .also { ReflectionTestUtils.setField(it, "id", writerId) }

    private fun inquiry(
        category: InquiryCategory = InquiryCategory.QUESTION,
        targetType: InquiryTargetType? = null,
        targetId: String? = null,
        img: String? = null,
        answer: String? = null,
        status: InquiryStatus? = InquiryStatus.PENDING,
        member: Member? = writer,
    ): Inquiry = Inquiry.builder()
        .member(member).category(category).targetType(targetType).targetId(targetId)
        .title("제목").content("내용").img(img).answer(answer).status(status)
        .build()

    @Nested
    inner class `작성자 확인` {

        @Test
        fun `작성자 ID와 같을 때만 본인 글이다`() {
            val inquiry = inquiry()

            assertThat(inquiry.isWrittenBy(writerId)).isTrue()
            assertThat(inquiry.isWrittenBy(UUID.randomUUID())).isFalse()
        }

        @Test
        fun `작성자 정보가 없는 옛 문의는 누구의 글도 아니다`() {
            assertThat(inquiry(member = null).isWrittenBy(writerId)).isFalse()
        }
    }

    @Nested
    inner class `답변 여부` {

        @Test
        fun `상태가 답변 완료면 답변이 달린 것이다`() {
            assertThat(inquiry(status = InquiryStatus.ANSWERED).isAnswered()).isTrue()
        }

        @Test
        fun `상태가 대기여도 답변 내용이 있으면 답변이 달린 것이다`() {
            assertThat(inquiry(status = InquiryStatus.PENDING, answer = "처리했습니다").isAnswered()).isTrue()
        }

        @Test
        fun `답변이 없거나 공백뿐이면 답변이 달리지 않은 것이다`() {
            assertThat(inquiry(answer = null).isAnswered()).isFalse()
            assertThat(inquiry(answer = "").isAnswered()).isFalse()
            assertThat(inquiry(answer = "  \n\t ").isAnswered()).isFalse()
        }

        @Test
        fun `NBSP만 있는 답변은 Java isBlank와 같게 내용이 있는 것으로 본다`() {
            assertThat(inquiry(answer = " ").isAnswered()).isTrue()
        }
    }

    @Test
    fun `답변을 달면 내용과 상태가 함께 바뀌고 다시 달면 덮어쓴다`() {
        val inquiry = inquiry()

        inquiry.answer("첫 답변")
        assertThat(inquiry.answer).isEqualTo("첫 답변")
        assertThat(inquiry.status).isEqualTo(InquiryStatus.ANSWERED)

        inquiry.answer("고친 답변")
        assertThat(inquiry.answer).isEqualTo("고친 답변")
        assertThat(inquiry.status).isEqualTo(InquiryStatus.ANSWERED)
    }

    @Nested
    inner class `수정` {

        @Test
        fun `보낸 값만 바꾸고 null인 값은 건드리지 않는다`() {
            val inquiry = inquiry(category = InquiryCategory.REPORT, img = "inquiries/a.png")

            inquiry.update(null, "새 제목", null, null)

            assertThat(inquiry.title).isEqualTo("새 제목")
            assertThat(inquiry.content).isEqualTo("내용")
            assertThat(inquiry.category).isEqualTo(InquiryCategory.REPORT)
            assertThat(inquiry.img).isEqualTo("inquiries/a.png")
        }

        @Test
        fun `제목과 내용이 공백뿐이면 바꾸지 않는다`() {
            val inquiry = inquiry()

            inquiry.update(null, "   ", "\n", null)

            assertThat(inquiry.title).isEqualTo("제목")
            assertThat(inquiry.content).isEqualTo("내용")
        }

        @Test
        fun `일반 문의로 바꾸면 신고 대상을 지운다`() {
            val inquiry = inquiry(category = InquiryCategory.REPORT, targetType = InquiryTargetType.POST, targetId = "abc")

            inquiry.update(InquiryCategory.QUESTION, null, null, null)

            assertThat(inquiry.category).isEqualTo(InquiryCategory.QUESTION)
            assertThat(inquiry.targetType).isNull()
            assertThat(inquiry.targetId).isNull()
        }

        @Test
        fun `신고나 제보로 바꿀 때는 기존 대상을 그대로 둔다`() {
            val inquiry = inquiry(category = InquiryCategory.REPORT, targetType = InquiryTargetType.POST, targetId = "abc")

            inquiry.update(InquiryCategory.TIP, null, null, null)

            assertThat(inquiry.category).isEqualTo(InquiryCategory.TIP)
            assertThat(inquiry.targetType).isEqualTo(InquiryTargetType.POST)
            assertThat(inquiry.targetId).isEqualTo("abc")
        }

        @Test
        fun `첨부는 값을 주면 바꾸고 빈 문자열이면 지운다`() {
            val inquiry = inquiry(img = "inquiries/a.png")

            inquiry.update(null, null, null, "inquiries/b.png")
            assertThat(inquiry.img).isEqualTo("inquiries/b.png")

            inquiry.update(null, null, null, "")
            assertThat(inquiry.img).isNull()
        }
    }

    @Test
    fun `카테고리 제목 내용 없이는 만들 수 없다`() {
        org.assertj.core.api.Assertions.assertThatThrownBy {
            Inquiry.builder().title("제목").content("내용").build()
        }.isInstanceOf(IllegalArgumentException::class.java).hasMessageContaining("category")
    }
}
