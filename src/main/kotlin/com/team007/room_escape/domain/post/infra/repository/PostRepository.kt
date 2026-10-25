package com.team007.room_escape.domain.post.infra.repository

import com.team007.room_escape.domain.post.infra.entity.Post
import com.team007.room_escape.domain.post.type.PostSearchType
import jakarta.persistence.LockModeType
import org.springframework.data.domain.Page
import org.springframework.data.domain.Pageable
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Lock
import org.springframework.data.jpa.repository.Modifying
import org.springframework.data.jpa.repository.Query
import org.springframework.data.repository.query.Param
import java.util.UUID

/** 검색어 없는 목록 개수. 회원은 soft delete라 조인해도 결과가 같아서 조인 없이 센다. (조인 시 1건 0.5초) */
private const val COUNT_NOT_DELETED = """
    SELECT COUNT(*)
    FROM Post p
    WHERE p.deletedAt IS NULL
    """

interface PostRepository : JpaRepository<Post, UUID> {

    /** 복구 전용: 삭제 필터를 우회하고 대상 행을 잠근다. */
    @Query(value = "select * from post where id = :id for update", nativeQuery = true)
    fun findForRestoration(@Param("id") id: UUID): Post?

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("select p from Post p where p.id = :id and p.deletedAt is null")
    fun findForDeletion(@Param("id") id: UUID): Post?

    fun findByIdAndDeletedAtIsNull(id: UUID): Post?

    fun existsByIdAndDeletedAtIsNull(id: UUID): Boolean

    @Query(
        value = """
        SELECT p
        FROM Post p
        JOIN FETCH p.member
        JOIN FETCH p.festival
        WHERE p.festival.id = :festivalId
          AND p.deletedAt IS NULL
        """,
        countQuery = """
        SELECT COUNT(p)
        FROM Post p
        WHERE p.festival.id = :festivalId
          AND p.deletedAt IS NULL
        """,
    )
    fun findAllByFestivalId(@Param("festivalId") festivalId: Long, page: Pageable): Page<Post>

    @Query(
        value = """
        SELECT p
        FROM Post p
        JOIN FETCH p.member m
        JOIN FETCH p.festival f
        WHERE p.deletedAt IS NULL
          AND (
               (:#{#type.name()} = 'TITLE'
                    AND LOWER(p.title) LIKE LOWER(CONCAT('%', :keyword, '%')))
            OR (:#{#type.name()} = 'MEMBER_NICKNAME'
                    AND m.deletedAt IS NULL
                    AND LOWER(m.nickname) LIKE LOWER(CONCAT('%', :keyword, '%')))
            OR (:#{#type.name()} = 'FESTIVAL_TITLE'
                    AND LOWER(f.title) LIKE LOWER(CONCAT('%', :keyword, '%')))
          )
        """,
        countQuery = """
        SELECT COUNT(p)
        FROM Post p
        JOIN p.member m
        JOIN p.festival f
        WHERE p.deletedAt IS NULL
          AND (
               (:#{#type.name()} = 'TITLE'
                    AND LOWER(p.title) LIKE LOWER(CONCAT('%', :keyword, '%')))
            OR (:#{#type.name()} = 'MEMBER_NICKNAME'
                    AND m.deletedAt IS NULL
                    AND LOWER(m.nickname) LIKE LOWER(CONCAT('%', :keyword, '%')))
            OR (:#{#type.name()} = 'FESTIVAL_TITLE'
                    AND LOWER(f.title) LIKE LOWER(CONCAT('%', :keyword, '%')))
          )
        """,
    )
    fun searchPosts(
        @Param("type") type: PostSearchType,
        @Param("keyword") keyword: String,
        pageable: Pageable,
    ): Page<Post>

    @Query(
        value = """
        SELECT p
        FROM Post p
        JOIN FETCH p.member
        JOIN FETCH p.festival
        """,
        countQuery = """
        SELECT COUNT(p)
        FROM Post p
        """,
    )
    fun findAllIncludingDeleted(page: Pageable): Page<Post>

    @Query(
        value = """
        SELECT p
        FROM Post p
        JOIN FETCH p.member m
        LEFT JOIN FETCH p.festival f
        WHERE (
               (:#{#type.name()} = 'TITLE'
                    AND LOWER(p.title) LIKE LOWER(CONCAT('%', :keyword, '%')))
            OR (:#{#type.name()} = 'MEMBER_NICKNAME'
                    AND LOWER(m.nickname) LIKE LOWER(CONCAT('%', :keyword, '%')))
            OR (:#{#type.name()} = 'FESTIVAL_TITLE'
                    AND LOWER(f.title) LIKE LOWER(CONCAT('%', :keyword, '%')))
        )
        """,
        countQuery = """
        SELECT COUNT(p)
        FROM Post p
        JOIN p.member m
        LEFT JOIN p.festival f
        WHERE (
               (:#{#type.name()} = 'TITLE'
                    AND LOWER(p.title) LIKE LOWER(CONCAT('%', :keyword, '%')))
            OR (:#{#type.name()} = 'MEMBER_NICKNAME'
                    AND LOWER(m.nickname) LIKE LOWER(CONCAT('%', :keyword, '%')))
            OR (:#{#type.name()} = 'FESTIVAL_TITLE'
                    AND LOWER(f.title) LIKE LOWER(CONCAT('%', :keyword, '%')))
        )
        """,
    )
    fun searchPostsIncludingDeleted(
        @Param("type") type: PostSearchType,
        @Param("keyword") keyword: String,
        pageable: Pageable,
    ): Page<Post>

    @Query(
        value = """
        SELECT p
        FROM Post p
        JOIN FETCH p.member
        LEFT JOIN FETCH p.festival
        WHERE p.deletedAt IS NULL
        """,
        countQuery = COUNT_NOT_DELETED,
    )
    fun findAllNotDeleted(page: Pageable): Page<Post>

    /** 좋아요순 전체 목록. idx_post_like_count를 타고, 동점은 최신순 → id로 고정한다. */
    @Query(
        value = """
        SELECT p
        FROM Post p
        JOIN FETCH p.member
        LEFT JOIN FETCH p.festival
        WHERE p.deletedAt IS NULL
        ORDER BY p.likeCount DESC, p.createdAt DESC, p.id DESC
        """,
        countQuery = COUNT_NOT_DELETED,
    )
    fun findAllOrderByLikeCount(pageable: Pageable): Page<Post>

    /** 좋아요순 검색. 닉네임·행사 제목으로 찾아야 해서 개수도 조인해서 센다. */
    @Query(
        value = """
        SELECT p
        FROM Post p
        JOIN FETCH p.member m
        LEFT JOIN FETCH p.festival f
        WHERE p.deletedAt IS NULL
          AND ((:searchType = 'TITLE'
                    AND LOWER(p.title) LIKE LOWER(CONCAT('%', :keyword, '%')))
            OR (:searchType = 'MEMBER_NICKNAME'
                    AND m.deletedAt IS NULL
                    AND LOWER(m.nickname) LIKE LOWER(CONCAT('%', :keyword, '%')))
            OR (:searchType = 'FESTIVAL_TITLE'
                    AND LOWER(f.title) LIKE LOWER(CONCAT('%', :keyword, '%'))))
        ORDER BY p.likeCount DESC, p.createdAt DESC, p.id DESC
        """,
        countQuery = """
        SELECT COUNT(p)
        FROM Post p
        JOIN p.member m
        LEFT JOIN p.festival f
        WHERE p.deletedAt IS NULL
          AND ((:searchType = 'TITLE'
                    AND LOWER(p.title) LIKE LOWER(CONCAT('%', :keyword, '%')))
            OR (:searchType = 'MEMBER_NICKNAME'
                    AND m.deletedAt IS NULL
                    AND LOWER(m.nickname) LIKE LOWER(CONCAT('%', :keyword, '%')))
            OR (:searchType = 'FESTIVAL_TITLE'
                    AND LOWER(f.title) LIKE LOWER(CONCAT('%', :keyword, '%'))))
        """,
    )
    fun searchPostsOrderByLikeCount(
        @Param("searchType") searchType: String,
        @Param("keyword") keyword: String,
        pageable: Pageable,
    ): Page<Post>

    /** 행사별 좋아요순 목록. 플래그로 합치면 행사별 인덱스를 못 탈 수 있어서 따로 둔다. */
    @Query(
        value = """
        SELECT p
        FROM Post p
        JOIN FETCH p.member
        JOIN FETCH p.festival f
        WHERE f.id = :festivalId
          AND p.deletedAt IS NULL
        ORDER BY p.likeCount DESC, p.createdAt DESC, p.id DESC
        """,
        countQuery = """
        SELECT COUNT(p)
        FROM Post p
        WHERE p.festival.id = :festivalId
          AND p.deletedAt IS NULL
        """,
    )
    fun findAllByFestivalIdOrderByLikeCount(@Param("festivalId") festivalId: Long, pageable: Pageable): Page<Post>

    /** 좋아요 수 1 증가. DB에서 바로 더해서 동시에 눌러도 빠지지 않는다. */
    @Modifying(flushAutomatically = true)
    @Query("UPDATE Post p SET p.likeCount = p.likeCount + 1 WHERE p.id = :id")
    fun increaseLikeCount(@Param("id") id: UUID): Int

    /** 좋아요 수 1 감소. 0 아래로는 내려가지 않는다. */
    @Modifying(flushAutomatically = true)
    @Query("UPDATE Post p SET p.likeCount = p.likeCount - 1 WHERE p.id = :id AND p.likeCount > 0")
    fun decreaseLikeCount(@Param("id") id: UUID): Int

    /** 영속성 컨텍스트에 올라온 엔티티 대신 DB의 최신 좋아요 수를 읽는다. (삭제된 후기 포함) */
    @Query("SELECT p.likeCount FROM Post p WHERE p.id = :id")
    fun findLikeCountById(@Param("id") id: UUID): Long?
}
