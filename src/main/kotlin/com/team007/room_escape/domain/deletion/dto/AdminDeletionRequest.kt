package com.team007.room_escape.domain.deletion.dto

import com.team007.room_escape.domain.deletion.infra.entity.DeletionReason
import com.team007.room_escape.domain.deletion.infra.entity.DeletionTargetType
import io.swagger.v3.oas.annotations.media.Schema
import jakarta.validation.constraints.NotBlank
import jakarta.validation.constraints.NotNull
import jakarta.validation.constraints.Size
import java.util.UUID

class AdminDeletionRequest private constructor() {
    @Schema(name = "AdminDeletionCreate", description = "관리자 콘텐츠 삭제 조치")
    data class Create(
        @field:NotNull val targetType: DeletionTargetType?,
        @field:NotBlank @field:Size(max = 64) val targetId: String?,
        @field:NotNull val reasonCode: DeletionReason?,
        @field:Size(max = 500) val reasonDetail: String?,
        val inquiryId: UUID?
    ) {
        // 기존 Java record 호출 방식을 유지한다.
        fun targetType(): DeletionTargetType? = targetType
        fun targetId(): String? = targetId
        fun reasonCode(): DeletionReason? = reasonCode
        fun reasonDetail(): String? = reasonDetail
        fun inquiryId(): UUID? = inquiryId
    }

    @Schema(name = "AdminDeletionRestore", description = "관리자가 삭제한 콘텐츠 복구 조치")
    data class Restore(
        @field:NotNull val targetType: DeletionTargetType?,
        @field:NotBlank @field:Size(max = 64) val targetId: String?
    ) {
        fun targetType(): DeletionTargetType? = targetType
        fun targetId(): String? = targetId
    }
}
