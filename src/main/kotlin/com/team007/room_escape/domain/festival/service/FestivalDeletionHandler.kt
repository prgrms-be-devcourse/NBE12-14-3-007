package com.team007.room_escape.domain.festival.service

import com.team007.room_escape.domain.deletion.infra.entity.DeletionHistory
import com.team007.room_escape.domain.deletion.infra.entity.DeletionTargetType
import com.team007.room_escape.domain.deletion.service.DeletionHandler
import com.team007.room_escape.domain.deletion.service.DeletionHistoryService
import com.team007.room_escape.domain.festival.infra.repository.FestivalRepository
import com.team007.room_escape.global.exception.BusinessException
import com.team007.room_escape.global.response.code.FestivalExceptionCode
import org.springframework.stereotype.Component

@Component
class FestivalDeletionHandler(
    private val festivals: FestivalRepository,
    private val deletion: FestivalDeletionService,
    private val histories: DeletionHistoryService
) : DeletionHandler {
    override fun restore(history: DeletionHistory) {
        val festival = festivals.findForDeletion(java.lang.Long.valueOf(history.targetId))
            .orElseThrow { BusinessException(FestivalExceptionCode.FESTIVAL_NOT_FOUND) }
        if (!festival.isDeleted()) {
            throw BusinessException(FestivalExceptionCode.FESTIVAL_NOT_DELETED)
        }

        histories.requireAdministratorDeletion(supports(), history.targetId)
        deletion.restore(festival)
    }

    override fun supports(): DeletionTargetType {
        return DeletionTargetType.FESTIVAL
    }

    override fun delete(history: DeletionHistory) {
        val festival = festivals.findForDeletion(java.lang.Long.valueOf(history.targetId))
            .orElseThrow { BusinessException(FestivalExceptionCode.FESTIVAL_NOT_FOUND) }
        deletion.delete(festival)
    }
}
