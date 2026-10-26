package com.team007.room_escape.domain.community.service

import com.team007.room_escape.domain.community.dto.CommunityRequest
import com.team007.room_escape.domain.community.dto.CommunityResponse
import com.team007.room_escape.domain.community.infra.entity.CommunityComment
import com.team007.room_escape.domain.community.infra.entity.CommunityPost
import com.team007.room_escape.domain.community.infra.repository.CommunityCommentRepository
import com.team007.room_escape.domain.community.infra.repository.CommunityPostRepository
import com.team007.room_escape.domain.community.type.CommunityCategory
import com.team007.room_escape.domain.deletion.infra.entity.DeletionTargetType
import com.team007.room_escape.domain.deletion.service.DeletionHistoryService
import com.team007.room_escape.domain.member.infra.entity.Member
import com.team007.room_escape.domain.member.infra.repository.MemberRepository
import com.team007.room_escape.global.exception.BusinessException
import com.team007.room_escape.global.response.code.CommonExceptionCode
import com.team007.room_escape.global.response.code.CommunityExceptionCode
import com.team007.room_escape.global.response.code.MemberExceptionCode
import com.team007.room_escape.global.storage.ImageUrlResolver
import com.team007.room_escape.global.util.RichTextSanitizer
import com.team007.room_escape.global.util.escapeLikePattern
import com.team007.room_escape.global.util.trimLikeJava
import org.springframework.data.domain.Page
import org.springframework.data.domain.PageRequest
import org.springframework.data.domain.Pageable
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.time.LocalDateTime
import java.util.UUID

@Service
class CommunityService(
    private val postRepository: CommunityPostRepository,
    private val commentRepository: CommunityCommentRepository,
    private val memberRepository: MemberRepository,
    private val richTextSanitizer: RichTextSanitizer,
    private val imageUrlResolver: ImageUrlResolver,
    private val deletionHistoryService: DeletionHistoryService,
) {

    @Transactional(readOnly = true)
    fun getPosts(category: CommunityCategory?, keyword: String?, pageable: Pageable): Page<CommunityResponse.PostListItem> {
        val posts = postRepository.search(category, keyword?.trimLikeJava().orEmpty().escapeLikePattern(), pageable)
        val commentCounts: Map<UUID, Long> =
            if (posts.isEmpty) {
                emptyMap()
            } else {
                commentRepository.countByPostIds(posts.content.map { savedId(it) })
                    .associate { it.postId to it.commentCount }
            }
        return posts.map { post ->
            CommunityResponse.PostListItem.from(post, commentCounts[post.id] ?: 0L, imageUrlResolver)
        }
    }

    /** countView가 false면 조회수를 올리지 않는다. 수정 화면처럼 글을 읽으려는 게 아닌 곳에서 쓴다. */
    @Transactional
    fun getPost(postId: UUID, countView: Boolean = true): CommunityResponse.PostDetail {
        if (countView && postRepository.increaseViewCount(postId) == 0) {
            throw BusinessException(CommunityExceptionCode.POST_NOT_FOUND)
        }
        val post = getPostEntity(postId)
        return CommunityResponse.PostDetail.from(post, commentRepository.countByPostIdAndDeletedAtIsNull(postId), imageUrlResolver)
    }

    @Transactional
    fun createPost(request: CommunityRequest.PostUpsert, memberId: UUID): CommunityResponse.PostDetail {
        val member = getActiveMember(memberId)
        val title = requiredTitle(request)
        val content = sanitizeRequiredContent(request.content)
        checkPostCreationAllowed(memberId, content)

        val post = postRepository.save(
            CommunityPost(member = member, category = requiredCategory(request), title = title, content = content)
        )
        return CommunityResponse.PostDetail.from(post, 0, imageUrlResolver)
    }

    @Transactional
    fun updatePost(postId: UUID, request: CommunityRequest.PostUpsert, memberId: UUID): CommunityResponse.PostDetail {
        getActiveMember(memberId)
        val post = getPostEntity(postId)
        checkAuthor(post.member.id, memberId, CommunityExceptionCode.POST_FORBIDDEN)

        post.update(requiredCategory(request), requiredTitle(request), sanitizeRequiredContent(request.content))
        return CommunityResponse.PostDetail.from(post, commentRepository.countByPostIdAndDeletedAtIsNull(postId), imageUrlResolver)
    }

    @Transactional
    fun deletePost(postId: UUID, memberId: UUID) {
        val post = postRepository.findForDeletion(postId)
            ?: throw BusinessException(CommunityExceptionCode.POST_NOT_FOUND)
        checkAuthor(post.member.id, memberId, CommunityExceptionCode.POST_FORBIDDEN)
        post.delete()
        deletionHistoryService.recordAuthorDeletion(DeletionTargetType.COMMUNITY_POST, postId.toString(), memberId)
    }

    /** 일반 댓글을 오래된 순으로 페이지 나누고, 각 댓글 아래에 대댓글을 붙인다. 삭제된 댓글도 자리를 남긴다. */
    @Transactional(readOnly = true)
    fun getComments(postId: UUID, pageable: Pageable): Page<CommunityResponse.CommentInfo> {
        getPostEntity(postId)
        // 정렬은 쿼리에 고정돼 있어서 클라이언트가 보낸 sort는 버린다.
        val roots = commentRepository.findRootsByPostId(postId, PageRequest.of(pageable.pageNumber, pageable.pageSize))
        val repliesByParentId: Map<Long?, List<CommunityComment>> =
            if (roots.isEmpty) {
                emptyMap()
            } else {
                commentRepository.findRepliesByParentIds(roots.content.mapNotNull { it.id })
                    .groupBy { it.parent?.id }
            }
        return roots.map { root ->
            CommunityResponse.CommentInfo.of(root, repliesByParentId[root.id].orEmpty(), imageUrlResolver)
        }
    }

    @Transactional
    fun createComment(postId: UUID, request: CommunityRequest.CommentCreate, memberId: UUID): CommunityResponse.CommentInfo {
        val member = getActiveMember(memberId)
        val post = getPostEntity(postId)
        val content = requireNotNull(request.content) { "검증을 통과한 요청에는 내용이 있다." }.trimLikeJava()
        checkCommentCreationAllowed(memberId, content)
        val comment = commentRepository.save(
            CommunityComment(post = post, member = member, parent = findParent(request.parentId, postId), content = content)
        )
        return CommunityResponse.CommentInfo.from(comment, imageUrlResolver)
    }

    @Transactional
    fun updateComment(commentId: Long, request: CommunityRequest.CommentUpsert, memberId: UUID): CommunityResponse.CommentInfo {
        getActiveMember(memberId)
        val comment = getCommentEntity(commentId)
        checkAuthor(comment.member.id, memberId, CommunityExceptionCode.COMMENT_FORBIDDEN)
        comment.update(requireNotNull(request.content) { "검증을 통과한 요청에는 내용이 있다." }.trimLikeJava())
        return CommunityResponse.CommentInfo.from(comment, imageUrlResolver)
    }

    /** 행은 지우지 않고 삭제 시각만 남긴다. 대댓글은 그대로 두고, 목록에는 "삭제된 댓글입니다"로 보인다. */
    @Transactional
    fun deleteComment(commentId: Long, memberId: UUID) {
        val comment = commentRepository.findForDeletion(commentId)
            ?: throw BusinessException(CommunityExceptionCode.COMMENT_NOT_FOUND)
        checkAuthor(comment.member.id, memberId, CommunityExceptionCode.COMMENT_FORBIDDEN)
        comment.delete()
        deletionHistoryService.recordAuthorDeletion(DeletionTargetType.COMMUNITY_COMMENT, commentId.toString(), memberId)
    }

    private fun getActiveMember(memberId: UUID): Member {
        val member = memberRepository.findByIdAndDeletedAtIsNull(memberId)
            ?: throw BusinessException(MemberExceptionCode.MEMBER_NOT_FOUND)
        if (member.isRestricted) {
            throw BusinessException(MemberExceptionCode.MEMBER_RESTRICTED)
        }
        return member
    }

    /** 삭제되지 않은 글. 삭제된 글은 @SQLRestriction 때문에 조회되지 않는다. */
    private fun getPostEntity(postId: UUID): CommunityPost =
        postRepository.findWithMemberById(postId) ?: throw BusinessException(CommunityExceptionCode.POST_NOT_FOUND)

    /**
     * 답글을 달 부모 댓글. 대댓글에 답글을 달면 그 대댓글의 부모 아래에 붙여 한 단계를 유지한다.
     * 삭제된 댓글에는 새 답글을 달 수 없다.
     */
    private fun findParent(parentId: Long?, postId: UUID): CommunityComment? {
        if (parentId == null) {
            return null
        }
        val parent = getCommentEntity(parentId)
        if (parent.post.id != postId) {
            throw BusinessException(CommunityExceptionCode.COMMENT_PARENT_MISMATCH)
        }
        return parent.parent ?: parent
    }

    /** 삭제되지 않은 댓글. 삭제된 댓글은 수정·삭제·답글 대상이 아니다. */
    private fun getCommentEntity(commentId: Long): CommunityComment =
        commentRepository.findByIdAndDeletedAtIsNull(commentId)
            ?: throw BusinessException(CommunityExceptionCode.COMMENT_NOT_FOUND)

    private fun sanitizeRequiredContent(content: String?): String {
        val sanitized = richTextSanitizer.sanitize(content)
        if (sanitized == null || !richTextSanitizer.hasVisibleText(sanitized)) {
            throw BusinessException(CommonExceptionCode.INVALID_INPUT)
        }
        return sanitized
    }

    private fun checkPostCreationAllowed(memberId: UUID, content: String) {
        val now = LocalDateTime.now()
        if (postRepository.existsByMemberIdAndContentAndCreatedAtAfter(memberId, content, now.minusSeconds(DUPLICATE_CHECK_SECONDS))) {
            throw BusinessException(CommunityExceptionCode.POST_DUPLICATE)
        }
        if (postRepository.existsByMemberIdAndCreatedAtAfter(memberId, now.minusSeconds(POST_COOLDOWN_SECONDS))) {
            throw BusinessException(CommunityExceptionCode.POST_CREATE_TOO_SOON)
        }
    }

    private fun checkCommentCreationAllowed(memberId: UUID, content: String) {
        val now = LocalDateTime.now()
        if (commentRepository.existsByMemberIdAndContentAndDeletedAtIsNullAndCreatedAtAfter(
                memberId, content, now.minusSeconds(DUPLICATE_CHECK_SECONDS),
            )
        ) {
            throw BusinessException(CommunityExceptionCode.COMMENT_DUPLICATE)
        }
        if (commentRepository.existsByMemberIdAndDeletedAtIsNullAndCreatedAtAfter(memberId, now.minusSeconds(COMMENT_COOLDOWN_SECONDS))) {
            throw BusinessException(CommunityExceptionCode.COMMENT_CREATE_TOO_SOON)
        }
    }

    private fun checkAuthor(authorId: UUID?, memberId: UUID, exceptionCode: CommunityExceptionCode) {
        if (authorId != memberId) {
            throw BusinessException(exceptionCode)
        }
    }

    private companion object {
        const val POST_COOLDOWN_SECONDS = 30L
        const val COMMENT_COOLDOWN_SECONDS = 5L
        const val DUPLICATE_CHECK_SECONDS = 60L

        /** 검증(@NotNull, @NotBlank)을 통과한 요청이라 값이 있다. 제목은 앞뒤 공백을 지운다. */
        fun requiredTitle(request: CommunityRequest.PostUpsert): String =
            requireNotNull(request.title) { "검증을 통과한 요청에는 제목이 있다." }.trimLikeJava()

        fun requiredCategory(request: CommunityRequest.PostUpsert): CommunityCategory =
            requireNotNull(request.category) { "검증을 통과한 요청에는 카테고리가 있다." }

        fun savedId(post: CommunityPost): UUID = requireNotNull(post.id) { "DB에서 읽은 글에는 id가 있다." }
    }
}
