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

        val voteType = requireNotNull(request.voteType) { "평가 종류는 필수입니다." }
        val vote = accuracyVoteRepository
            .findByFestivalAndMember(festival, member)
            ?: FestivalAccuracyVote(festival, member, voteType)

        vote.changeVote(voteType)
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
            ?.let { accuracyVoteRepository.delete(it) }

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

    private fun findUserSubmittedFestival(festivalId: Long): Festival {
        // 첫 투표는 잠글 투표 행이 없으므로 행사 행을 잠근다.
        // 투표·취소·삭제가 같은 잠금을 사용하며 트랜잭션 종료까지 유지한다.
        val festival = festivalRepository.findForDeletion(festivalId)
            ?: throw BusinessException(FestivalExceptionCode.FESTIVAL_NOT_FOUND)
        if (festival.providerType != ProviderType.MEMBER || festival.isDeleted()) {
            throw BusinessException(FestivalExceptionCode.FESTIVAL_NOT_FOUND)
        }
        return festival
    }
}
