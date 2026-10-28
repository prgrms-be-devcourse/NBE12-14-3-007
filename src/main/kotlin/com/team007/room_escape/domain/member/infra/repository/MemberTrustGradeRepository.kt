package com.team007.room_escape.domain.member.infra.repository

import com.team007.room_escape.domain.member.infra.entity.MemberRole
import jakarta.persistence.EntityManager
import org.springframework.stereotype.Repository
import java.time.LocalDateTime

/**
 * 신뢰 등급 자정 집계용 쿼리.
 * 반응이 달릴 때마다 계산하지 않고, 하루에 한 번 전체 작성자를 한 번의 SQL로 계산한다.
 */
@Repository
class MemberTrustGradeRepository(
    private val entityManager: EntityManager,
) {

    /**
     * 집계를 한 서버만 돌리도록 잠금을 잡는다. 트랜잭션이 끝나면 자동으로 풀린다.
     * 다른 서버가 이미 돌고 있으면 false 를 돌려준다.
     */
    fun tryAcquireNightlyLock(): Boolean =
        entityManager.createNativeQuery("SELECT pg_try_advisory_xact_lock(:key)")
            .setParameter("key", NIGHTLY_LOCK_KEY)
            .singleResult as Boolean

    /**
     * 행사를 올린 회원의 등급을 현재 반응 수로 다시 계산해 바뀐 회원만 갱신한다. 바뀐 회원 수를 돌려준다.
     *
     * - 삭제되지 않은 회원 제보 행사가 받은 좋아요와 '정확해요'만 센다. 본인이 누른 반응은 뺀다.
     * - 제재·관리자·탈퇴 회원과, 관리자가 직접 바꿔 고정한 회원은 건드리지 않는다.
     * - 좋아요와 '정확해요'가 모두 threshold 이상이면 TRUSTED, 하나만이면 RECOGNIZED, 아니면 UNVERIFIED다.
     */
    fun recalculateAuthorGrades(threshold: Long, now: LocalDateTime): Int =
        entityManager.createNativeQuery(RECALCULATE_SQL)
            .setParameter("threshold", threshold)
            .setParameter("now", now)
            .setParameter("trusted", MemberRole.ROLE_TRUSTED.name)
            .setParameter("recognized", MemberRole.ROLE_RECOGNIZED.name)
            .setParameter("unverified", MemberRole.ROLE_UNVERIFIED.name)
            .executeUpdate()

    private companion object {

        /** pg_try_advisory_xact_lock 에 쓰는 이 작업 전용 번호. 다른 잠금(행사 중복 검사 등)과 겹치지 않는 값이다. */
        const val NIGHTLY_LOCK_KEY = 7_302_023_001L

        val RECALCULATE_SQL = """
            WITH authors AS (
                SELECT DISTINCT f.member_id AS author_id
                FROM festival f
                WHERE f.provider_type = 'MEMBER' AND f.member_id IS NOT NULL
            ),
            received_likes AS (
                SELECT f.member_id AS author_id, COUNT(*) AS cnt
                FROM "like" l
                JOIN festival f ON f.id = l.festival_id
                WHERE f.provider_type = 'MEMBER'
                  AND f.deleted_at IS NULL
                  AND l.member_id <> f.member_id
                GROUP BY f.member_id
            ),
            received_votes AS (
                SELECT f.member_id AS author_id, COUNT(*) AS cnt
                FROM festival_accuracy_vote v
                JOIN festival f ON f.id = v.festival_id
                WHERE f.provider_type = 'MEMBER'
                  AND f.deleted_at IS NULL
                  AND v.vote_type = 'ACCURATE'
                  AND v.member_id <> f.member_id
                GROUP BY f.member_id
            ),
            grades AS (
                SELECT a.author_id,
                       CASE
                           WHEN COALESCE(l.cnt, 0) >= :threshold AND COALESCE(v.cnt, 0) >= :threshold THEN :trusted
                           WHEN COALESCE(l.cnt, 0) >= :threshold OR COALESCE(v.cnt, 0) >= :threshold THEN :recognized
                           ELSE :unverified
                       END AS grade
                FROM authors a
                LEFT JOIN received_likes l ON l.author_id = a.author_id
                LEFT JOIN received_votes v ON v.author_id = a.author_id
            )
            UPDATE member m
            SET role = g.grade, updated_at = :now
            FROM grades g
            WHERE m.id = g.author_id
              AND m.deleted_at IS NULL
              AND m.role_locked = FALSE
              AND m.role IN (:unverified, :recognized, :trusted)
              AND m.role <> g.grade
        """.trimIndent()
    }
}
