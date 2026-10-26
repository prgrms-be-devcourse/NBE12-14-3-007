package com.team007.room_escape.domain.like.infra.entity

import com.team007.room_escape.domain.festival.infra.entity.Festival
import com.team007.room_escape.domain.member.infra.entity.Member
import com.team007.room_escape.domain.post.infra.entity.Post
import com.team007.room_escape.global.entity.BaseTimeEntity
import jakarta.persistence.Entity
import jakarta.persistence.FetchType
import jakarta.persistence.GeneratedValue
import jakarta.persistence.GenerationType
import jakarta.persistence.Id
import jakarta.persistence.JoinColumn
import jakarta.persistence.ManyToOne
import jakarta.persistence.Table
import jakarta.persistence.UniqueConstraint

// TODO 추후에 필요하면 테이블 분리

/** 후기나 행사 중 하나에 누른 좋아요. 대상이 하나만 채워지도록 [of]로만 만든다. */
@Entity
@Table(
    name = "`like`",
    uniqueConstraints = [
        UniqueConstraint(name = "uk_like_post_member", columnNames = ["src_id", "member_id"]),
        UniqueConstraint(name = "uk_like_festival_member", columnNames = ["festival_id", "member_id"]),
    ],
)
class Like private constructor(
    post: Post?,
    festival: Festival?,
    member: Member,
) : BaseTimeEntity() {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    var id: Long? = null
        protected set

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "src_id")
    var post: Post? = post
        protected set

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "festival_id")
    var festival: Festival? = festival
        protected set

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "member_id", nullable = false)
    var member: Member = member
        protected set

    companion object {
        /** 후기 좋아요 */
        fun of(post: Post, member: Member): Like = Like(post = post, festival = null, member = member)

        /** 행사 좋아요 */
        fun of(festival: Festival, member: Member): Like = Like(post = null, festival = festival, member = member)
    }
}
