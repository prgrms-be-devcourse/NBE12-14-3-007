package com.team007.room_escape.domain.inquiry.infra.entity

import com.team007.room_escape.domain.member.infra.entity.Member
import com.team007.room_escape.global.entity.SoftDeletableEntity
import com.team007.room_escape.global.util.StringUtil.emptyToNull
import com.team007.room_escape.global.util.isBlankLikeJava
import com.team007.room_escape.global.util.isNullOrBlankLikeJava
import jakarta.persistence.Column
import jakarta.persistence.Entity
import jakarta.persistence.EnumType
import jakarta.persistence.Enumerated
import jakarta.persistence.FetchType
import jakarta.persistence.Id
import jakarta.persistence.JoinColumn
import jakarta.persistence.ManyToOne
import jakarta.persistence.Table
import org.hibernate.annotations.UuidGenerator
import java.util.UUID

// @SQLRestriction 을 걸면 관리자가 삭제된 문의를 조회할 수 없어서 걸지 않는다.
// 삭제 제외 조건은 repository 쿼리에서 직접 건다.
@Entity
@Table(name = "inquiry")
class Inquiry(
    member: Member?,
    category: InquiryCategory,
    title: String,
    content: String,
    targetType: InquiryTargetType? = null,
    targetId: String? = null,
    img: String? = null,
    answer: String? = null,
    status: InquiryStatus? = null,
    id: UUID? = null,
) : SoftDeletableEntity() {

    @Id
    @UuidGenerator(style = UuidGenerator.Style.VERSION_7)
    var id: UUID? = id
        protected set

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "member_id")
    var member: Member? = member
        protected set

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 32)
    var category: InquiryCategory = category
        protected set

    @Enumerated(EnumType.STRING)
    @Column(name = "target_type", length = 32)
    var targetType: InquiryTargetType? = targetType
        protected set

    @Column(name = "target_id")
    var targetId: String? = targetId
        protected set

    @Column(nullable = false)
    var title: String = title
        protected set

    @Column(nullable = false, columnDefinition = "text")
    var content: String = content
        protected set

    @Column(length = 2048)
    var img: String? = img
        protected set

    @Column(columnDefinition = "text")
    var answer: String? = answer
        protected set

    @Enumerated(EnumType.STRING)
    @Column(length = 32)
    var status: InquiryStatus? = status
        protected set

    /** 작성자 본인인지. member가 없는 과거 데이터도 있어 null이면 아니다. */
    fun isWrittenBy(memberId: UUID): Boolean = member?.id == memberId

    /**
     * 답변이 달렸는지.
     * status와 answer 둘 다 보는 이유는, 답변만 넣고 상태를 안 바꾼 경우에도
     * 수정이 막혀야 하기 때문이다.
     */
    fun isAnswered(): Boolean = status == InquiryStatus.ANSWERED || !answer.isNullOrBlankLikeJava()

    /**
     * 관리자 답변을 단다. 답변과 상태를 항상 함께 바꾼다.
     * 둘 중 하나만 바뀌면 isAnswered()의 두 조건이 어긋나기 때문이다.
     *
     * 이미 답변이 있으면 덮어쓴다. 잘못 쓴 답변을 관리자가 고칠 수 있어야 한다.
     */
    fun answer(answer: String?) {
        this.answer = answer
        status = InquiryStatus.ANSWERED
    }

    /**
     * 문의 수정. PATCH 의미에 맞춰 null인 값은 건드리지 않는다.
     * img는 빈 문자열이면 첨부를 지운다.
     *
     * @param img R2 저장 key. 공개 URL이 아니다
     */
    fun update(category: InquiryCategory?, title: String?, content: String?, img: String?) {
        category?.let {
            this.category = it
            if (it == InquiryCategory.QUESTION) {
                targetType = null
                targetId = null
            }
        }
        title?.takeUnless { it.isBlankLikeJava() }?.let { this.title = it }
        content?.takeUnless { it.isBlankLikeJava() }?.let { this.content = it }
        img?.let { this.img = emptyToNull(it) }
    }
}
