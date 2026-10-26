package com.team007.room_escape.domain.member.service

import com.team007.room_escape.domain.deletion.dto.DeletionHistoryResponse
import com.team007.room_escape.domain.deletion.infra.entity.DeletionTargetType
import com.team007.room_escape.domain.deletion.service.DeletionHistoryService
import com.team007.room_escape.domain.member.dto.MyContentResponse
import com.team007.room_escape.domain.member.infra.repository.MyContentRepository
import org.springframework.data.domain.Page
import org.springframework.data.domain.Pageable
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.util.UUID

@Service
@Transactional(readOnly = true)
class MyContentService(
    private val contents: MyContentRepository,
    private val members: MemberReader,
    private val histories: DeletionHistoryService,
) {

    fun findMine(memberId: UUID, comments: Boolean, pageable: Pageable): Page<MyContentResponse.Item> {
        members.getActiveMember(memberId)
        val rows = contents.findMine(memberId, comments, pageable)

        // 삭제된 항목만 종류별로 최근 조치 이력을 한 번에 읽는다.
        val latest = DeletionTargetType.entries.associateWith { type ->
            histories.findLatestForTargets(
                type,
                rows.content.filter { it.type == type && it.deletedAt != null }.map { it.targetId },
            )
        }

        return rows.map { row ->
            val history = latest.getValue(row.type)[row.targetId]
            MyContentResponse.Item(
                type = row.type,
                targetId = row.targetId,
                title = row.title,
                createdAt = row.createdAt,
                deletedAt = row.deletedAt,
                parentDeleted = row.parentDeleted,
                originalPath = row.originalPath.takeUnless { row.deletedAt != null || row.parentDeleted },
                deletion = history?.let { DeletionHistoryResponse.Latest.from(it) },
            )
        }
    }
}
