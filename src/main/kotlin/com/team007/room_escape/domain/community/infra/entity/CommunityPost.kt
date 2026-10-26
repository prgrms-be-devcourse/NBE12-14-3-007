package com.team007.room_escape.domain.community.infra.entity

import com.team007.room_escape.domain.community.type.CommunityCategory
import com.team007.room_escape.domain.member.infra.entity.Member
import com.team007.room_escape.global.entity.SoftDeletableEntity
import jakarta.persistence.Column
import jakarta.persistence.Entity
import jakarta.persistence.EnumType
import jakarta.persistence.Enumerated
import jakarta.persistence.FetchType
import jakarta.persistence.Id
import jakarta.persistence.JoinColumn
import jakarta.persistence.ManyToOne
import jakarta.persistence.Table
import org.hibernate.annotations.SQLRestriction
import org.hibernate.annotations.UuidGenerator
import java.util.UUID

@Entity
@Table(name = "community_post")
// 삭제된 글은 어디서도 보이지 않는다. 복구할 때만 native 쿼리(findForRestoration)로 우회한다.
@SQLRestriction("deleted_at is null")
class CommunityPost(
    member: Member,
    category: CommunityCategory,
    title: String,
    content: String,
) : SoftDeletableEntity() {

    @Id
    @UuidGenerator(style = UuidGenerator.Style.VERSION_7)
    var id: UUID? = null
        protected set

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "member_id", nullable = false)
    var member: Member = member
        protected set

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 32)
    var category: CommunityCategory = category
        protected set

    @Column(nullable = false, length = 100)
    var title: String = title
        protected set

    @Column(nullable = false, columnDefinition = "text")
    var content: String = content
        protected set

    /** 조회수. increaseViewCount로만 바꾸고, 글을 수정할 때 처음 읽은 값으로 덮지 않게 updatable = false. */
    @Column(name = "view_count", nullable = false, updatable = false)
    var viewCount: Long = 0
        protected set

    fun update(category: CommunityCategory, title: String, content: String) {
        this.category = category
        this.title = title
        this.content = content
    }
}
