package com.team007.room_escape.domain.festival.service

import com.team007.room_escape.domain.festival.dto.FestivalAccuracyVoteRequest
import com.team007.room_escape.domain.festival.infra.entity.Festival
import com.team007.room_escape.domain.festival.infra.entity.FestivalAccuracyVote
import com.team007.room_escape.domain.festival.infra.entity.FestivalAccuracyVoteType
import com.team007.room_escape.domain.festival.infra.entity.ProviderType
import com.team007.room_escape.domain.festival.infra.repository.FestivalAccuracyVoteRepository
import com.team007.room_escape.domain.festival.infra.repository.FestivalRepository
import com.team007.room_escape.domain.member.infra.entity.Member
import com.team007.room_escape.domain.member.service.MemberReader
import com.team007.room_escape.domain.member.service.MemberTrustGradeService
import com.team007.room_escape.global.exception.BusinessException
import com.team007.room_escape.global.response.code.FestivalExceptionCode
import org.assertj.core.api.Assertions.assertThat
import org.assertj.core.api.Assertions.assertThatThrownBy
import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.extension.ExtendWith
import org.mockito.ArgumentMatchers.any
import org.mockito.InjectMocks
import org.mockito.Mock
import org.mockito.Mockito.never
import org.mockito.Mockito.verify
import org.mockito.Mockito.`when`
import org.mockito.junit.jupiter.MockitoExtension
import java.util.Optional
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

    @Test
    @DisplayName("본인이 제보한 행사의 정확도는 평가할 수 없다")
    fun rejectSelfAccuracyVote() {
        val memberId = UUID.randomUUID()
        val member = Member.builder().id(memberId).build()
        val festival = Festival.builder()
            .id(1L)
            .member(member)
            .providerType(ProviderType.MEMBER)
            .build()
        val request = FestivalAccuracyVoteRequest.Upsert(FestivalAccuracyVoteType.ACCURATE)

        `when`(memberReader.getActiveMember(memberId)).thenReturn(member)
        `when`(
            festivalRepository.findByIdAndProviderTypeAndDeletedAtIsNull(1L, ProviderType.MEMBER)
        ).thenReturn(Optional.of(festival))

        assertThatThrownBy { accuracyVoteService.vote(memberId, 1L, request) }
            .isInstanceOfSatisfying(BusinessException::class.java) { exception ->
                assertThat(exception.exceptionCode)
                    .isEqualTo(FestivalExceptionCode.SELF_ACCURACY_VOTE_NOT_ALLOWED)
            }

        verify(accuracyVoteRepository, never()).save(any(FestivalAccuracyVote::class.java))
    }
}
