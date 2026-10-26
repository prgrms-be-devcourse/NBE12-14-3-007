package com.team007.room_escape.domain.post.service

import com.team007.room_escape.domain.deletion.infra.entity.DeletionHistory
import com.team007.room_escape.domain.deletion.infra.entity.DeletionTargetType
import com.team007.room_escape.domain.deletion.service.DeletionHandler
import com.team007.room_escape.domain.deletion.service.DeletionHistoryService
import com.team007.room_escape.domain.post.infra.repository.PostRepository
import com.team007.room_escape.global.exception.BusinessException
import com.team007.room_escape.global.response.code.PostExceptionCode
import org.springframework.stereotype.Component
import java.util.UUID

@Component
class PostDeletionHandler(
    private val posts: PostRepository,
    private val histories: DeletionHistoryService,
) : DeletionHandler {

    override fun restore(history: DeletionHistory) {
        val target = posts.findForRestoration(UUID.fromString(history.targetId)) ?: throw notFound()
        if (!target.isDeleted()) {
            throw notFound()
        }
        histories.requireAdministratorDeletion(supports(), history.targetId)
        target.restore()
    }

    override fun supports(): DeletionTargetType = DeletionTargetType.POST

    override fun delete(history: DeletionHistory) {
        (posts.findForDeletion(UUID.fromString(history.targetId)) ?: throw notFound()).delete()
    }

    private fun notFound() = BusinessException(PostExceptionCode.POST_NOT_FOUND)
}
