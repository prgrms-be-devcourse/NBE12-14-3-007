package com.team007.room_escape.domain.member.dto

import com.team007.room_escape.domain.deletion.dto.DeletionHistoryResponse
import com.team007.room_escape.domain.deletion.infra.entity.DeletionTargetType
import java.time.LocalDateTime

class MyContentResponse private constructor() {

    data class Item(
        val type: DeletionTargetType,
        val targetId: String,
        val title: String?,
        val createdAt: LocalDateTime?,
        val deletedAt: LocalDateTime?,
        val parentDeleted: Boolean,
        val originalPath: String?,
        val deletion: DeletionHistoryResponse.Latest?,
    )
}
