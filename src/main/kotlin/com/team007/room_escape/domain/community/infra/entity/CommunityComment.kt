package com.team007.room_escape.domain.community.infra.entity

import com.team007.room_escape.domain.member.infra.entity.Member
import com.team007.room_escape.global.entity.SoftDeletableEntity
import jakarta.persistence.Column
import jakarta.persistence.Entity
import jakarta.persistence.FetchType
import jakarta.persistence.GeneratedValue
import jakarta.persistence.GenerationType
import jakarta.persistence.Id
import jakarta.persistence.JoinColumn
import jakarta.persistence.ManyToOne
import jakarta.persistence.Table

@Entity
@Table(name = "community_comment")
// 삭제된 댓글도 "삭제된 댓글입니다"로 자리를 남겨야 해서 @SQLRestriction을 걸지 않는다.
// 수정·삭제·신고·댓글 수처럼 살아 있는 댓글만 다뤄야 하는 곳은 DeletedAtIsNull 조건으로 거른다.
class CommunityComment(
    post: CommunityPost,
    member: Member,
    parent: CommunityComment? = null,
    content: String,
) : SoftDeletableEntity() {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    var id: Long? = null
        protected set

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "post_id", nullable = false)
    var post: CommunityPost = post
        protected set

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "member_id", nullable = false)
    var member: Member = member
        protected set

    /** 대댓글이면 부모 댓글. 일반 댓글이면 null. 대댓글의 부모는 항상 일반 댓글이다(한 단계). */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "parent_id")
    var parent: CommunityComment? = parent
        protected set

    @Column(nullable = false, length = 500)
    var content: String = content
        protected set

    fun update(content: String) {
        this.content = content
    }

    fun isReply(): Boolean = parent != null
}
