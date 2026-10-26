package com.team007.room_escape.domain.deletion.service

import com.team007.room_escape.domain.deletion.dto.AdminDeletionRequest
import com.team007.room_escape.domain.deletion.dto.DeletionHistoryResponse
import com.team007.room_escape.domain.deletion.infra.entity.DeletionAction
import com.team007.room_escape.domain.deletion.infra.entity.DeletionActorType
import com.team007.room_escape.domain.deletion.infra.entity.DeletionHistory
import com.team007.room_escape.domain.deletion.infra.entity.DeletionReason
import com.team007.room_escape.domain.deletion.infra.entity.DeletionTargetType
import com.team007.room_escape.domain.inquiry.service.InquiryDeletionProcessor
import com.team007.room_escape.domain.member.infra.entity.MemberRole
import com.team007.room_escape.domain.member.service.MemberReader
import com.team007.room_escape.global.exception.BusinessException
import com.team007.room_escape.global.response.code.DeletionExceptionCode
import org.springframework.security.access.AccessDeniedException
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.util.UUID
import java.util.stream.Collectors

@Service
class AdminDeletionFacade(
    handlers: List<DeletionHandler>,
    private val histories: DeletionHistoryService,
    private val members: MemberReader,
    private val inquiries: InquiryDeletionProcessor
) {
    private val handlers: Map<DeletionTargetType, DeletionHandler> = handlers.stream()
        .collect(Collectors.toMap({ it.supports() }, { it }))

    @Transactional
    fun restore(adminId: UUID, type: DeletionTargetType?, targetId: String?) {
        requireAdministrator(adminId, "관리자만 복구할 수 있습니다.")
        val history = DeletionHistory.record(
            type, targetId, DeletionAction.RESTORE,
            adminId, DeletionActorType.ADMIN, DeletionReason.ADMIN_RESTORE, null
        )
        val handler = handlers[type]
            ?: throw BusinessException(DeletionExceptionCode.HANDLER_NOT_REGISTERED)
        handler.restore(history)
        histories.record(history)
    }

    @Transactional(readOnly = true)
    fun latest(adminId: UUID, type: DeletionTargetType?, targetId: String?): DeletionHistoryResponse.Latest? {
        requireAdministrator(adminId, "관리자만 조치 이력을 조회할 수 있습니다.")
        if (type == null) {
            throw BusinessException(DeletionExceptionCode.INVALID_TARGET_TYPE)
        }
        return histories.findLatest(type, targetId)
            .map { DeletionHistoryResponse.Latest.from(it) }.orElse(null)
    }

    @Transactional
    fun delete(adminId: UUID, request: AdminDeletionRequest.Create) {
        requireAdministrator(adminId, "관리자만 삭제할 수 있습니다.")
        val history = DeletionHistory.record(
            request.targetType, request.targetId, DeletionAction.DELETE,
            adminId, DeletionActorType.ADMIN, request.reasonCode, request.reasonDetail
        )
        val handler = handlers[history.targetType]
            ?: throw BusinessException(DeletionExceptionCode.HANDLER_NOT_REGISTERED)
        handler.delete(history)
        histories.record(history)
        val inquiryId = request.inquiryId
        if (inquiryId != null) {
            inquiries.complete(inquiryId, history)
        }
    }

    /** 기존 토큰의 권한이 아니라 DB의 현재 회원 상태로 판단한다. */
    private fun requireAdministrator(adminId: UUID, message: String) {
        if (members.getActiveMember(adminId).role != MemberRole.ROLE_ADMIN) {
            throw AccessDeniedException(message)
        }
    }
}
