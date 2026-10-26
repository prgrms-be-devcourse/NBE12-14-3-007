package com.team007.room_escape.domain.deletion.dto

import com.team007.room_escape.domain.deletion.infra.entity.DeletionAction
import com.team007.room_escape.domain.deletion.infra.entity.DeletionActorType
import com.team007.room_escape.domain.deletion.infra.entity.DeletionHistory
import com.team007.room_escape.domain.deletion.infra.entity.DeletionReason
import java.time.LocalDateTime

class DeletionHistoryResponse private constructor() {
    /** 최근 조치 정보다. 현재 삭제 여부와 복구 가능 여부 자체를 의미하지 않는다. */
    data class Latest(
        val action: DeletionAction?,
        val actorType: DeletionActorType?,
        val reasonCode: DeletionReason?,
        val reasonLabel: String?,
        val reasonDetail: String?,
        val createdAt: LocalDateTime?
    ) {
        // 기존 Java record 호출 방식을 유지한다.
        fun action(): DeletionAction? = action
        fun actorType(): DeletionActorType? = actorType
        fun reasonCode(): DeletionReason? = reasonCode
        fun reasonLabel(): String? = reasonLabel
        fun reasonDetail(): String? = reasonDetail
        fun createdAt(): LocalDateTime? = createdAt

        companion object {
            fun from(history: DeletionHistory): Latest =
                Latest(
                    history.action, history.actorType, history.reason,
                    history.reason.description, history.reasonDetail, history.createdAt
                )
        }
    }
}
