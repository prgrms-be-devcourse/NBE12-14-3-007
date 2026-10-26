package com.team007.room_escape.domain.post.infra.entity

import com.team007.room_escape.domain.festival.infra.entity.Festival
import com.team007.room_escape.domain.member.infra.entity.Member
import com.team007.room_escape.global.entity.SoftDeletableEntity
import jakarta.persistence.Column
import jakarta.persistence.Entity
import jakarta.persistence.FetchType
import jakarta.persistence.Id
import jakarta.persistence.JoinColumn
import jakarta.persistence.ManyToOne
import jakarta.persistence.Table
import org.hibernate.annotations.UuidGenerator
import java.util.UUID

@Entity
@Table(name = "post")
class Post(
    member: Member,
    festival: Festival? = null,
    title: String,
    content: String,
    thumbnail: String? = null,
) : SoftDeletableEntity() {

    @Id
    @UuidGenerator(style = UuidGenerator.Style.VERSION_7)
    var id: UUID? = null
        protected set

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "member_id", nullable = false)
    var member: Member = member
        protected set

    /** DB에서는 비울 수 있지만 API로 쓰는 후기는 항상 행사에 매달린다. */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "pu_fev_id")
    var festival: Festival? = festival
        protected set

    @Column(nullable = false)
    var title: String = title
        protected set

    @Column(nullable = false, columnDefinition = "text")
    var content: String = content
        protected set

    @Column(length = 2048)
    var thumbnail: String? = thumbnail
        protected set

    /** 좋아요 수. increase/decreaseLikeCount로만 바꾸고, 엔티티 저장 때 옛 값으로 덮지 않게 updatable = false. */
    @Column(nullable = false, updatable = false)
    var likeCount: Long = 0
        protected set

    fun update(title: String, content: String, thumbnail: String?) {
        this.title = title
        this.content = content
        this.thumbnail = thumbnail
    }
}
