package com.team007.room_escape.domain.post.service

import com.team007.room_escape.domain.deletion.service.DeletionHistoryService
import com.team007.room_escape.domain.festival.infra.entity.Festival
import com.team007.room_escape.domain.festival.infra.entity.ProviderType
import com.team007.room_escape.domain.festival.infra.repository.FestivalRepository
import com.team007.room_escape.domain.like.infra.repository.LikeRepository
import com.team007.room_escape.domain.member.infra.entity.Member
import com.team007.room_escape.domain.member.infra.entity.MemberRole
import com.team007.room_escape.domain.member.service.MemberReader
import com.team007.room_escape.domain.post.dto.PostResponse
import com.team007.room_escape.domain.post.infra.entity.Post
import com.team007.room_escape.domain.post.infra.repository.PostRepository
import com.team007.room_escape.domain.post.type.PostSearchType
import com.team007.room_escape.global.storage.ImageUrlResolver
import com.team007.room_escape.global.storage.R2StorageService
import com.team007.room_escape.global.util.RichTextSanitizer
import org.assertj.core.api.Assertions.assertThat
import org.assertj.core.groups.Tuple.tuple
import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.extension.ExtendWith
import org.mockito.ArgumentMatchers.any
import org.mockito.ArgumentMatchers.anyLong
import org.mockito.Mock
import org.mockito.Mockito.`when`
import org.mockito.Mockito.never
import org.mockito.Mockito.verify
import org.mockito.Mockito.verifyNoInteractions
import org.mockito.junit.jupiter.MockitoExtension
import org.springframework.data.domain.Page
import org.springframework.data.domain.PageImpl
import org.springframework.data.domain.PageRequest
import org.springframework.data.domain.Pageable
import org.springframework.data.domain.Sort
import org.springframework.test.util.ReflectionTestUtils
import java.util.UUID

/**
 * 후기 목록의 정렬 분기와 좋아요 수(post.like_count) 응답을 검증한다.
 * 실제 정렬 결과는 LikeSortRepositoryTest 에서 DB로 확인한다.
 */
@ExtendWith(MockitoExtension::class)
class PostServiceTest {

    @field:Mock lateinit var postRepository: PostRepository
    @field:Mock lateinit var festivalRepository: FestivalRepository
    @field:Mock lateinit var memberReader: MemberReader
    @field:Mock lateinit var richTextSanitizer: RichTextSanitizer
    @field:Mock lateinit var likeRepository: LikeRepository
    @field:Mock lateinit var imageUrlResolver: ImageUrlResolver
    @field:Mock lateinit var r2StorageService: R2StorageService
    @field:Mock lateinit var deletionHistoryService: DeletionHistoryService

    private val postService by lazy {
        PostService(
            postRepository,
            festivalRepository,
            memberReader,
            richTextSanitizer,
            likeRepository,
            imageUrlResolver,
            r2StorageService,
            deletionHistoryService,
        )
    }

    @Test
    @DisplayName("좋아요순 검색이면 정렬을 뗀 페이지로 검색 전용 쿼리를 쓰고 검색 조건을 넘긴다")
    fun searchUsesLikeSortQuery() {
        val post = post(likeCount = 4)
        `when`(postRepository.searchPostsOrderByLikeCount("MEMBER_NICKNAME", "닉", UNSORTED))
            .thenReturn(PageImpl(listOf(post), UNSORTED, 13))

        val result = postService.searchPosts(PostSearchType.MEMBER_NICKNAME, "닉", LIKE_SORT)

        assertThat(result.content.map { it.likeCount }).containsExactly(4L)
        assertThat(result.totalElements).isEqualTo(13)
        verify(postRepository, never()).searchPosts(anyValue(), anyValue(), anyValue())
        verify(postRepository, never()).findAllNotDeleted(anyValue())
        verify(postRepository, never()).findAllOrderByLikeCount(anyValue())
    }

    @Test
    @DisplayName("검색어가 비어 있으면 좋아요순 전체 목록으로 조회한다 (조인 없는 개수 쿼리)")
    fun blankKeywordFallsBackToAllPosts() {
        `when`(postRepository.findAllOrderByLikeCount(UNSORTED)).thenReturn(Page.empty(UNSORTED))

        val result = postService.searchPosts(PostSearchType.TITLE, "  ", LIKE_SORT)

        assertThat(result.content).isEmpty()
        verify(postRepository, never()).searchPostsOrderByLikeCount(anyValue(), anyValue(), anyValue())
        // 좋아요 수는 post 에 있으므로 like 테이블을 따로 세지 않는다
        verifyNoInteractions(likeRepository)
    }

    @Test
    @DisplayName("행사별 좋아요순이면 행사 조건으로 전용 쿼리를 쓴다")
    fun festivalPostsUseLikeSortQuery() {
        val post = post(likeCount = 0)
        `when`(postRepository.findAllByFestivalIdOrderByLikeCount(3L, UNSORTED))
            .thenReturn(PageImpl(listOf(post), UNSORTED, 1))

        val result = postService.getPostsByFestival(3L, LIKE_SORT)

        assertThat(result.content.map { it.likeCount }).containsExactly(0L)
        verify(postRepository, never()).findAllByFestivalId(anyLong(), anyValue())
    }

    @Test
    @DisplayName("최신순은 기존 쿼리를 그대로 쓰고, 좋아요 수는 후기에 저장된 값을 쓴다")
    fun latestSortKeepsExistingQuery() {
        val latest = PageRequest.of(0, 6, Sort.by(Sort.Direction.DESC, "createdAt"))
        val first = post(likeCount = 0)
        val second = post(likeCount = 2)
        `when`(postRepository.findAllNotDeleted(latest))
            .thenReturn(PageImpl(listOf(first, second), latest, 2))

        val result = postService.searchPosts(null, null, latest)

        assertThat(result.content)
            .extracting(PostResponse.ListItem::id, PostResponse.ListItem::likeCount)
            .containsExactly(tuple(first.id, 0L), tuple(second.id, 2L))
        verify(postRepository, never()).findAllOrderByLikeCount(anyValue())
        verify(postRepository, never()).searchPostsOrderByLikeCount(anyValue(), anyValue(), anyValue())
        verifyNoInteractions(likeRepository)
    }

    @Test
    @DisplayName("상세 응답에 후기에 저장된 좋아요 수와 내가 눌렀는지를 함께 담는다")
    fun detailIncludesLikeCount() {
        val post = post(likeCount = 7)
        val postId = checkNotNull(post.id)
        val memberId = UUID.randomUUID()
        `when`(postRepository.findByIdAndDeletedAtIsNull(postId)).thenReturn(post)
        `when`(likeRepository.existsByPostIdAndMemberId(postId, memberId)).thenReturn(true)

        val result = postService.getPostDetail(postId, memberId)

        assertThat(result.likeCount).isEqualTo(7L)
        assertThat(result.likedByMe).isTrue()
    }

    @Test
    @DisplayName("비회원 상세 조회도 좋아요 수는 보이고, 누른 여부는 묻지 않는다")
    fun guestDetailIncludesLikeCount() {
        val post = post(likeCount = 3)
        val postId = checkNotNull(post.id)
        `when`(postRepository.findByIdAndDeletedAtIsNull(postId)).thenReturn(post)

        val result = postService.getPostDetail(postId, null)

        assertThat(result.likeCount).isEqualTo(3L)
        assertThat(result.likedByMe).isFalse()
        verifyNoInteractions(likeRepository)
    }

    /** DB에서 읽어 온 후기처럼 id와 좋아요 수를 채운다. 둘 다 DB가 정하는 값이라 생성자로 받지 않는다. */
    private fun post(likeCount: Long): Post {
        val member = Member(
            email = "a@test.local",
            password = "x",
            role = MemberRole.ROLE_UNVERIFIED,
            nickname = "닉네임",
            id = UUID.randomUUID(),
        )
        val festival = Festival.builder().id(3L).providerType(ProviderType.PUBLIC).title("행사").build()
        return Post(member = member, festival = festival, title = "후기", content = "내용").apply {
            ReflectionTestUtils.setField(this, "id", UUID.randomUUID())
            ReflectionTestUtils.setField(this, "likeCount", likeCount)
        }
    }


    /** Mockito any()는 null을 돌려줘서 Kotlin의 non-null 매개변수에 그대로 넣으면 NPE가 난다. 매처만 등록하고 타입을 맞춘다. */
    @Suppress("UNCHECKED_CAST")
    private fun <T> anyValue(): T {
        any<T>()
        return null as T
    }
    companion object {
        private val LIKE_SORT: Pageable = PageRequest.of(2, 6, Sort.by(Sort.Direction.DESC, "likeCount"))
        private val UNSORTED: Pageable = PageRequest.of(2, 6)
    }
}
