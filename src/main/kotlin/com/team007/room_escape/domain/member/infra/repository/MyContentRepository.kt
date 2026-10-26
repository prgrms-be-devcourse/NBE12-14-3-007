package com.team007.room_escape.domain.member.infra.repository

import com.team007.room_escape.domain.deletion.infra.entity.DeletionTargetType
import jakarta.persistence.EntityManager
import org.springframework.data.domain.Page
import org.springframework.data.domain.PageImpl
import org.springframework.data.domain.Pageable
import org.springframework.stereotype.Repository
import java.sql.Timestamp
import java.time.LocalDateTime
import java.util.UUID

/** 본인 이력 전용 조회. 일반 공개 조회의 삭제 필터를 변경하지 않는다. */
@Repository
class MyContentRepository(
    private val entityManager: EntityManager,
) {

    data class Row(
        val type: DeletionTargetType,
        val targetId: String,
        val title: String?,
        val createdAt: LocalDateTime?,
        val deletedAt: LocalDateTime?,
        val parentDeleted: Boolean,
        val originalPath: String?,
    )

    fun findMine(memberId: UUID, comments: Boolean, pageable: Pageable): Page<Row> {
        val source = if (comments) COMMENTS else POSTS
        val total = (entityManager.createNativeQuery("select count(*) from ($source) mine")
            .setParameter("memberId", memberId).singleResult as Number).toLong()
        val results = entityManager.createNativeQuery(
            "select * from ($source) mine order by created_at desc, type, target_id",
        )
            .setParameter("memberId", memberId)
            .setFirstResult(Math.toIntExact(pageable.offset))
            .setMaxResults(pageable.pageSize)
            .resultList

        val rows = results.map { result ->
            val row = result as Array<*>
            Row(
                DeletionTargetType.valueOf(row[0] as String),
                row[1] as String,
                row[2] as String?,
                toLocalDateTime(row[3]),
                toLocalDateTime(row[4]),
                row[5] as Boolean,
                row[6] as String?,
            )
        }
        return PageImpl(rows, pageable, total)
    }

    private fun toLocalDateTime(value: Any?): LocalDateTime? = when (value) {
        null -> null
        is LocalDateTime -> value
        else -> (value as Timestamp).toLocalDateTime()
    }

    private companion object {

        const val POSTS = """
            select 'FESTIVAL' as type, cast(f.id as text) as target_id, f.title, s.created_at, f.deleted_at,
            false as parent_deleted, '/events/' || f.id as original_path
            from festival_submission s join festival f on f.id = s.festival_id where f.member_id = :memberId and f.provider_type = 'MEMBER'
            union all
            select 'POST', cast(p.id as text), p.title, p.created_at, p.deleted_at, false, '/reviews/' || p.id
            from post p where p.member_id = :memberId
            union all
            select 'COMMUNITY_POST', cast(p.id as text), p.title, p.created_at, p.deleted_at, false, '/community/' || p.id
            from community_post p where p.member_id = :memberId
            """

        const val COMMENTS = """
            select 'COMMENT' as type, cast(c.id as text) as target_id, c.content as title, c.created_at, c.deleted_at,
            (p.deleted_at is not null) as parent_deleted, '/reviews/' || p.id as original_path
            from comment c join post p on p.id = c.post_id where c.member_id = :memberId
            union all
            select 'COMMUNITY_COMMENT', cast(c.id as text), c.content, c.created_at, c.deleted_at,
            (p.deleted_at is not null), '/community/' || p.id
            from community_comment c join community_post p on p.id = c.post_id where c.member_id = :memberId
            """
    }
}
