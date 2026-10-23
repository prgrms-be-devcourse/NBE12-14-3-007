package com.team007.room_escape.domain.deletion.service

import com.team007.room_escape.domain.deletion.infra.entity.DeletionHistory
import com.team007.room_escape.domain.deletion.infra.entity.DeletionTargetType

interface DeletionHandler {
    fun supports(): DeletionTargetType
    fun delete(history: DeletionHistory)
    fun restore(history: DeletionHistory)
}