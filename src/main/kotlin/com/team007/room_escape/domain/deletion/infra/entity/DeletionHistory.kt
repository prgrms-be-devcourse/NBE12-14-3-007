package com.team007.room_escape.domain.deletion.infra.entity

import com.team007.room_escape.global.exception.BusinessException
import com.team007.room_escape.global.response.code.DeletionExceptionCode
import jakarta.persistence.Column
import jakarta.persistence.Entity
import jakarta.persistence.EnumType
import jakarta.persistence.Enumerated
import jakarta.persistence.GeneratedValue
import jakarta.persistence.GenerationType
import jakarta.persistence.Id
import jakarta.persistence.Table
import org.hibernate.annotations.Immutable
import java.time.LocalDateTime
import java.util.UUID

/** 발생한 조치의 기록이다. 현재 삭제 여부는 각 콘텐츠의 deletedAt이 기준이다. */
@Entity
@Table(name = "deletion_history")
@Immutable
class DeletionHistory protected constructor() {
    @field:Id
    @field:GeneratedValue(strategy = GenerationType.IDENTITY)
    var id: Long? = null
        protected set

    @field:Enumerated(EnumType.STRING)
    @field:Column(name = "target_type", nullable = false, length = 32, updatable = false)
    lateinit var targetType: DeletionTargetType
        protected set

    @field:Column(name = "target_id", nullable = false, length = 64, updatable = false)
    lateinit var targetId: String
        protected set

    @field:Enumerated(EnumType.STRING)
    @field:Column(nullable = false, length = 16, updatable = false)
    lateinit var action: DeletionAction
        protected set

    @field:Column(name = "actor_id", nullable = false, updatable = false)
    lateinit var actorId: UUID
        protected set

    @field:Enumerated(EnumType.STRING)
    @field:Column(name = "actor_type", nullable = false, length = 16, updatable = false)
    lateinit var actorType: DeletionActorType
        protected set

    @field:Enumerated(EnumType.STRING)
    @field:Column(name = "reason_code", nullable = false, length = 32, updatable = false)
    lateinit var reason: DeletionReason
        protected set

    @field:Column(name = "reason_detail", length = 500, updatable = false)
    var reasonDetail: String? = null
        protected set

    @field:Column(name = "created_at", nullable = false, updatable = false)
    lateinit var createdAt: LocalDateTime
        protected set

    companion object {
        @JvmStatic
        fun record(
            targetType: DeletionTargetType?,
            targetId: String?,
            action: DeletionAction?,
            actorId: UUID?,
            actorType: DeletionActorType?,
            reason: DeletionReason?,
            detail: String?
        ): DeletionHistory {
            // Java String.isBlank()/strip()과 같은 공백 판정을 유지한다.
            val text = if (detail == null || detail.codePoints().allMatch { Character.isWhitespace(it) }) {
                null
            } else {
                detail.trim { Character.isWhitespace(it) }
            }
            if (targetType == null || action == null || actorId == null || actorType == null || reason == null
                || (text != null && text.length > 500)
            ) {
                throw BusinessException(DeletionExceptionCode.INVALID_DELETION_REQUEST)
            }
            // 사유가 '기타'면 무엇이 문제였는지 상세로 남겨야 이력만 보고 판단할 수 있다.
            if (reason == DeletionReason.OTHER && text == null) {
                throw BusinessException(DeletionExceptionCode.REASON_DETAIL_REQUIRED)
            }
            val valid = when {
                action == DeletionAction.RESTORE ->
                    actorType == DeletionActorType.ADMIN && reason == DeletionReason.ADMIN_RESTORE
                actorType == DeletionActorType.AUTHOR ->
                    reason == DeletionReason.AUTHOR_REQUEST && text == null
                else -> reason != DeletionReason.AUTHOR_REQUEST && reason != DeletionReason.ADMIN_RESTORE
            }
            if (!valid) {
                throw BusinessException(DeletionExceptionCode.INVALID_ACTOR_FOR_ACTION)
            }
            return DeletionHistory().also {
                it.targetType = targetType
                it.targetId = targetType.normalizeId(targetId)
                it.action = action
                it.actorId = actorId
                it.actorType = actorType
                it.reason = reason
                it.reasonDetail = text
                it.createdAt = LocalDateTime.now()
            }
        }
    }
}
