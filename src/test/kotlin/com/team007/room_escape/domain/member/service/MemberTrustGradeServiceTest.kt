package com.team007.room_escape.domain.member.service

import com.team007.room_escape.domain.festival.infra.entity.Festival
import com.team007.room_escape.domain.festival.infra.entity.ProviderType
import com.team007.room_escape.domain.festival.infra.repository.FestivalAccuracyVoteRepository
import com.team007.room_escape.domain.like.infra.repository.LikeRepository
import com.team007.room_escape.domain.member.infra.entity.Member
import com.team007.room_escape.domain.member.infra.entity.MemberRole
import com.team007.room_escape.domain.member.infra.repository.MemberRepository
import com.team007.room_escape.support.anyDateTime
import com.team007.room_escape.support.eqOf
import jakarta.persistence.EntityManager
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.extension.ExtendWith
import org.mockito.ArgumentMatchers.any
import org.mockito.ArgumentMatchers.eq
import org.mockito.InjectMocks
import org.mockito.Mock
import org.mockito.Mockito.verify
import org.mockito.Mockito.verifyNoInteractions
import org.mockito.Mockito.`when`
import org.mockito.junit.jupiter.MockitoExtension
import java.time.LocalDateTime
import java.util.UUID

@ExtendWith(MockitoExtension::class)
class MemberTrustGradeServiceTest {

    @field:Mock
    private lateinit var likeRepository: LikeRepository

    @field:Mock
    private lateinit var accuracyVoteRepository: FestivalAccuracyVoteRepository

    @field:Mock
    private lateinit var memberRepository: MemberRepository

    @field:Mock
    private lateinit var entityManager: EntityManager

    @field:InjectMocks
    private lateinit var memberTrustGradeService: MemberTrustGradeService

    @Test
    @DisplayName("좋아요 또는 정확해요 중 하나가 10개 이상이면 탈출 메이커 등급이 된다")
    fun becomeRecognizedWhenEitherConditionIsMet() {
        val author = author(MemberRole.ROLE_UNVERIFIED)
        val festival = festivalBy(author)
        `when`(likeRepository.countReceivedFestivalLikesByAuthorId(author.id)).thenReturn(10L)
        `when`(accuracyVoteRepository.countReceivedAccurateVotesByAuthorId(author.id)).thenReturn(9L)

        memberTrustGradeService.refreshForFestival(festival)

        verify(memberRepository).updateTrustGrade(
            eqOf(author.id), eqOf(MemberRole.ROLE_RECOGNIZED), anyDateTime()
        )
    }

    @Test
    @DisplayName("좋아요와 정확해요가 모두 10개 이상이면 신뢰 제보자가 된다")
    fun becomeTrustedWhenBothConditionsAreMet() {
        val author = author(MemberRole.ROLE_UNVERIFIED)
        val festival = festivalBy(author)
        `when`(likeRepository.countReceivedFestivalLikesByAuthorId(author.id)).thenReturn(10L)
        `when`(accuracyVoteRepository.countReceivedAccurateVotesByAuthorId(author.id)).thenReturn(10L)

        memberTrustGradeService.refreshForFestival(festival)

        verify(memberRepository).updateTrustGrade(
            eqOf(author.id), eqOf(MemberRole.ROLE_TRUSTED), anyDateTime()
        )
    }

    @Test
    @DisplayName("제재 회원과 관리자는 자동 등급 계산으로 변경하지 않는다")
    fun preserveWarningAndAdmin() {
        val warning = author(MemberRole.ROLE_WARNING)
        val admin = author(MemberRole.ROLE_ADMIN)
        memberTrustGradeService.refreshForFestival(festivalBy(warning))
        memberTrustGradeService.refreshForFestival(festivalBy(admin))

        assertThat(warning.role).isEqualTo(MemberRole.ROLE_WARNING)
        assertThat(admin.role).isEqualTo(MemberRole.ROLE_ADMIN)
        verifyNoInteractions(likeRepository, accuracyVoteRepository, memberRepository, entityManager)
    }

    private fun author(role: MemberRole): Member = Member(
        email = "member@test.com",
        password = "pw",
        role = role,
        nickname = "닉네임",
        id = UUID.randomUUID(),
    )

    private fun festivalBy(author: Member): Festival = Festival.builder()
        .member(author)
        .providerType(ProviderType.MEMBER)
        .build()
}
