package com.team007.room_escape.domain.festival.infra.entity

import com.team007.room_escape.domain.member.infra.entity.Member
import com.team007.room_escape.global.entity.BaseTimeEntity
import jakarta.persistence.*

@Entity
@Table(name = "festival_accuracy_vote", uniqueConstraints = [
    UniqueConstraint(name = "uk_festival_accuracy_vote_festival_member", columnNames = ["festival_id", "member_id"])
])
class FestivalAccuracyVote protected constructor() : BaseTimeEntity() {
    @field:Id
    @field:GeneratedValue(strategy = GenerationType.IDENTITY)
    var id: Long? = null
        protected set

    @field:ManyToOne(fetch = FetchType.LAZY, optional = false)
    @field:JoinColumn(name = "festival_id", nullable = false)
    var festival: Festival? = null
        protected set

    @field:ManyToOne(fetch = FetchType.LAZY, optional = false)
    @field:JoinColumn(name = "member_id", nullable = false)
    var member: Member? = null
        protected set

    @field:Enumerated(EnumType.STRING)
    @field:Column(name = "vote_type", nullable = false, length = 16)
    var voteType: FestivalAccuracyVoteType? = null
        protected set

    fun changeVote(voteType: FestivalAccuracyVoteType) {
        this.voteType = voteType
    }

    companion object {
        @Deprecated("Kotlin에서는 create()를 사용하세요. Java 호출 호환용입니다.")
        @JvmStatic
        fun builder(): FestivalAccuracyVoteBuilder = FestivalAccuracyVoteBuilder()

        fun create(
            festival: Festival,
            member: Member,
            voteType: FestivalAccuracyVoteType
        ): FestivalAccuracyVote = FestivalAccuracyVote().also {
            it.festival = festival
            it.member = member
            it.voteType = voteType
        }
    }

    class FestivalAccuracyVoteBuilder {
        private var festival: Festival? = null
        private var member: Member? = null
        private var voteType: FestivalAccuracyVoteType? = null

        fun festival(festival: Festival?): FestivalAccuracyVoteBuilder = apply { this.festival = festival }
        fun member(member: Member?): FestivalAccuracyVoteBuilder = apply { this.member = member }
        fun voteType(voteType: FestivalAccuracyVoteType?): FestivalAccuracyVoteBuilder = apply { this.voteType = voteType }

        fun build(): FestivalAccuracyVote = create(
            festival = requireNotNull(festival) { "투표할 행사는 필수입니다." },
            member = requireNotNull(member) { "투표 회원은 필수입니다." },
            voteType = requireNotNull(voteType) { "평가 종류는 필수입니다." }
        )
    }
}
