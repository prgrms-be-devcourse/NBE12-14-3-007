package com.team007.room_escape.domain.festival.infra.repository

import com.team007.room_escape.domain.festival.infra.dto.FestivalVoteCount
import com.team007.room_escape.domain.festival.infra.entity.Festival
import com.team007.room_escape.domain.festival.infra.entity.FestivalAccuracyVote
import com.team007.room_escape.domain.festival.infra.entity.FestivalAccuracyVoteType
import com.team007.room_escape.domain.member.infra.entity.Member
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Query
import org.springframework.data.repository.query.Param
import java.util.*

interface FestivalAccuracyVoteRepository

    : JpaRepository<FestivalAccuracyVote, Long> {
    fun findByFestivalAndMember(
        festival: Festival,
        member: Member
    ): Optional<FestivalAccuracyVote>

    fun findByFestivalIdAndMemberId(
        festivalId: Long,
        memberId: UUID
    ): Optional<FestivalAccuracyVote>

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

    /** 회원이 작성한 삭제되지 않은 행사 제보들이 받은 '정확해요' 합계  */
    @Query(
        """
		SELECT COUNT(v)
		FROM FestivalAccuracyVote v
		JOIN v.festival f
		WHERE f.member.id = :authorId
		  AND f.providerType = com.team007.room_escape.domain.festival.infra.entity.ProviderType.MEMBER
		  AND f.deletedAt IS NULL
		  AND v.voteType = com.team007.room_escape.domain.festival.infra.entity.FestivalAccuracyVoteType.ACCURATE
		  AND v.member.id <> f.member.id
		
		"""
    )
    fun countReceivedAccurateVotesByAuthorId(@Param("authorId") authorId: UUID): Long
}
