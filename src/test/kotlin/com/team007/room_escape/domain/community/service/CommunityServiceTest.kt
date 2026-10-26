package com.team007.room_escape.domain.community.service

import com.team007.room_escape.domain.community.dto.CommunityRequest
import com.team007.room_escape.domain.community.infra.entity.CommunityPost
import com.team007.room_escape.domain.community.infra.repository.CommunityCommentRepository
import com.team007.room_escape.domain.community.infra.repository.CommunityPostRepository
import com.team007.room_escape.domain.community.type.CommunityCategory
import com.team007.room_escape.domain.deletion.service.DeletionHistoryService
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
import org.mockito.Mock
import org.mockito.Mockito.verify
import org.mockito.Mockito.`when`
import org.mockito.junit.jupiter.MockitoExtension
import org.springframework.test.util.ReflectionTestUtils
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

    @field:Mock
    private lateinit var deletionHistoryService: DeletionHistoryService

    private val communityService by lazy {
        CommunityService(
            postRepository, commentRepository, memberRepository,
            richTextSanitizer, imageUrlResolver, deletionHistoryService,
        )
    }

    @Test
    fun 저장하기_전에_에디터_HTML을_정제한다() {
        val memberId = UUID.randomUUID()
        givenActiveMember(memberId)
        `when`(richTextSanitizer.sanitize(anyValue())).thenReturn("<p>안전한 내용</p>")
        `when`(richTextSanitizer.hasVisibleText(anyValue())).thenReturn(true)
        // 저장하면 DB가 id를 채운다.
        `when`(postRepository.save(any(CommunityPost::class.java))).thenAnswer { invocation ->
            invocation.getArgument<CommunityPost>(0).also { ReflectionTestUtils.setField(it, "id", UUID.randomUUID()) }
        }
        val request = CommunityRequest.PostUpsert(
            CommunityCategory.FREE,
            "자유 이야기",
            "<script>위험</script><p>안전한 내용</p>",
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
        givenActiveMember(otherId)
        `when`(postRepository.findWithMemberById(anyValue())).thenReturn(post(author = member(authorId)))
        val request = CommunityRequest.PostUpsert(
            CommunityCategory.FREE,
            "수정할 제목",
            "<p>수정할 내용</p>",
        )

        assertThatThrownBy { communityService.updatePost(UUID.randomUUID(), request, otherId) }
            .isInstanceOfSatisfying(BusinessException::class.java) { exception ->
                assertThat(exception.exceptionCode).isEqualTo(CommunityExceptionCode.POST_FORBIDDEN)
            }
    }

    @Test
    fun 게시글은_30초_안에_연속으로_등록할_수_없다() {
        val memberId = UUID.randomUUID()
        givenActiveMember(memberId)
        `when`(richTextSanitizer.sanitize(anyValue())).thenReturn("<p>새 내용</p>")
        `when`(richTextSanitizer.hasVisibleText(anyValue())).thenReturn(true)
        `when`(postRepository.existsByMemberIdAndCreatedAtAfter(anyValue(), anyValue())).thenReturn(true)

        assertThatThrownBy {
            communityService.createPost(
                CommunityRequest.PostUpsert(CommunityCategory.FREE, "새 제목", "<p>새 내용</p>"),
                memberId,
            )
        }.isInstanceOfSatisfying(BusinessException::class.java) { exception ->
            assertThat(exception.exceptionCode).isEqualTo(CommunityExceptionCode.POST_CREATE_TOO_SOON)
        }
    }

    @Test
    fun 같은_게시글은_1분_안에_다시_등록할_수_없다() {
        val memberId = UUID.randomUUID()
        givenActiveMember(memberId)
        `when`(richTextSanitizer.sanitize(anyValue())).thenReturn("<p>같은 내용</p>")
        `when`(richTextSanitizer.hasVisibleText(anyValue())).thenReturn(true)
        `when`(postRepository.existsByMemberIdAndContentAndCreatedAtAfter(anyValue(), anyValue(), anyValue()))
            .thenReturn(true)

        assertThatThrownBy {
            communityService.createPost(
                CommunityRequest.PostUpsert(CommunityCategory.FREE, "같은 제목", "<p>같은 내용</p>"),
                memberId,
            )
        }.isInstanceOfSatisfying(BusinessException::class.java) { exception ->
            assertThat(exception.exceptionCode).isEqualTo(CommunityExceptionCode.POST_DUPLICATE)
        }
    }

    @Test
    fun 없는_글에는_댓글을_달거나_댓글을_조회할_수_없다() {
        val memberId = UUID.randomUUID()
        val postId = UUID.randomUUID()
        givenActiveMember(memberId)
        `when`(postRepository.findWithMemberById(postId)).thenReturn(null)

        assertThatThrownBy {
            communityService.createComment(postId, CommunityRequest.CommentCreate("새 댓글", null), memberId)
        }.isInstanceOfSatisfying(BusinessException::class.java) { exception ->
            assertThat(exception.exceptionCode).isEqualTo(CommunityExceptionCode.POST_NOT_FOUND)
        }
        assertThatThrownBy {
            communityService.getComments(postId, org.springframework.data.domain.PageRequest.of(0, 10))
        }.isInstanceOfSatisfying(BusinessException::class.java) { exception ->
            assertThat(exception.exceptionCode).isEqualTo(CommunityExceptionCode.POST_NOT_FOUND)
        }
    }

    @Test
    fun 댓글은_5초_안에_연속으로_등록할_수_없다() {
        val memberId = UUID.randomUUID()
        val postId = UUID.randomUUID()
        givenActiveMember(memberId)
        `when`(postRepository.findWithMemberById(postId)).thenReturn(post(author = member(UUID.randomUUID())))
        `when`(commentRepository.existsByMemberIdAndDeletedAtIsNullAndCreatedAtAfter(anyValue(), anyValue()))
            .thenReturn(true)

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
        givenActiveMember(memberId)
        `when`(postRepository.findWithMemberById(postId)).thenReturn(post(author = member(UUID.randomUUID())))
        `when`(
            commentRepository.existsByMemberIdAndContentAndDeletedAtIsNullAndCreatedAtAfter(
                anyValue(), anyValue(), anyValue(),
            )
        ).thenReturn(true)

        assertThatThrownBy {
            communityService.createComment(postId, CommunityRequest.CommentCreate("같은 댓글", null), memberId)
        }.isInstanceOfSatisfying(BusinessException::class.java) { exception ->
            assertThat(exception.exceptionCode).isEqualTo(CommunityExceptionCode.COMMENT_DUPLICATE)
        }
    }

    private fun givenActiveMember(id: UUID) {
        `when`(memberRepository.findByIdAndDeletedAtIsNull(id)).thenReturn(member(id))
    }

    private fun member(id: UUID): Member = Member(
        email = "member@test.com",
        password = "pw",
        role = MemberRole.ROLE_UNVERIFIED,
        nickname = "이웃",
        id = id,
    )

    private fun post(author: Member): CommunityPost =
        CommunityPost(member = author, category = CommunityCategory.FREE, title = "기존 제목", content = "<p>기존 내용</p>")

    /** Mockito any()는 null을 돌려줘서 Kotlin의 non-null 매개변수에 그대로 넣으면 NPE가 난다. 매처만 등록하고 타입을 맞춘다. */
    @Suppress("UNCHECKED_CAST")
    private fun <T> anyValue(): T {
        any<T>()
        return null as T
    }
}
