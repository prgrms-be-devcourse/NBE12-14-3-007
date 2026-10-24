package com.team007.room_escape.domain.comment.service

import com.team007.room_escape.domain.comment.infra.repository.CommentRepository
import com.team007.room_escape.domain.deletion.infra.entity.DeletionHistory
import com.team007.room_escape.domain.deletion.infra.entity.DeletionTargetType
import com.team007.room_escape.domain.deletion.service.DeletionHandler
import com.team007.room_escape.domain.deletion.service.DeletionHistoryService
import com.team007.room_escape.domain.post.infra.repository.PostRepository
import com.team007.room_escape.global.exception.BusinessException
import com.team007.room_escape.global.response.code.CommentExceptionCode
import org.springframework.stereotype.Component

@Component
class CommentDeletionHandler(
    private val comments: CommentRepository,
    private val histories: DeletionHistoryService,
    private val parents: PostRepository,
) : DeletionHandler {

    override fun restore(history: DeletionHistory) {
        val target = comments.findForRestoration(history.targetId.toLong())
            .orElseThrow { notFound() }
        if (!target.isDeleted()) {
            throw notFound()
        }
        histories.requireAdministratorDeletion(supports(), history.targetId)
        val parent = parents.findForRestoration(target.post.id)
            .orElseThrow { notFound() }
        if (parent.isDeleted()) {
            throw notFound()
        }
        target.restore()
    }

    override fun supports(): DeletionTargetType = DeletionTargetType.COMMENT

    override fun delete(history: DeletionHistory) {
        comments.findForDeletion(history.targetId.toLong())
            .orElseThrow { notFound() }
            .delete()
    }

    private fun notFound() = BusinessException(CommentExceptionCode.COMMENT_NOT_FOUND)
}
