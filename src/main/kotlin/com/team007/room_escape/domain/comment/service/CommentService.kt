package com.team007.room_escape.domain.comment.service

import com.team007.room_escape.domain.comment.dto.CommentRequest
import com.team007.room_escape.domain.comment.dto.CommentResponse
import com.team007.room_escape.domain.comment.infra.entity.Comment
import com.team007.room_escape.domain.comment.infra.repository.CommentRepository
import com.team007.room_escape.domain.deletion.infra.entity.DeletionTargetType
import com.team007.room_escape.domain.deletion.service.DeletionHistoryService
import com.team007.room_escape.domain.member.infra.entity.MemberRole
import com.team007.room_escape.domain.member.service.MemberReader
import com.team007.room_escape.domain.post.infra.repository.PostRepository
import com.team007.room_escape.global.exception.BusinessException
import com.team007.room_escape.global.response.code.CommentExceptionCode
import com.team007.room_escape.global.response.code.PostExceptionCode
import com.team007.room_escape.global.storage.ImageUrlResolver
import org.springframework.data.domain.Page
import org.springframework.data.domain.PageRequest
import org.springframework.data.domain.Pageable
import org.springframework.security.access.AccessDeniedException
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.util.UUID

@Service
class CommentService(
    private val commentRepository: CommentRepository,
    private val memberReader: MemberReader,
    private val postRepository: PostRepository,
    private val imageUrlResolver: ImageUrlResolver,
    private val deletionHistoryService: DeletionHistoryService,
) {

    @Transactional(readOnly = true)
    fun getCommentsForAdmin(postId: UUID, adminId: UUID, page: Pageable): Page<CommentResponse.AdminInfo> {
        if (memberReader.getActiveMember(adminId).role != MemberRole.ROLE_ADMIN) {
            throw AccessDeniedException("관리자만 삭제된 댓글을 조회할 수 있습니다.")
        }
        val post = postRepository.findById(postId)
            .orElseThrow { BusinessException(PostExceptionCode.POST_NOT_FOUND) }
        val roots = commentRepository.findRootsByPostId(postId, PageRequest.of(page.pageNumber, page.pageSize))
        val replies = if (roots.isEmpty) emptyList() else commentRepository.findRepliesByParentIds(roots.idList())
        val histories = deletionHistoryService.findLatestForTargets(
            DeletionTargetType.COMMENT,
            (roots.content + replies).filter { it.isDeleted() }.map { it.id.toString() },
        )
        val repliesByParentId = replies.groupBy { it.parent?.id }
        return roots.map { root ->
            CommentResponse.AdminInfo.from(
                root, imageUrlResolver, post.isDeleted(), histories[root.id.toString()],
                repliesByParentId[root.id].orEmpty().map { reply ->
                    CommentResponse.AdminInfo.from(
                        reply, imageUrlResolver, post.isDeleted(), histories[reply.id.toString()], emptyList()
                    )
                },
            )
        }
    }

    @Transactional
    fun createComment(postId: UUID, request: CommentRequest.Create, memberId: UUID): CommentResponse.Info {
        val member = memberReader.getUnrestrictedMember(memberId)

        val post = postRepository.findByIdAndDeletedAtIsNull(postId)
            ?: throw BusinessException(PostExceptionCode.POST_NOT_FOUND)

        val comment = Comment(
            post = post,
            member = member,
            parent = findParent(request.parentId, postId),
            content = requiredContent(request.content),
        )

        commentRepository.save(comment)

        return CommentResponse.Info.from(comment, imageUrlResolver)
    }

    /** 일반 댓글을 오래된 순으로 페이지 나누고, 각 댓글 아래에 대댓글을 붙인다. 삭제된 댓글도 자리를 남긴다. */
    @Transactional(readOnly = true)
    fun getComments(postId: UUID, page: Pageable): Page<CommentResponse.Info> {
        if (!postRepository.existsByIdAndDeletedAtIsNull(postId)) {
            throw BusinessException(PostExceptionCode.POST_NOT_FOUND)
        }

        // 정렬은 쿼리에 고정돼 있어서 클라이언트가 보낸 sort는 버린다.
        val roots = commentRepository.findRootsByPostId(postId, PageRequest.of(page.pageNumber, page.pageSize))

        val repliesByParentId = if (roots.isEmpty) {
            emptyMap()
        } else {
            commentRepository.findRepliesByParentIds(roots.idList()).groupBy { it.parent?.id }
        }

        return roots.map { root ->
            CommentResponse.Info.of(root, repliesByParentId[root.id].orEmpty(), imageUrlResolver)
        }
    }

    @Transactional
    fun updateComment(id: Long, request: CommentRequest.Upsert, memberId: UUID): CommentResponse.Info {
        memberReader.getUnrestrictedMember(memberId)

        val comment = getActiveComment(id)

        if (comment.member.id != memberId) {
            throw BusinessException(CommentExceptionCode.COMMENT_FORBIDDEN)
        }

        comment.update(requiredContent(request.content))

        return CommentResponse.Info.from(comment, imageUrlResolver)
    }

    /** 행은 지우지 않고 삭제 시각만 남긴다. 대댓글은 그대로 두고, 목록에는 "삭제된 댓글입니다"로 보인다. */
    @Transactional
    fun deleteComment(id: Long, memberId: UUID) {
        val comment = commentRepository.findForDeletion(id)
            .orElseThrow { BusinessException(CommentExceptionCode.COMMENT_NOT_FOUND) }

        val isAuthor = comment.member.id == memberId

        if (!isAuthor) {
            throw BusinessException(CommentExceptionCode.COMMENT_FORBIDDEN)
        }

        comment.delete()
        deletionHistoryService.recordAuthorDeletion(DeletionTargetType.COMMENT, id.toString(), memberId)
    }

    /**
     * 답글을 달 부모 댓글. 대댓글에 답글을 달면 그 대댓글의 부모 아래에 붙여 한 단계를 유지한다.
     * 삭제된 댓글에는 새 답글을 달 수 없다.
     */
    private fun findParent(parentId: Long?, postId: UUID): Comment? {
        if (parentId == null) {
            return null
        }

        val parent = getActiveComment(parentId)

        if (parent.post.id != postId) {
            throw BusinessException(CommentExceptionCode.COMMENT_PARENT_MISMATCH)
        }

        return if (parent.isReply()) parent.parent else parent
    }

    private fun getActiveComment(id: Long): Comment =
        commentRepository.findByIdAndDeletedAtIsNull(id)
            .orElseThrow { BusinessException(CommentExceptionCode.COMMENT_NOT_FOUND) }

    private fun Page<Comment>.idList(): List<Long> = content.mapNotNull { it.id }

    // 요청 DTO는 검증 메시지를 유지하려고 nullable로 받는다. 컨트롤러의 @Valid(@NotBlank)를 통과하면 null이 아니다.
    private fun requiredContent(content: String?): String = requireNotNull(content) { "content는 필수입니다." }
}
