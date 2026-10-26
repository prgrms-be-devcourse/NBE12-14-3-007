package com.team007.room_escape.domain.festival.service

import com.team007.room_escape.domain.festival.dto.FestivalAccuracyVoteRequest
import com.team007.room_escape.domain.festival.dto.FestivalAccuracyVoteResponse
import com.team007.room_escape.domain.festival.infra.entity.Festival
import com.team007.room_escape.domain.festival.infra.entity.FestivalAccuracyVote
import com.team007.room_escape.domain.festival.infra.entity.FestivalAccuracyVoteType
import com.team007.room_escape.domain.festival.infra.entity.ProviderType
import com.team007.room_escape.domain.festival.infra.repository.FestivalAccuracyVoteRepository
import com.team007.room_escape.domain.festival.infra.repository.FestivalRepository
import com.team007.room_escape.domain.member.service.MemberReader
import com.team007.room_escape.domain.member.service.MemberTrustGradeService
import com.team007.room_escape.global.exception.BusinessException
import com.team007.room_escape.global.response.code.FestivalExceptionCode
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.util.UUID

@Service
class FestivalAccuracyVoteService(
    private val accuracyVoteRepository: FestivalAccuracyVoteRepository,
    private val festivalRepository: FestivalRepository,
    private val memberReader: MemberReader,
    private val memberTrustGradeService: MemberTrustGradeService
) {
    @Transactional
    fun vote(
        memberId: UUID,
        festivalId: Long,
        request: FestivalAccuracyVoteRequest.Upsert
    ): FestivalAccuracyVoteResponse.Info {
        val member = memberReader.getActiveMember(memberId)
        val festival = findUserSubmittedFestival(festivalId)

        if (festival.member?.id == memberId) {
            throw BusinessException(FestivalExceptionCode.SELF_ACCURACY_VOTE_NOT_ALLOWED)
        }

        val vote = accuracyVoteRepository
            .findByFestivalAndMember(festival, member)
            .orElseGet {
                FestivalAccuracyVote.builder()
                    .festival(festival)
                    .member(member)
                    .voteType(request.voteType)
                    .build()
            }

        vote.changeVote(request.voteType)
        accuracyVoteRepository.save(vote)

        val response = buildResponse(festival, vote.voteType)
        memberTrustGradeService.refreshForFestival(festival)
        return response
    }

    @Transactional
    fun cancelVote(memberId: UUID, festivalId: Long): FestivalAccuracyVoteResponse.Info {
        val member = memberReader.getActiveMember(memberId)
        val festival = findUserSubmittedFestival(festivalId)

        accuracyVoteRepository
            .findByFestivalAndMember(festival, member)
            .ifPresent(accuracyVoteRepository::delete)

        val response = buildResponse(festival, null)
        memberTrustGradeService.refreshForFestival(festival)
        return response
    }

    private fun buildResponse(
        festival: Festival,
        myVote: FestivalAccuracyVoteType?
    ): FestivalAccuracyVoteResponse.Info {
        accuracyVoteRepository.flush()

        val accurateCount = accuracyVoteRepository.countByFestivalAndVoteType(
            festival,
            FestivalAccuracyVoteType.ACCURATE
        )
        val inaccurateCount = accuracyVoteRepository.countByFestivalAndVoteType(
            festival,
            FestivalAccuracyVoteType.INACCURATE
        )

        return FestivalAccuracyVoteResponse.Info.from(accurateCount, inaccurateCount, myVote)
    }

    private fun findUserSubmittedFestival(festivalId: Long): Festival =
        festivalRepository
            .findByIdAndProviderTypeAndDeletedAtIsNull(festivalId, ProviderType.MEMBER)
            .orElseThrow { BusinessException(FestivalExceptionCode.FESTIVAL_NOT_FOUND) }
}
