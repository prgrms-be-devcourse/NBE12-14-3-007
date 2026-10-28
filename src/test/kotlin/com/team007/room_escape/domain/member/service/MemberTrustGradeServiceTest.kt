package com.team007.room_escape.domain.member.service

import com.team007.room_escape.domain.member.infra.repository.MemberTrustGradeRepository
import com.team007.room_escape.support.anyDateTime
import com.team007.room_escape.support.eqOf
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test
import org.mockito.Mockito.mock
import org.mockito.Mockito.never
import org.mockito.Mockito.verify
import org.mockito.Mockito.`when`

class MemberTrustGradeServiceTest {

    private val trustGrades = mock(MemberTrustGradeRepository::class.java)
    private val service = MemberTrustGradeService(trustGrades)

    @Test
    fun `잠금을 잡으면 기준 10개로 집계하고 바뀐 회원 수를 돌려준다`() {
        `when`(trustGrades.tryAcquireNightlyLock()).thenReturn(true)
        `when`(trustGrades.recalculateAuthorGrades(eqOf(10L), anyDateTime())).thenReturn(3)

        assertThat(service.recalculateAll()).isEqualTo(3)

        verify(trustGrades).recalculateAuthorGrades(eqOf(10L), anyDateTime())
    }

    @Test
    fun `다른 서버가 이미 집계 중이면 아무것도 하지 않고 null을 돌려준다`() {
        `when`(trustGrades.tryAcquireNightlyLock()).thenReturn(false)

        assertThat(service.recalculateAll()).isNull()

        verify(trustGrades, never()).recalculateAuthorGrades(eqOf(10L), anyDateTime())
    }
}
