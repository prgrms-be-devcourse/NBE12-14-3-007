package com.team007.room_escape.domain.like.infra.repository

import com.team007.room_escape.domain.festival.infra.entity.Festival
import com.team007.room_escape.domain.like.infra.dto.FestivalLikeCount
import com.team007.room_escape.domain.like.infra.entity.Like
import com.team007.room_escape.domain.post.infra.entity.Post
import org.springframework.data.domain.Page
import org.springframework.data.domain.Pageable
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Query
import org.springframework.data.repository.query.Param
import java.util.UUID

interface LikeRepository : JpaRepository<Like, Long> {

    /** 후기. 좋아요 수는 post.like_count 에 있다. (PostRepository.findLikeCountById) */
    fun existsByPostIdAndMemberId(postId: UUID, memberId: UUID): Boolean

    fun findByPostIdAndMemberId(postId: UUID, memberId: UUID): Like?

    /** 행사 */
    fun countByFestivalId(festivalId: Long): Long

    fun existsByFestivalIdAndMemberId(festivalId: Long, memberId: UUID): Boolean

    fun findByFestivalIdAndMemberId(festivalId: Long, memberId: UUID): Like?

    /** 목록 한 페이지에 담긴 행사들의 좋아요 수를 한 번에 센다. 좋아요가 없는 행사는 결과에 없다. */
    @Query(
        """
        SELECT new com.team007.room_escape.domain.like.infra.dto.FestivalLikeCount(l.festival.id, COUNT(l))
        FROM Like l
        WHERE l.festival.id IN :festivalIds
        GROUP BY l.festival.id
        """
    )
    fun countByFestivalIds(@Param("festivalIds") festivalIds: Collection<Long>): List<FestivalLikeCount>

    /**
     * 마이페이지: 회원이 좋아요한 후기. 최근에 누른 것부터, 삭제된 후기는 뺀다.
     * 순서는 이 쿼리가 정하므로 정렬 없는 Pageable을 넘긴다.
     */
    @Query(
        value = """
        SELECT p
        FROM Like l
        JOIN l.post p
        JOIN FETCH p.member
        JOIN FETCH p.festival
        WHERE l.member.id = :memberId
          AND p.deletedAt IS NULL
        ORDER BY l.createdAt DESC, l.id DESC
        """,
        countQuery = """
        SELECT COUNT(l)
        FROM Like l
        JOIN l.post p
        WHERE l.member.id = :memberId
          AND p.deletedAt IS NULL
        """,
    )
    fun findLikedPosts(@Param("memberId") memberId: UUID, pageable: Pageable): Page<Post>

    /**
     * 마이페이지: 회원이 좋아요한 행사. 최근에 누른 것부터, 삭제된 행사는 뺀다.
     * 회원 제보 행사는 목록에 제보자를 보여 주므로 함께 읽는다.
     */
    @Query(
        value = """
        SELECT f
        FROM Like l
        JOIN l.festival f
        LEFT JOIN FETCH f.member
        WHERE l.member.id = :memberId
          AND f.deletedAt IS NULL
        ORDER BY l.createdAt DESC, l.id DESC
        """,
        countQuery = """
        SELECT COUNT(l)
        FROM Like l
        JOIN l.festival f
        WHERE l.member.id = :memberId
          AND f.deletedAt IS NULL
        """,
    )
    fun findLikedFestivals(@Param("memberId") memberId: UUID, pageable: Pageable): Page<Festival>
}
