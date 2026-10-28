package com.team007.room_escape.domain.festival.infra.repository

import com.team007.room_escape.domain.festival.infra.dto.FestivalVoteCount
import com.team007.room_escape.domain.festival.infra.entity.Festival
import com.team007.room_escape.domain.festival.infra.entity.FestivalAccuracyVote
import com.team007.room_escape.domain.festival.infra.entity.FestivalAccuracyVoteType
import com.team007.room_escape.domain.member.infra.entity.Member
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Query
import org.springframework.data.repository.query.Param
import java.util.UUID

interface FestivalAccuracyVoteRepository

    : JpaRepository<FestivalAccuracyVote, Long> {
    fun findByFestivalAndMember(
        festival: Festival,
        member: Member
    ): FestivalAccuracyVote?

    fun findByFestivalIdAndMemberId(
        festivalId: Long,
        memberId: UUID
    ): FestivalAccuracyVote?

    fun countByFestivalAndVoteType(
        festival: Festival,
        voteType: FestivalAccuracyVoteType
    ): Long

    /** 목록 한 페이지에 담긴 행사들의 투표 수를 종류별로 한 번에 센다. 투표가 없는 행사는 결과에 없다.  */
    @Query(
        """
		SELECT new com.team007.room_escape.domain.festival.infra.dto.FestivalVoteCount(
			v.festival.id, v.voteType, COUNT(v))
		FROM FestivalAccuracyVote v
		WHERE v.festival.id IN :festivalIds
		GROUP BY v.festival.id, v.voteType
		
		"""
    )
    fun countByFestivalIds(
        @Param("festivalIds") festivalIds: MutableCollection<Long>
    ): List<FestivalVoteCount>
}
