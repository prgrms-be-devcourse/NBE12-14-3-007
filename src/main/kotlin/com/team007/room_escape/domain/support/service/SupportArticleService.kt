package com.team007.room_escape.domain.support.service

import com.team007.room_escape.domain.support.dto.SupportArticleRequest
import com.team007.room_escape.domain.support.dto.SupportArticleResponse
import com.team007.room_escape.domain.support.infra.entity.SupportArticle
import com.team007.room_escape.domain.support.infra.entity.SupportArticleType
import com.team007.room_escape.domain.support.infra.repository.SupportArticleRepository
import com.team007.room_escape.global.exception.BusinessException
import com.team007.room_escape.global.response.code.SupportExceptionCode
import org.springframework.data.domain.Page
import org.springframework.data.domain.PageRequest
import org.springframework.data.domain.Pageable
import org.springframework.data.domain.Sort
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

/** 고객센터 공지사항·자주 묻는 질문. 조회는 누구나, 쓰기는 관리자만 한다(권한은 컨트롤러가 막는다). */
@Service
@Transactional(readOnly = true)
class SupportArticleService(
    private val articles: SupportArticleRepository,
) {

    /** 공지사항 최신순. 클라이언트가 보낸 정렬은 버린다. */
    fun notices(pageable: Pageable): Page<SupportArticleResponse.Item> =
        articles.findByTypeAndDeletedAtIsNull(
            SupportArticleType.NOTICE,
            PageRequest.of(pageable.pageNumber, pageable.pageSize, NOTICE_ORDER),
        ).map(SupportArticleResponse.Item::from)

    /** 자주 묻는 질문 전체. 개수가 적어 페이지로 나누지 않는다. */
    fun faqs(): List<SupportArticleResponse.Item> =
        articles.findAllByTypeAndDeletedAtIsNull(SupportArticleType.FAQ, FAQ_ORDER)
            .map(SupportArticleResponse.Item::from)

    @Transactional
    fun create(request: SupportArticleRequest.Create): SupportArticleResponse.Item {
        val type = requireNotNull(request.type)
        val article = SupportArticle(
            type = type,
            title = request.cleanTitle(),
            content = request.cleanContent(),
            displayOrder = when (type) {
                SupportArticleType.NOTICE -> 0
                SupportArticleType.FAQ -> request.displayOrder ?: (articles.findMaxDisplayOrder(type) + 1)
            },
        )
        return SupportArticleResponse.Item.from(articles.save(article))
    }

    @Transactional
    fun update(articleId: Long, request: SupportArticleRequest.Update): SupportArticleResponse.Item {
        val article = getArticle(articleId)
        article.update(
            title = request.cleanTitle(),
            content = request.cleanContent(),
            displayOrder = when (article.type) {
                SupportArticleType.NOTICE -> article.displayOrder
                SupportArticleType.FAQ -> request.displayOrder ?: article.displayOrder
            },
        )
        return SupportArticleResponse.Item.from(article)
    }

    @Transactional
    fun delete(articleId: Long) {
        getArticle(articleId).delete()
    }

    private fun getArticle(articleId: Long): SupportArticle =
        articles.findByIdAndDeletedAtIsNull(articleId)
            ?: throw BusinessException(SupportExceptionCode.SUPPORT_ARTICLE_NOT_FOUND)

    companion object {
        private val NOTICE_ORDER: Sort = Sort.by(Sort.Order.desc("createdAt"), Sort.Order.desc("id"))
        private val FAQ_ORDER: Sort = Sort.by(Sort.Order.asc("displayOrder"), Sort.Order.asc("id"))
    }
}
