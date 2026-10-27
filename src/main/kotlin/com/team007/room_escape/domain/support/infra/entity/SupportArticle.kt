package com.team007.room_escape.domain.support.infra.entity

import com.team007.room_escape.global.entity.SoftDeletableEntity
import jakarta.persistence.Column
import jakarta.persistence.Entity
import jakarta.persistence.EnumType
import jakarta.persistence.Enumerated
import jakarta.persistence.GeneratedValue
import jakarta.persistence.GenerationType
import jakarta.persistence.Id
import jakarta.persistence.Table

/**
 * 고객센터의 공지사항 또는 자주 묻는 질문 하나. 관리자만 쓰고 고친다.
 * 본문은 줄바꿈으로 문단을 나눈 평문이다. HTML을 받지 않아서 따로 정제하지 않는다.
 */
@Entity
@Table(name = "support_article")
class SupportArticle(
    type: SupportArticleType,
    title: String,
    content: String,
    displayOrder: Int = 0,
) : SoftDeletableEntity() {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    var id: Long? = null
        protected set

    /** 공지사항을 질문으로 바꾸는 일은 없어서 처음 정한 종류를 유지한다. */
    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 16, updatable = false)
    var type: SupportArticleType = type
        protected set

    @Column(nullable = false, length = 100)
    var title: String = title
        protected set

    @Column(nullable = false, columnDefinition = "text")
    var content: String = content
        protected set

    /** 자주 묻는 질문의 표시 순서. 작을수록 위에 보인다. 공지사항은 최신순이라 쓰지 않는다. */
    @Column(name = "display_order", nullable = false)
    var displayOrder: Int = displayOrder
        protected set

    fun update(title: String, content: String, displayOrder: Int) {
        this.title = title
        this.content = content
        this.displayOrder = displayOrder
    }
}
