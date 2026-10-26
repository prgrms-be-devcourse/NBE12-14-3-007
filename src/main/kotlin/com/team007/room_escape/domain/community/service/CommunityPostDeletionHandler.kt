package com.team007.room_escape.domain.community.service

import com.team007.room_escape.domain.community.infra.repository.CommunityPostRepository
import com.team007.room_escape.domain.deletion.infra.entity.DeletionHistory
import com.team007.room_escape.domain.deletion.infra.entity.DeletionTargetType
import com.team007.room_escape.domain.deletion.service.DeletionHandler
import com.team007.room_escape.domain.deletion.service.DeletionHistoryService
import com.team007.room_escape.global.exception.BusinessException
import com.team007.room_escape.global.response.code.CommunityExceptionCode
import org.springframework.stereotype.Component
import java.util.UUID

@Component
class CommunityPostDeletionHandler(
    private val posts: CommunityPostRepository,
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

    override fun supports(): DeletionTargetType = DeletionTargetType.COMMUNITY_POST

    override fun delete(history: DeletionHistory) {
        (posts.findForDeletion(UUID.fromString(history.targetId)) ?: throw notFound()).delete()
    }

    private fun notFound() = BusinessException(CommunityExceptionCode.POST_NOT_FOUND)
}
