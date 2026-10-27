package com.team007.room_escape.domain.member.service

import com.team007.room_escape.domain.member.infra.repository.MemberRepository
import com.team007.room_escape.domain.member.infra.repository.PurgedProfileImage
import com.team007.room_escape.global.storage.R2StorageService
import com.team007.room_escape.support.anyDateTime
import com.team007.room_escape.support.capture
import org.assertj.core.api.Assertions.assertThat
import org.assertj.core.api.Assertions.assertThatCode
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.mockito.ArgumentCaptor
import org.mockito.Mockito.inOrder
import org.mockito.Mockito.mock
import org.mockito.Mockito.never
import org.mockito.Mockito.verify
import org.mockito.Mockito.`when`
import java.time.LocalDateTime
import java.util.UUID

/**
 * 파기 배치가 저장소에 넘기는 기준 시각을 검증한다.
 * 기준 시각이 미래가 되면 탈퇴 회원 전체가 한 번에 파기되므로
 * 방향과 보관 기간 반영을 쿼리와 분리해 확인한다.
 */
class MemberPurgeSchedulerTest {

    private lateinit var memberRepository: MemberRepository
    private lateinit var storage: R2StorageService
    private lateinit var scheduler: MemberPurgeScheduler

    @BeforeEach
    fun setUp() {
        memberRepository = mock(MemberRepository::class.java)
        storage = mock(R2StorageService::class.java)
        scheduler = MemberPurgeScheduler(memberRepository, storage, RETENTION_MONTHS)
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

    /** 파기 쿼리가 key를 지운 뒤에는 어떤 파일을 지울지 알 수 없으므로, 반드시 파기 전에 읽어야 한다. */
    @Test
    fun 파기하기_전에_프로필_이미지를_읽어_R2에서_지운다() {
        val first = PurgedProfileImage(UUID.randomUUID(), "profiles/a/1.png")
        val second = PurgedProfileImage(UUID.randomUUID(), "profiles/b/2.png")
        `when`(memberRepository.findProfileImagesToPurge(anyDateTime())).thenReturn(listOf(first, second))
        `when`(memberRepository.purgeWithdrawnBefore(anyDateTime())).thenReturn(2)

        scheduler.purgeWithdrawnMembers()

        val order = inOrder(memberRepository, storage)
        order.verify(memberRepository).findProfileImagesToPurge(anyDateTime())
        order.verify(memberRepository).purgeWithdrawnBefore(anyDateTime())
        order.verify(storage).discardOwnedBy(first.key, first.memberId)
        order.verify(storage).discardOwnedBy(second.key, second.memberId)
    }

    @Test
    fun 지울_이미지가_없으면_R2를_건드리지_않는다() {
        `when`(memberRepository.findProfileImagesToPurge(anyDateTime())).thenReturn(emptyList())
        `when`(memberRepository.purgeWithdrawnBefore(anyDateTime())).thenReturn(0)

        scheduler.purgeWithdrawnMembers()

        verify(storage, never()).discardOwnedBy(org.mockito.ArgumentMatchers.anyString(), org.mockito.ArgumentMatchers.any())
    }

    private companion object {
        const val RETENTION_MONTHS = 6
    }
}
