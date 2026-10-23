package com.team007.room_escape.domain.inquiry.infra.entity

import com.team007.room_escape.domain.member.infra.entity.Member
import com.team007.room_escape.global.entity.SoftDeletableEntity
import com.team007.room_escape.global.util.StringUtil.emptyToNull
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
class Inquiry private constructor(
    id: UUID?,
    member: Member?,
    category: InquiryCategory,
    targetType: InquiryTargetType?,
    targetId: String?,
    title: String,
    content: String,
    img: String?,
    answer: String?,
    status: InquiryStatus?
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

    /** 작성자 본인인지. member가 없는 과거 데이터도 있어 null을 먼저 거른다. */
    fun isWrittenBy(memberId: UUID): Boolean {
        val writer = member
        return writer != null && writer.id == memberId
    }

    /**
     * 답변이 달렸는지.
     * status와 answer 둘 다 보는 이유는, 답변만 넣고 상태를 안 바꾼 경우에도
     * 수정이 막혀야 하기 때문이다.
     */
    fun isAnswered(): Boolean {
        val current = answer
        return status == InquiryStatus.ANSWERED || (current != null && !isBlank(current))
    }

    /**
     * 관리자 답변을 단다. 답변과 상태를 항상 함께 바꾼다.
     * 둘 중 하나만 바뀌면 isAnswered()의 두 조건이 어긋나기 때문이다.
     *
     * 이미 답변이 있으면 덮어쓴다. 잘못 쓴 답변을 관리자가 고칠 수 있어야 한다.
     */
    fun answer(answer: String?) {
        this.answer = answer
        this.status = InquiryStatus.ANSWERED
    }

    /**
     * 문의 수정. PATCH 의미에 맞춰 null인 값은 건드리지 않는다.
     * img는 빈 문자열이면 첨부를 지운다.
     *
     * @param img R2 저장 key. 공개 URL이 아니다
     */
    fun update(category: InquiryCategory?, title: String?, content: String?, img: String?) {
        if (category != null) {
            this.category = category
            if (category == InquiryCategory.QUESTION) {
                this.targetType = null
                this.targetId = null
            }
        }
        if (title != null && !isBlank(title)) {
            this.title = title
        }
        if (content != null && !isBlank(content)) {
            this.content = content
        }
        if (img != null) {
            this.img = emptyToNull(img)
        }
    }

    // Kotlin의 isBlank()는 NBSP도 공백으로 봐서, Java String.isBlank()와 같은 기준으로 맞춘다.
    private fun isBlank(value: String): Boolean {
        return value.all { Character.isWhitespace(it) }
    }

    class InquiryBuilder internal constructor() {
        private var id: UUID? = null
        private var member: Member? = null
        private var category: InquiryCategory? = null
        private var targetType: InquiryTargetType? = null
        private var targetId: String? = null
        private var title: String? = null
        private var content: String? = null
        private var img: String? = null
        private var answer: String? = null
        private var status: InquiryStatus? = null

        fun id(id: UUID?): InquiryBuilder = apply { this.id = id }

        fun member(member: Member?): InquiryBuilder = apply { this.member = member }

        fun category(category: InquiryCategory?): InquiryBuilder = apply { this.category = category }

        fun targetType(targetType: InquiryTargetType?): InquiryBuilder = apply { this.targetType = targetType }

        fun targetId(targetId: String?): InquiryBuilder = apply { this.targetId = targetId }

        fun title(title: String?): InquiryBuilder = apply { this.title = title }

        fun content(content: String?): InquiryBuilder = apply { this.content = content }

        fun img(img: String?): InquiryBuilder = apply { this.img = img }

        fun answer(answer: String?): InquiryBuilder = apply { this.answer = answer }

        fun status(status: InquiryStatus?): InquiryBuilder = apply { this.status = status }

        fun build(): Inquiry {
            return Inquiry(
                id, member,
                requireNotNull(category) { "category는 필수입니다." },
                targetType, targetId,
                requireNotNull(title) { "title은 필수입니다." },
                requireNotNull(content) { "content는 필수입니다." },
                img, answer, status
            )
        }
    }

    companion object {

        @JvmStatic
        fun builder(): InquiryBuilder = InquiryBuilder()
    }
}
