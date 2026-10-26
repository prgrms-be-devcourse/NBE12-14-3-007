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
import org.assertj.core.api.Assertions.assertThat
import org.assertj.core.api.Assertions.assertThatCode
import org.assertj.core.api.Assertions.assertThatThrownBy
import org.junit.jupiter.api.Test
import org.mockito.Mockito.mock
import org.mockito.Mockito.`when`
import java.util.UUID

class InquiryTargetValidatorTest {

    private val festivals = mock(FestivalRepository::class.java)
    private val posts = mock(PostRepository::class.java)
    private val comments = mock(CommentRepository::class.java)
    private val members = mock(MemberRepository::class.java)
    private val communityPosts = mock(CommunityPostRepository::class.java)
    private val communityComments = mock(CommunityCommentRepository::class.java)
    private val validator =
        InquiryTargetValidator(festivals, posts, comments, members, communityPosts, communityComments)

    private val uuid = UUID.randomUUID()

    private fun org.assertj.core.api.AbstractThrowableAssert<*, *>.isTargetNotFound() {
        isInstanceOfSatisfying(BusinessException::class.java) {
            assertThat(it.exceptionCode).isEqualTo(InquiryExceptionCode.INQUIRY_TARGET_NOT_FOUND)
        }
    }

    @Test
    fun `대상이 없는 일반 문의는 그대로 통과한다`() {
        assertThatCode { validator.validate(null, null) }.doesNotThrowAnyException()
        assertThatCode { validator.validate(null, "아무 값") }.doesNotThrowAnyException()
    }

    @Test
    fun `행사 대상은 삭제되지 않은 행사가 있어야 한다`() {
        `when`(festivals.existsByIdAndDeletedAtIsNull(12L)).thenReturn(true)

        assertThatCode { validator.validate(InquiryTargetType.FESTIVAL, "12") }.doesNotThrowAnyException()
        assertThatThrownBy { validator.validate(InquiryTargetType.FESTIVAL, "13") }.isTargetNotFound()
    }

    @Test
    fun `후기 대상은 UUID로 삭제되지 않은 후기를 찾는다`() {
        `when`(posts.existsByIdAndDeletedAtIsNull(uuid)).thenReturn(true)

        assertThatCode { validator.validate(InquiryTargetType.POST, uuid.toString()) }.doesNotThrowAnyException()
        assertThatThrownBy { validator.validate(InquiryTargetType.POST, UUID.randomUUID().toString()) }.isTargetNotFound()
    }

    @Test
    fun `후기 댓글 대상은 숫자 ID로 찾는다`() {
        `when`(comments.existsByIdAndDeletedAtIsNull(5L)).thenReturn(true)

        assertThatCode { validator.validate(InquiryTargetType.COMMENT, "5") }.doesNotThrowAnyException()
        assertThatThrownBy { validator.validate(InquiryTargetType.COMMENT, "6") }.isTargetNotFound()
    }

    @Test
    fun `회원 대상은 탈퇴하지 않은 회원이 있어야 한다`() {
        `when`(members.existsByIdAndDeletedAtIsNull(uuid)).thenReturn(true)

        assertThatCode { validator.validate(InquiryTargetType.MEMBER, uuid.toString()) }.doesNotThrowAnyException()
        assertThatThrownBy { validator.validate(InquiryTargetType.MEMBER, UUID.randomUUID().toString()) }.isTargetNotFound()
    }

    @Test
    fun `커뮤니티 글 대상은 UUID로 찾는다`() {
        `when`(communityPosts.existsById(uuid)).thenReturn(true)

        assertThatCode { validator.validate(InquiryTargetType.COMMUNITY_POST, uuid.toString()) }.doesNotThrowAnyException()
        assertThatThrownBy { validator.validate(InquiryTargetType.COMMUNITY_POST, UUID.randomUUID().toString()) }.isTargetNotFound()
    }

    @Test
    fun `커뮤니티 댓글 대상은 숫자 ID로 찾는다`() {
        `when`(communityComments.existsByIdAndDeletedAtIsNull(9L)).thenReturn(true)

        assertThatCode { validator.validate(InquiryTargetType.COMMUNITY_COMMENT, "9") }.doesNotThrowAnyException()
        assertThatThrownBy { validator.validate(InquiryTargetType.COMMUNITY_COMMENT, "10") }.isTargetNotFound()
    }

    @Test
    fun `ID 앞뒤 공백은 무시한다`() {
        `when`(festivals.existsByIdAndDeletedAtIsNull(12L)).thenReturn(true)
        `when`(posts.existsByIdAndDeletedAtIsNull(uuid)).thenReturn(true)

        assertThatCode { validator.validate(InquiryTargetType.FESTIVAL, " 12 ") }.doesNotThrowAnyException()
        assertThatCode { validator.validate(InquiryTargetType.POST, "  $uuid ") }.doesNotThrowAnyException()
    }

    @Test
    fun `ID 형식이 틀리면 대상을 찾을 수 없다고 알린다`() {
        assertThatThrownBy { validator.validate(InquiryTargetType.FESTIVAL, "abc") }.isTargetNotFound()
        assertThatThrownBy { validator.validate(InquiryTargetType.COMMENT, "") }.isTargetNotFound()
        assertThatThrownBy { validator.validate(InquiryTargetType.POST, "not-a-uuid") }.isTargetNotFound()
        assertThatThrownBy { validator.validate(InquiryTargetType.MEMBER, "123") }.isTargetNotFound()
    }

    @Test
    fun `대상 종류만 있고 ID가 없으면 예외를 던진다`() {
        // Java 시절 trim()에서 NPE가 나던 시점과 같은 곳에서 실패한다.
        assertThatThrownBy { validator.validate(InquiryTargetType.FESTIVAL, null) }
            .isInstanceOf(RuntimeException::class.java)
    }
}
