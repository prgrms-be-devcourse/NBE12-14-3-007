package com.team007.room_escape.domain.community.service

import com.team007.room_escape.domain.community.dto.CommunityRequest
import com.team007.room_escape.domain.community.infra.entity.CommunityPost
import com.team007.room_escape.domain.community.infra.repository.CommunityCommentRepository
import com.team007.room_escape.domain.community.infra.repository.CommunityPostRepository
import com.team007.room_escape.domain.community.type.CommunityCategory
import com.team007.room_escape.domain.member.infra.entity.Member
import com.team007.room_escape.domain.member.infra.entity.MemberRole
import com.team007.room_escape.domain.member.infra.repository.MemberRepository
import com.team007.room_escape.global.exception.BusinessException
import com.team007.room_escape.global.response.code.CommunityExceptionCode
import com.team007.room_escape.global.storage.ImageUrlResolver
import com.team007.room_escape.global.util.RichTextSanitizer
import org.assertj.core.api.Assertions.assertThat
import org.assertj.core.api.Assertions.assertThatThrownBy
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.extension.ExtendWith
import org.mockito.ArgumentCaptor
import org.mockito.ArgumentMatchers.any
import org.mockito.ArgumentMatchers.anyString
import org.mockito.InjectMocks
import org.mockito.Mock
import org.mockito.Mockito.verify
import org.mockito.Mockito.`when`
import org.mockito.junit.jupiter.MockitoExtension
import java.time.LocalDateTime
import java.util.Optional
import java.util.UUID

@ExtendWith(MockitoExtension::class)
class CommunityServiceTest {

    @field:Mock
    private lateinit var postRepository: CommunityPostRepository

    @field:Mock
    private lateinit var commentRepository: CommunityCommentRepository

    @field:Mock
    private lateinit var memberRepository: MemberRepository

    @field:Mock
    private lateinit var richTextSanitizer: RichTextSanitizer

    @field:Mock
    private lateinit var imageUrlResolver: ImageUrlResolver

    @field:InjectMocks
    private lateinit var communityService: CommunityService

    @Test
    fun 저장하기_전에_에디터_HTML을_정제한다() {
        val memberId = UUID.randomUUID()
        `when`(memberRepository.findByIdAndDeletedAtIsNull(memberId))
            .thenReturn(Optional.of(member(memberId)))
        `when`(richTextSanitizer.sanitize(any())).thenReturn("<p>안전한 내용</p>")
        `when`(richTextSanitizer.hasVisibleText(any())).thenReturn(true)
        val request = CommunityRequest.PostUpsert(
            CommunityCategory.FREE,
            "자유 이야기",
            "<script>위험</script><p>안전한 내용</p>"
        )

        communityService.createPost(request, memberId)

        val captor = ArgumentCaptor.forClass(CommunityPost::class.java)
        verify(postRepository).save(captor.capture())
        assertThat(captor.value.content).isEqualTo("<p>안전한 내용</p>")
    }

    @Test
    fun 작성자가_아니면_글을_수정할_수_없다() {
        val authorId = UUID.randomUUID()
        val otherId = UUID.randomUUID()
        `when`(memberRepository.findByIdAndDeletedAtIsNull(otherId))
            .thenReturn(Optional.of(member(otherId)))
        `when`(postRepository.findById(any()))
            .thenReturn(Optional.of(CommunityPost.builder().member(member(authorId)).build()))
        val request = CommunityRequest.PostUpsert(
            CommunityCategory.FREE,
            "수정할 제목",
            "<p>수정할 내용</p>"
        )

        assertThatThrownBy { communityService.updatePost(UUID.randomUUID(), request, otherId) }
            .isInstanceOfSatisfying(BusinessException::class.java) { exception ->
                assertThat(exception.exceptionCode).isEqualTo(CommunityExceptionCode.POST_FORBIDDEN)
            }
    }

    @Test
    fun 게시글은_30초_안에_연속으로_등록할_수_없다() {
        val memberId = UUID.randomUUID()
        `when`(memberRepository.findByIdAndDeletedAtIsNull(memberId))
            .thenReturn(Optional.of(member(memberId)))
        `when`(richTextSanitizer.sanitize(any())).thenReturn("<p>새 내용</p>")
        `when`(richTextSanitizer.hasVisibleText(any())).thenReturn(true)
        `when`(postRepository.existsByMemberIdAndCreatedAtAfter(any(), any())).thenReturn(true)

        assertThatThrownBy {
            communityService.createPost(
                CommunityRequest.PostUpsert(CommunityCategory.FREE, "새 제목", "<p>새 내용</p>"),
                memberId
            )
        }.isInstanceOfSatisfying(BusinessException::class.java) { exception ->
            assertThat(exception.exceptionCode).isEqualTo(CommunityExceptionCode.POST_CREATE_TOO_SOON)
        }
    }

    @Test
    fun 같은_게시글은_1분_안에_다시_등록할_수_없다() {
        val memberId = UUID.randomUUID()
        `when`(memberRepository.findByIdAndDeletedAtIsNull(memberId))
            .thenReturn(Optional.of(member(memberId)))
        `when`(richTextSanitizer.sanitize(any())).thenReturn("<p>같은 내용</p>")
        `when`(richTextSanitizer.hasVisibleText(any())).thenReturn(true)
        `when`(postRepository.existsByMemberIdAndContentAndCreatedAtAfter(any(), any(), any()))
            .thenReturn(true)

        assertThatThrownBy {
            communityService.createPost(
                CommunityRequest.PostUpsert(CommunityCategory.FREE, "같은 제목", "<p>같은 내용</p>"),
                memberId
            )
        }.isInstanceOfSatisfying(BusinessException::class.java) { exception ->
            assertThat(exception.exceptionCode).isEqualTo(CommunityExceptionCode.POST_DUPLICATE)
        }
    }

    @Test
    fun 댓글은_5초_안에_연속으로_등록할_수_없다() {
        val memberId = UUID.randomUUID()
        val postId = UUID.randomUUID()
        `when`(memberRepository.findByIdAndDeletedAtIsNull(memberId))
            .thenReturn(Optional.of(member(memberId)))
        `when`(postRepository.findById(postId))
            .thenReturn(Optional.of(CommunityPost.builder().member(member(UUID.randomUUID())).build()))
        // Mockito의 any()는 null을 반환하므로 Kotlin의 non-null 인자 검사를 통과할 대체값을 준다.
        // 실제 호출 비교에는 대체값이 아니라 any()로 등록한 매처가 사용된다.
        `when`(
            commentRepository.existsByMemberIdAndDeletedAtIsNullAndCreatedAtAfter(
                any(UUID::class.java) ?: UUID(0, 0),
                any(LocalDateTime::class.java) ?: LocalDateTime.MIN
            )
        ).thenReturn(true)

        assertThatThrownBy {
            communityService.createComment(postId, CommunityRequest.CommentCreate("새 댓글", null), memberId)
        }.isInstanceOfSatisfying(BusinessException::class.java) { exception ->
            assertThat(exception.exceptionCode).isEqualTo(CommunityExceptionCode.COMMENT_CREATE_TOO_SOON)
        }
    }

    @Test
    fun 같은_댓글은_1분_안에_다시_등록할_수_없다() {
        val memberId = UUID.randomUUID()
        val postId = UUID.randomUUID()
        `when`(memberRepository.findByIdAndDeletedAtIsNull(memberId))
            .thenReturn(Optional.of(member(memberId)))
        `when`(postRepository.findById(postId))
            .thenReturn(Optional.of(CommunityPost.builder().member(member(UUID.randomUUID())).build()))
        `when`(
            commentRepository.existsByMemberIdAndContentAndDeletedAtIsNullAndCreatedAtAfter(
                any(UUID::class.java) ?: UUID(0, 0),
                anyString(),
                any(LocalDateTime::class.java) ?: LocalDateTime.MIN
            )
        ).thenReturn(true)

        assertThatThrownBy {
            communityService.createComment(postId, CommunityRequest.CommentCreate("같은 댓글", null), memberId)
        }.isInstanceOfSatisfying(BusinessException::class.java) { exception ->
            assertThat(exception.exceptionCode).isEqualTo(CommunityExceptionCode.COMMENT_DUPLICATE)
        }
    }

    private fun member(id: UUID): Member = Member.builder()
        .id(id)
        .role(MemberRole.ROLE_UNVERIFIED)
        .nickname("이웃")
        .build()
}
