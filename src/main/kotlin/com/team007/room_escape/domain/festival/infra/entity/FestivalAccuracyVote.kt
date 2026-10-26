package com.team007.room_escape.domain.festival.infra.entity

import com.team007.room_escape.domain.member.infra.entity.Member
import com.team007.room_escape.global.entity.BaseTimeEntity
import jakarta.persistence.*

@Entity
@Table(name = "festival_accuracy_vote", uniqueConstraints = [
    UniqueConstraint(name = "uk_festival_accuracy_vote_festival_member", columnNames = ["festival_id", "member_id"])
])
class FestivalAccuracyVote(
    festival: Festival,
    member: Member,
    voteType: FestivalAccuracyVoteType,
) : BaseTimeEntity() {
    @field:Id
    @field:GeneratedValue(strategy = GenerationType.IDENTITY)
    var id: Long? = null
        protected set

    @field:ManyToOne(fetch = FetchType.LAZY, optional = false)
    @field:JoinColumn(name = "festival_id", nullable = false)
    var festival: Festival = festival
        protected set

    @field:ManyToOne(fetch = FetchType.LAZY, optional = false)
    @field:JoinColumn(name = "member_id", nullable = false)
    var member: Member = member
        protected set

    @field:Enumerated(EnumType.STRING)
    @field:Column(name = "vote_type", nullable = false, length = 16)
    var voteType: FestivalAccuracyVoteType = voteType
        protected set

    fun changeVote(voteType: FestivalAccuracyVoteType) {
        this.voteType = voteType
    }
}
