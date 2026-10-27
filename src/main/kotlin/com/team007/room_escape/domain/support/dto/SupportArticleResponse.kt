package com.team007.room_escape.domain.support.dto

import com.team007.room_escape.domain.support.infra.entity.SupportArticle
import com.team007.room_escape.domain.support.infra.entity.SupportArticleType
import io.swagger.v3.oas.annotations.media.Schema
import java.time.LocalDateTime

class SupportArticleResponse private constructor() {

    @Schema(name = "SupportArticleItem", description = "고객센터 공지사항·자주 묻는 질문 하나")
    data class Item(
        val id: Long,
        val type: SupportArticleType,
        val title: String,
        @field:Schema(description = "본문. 줄바꿈으로 문단을 나눈 평문")
        val content: String,
        @field:Schema(description = "자주 묻는 질문의 표시 순서. 작을수록 위")
        val displayOrder: Int,
        val createdAt: LocalDateTime?,
        val updatedAt: LocalDateTime?,
    ) {
        companion object {
            fun from(article: SupportArticle): Item = Item(
                id = checkNotNull(article.id) { "저장되지 않은 고객센터 글입니다." },
                type = article.type,
                title = article.title,
                content = article.content,
                displayOrder = article.displayOrder,
                createdAt = article.createdAt,
                updatedAt = article.updatedAt,
            )
        }
    }
}
