package com.team007.room_escape.domain.inquiry.service

import com.team007.room_escape.domain.comment.infra.entity.Comment
import com.team007.room_escape.domain.comment.infra.repository.CommentRepository
import com.team007.room_escape.domain.community.infra.entity.CommunityComment
import com.team007.room_escape.domain.community.infra.entity.CommunityPost
import com.team007.room_escape.domain.community.infra.repository.CommunityCommentRepository
import com.team007.room_escape.domain.inquiry.dto.AdminInquiryRequest
import com.team007.room_escape.domain.inquiry.infra.entity.Inquiry
import com.team007.room_escape.domain.inquiry.infra.entity.InquiryCategory
import com.team007.room_escape.domain.inquiry.infra.entity.InquiryStatus
import com.team007.room_escape.domain.inquiry.infra.entity.InquiryTargetType
import com.team007.room_escape.domain.inquiry.infra.repository.InquiryRepository
import com.team007.room_escape.domain.member.infra.entity.Member
import com.team007.room_escape.domain.member.infra.entity.MemberRole
import com.team007.room_escape.domain.post.infra.entity.Post
import com.team007.room_escape.global.config.R2Properties
import com.team007.room_escape.global.exception.BusinessException
import com.team007.room_escape.global.response.code.CommonExceptionCode
import com.team007.room_escape.global.response.code.InquiryExceptionCode
import com.team007.room_escape.global.storage.ImageUrlResolver
import org.assertj.core.api.Assertions.assertThat
import org.assertj.core.api.Assertions.assertThatThrownBy
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test
import org.mockito.Mockito.mock
import org.mockito.Mockito.`when`
import org.springframework.data.domain.PageImpl
import org.springframework.data.domain.PageRequest
import org.springframework.data.domain.Sort
import org.springframework.test.util.ReflectionTestUtils
import java.util.Optional
import java.util.UUID

class AdminInquiryServiceTest {

    private val inquiryRepository = mock(InquiryRepository::class.java)
    private val commentRepository = mock(CommentRepository::class.java)
    private val communityCommentRepository = mock(CommunityCommentRepository::class.java)
    private val imageUrlResolver =
        ImageUrlResolver(R2Properties("account", "access", "secret", "bucket", "https://img.example.com"))
    private val service =
        AdminInquiryService(inquiryRepository, commentRepository, communityCommentRepository, imageUrlResolver)

    private val inquiryId = UUID.randomUUID()
    private val member: Member = Member.builder()
        .email("a@example.com").password("pw").nickname("작성자").role(MemberRole.ROLE_UNVERIFIED)
        .profileImg("profiles/a.png").build()
        .also { ReflectionTestUtils.setField(it, "id", UUID.randomUUID()) }

    private fun stored(
        category: InquiryCategory = InquiryCategory.QUESTION,
        targetType: InquiryTargetType? = null,
        targetId: String? = null,
        owner: Member? = member,
    ) = Inquiry(
        id = inquiryId, member = owner, category = category, title = "제목", content = "내용",
        targetType = targetType, targetId = targetId, img = "inquiries/x.png", status = InquiryStatus.PENDING,
    )

    private fun org.assertj.core.api.AbstractThrowableAssert<*, *>.isBusiness(code: Enum<*>) {
        isInstanceOfSatisfying(BusinessException::class.java) {
            assertThat(it.exceptionCode).isEqualTo(code)
        }
    }

    @Nested
    inner class `검색` {

        private fun search(title: String? = null, includeDeleted: Boolean? = null) =
            AdminInquiryRequest.Search(title, InquiryStatus.PENDING, InquiryCategory.REPORT, includeDeleted)

        @Test
        fun `정렬 가능한 필드는 createdAt status category뿐이다`() {
            val pageable = PageRequest.of(0, 20, Sort.by("createdAt", "status", "category"))
            `when`(inquiryRepository.search("취소", InquiryStatus.PENDING, InquiryCategory.REPORT, false, pageable))
                .thenReturn(PageImpl(listOf(stored()), pageable, 1))

            assertThat(service.search(search("  취소 "), pageable).content).hasSize(1)
        }

        @Test
        fun `정렬 필드가 허용 목록에 없으면 잘못된 입력이다`() {
            assertThatThrownBy { service.search(search(), PageRequest.of(0, 20, Sort.by("title"))) }
                .isBusiness(CommonExceptionCode.INVALID_INPUT)
        }

        @Test
        fun `조건을 정리해서 저장소에 넘기고 작성자 프로필은 공개 URL로 바꾼다`() {
            val pageable = PageRequest.of(0, 20)
            `when`(inquiryRepository.search("abc", InquiryStatus.PENDING, InquiryCategory.REPORT, true, pageable))
                .thenReturn(PageImpl(listOf(stored()), pageable, 1))

            val page = service.search(search("  ABC ", includeDeleted = true), pageable)

            assertThat(page.content.single().writer?.profileImg).isEqualTo("https://img.example.com/profiles/a.png")
        }

        @Test
        fun `작성자가 없는 문의는 작성자 없이 내려간다`() {
            val pageable = PageRequest.of(0, 20)
            `when`(inquiryRepository.search("", InquiryStatus.PENDING, InquiryCategory.REPORT, false, pageable))
                .thenReturn(PageImpl(listOf(stored(owner = null)), pageable, 1))

            assertThat(service.search(search(), pageable).content.single().writer).isNull()
        }
    }

    @Nested
    inner class `상세` {

        @Test
        fun `삭제 여부와 상관없이 상세를 돌려주고 첨부와 프로필을 공개 URL로 바꾼다`() {
            `when`(inquiryRepository.findDetailById(inquiryId)).thenReturn(stored())

            val detail = service.findById(inquiryId)

            assertThat(detail.img).isEqualTo("https://img.example.com/inquiries/x.png")
            assertThat(detail.writer?.profileImg).isEqualTo("https://img.example.com/profiles/a.png")
            assertThat(detail.targetPostId).isNull()
        }

        @Test
        fun `없는 문의는 찾을 수 없다`() {
            `when`(inquiryRepository.findDetailById(inquiryId)).thenReturn(null)

            assertThatThrownBy { service.findById(inquiryId) }.isBusiness(InquiryExceptionCode.INQUIRY_NOT_FOUND)
        }

        @Test
        fun `후기 댓글 신고면 댓글이 달린 후기 ID를 함께 돌려준다`() {
            val postId = UUID.randomUUID()
            val post = mock(Post::class.java).also { `when`(it.id).thenReturn(postId) }
            `when`(inquiryRepository.findDetailById(inquiryId))
                .thenReturn(stored(InquiryCategory.REPORT, InquiryTargetType.COMMENT, "7"))
            `when`(commentRepository.findById(7L)).thenReturn(Optional.of(Comment(post, member, null, "댓글")))

            assertThat(service.findById(inquiryId).targetPostId).isEqualTo(postId)
        }

        @Test
        fun `커뮤니티 댓글 신고면 커뮤니티 글 ID를 돌려준다`() {
            val postId = UUID.randomUUID()
            val post = mock(CommunityPost::class.java).also { `when`(it.id).thenReturn(postId) }
            `when`(inquiryRepository.findDetailById(inquiryId))
                .thenReturn(stored(InquiryCategory.REPORT, InquiryTargetType.COMMUNITY_COMMENT, "8"))
            `when`(communityCommentRepository.findById(8L))
                .thenReturn(Optional.of(CommunityComment(post, member, null, "댓글")))

            assertThat(service.findById(inquiryId).targetPostId).isEqualTo(postId)
        }

        @Test
        fun `댓글이 없거나 ID가 숫자가 아니거나 댓글 신고가 아니면 null이다`() {
            `when`(inquiryRepository.findDetailById(inquiryId))
                .thenReturn(stored(InquiryCategory.REPORT, InquiryTargetType.COMMENT, "7"))
            `when`(commentRepository.findById(7L)).thenReturn(Optional.empty())
            assertThat(service.findById(inquiryId).targetPostId).isNull()

            `when`(inquiryRepository.findDetailById(inquiryId))
                .thenReturn(stored(InquiryCategory.REPORT, InquiryTargetType.COMMENT, "abc"))
            assertThat(service.findById(inquiryId).targetPostId).isNull()

            `when`(inquiryRepository.findDetailById(inquiryId))
                .thenReturn(stored(InquiryCategory.REPORT, InquiryTargetType.POST, "7"))
            assertThat(service.findById(inquiryId).targetPostId).isNull()
        }
    }

    @Nested
    inner class `답변` {

        @Test
        fun `앞뒤 공백을 지운 답변을 달고 답변 완료로 바꾼다`() {
            val inquiry = stored()
            `when`(inquiryRepository.findForProcessing(inquiryId)).thenReturn(inquiry)

            val detail = service.answer(inquiryId, AdminInquiryRequest.Answer("  확인했습니다  "))

            assertThat(inquiry.answer).isEqualTo("확인했습니다")
            assertThat(inquiry.status).isEqualTo(InquiryStatus.ANSWERED)
            assertThat(detail.answer).isEqualTo("확인했습니다")
        }

        @Test
        fun `이미 답변이 있으면 덮어쓴다`() {
            val inquiry = stored().also { it.answer("첫 답변") }
            `when`(inquiryRepository.findForProcessing(inquiryId)).thenReturn(inquiry)

            service.answer(inquiryId, AdminInquiryRequest.Answer("고친 답변"))

            assertThat(inquiry.answer).isEqualTo("고친 답변")
        }

        @Test
        fun `없는 문의에는 답변할 수 없다`() {
            `when`(inquiryRepository.findForProcessing(inquiryId)).thenReturn(null)

            assertThatThrownBy { service.answer(inquiryId, AdminInquiryRequest.Answer("답")) }
                .isBusiness(InquiryExceptionCode.INQUIRY_NOT_FOUND)
        }

        @Test
        fun `삭제된 문의에는 답변하지 않는다`() {
            val inquiry = stored().also { it.delete() }
            `when`(inquiryRepository.findForProcessing(inquiryId)).thenReturn(inquiry)

            assertThatThrownBy { service.answer(inquiryId, AdminInquiryRequest.Answer("답")) }
                .isBusiness(InquiryExceptionCode.INQUIRY_ALREADY_DELETED)
            assertThat(inquiry.answer).isNull()
        }
    }
}
