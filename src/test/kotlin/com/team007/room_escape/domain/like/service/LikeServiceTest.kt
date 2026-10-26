package com.team007.room_escape.domain.like.service

import com.team007.room_escape.domain.festival.infra.entity.Festival
import com.team007.room_escape.domain.festival.infra.entity.ProviderType
import com.team007.room_escape.domain.festival.infra.repository.FestivalRepository
import com.team007.room_escape.domain.like.infra.entity.Like
import com.team007.room_escape.domain.like.infra.repository.LikeRepository
import com.team007.room_escape.domain.member.infra.entity.Member
import com.team007.room_escape.domain.member.infra.entity.MemberRole
import com.team007.room_escape.domain.member.service.MemberReader
import com.team007.room_escape.domain.member.service.MemberTrustGradeService
import com.team007.room_escape.domain.post.infra.entity.Post
import com.team007.room_escape.domain.post.infra.repository.PostRepository
import com.team007.room_escape.global.exception.BusinessException
import com.team007.room_escape.global.exception.ExceptionCode
import com.team007.room_escape.global.response.code.FestivalExceptionCode
import com.team007.room_escape.global.response.code.LikeExceptionCode
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.assertThrows
import org.junit.jupiter.api.extension.ExtendWith
import org.mockito.ArgumentMatchers.any
import org.mockito.ArgumentMatchers.anyLong
import org.mockito.Mock
import org.mockito.Mockito.inOrder
import org.mockito.Mockito.never
import org.mockito.Mockito.verify
import org.mockito.Mockito.`when`
import org.mockito.junit.jupiter.MockitoExtension
import java.util.UUID

@ExtendWith(MockitoExtension::class)
class LikeServiceTest {

    @field:Mock private lateinit var likeRepository: LikeRepository
    @field:Mock private lateinit var postRepository: PostRepository
    @field:Mock private lateinit var festivalRepository: FestivalRepository
    @field:Mock private lateinit var memberReader: MemberReader
    @field:Mock private lateinit var memberTrustGradeService: MemberTrustGradeService

    private val likeService by lazy {
        LikeService(likeRepository, postRepository, festivalRepository, memberReader, memberTrustGradeService)
    }

    private val memberId: UUID = UUID.randomUUID()
    private val member: Member = Member(email = "member@test.com", password = "pw", role = MemberRole.ROLE_UNVERIFIED, nickname = "닉네임", id = memberId)
    private val postId: UUID = UUID.randomUUID()

    @Test
    @DisplayName("본인이 제보한 행사에는 좋아요를 등록할 수 없다")
    fun rejectSelfFestivalLike() {
        val festival = Festival(id = 1L, member = member, providerType = ProviderType.MEMBER)
        `when`(festivalRepository.findByIdAndDeletedAtIsNull(1L)).thenReturn(festival)
        `when`(memberReader.getUnrestrictedMember(memberId)).thenReturn(member)

        assertExceptionCode(LikeExceptionCode.SELF_FESTIVAL_LIKE_NOT_ALLOWED) {
            likeService.createFestivalLike(1L, memberId)
        }
        verify(likeRepository, never()).save(any(Like::class.java))
    }

    @Test
    @DisplayName("삭제된 행사에는 좋아요를 새로 등록할 수 없다")
    fun rejectLikeOnDeletedFestival() {
        `when`(festivalRepository.findByIdAndDeletedAtIsNull(1L)).thenReturn(null)
        `when`(memberReader.getUnrestrictedMember(memberId)).thenReturn(member)

        assertExceptionCode(FestivalExceptionCode.FESTIVAL_NOT_FOUND) {
            likeService.createFestivalLike(1L, memberId)
        }
        verify(likeRepository, never()).save(any(Like::class.java))
    }

    @Test
    @DisplayName("삭제된 행사의 좋아요 개수는 조회할 수 없다")
    fun rejectLikeCountOnDeletedFestival() {
        `when`(festivalRepository.existsByIdAndDeletedAtIsNull(1L)).thenReturn(false)

        assertExceptionCode(FestivalExceptionCode.FESTIVAL_NOT_FOUND) {
            likeService.getFestivalLikeCount(1L)
        }
        verify(likeRepository, never()).countByFestivalId(anyLong())
    }

    @Test
    @DisplayName("후기 좋아요를 등록하면 후기의 좋아요 수를 올리고 올라간 값을 돌려준다")
    fun createPostLikeIncreasesLikeCount() {
        `when`(memberReader.getUnrestrictedMember(memberId)).thenReturn(member)
        `when`(postRepository.findByIdAndDeletedAtIsNull(postId)).thenReturn(post())
        `when`(likeRepository.existsByPostIdAndMemberId(postId, memberId)).thenReturn(false)
        `when`(postRepository.findLikeCountById(postId)).thenReturn(3L)

        val response = likeService.createPostLike(postId, memberId)

        assertThat(response.likeCount).isEqualTo(3L)
        val order = inOrder(likeRepository, postRepository)
        order.verify(likeRepository).save(any(Like::class.java))
        order.verify(postRepository).increaseLikeCount(postId)
    }

    @Test
    @DisplayName("이미 좋아요한 후기면 좋아요 수를 바꾸지 않는다")
    fun duplicatePostLikeDoesNotChangeLikeCount() {
        `when`(memberReader.getUnrestrictedMember(memberId)).thenReturn(member)
        `when`(postRepository.findByIdAndDeletedAtIsNull(postId)).thenReturn(post())
        `when`(likeRepository.existsByPostIdAndMemberId(postId, memberId)).thenReturn(true)

        assertThrows<BusinessException> { likeService.createPostLike(postId, memberId) }

        verify(postRepository, never()).increaseLikeCount(anyValue())
    }

    @Test
    @DisplayName("후기 좋아요를 취소하면 후기의 좋아요 수를 내리고 내려간 값을 돌려준다")
    fun deletePostLikeDecreasesLikeCount() {
        val like = Like.of(post(), member)
        `when`(postRepository.existsById(postId)).thenReturn(true)
        `when`(likeRepository.findByPostIdAndMemberId(postId, memberId)).thenReturn(like)
        `when`(postRepository.findLikeCountById(postId)).thenReturn(2L)

        val response = likeService.deletePostLike(postId, memberId)

        assertThat(response.likeCount).isEqualTo(2L)
        val order = inOrder(likeRepository, postRepository)
        order.verify(likeRepository).delete(like)
        order.verify(postRepository).decreaseLikeCount(postId)
    }

    private fun post(): Post = Post(member = member, title = "후기", content = "내용")

    private fun assertExceptionCode(expected: ExceptionCode, action: () -> Unit) {
        val e = assertThrows<BusinessException> { action() }
        assertThat(e.exceptionCode).isEqualTo(expected)
    }

    /** Mockito any()는 null을 돌려줘서 Kotlin의 non-null 매개변수에 그대로 넣으면 NPE가 난다. 매처만 등록하고 타입을 맞춘다. */
    @Suppress("UNCHECKED_CAST")
    private fun <T> anyValue(): T {
        any<T>()
        return null as T
    }
}
