package com.team007.room_escape.domain.member.service

import com.team007.room_escape.domain.member.infra.repository.MemberRepository
import com.team007.room_escape.support.anyDateTime
import com.team007.room_escape.support.capture
import org.assertj.core.api.Assertions.assertThat
import org.assertj.core.api.Assertions.assertThatCode
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.mockito.ArgumentCaptor
import org.mockito.Mockito.mock
import org.mockito.Mockito.verify
import org.mockito.Mockito.`when`
import java.time.LocalDateTime

/**
 * 파기 배치가 저장소에 넘기는 기준 시각을 검증한다.
 * 기준 시각이 미래가 되면 탈퇴 회원 전체가 한 번에 파기되므로
 * 방향과 보관 기간 반영을 쿼리와 분리해 확인한다.
 */
class MemberPurgeSchedulerTest {

    private lateinit var memberRepository: MemberRepository
    private lateinit var scheduler: MemberPurgeScheduler

    @BeforeEach
    fun setUp() {
        memberRepository = mock(MemberRepository::class.java)
        scheduler = MemberPurgeScheduler(memberRepository, RETENTION_MONTHS)
    }

    private fun capturedThreshold(): LocalDateTime {
        val threshold = ArgumentCaptor.forClass(LocalDateTime::class.java)
        verify(memberRepository).purgeWithdrawnBefore(capture(threshold, LocalDateTime.MIN))
        return threshold.value
    }

    @Test
    fun 보관_기간만큼_과거_시각을_기준으로_파기를_요청한다() {
        `when`(memberRepository.purgeWithdrawnBefore(anyDateTime())).thenReturn(0)
        val before = LocalDateTime.now()

        scheduler.purgeWithdrawnMembers()

        assertThat(capturedThreshold())
            .isAfterOrEqualTo(before.minusMonths(RETENTION_MONTHS.toLong()))
            .isBeforeOrEqualTo(LocalDateTime.now().minusMonths(RETENTION_MONTHS.toLong()))
    }

    /** 기준 시각이 현재보다 미래면 탈퇴 직후 회원까지 파기된다. */
    @Test
    fun 기준_시각은_반드시_현재보다_과거다() {
        `when`(memberRepository.purgeWithdrawnBefore(anyDateTime())).thenReturn(0)

        scheduler.purgeWithdrawnMembers()

        assertThat(capturedThreshold()).isBefore(LocalDateTime.now())
    }

    @Test
    fun 파기할_회원이_없어도_정상_종료한다() {
        `when`(memberRepository.purgeWithdrawnBefore(anyDateTime())).thenReturn(0)

        assertThatCode { scheduler.purgeWithdrawnMembers() }.doesNotThrowAnyException()
    }

    private companion object {
        const val RETENTION_MONTHS = 6
    }
}
