package com.team007.room_escape.domain.like.infra.repository

import com.team007.room_escape.domain.like.infra.dto.FestivalLikeCount
import com.team007.room_escape.domain.like.infra.entity.Like
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

    /** 회원이 작성한 삭제되지 않은 행사 제보들이 받은 좋아요 합계 */
    @Query(
        """
        SELECT COUNT(l)
        FROM Like l
        JOIN l.festival f
        WHERE f.member.id = :authorId
          AND f.providerType = com.team007.room_escape.domain.festival.infra.entity.ProviderType.MEMBER
          AND f.deletedAt IS NULL
          AND l.member.id <> f.member.id
        """
    )
    fun countReceivedFestivalLikesByAuthorId(@Param("authorId") authorId: UUID): Long
}
