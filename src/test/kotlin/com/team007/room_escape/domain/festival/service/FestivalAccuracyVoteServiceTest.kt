package com.team007.room_escape.domain.festival.service

import com.team007.room_escape.domain.festival.dto.FestivalAccuracyVoteRequest
import com.team007.room_escape.domain.festival.infra.entity.Festival
import com.team007.room_escape.domain.festival.infra.entity.FestivalAccuracyVote
import com.team007.room_escape.domain.festival.infra.entity.FestivalAccuracyVoteType
import com.team007.room_escape.domain.festival.infra.entity.ProviderType
import com.team007.room_escape.domain.festival.infra.repository.FestivalAccuracyVoteRepository
import com.team007.room_escape.domain.festival.infra.repository.FestivalRepository
import com.team007.room_escape.domain.member.infra.entity.Member
import com.team007.room_escape.domain.member.infra.entity.MemberRole
import com.team007.room_escape.domain.member.service.MemberReader
import com.team007.room_escape.domain.member.service.MemberTrustGradeService
import com.team007.room_escape.global.exception.BusinessException
import com.team007.room_escape.global.response.code.FestivalExceptionCode
import com.team007.room_escape.global.response.code.MemberExceptionCode
import org.assertj.core.api.Assertions.assertThat
import org.assertj.core.api.Assertions.assertThatThrownBy
import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.extension.ExtendWith
import org.junit.jupiter.params.ParameterizedTest
import org.junit.jupiter.params.provider.EnumSource
import org.mockito.ArgumentMatchers.any
import org.mockito.InjectMocks
import org.mockito.Mock
import org.mockito.Mockito.never
import org.mockito.Mockito.inOrder
import org.mockito.Mockito.verify
import org.mockito.Mockito.verifyNoInteractions
import org.mockito.Mockito.`when`
import org.mockito.junit.jupiter.MockitoExtension
import java.util.UUID

@ExtendWith(MockitoExtension::class)
class FestivalAccuracyVoteServiceTest {

    @field:Mock
    private lateinit var accuracyVoteRepository: FestivalAccuracyVoteRepository

    @field:Mock
    private lateinit var festivalRepository: FestivalRepository

    @field:Mock
    private lateinit var memberReader: MemberReader

    @field:Mock
    private lateinit var memberTrustGradeService: MemberTrustGradeService

    @field:InjectMocks
    private lateinit var accuracyVoteService: FestivalAccuracyVoteService

    @ParameterizedTest
    @EnumSource(MemberExceptionCode::class, names = ["MEMBER_RESTRICTED", "MEMBER_NOT_FOUND"])
    fun `제재 또는 탈퇴 회원은 평가 등록 변경 취소 전에 차단한다`(code: MemberExceptionCode) {
        val memberId = UUID.randomUUID()
        `when`(memberReader.getUnrestrictedMember(memberId)).thenThrow(BusinessException(code))

        // 등록과 변경은 같은 vote 경로를 사용한다.
        assertThatThrownBy {
            accuracyVoteService.vote(memberId, 1L,
                FestivalAccuracyVoteRequest.Upsert(FestivalAccuracyVoteType.ACCURATE))
        }.isInstanceOfSatisfying(BusinessException::class.java) {
            assertThat(it.exceptionCode).isEqualTo(code)
        }
        assertThatThrownBy { accuracyVoteService.cancelVote(memberId, 1L) }
            .isInstanceOfSatisfying(BusinessException::class.java) {
                assertThat(it.exceptionCode).isEqualTo(code)
            }

        verifyNoInteractions(festivalRepository, accuracyVoteRepository, memberTrustGradeService)
    }

    @Test
    fun repeatedVoteUpdatesExistingVoteAfterLockingFestival() {
        val memberId = UUID.randomUUID()
        val member = Member(email = "member@test.com", password = "pw", role = MemberRole.ROLE_UNVERIFIED, nickname = "닉네임", id = memberId)
        val festival = Festival(id = 1L, providerType = ProviderType.MEMBER)
        val vote = FestivalAccuracyVote(festival, member, FestivalAccuracyVoteType.ACCURATE)
        `when`(memberReader.getUnrestrictedMember(memberId)).thenReturn(member)
        `when`(festivalRepository.findForDeletion(1L)).thenReturn(festival)
        `when`(accuracyVoteRepository.findByFestivalAndMember(festival, member))
            .thenReturn(vote)

        accuracyVoteService.vote(memberId, 1L,
            FestivalAccuracyVoteRequest.Upsert(FestivalAccuracyVoteType.INACCURATE))

        assertThat(vote.voteType).isEqualTo(FestivalAccuracyVoteType.INACCURATE)
        val order = inOrder(festivalRepository, accuracyVoteRepository)
        order.verify(festivalRepository).findForDeletion(1L)
        order.verify(accuracyVoteRepository).findByFestivalAndMember(festival, member)
        order.verify(accuracyVoteRepository).save(vote)
    }

    @Test
    fun deletedFestivalRejectsVotingAfterLocking() {
        val memberId = UUID.randomUUID()
        val member = Member(email = "member@test.com", password = "pw", role = MemberRole.ROLE_UNVERIFIED, nickname = "닉네임", id = memberId)
        val festival = Festival(id = 1L, providerType = ProviderType.MEMBER)
        festival.delete()
        `when`(memberReader.getUnrestrictedMember(memberId)).thenReturn(member)
        `when`(festivalRepository.findForDeletion(1L)).thenReturn(festival)

        assertThatThrownBy {
            accuracyVoteService.vote(memberId, 1L,
                FestivalAccuracyVoteRequest.Upsert(FestivalAccuracyVoteType.ACCURATE))
        }.isInstanceOfSatisfying(BusinessException::class.java) {
            assertThat(it.exceptionCode).isEqualTo(FestivalExceptionCode.FESTIVAL_NOT_FOUND)
        }
        verify(accuracyVoteRepository, never()).save(any(FestivalAccuracyVote::class.java))
    }

    @Test
    fun cancelVoteLocksFestivalBeforeReadingVote() {
        val memberId = UUID.randomUUID()
        val member = Member(email = "member@test.com", password = "pw", role = MemberRole.ROLE_UNVERIFIED, nickname = "닉네임", id = memberId)
        val festival = Festival(id = 1L, providerType = ProviderType.MEMBER)
        val vote = FestivalAccuracyVote(festival, member, FestivalAccuracyVoteType.ACCURATE)
        `when`(memberReader.getUnrestrictedMember(memberId)).thenReturn(member)
        `when`(festivalRepository.findForDeletion(1L)).thenReturn(festival)
        `when`(accuracyVoteRepository.findByFestivalAndMember(festival, member))
            .thenReturn(vote)

        accuracyVoteService.cancelVote(memberId, 1L)

        val order = inOrder(festivalRepository, accuracyVoteRepository)
        order.verify(festivalRepository).findForDeletion(1L)
        order.verify(accuracyVoteRepository).findByFestivalAndMember(festival, member)
        order.verify(accuracyVoteRepository).delete(vote)
    }

    @Test
    @DisplayName("본인이 제보한 행사의 정확도는 평가할 수 없다")
    fun rejectSelfAccuracyVote() {
        val memberId = UUID.randomUUID()
        val member = Member(email = "member@test.com", password = "pw", role = MemberRole.ROLE_UNVERIFIED, nickname = "닉네임", id = memberId)
        val festival = Festival(
            id = 1L,
            member = member,
            providerType = ProviderType.MEMBER,
        )
        val request = FestivalAccuracyVoteRequest.Upsert(FestivalAccuracyVoteType.ACCURATE)

        `when`(memberReader.getUnrestrictedMember(memberId)).thenReturn(member)
        `when`(
            festivalRepository.findForDeletion(1L)
        ).thenReturn(festival)

        assertThatThrownBy { accuracyVoteService.vote(memberId, 1L, request) }
            .isInstanceOfSatisfying(BusinessException::class.java) { exception ->
                assertThat(exception.exceptionCode)
                    .isEqualTo(FestivalExceptionCode.SELF_ACCURACY_VOTE_NOT_ALLOWED)
            }

        verify(accuracyVoteRepository, never()).save(any(FestivalAccuracyVote::class.java))
    }
}
