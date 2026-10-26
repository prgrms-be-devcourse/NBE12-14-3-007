package com.team007.room_escape.domain.deletion.service

import com.team007.room_escape.domain.deletion.infra.entity.DeletionAction
import com.team007.room_escape.domain.deletion.infra.entity.DeletionActorType
import com.team007.room_escape.domain.deletion.infra.entity.DeletionHistory
import com.team007.room_escape.domain.deletion.infra.entity.DeletionReason
import com.team007.room_escape.domain.deletion.infra.entity.DeletionTargetType
import com.team007.room_escape.domain.deletion.infra.repository.DeletionHistoryRepository
import com.team007.room_escape.global.exception.BusinessException
import com.team007.room_escape.global.response.code.DeletionExceptionCode
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Propagation
import org.springframework.transaction.annotation.Transactional
import java.util.UUID

@Service
@Transactional(readOnly = true)
class DeletionHistoryService(
    private val repository: DeletionHistoryRepository
) {
    /** 대상의 상태 변경과 같은 트랜잭션으로만 기록한다. */
    @Transactional(propagation = Propagation.MANDATORY)
    fun record(history: DeletionHistory) {
        repository.save(history)
    }

    @Transactional(propagation = Propagation.MANDATORY)
    fun recordAuthorDeletion(type: DeletionTargetType, targetId: String?, authorId: UUID) {
        repository.save(
            DeletionHistory.record(
                type, targetId, DeletionAction.DELETE,
                authorId, DeletionActorType.AUTHOR, DeletionReason.AUTHOR_REQUEST, null
            )
        )
    }

    fun findLatest(type: DeletionTargetType, targetId: String?): DeletionHistory? =
        repository.findFirstByTargetTypeAndTargetIdOrderByIdDesc(type, type.normalizeId(targetId))

    fun findLatestForTargets(type: DeletionTargetType, ids: List<String?>): Map<String, DeletionHistory> {
        if (ids.isEmpty()) {
            return emptyMap()
        }
        val normalized = ids.map { type.normalizeId(it) }.distinct()
        return repository.findLatestForTargets(type, normalized).associateBy { it.targetId }
    }

    /** 대상 행을 잠근 뒤 호출한다. 마지막 조치가 관리자 삭제인지 확인한다. */
    fun requireAdministratorDeletion(type: DeletionTargetType, targetId: String?) {
        val latest = findLatest(type, targetId)
            ?: throw BusinessException(DeletionExceptionCode.RESTORE_HISTORY_NOT_FOUND)
        if (latest.action != DeletionAction.DELETE || latest.actorType != DeletionActorType.ADMIN) {
            throw BusinessException(DeletionExceptionCode.RESTORE_NOT_ALLOWED)
        }
    }
}
