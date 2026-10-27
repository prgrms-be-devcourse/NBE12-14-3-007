package com.team007.room_escape.domain.support.infra.repository

import com.team007.room_escape.domain.support.infra.entity.SupportArticle
import com.team007.room_escape.domain.support.infra.entity.SupportArticleType
import org.springframework.data.domain.Page
import org.springframework.data.domain.Pageable
import org.springframework.data.domain.Sort
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Query
import org.springframework.data.repository.query.Param

interface SupportArticleRepository : JpaRepository<SupportArticle, Long> {

    fun findByTypeAndDeletedAtIsNull(type: SupportArticleType, pageable: Pageable): Page<SupportArticle>

    fun findAllByTypeAndDeletedAtIsNull(type: SupportArticleType, sort: Sort): List<SupportArticle>

    fun findByIdAndDeletedAtIsNull(id: Long): SupportArticle?

    /** 새 질문을 맨 아래에 두려고 지금 가장 큰 표시 순서를 구한다. 글이 없으면 0이다. */
    @Query(
        """
        SELECT COALESCE(MAX(a.displayOrder), 0)
        FROM SupportArticle a
        WHERE a.type = :type AND a.deletedAt IS NULL
        """,
    )
    fun findMaxDisplayOrder(@Param("type") type: SupportArticleType): Int
}
