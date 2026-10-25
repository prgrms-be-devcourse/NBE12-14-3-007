package com.team007.room_escape.domain.post.service

import com.team007.room_escape.domain.deletion.infra.entity.DeletionTargetType
import com.team007.room_escape.domain.deletion.service.DeletionHistoryService
import com.team007.room_escape.domain.festival.infra.repository.FestivalRepository
import com.team007.room_escape.domain.like.infra.repository.LikeRepository
import com.team007.room_escape.domain.like.type.LikeSort
import com.team007.room_escape.domain.member.service.MemberReader
import com.team007.room_escape.domain.post.dto.PostRequest
import com.team007.room_escape.domain.post.dto.PostResponse
import com.team007.room_escape.domain.post.infra.entity.Post
import com.team007.room_escape.domain.post.infra.repository.PostRepository
import com.team007.room_escape.domain.post.type.PostSearchType
import com.team007.room_escape.global.exception.BusinessException
import com.team007.room_escape.global.response.code.CommonExceptionCode
import com.team007.room_escape.global.response.code.FestivalExceptionCode
import com.team007.room_escape.global.response.code.PostExceptionCode
import com.team007.room_escape.global.storage.ImageUrlResolver
import com.team007.room_escape.global.storage.R2StorageService
import com.team007.room_escape.global.util.RichTextSanitizer
import org.springframework.data.domain.Page
import org.springframework.data.domain.Pageable
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.util.UUID

@Service
class PostService(
    private val postRepository: PostRepository,
    private val festivalRepository: FestivalRepository,
    private val memberReader: MemberReader,
    private val richTextSanitizer: RichTextSanitizer,
    private val likeRepository: LikeRepository,
    private val imageUrlResolver: ImageUrlResolver,
    private val r2StorageService: R2StorageService,
    private val deletionHistoryService: DeletionHistoryService,
) {

    @Transactional
    fun createPost(festivalId: Long, request: PostRequest, memberId: UUID): PostResponse.Create {
        val member = memberReader.getUnrestrictedMember(memberId)
        val festival = festivalRepository.findByIdAndDeletedAtIsNull(festivalId)
            .orElseThrow { BusinessException(FestivalExceptionCode.FESTIVAL_NOT_FOUND) }
        val content = sanitizeRequiredContent(request.content)
        val thumbnail = imageUrlResolver.toKey(request.thumbnail)
        r2StorageService.requireOwnedBy(thumbnail, null, memberId)

        val post = postRepository.save(
            Post(
                member = member,
                festival = festival,
                title = requiredTitle(request),
                content = content,
                thumbnail = thumbnail,
            )
        )

        return PostResponse.Create.from(post)
    }

    @Transactional(readOnly = true)
    fun searchPosts(type: PostSearchType?, keyword: String?, page: Pageable): Page<PostResponse.ListItem> {
        val hasKeyword = type != null && !keyword.isNullOrBlank()

        if (LikeSort.isRequested(page)) {
            val unsorted = LikeSort.withoutSort(page)
            return toListItems(
                if (hasKeyword) postRepository.searchPostsOrderByLikeCount(type.name, keyword, unsorted)
                else postRepository.findAllOrderByLikeCount(unsorted)
            )
        }
        if (!hasKeyword) {
            return toListItems(postRepository.findAllNotDeleted(page))
        }
        return toListItems(postRepository.searchPosts(type, keyword, page))
    }

    @Transactional(readOnly = true)
    fun searchPostsForAdmin(type: PostSearchType?, keyword: String?, page: Pageable): Page<PostResponse.AdminListItem> {
        val posts = if (type == null || keyword.isNullOrBlank()) {
            postRepository.findAllIncludingDeleted(page)
        } else {
            postRepository.searchPostsIncludingDeleted(type, keyword, page)
        }
        return posts.map { PostResponse.AdminListItem.from(it, imageUrlResolver) }
    }

    @Transactional(readOnly = true)
    fun getPostsByFestival(festivalId: Long, page: Pageable): Page<PostResponse.ListItem> {
        if (LikeSort.isRequested(page)) {
            return toListItems(
                postRepository.findAllByFestivalIdOrderByLikeCount(festivalId, LikeSort.withoutSort(page))
            )
        }
        return toListItems(postRepository.findAllByFestivalId(festivalId, page))
    }

    private fun toListItems(posts: Page<Post>): Page<PostResponse.ListItem> =
        posts.map { PostResponse.ListItem.from(it, imageUrlResolver) }

    @Transactional(readOnly = true)
    fun getPostDetail(id: UUID, memberId: UUID?): PostResponse.Detail {
        val post = postRepository.findByIdAndDeletedAtIsNull(id)
            ?: throw BusinessException(PostExceptionCode.POST_NOT_FOUND)

        // 좋아요 버튼 상태용. 비회원은 항상 false.
        val likedByMe = memberId != null && likeRepository.existsByPostIdAndMemberId(id, memberId)

        return PostResponse.Detail.from(post, likedByMe, imageUrlResolver)
    }

    @Transactional
    fun updatePost(postId: UUID, request: PostRequest, memberId: UUID): PostResponse.Detail {
        memberReader.getUnrestrictedMember(memberId)

        val post = postRepository.findByIdAndDeletedAtIsNull(postId)
            ?: throw BusinessException(PostExceptionCode.POST_NOT_FOUND)

        if (post.member.id != memberId) {
            throw BusinessException(PostExceptionCode.POST_FORBIDDEN)
        }
        val content = sanitizeRequiredContent(request.content)
        // 화면은 썸네일을 안 바꿔도 URL을 다시 보내서 양쪽을 key로 맞춰 비교한다.
        val previousThumbnail = imageUrlResolver.toKey(post.thumbnail)
        val thumbnail = imageUrlResolver.toKey(request.thumbnail)
        r2StorageService.requireOwnedBy(thumbnail, previousThumbnail, memberId)

        post.update(requiredTitle(request), content, thumbnail)
        deleteReplacedThumbnail(previousThumbnail, thumbnail, memberId)

        return PostResponse.Detail.from(
            post,
            likeRepository.existsByPostIdAndMemberId(postId, memberId),
            imageUrlResolver,
        )
    }

    @Transactional
    fun deletePost(postId: UUID, memberId: UUID) {
        val post = postRepository.findForDeletion(postId)
            ?: throw BusinessException(PostExceptionCode.POST_NOT_FOUND)

        if (post.member.id != memberId) {
            throw BusinessException(PostExceptionCode.POST_FORBIDDEN)
        }

        post.delete()
        deletionHistoryService.recordAuthorDeletion(DeletionTargetType.POST, postId.toString(), memberId)
    }

    /** 교체된 옛 썸네일을 R2에서 지운다. */
    private fun deleteReplacedThumbnail(previousKey: String?, currentKey: String?, memberId: UUID) {
        if (previousKey == null || previousKey == currentKey) {
            return
        }
        r2StorageService.deleteOwnedBy(previousKey, memberId)
    }

    private fun sanitizeRequiredContent(content: String?): String {
        val sanitized = richTextSanitizer.sanitize(content)
        if (sanitized == null || !richTextSanitizer.hasVisibleText(sanitized)) {
            throw BusinessException(CommonExceptionCode.INVALID_INPUT)
        }
        return sanitized
    }

    /** 컨트롤러의 @Valid가 빈 제목을 먼저 막는다. */
    private fun requiredTitle(request: PostRequest): String =
        requireNotNull(request.title) { "title은 필수입니다." }
}
