package com.team007.room_escape.domain.community.infra.repository

import com.team007.room_escape.domain.community.infra.entity.CommunityPost
import com.team007.room_escape.domain.community.type.CommunityCategory
import jakarta.persistence.LockModeType
import org.springframework.data.domain.Page
import org.springframework.data.domain.Pageable
import org.springframework.data.jpa.repository.EntityGraph
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Lock
import org.springframework.data.jpa.repository.Modifying
import org.springframework.data.jpa.repository.Query
import org.springframework.data.repository.query.Param
import java.time.LocalDateTime
import java.util.UUID

// CommunityPost엔 @SQLRestriction이 있어서 JPQL·파생 쿼리는 삭제된 글을 자동으로 뺀다.
interface CommunityPostRepository : JpaRepository<CommunityPost, UUID> {

    /** 복구 전용: 삭제 필터를 우회하고 대상 행을 잠근다. */
    @Query(value = "select * from community_post where id = :id for update", nativeQuery = true)
    fun findForRestoration(@Param("id") id: UUID): CommunityPost?

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("select p from CommunityPost p where p.id = :id and p.deletedAt is null")
    fun findForDeletion(@Param("id") id: UUID): CommunityPost?

    /** 조회수 1 증가. 바뀐 행 수를 돌려주므로 0이면 없는(또는 삭제된) 글이다. */
    @Modifying
    @Query(
        """
        update CommunityPost p
        set p.viewCount = p.viewCount + 1
        where p.id = :postId
          and p.deletedAt is null
        """
    )
    fun increaseViewCount(@Param("postId") postId: UUID): Int

    fun existsByMemberIdAndCreatedAtAfter(memberId: UUID, createdAfter: LocalDateTime): Boolean

    fun existsByMemberIdAndContentAndCreatedAtAfter(
        memberId: UUID,
        content: String,
        createdAfter: LocalDateTime,
    ): Boolean

    /** 카테고리가 null이면 전체, 검색어가 빈 문자열이면 검색하지 않는다. 검색어는 escapeLikePattern()으로 바꿔 넘긴다. */
    @EntityGraph(attributePaths = ["member"])
    @Query(
        """
        select p from CommunityPost p
        where (:category is null or p.category = :category)
          and (:keyword = ''
               or lower(p.title) like lower(concat('%', :keyword, '%')) escape '!'
               or lower(p.content) like lower(concat('%', :keyword, '%')) escape '!')
        """
    )
    fun search(
        @Param("category") category: CommunityCategory?,
        @Param("keyword") keyword: String,
        pageable: Pageable,
    ): Page<CommunityPost>

    /** 작성자를 함께 읽는다. 삭제된 글은 @SQLRestriction 때문에 찾지 못한다. */
    @EntityGraph(attributePaths = ["member"])
    fun findWithMemberById(id: UUID): CommunityPost?
}
