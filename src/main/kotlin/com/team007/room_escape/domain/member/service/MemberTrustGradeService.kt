package com.team007.room_escape.domain.member.service

import com.team007.room_escape.domain.member.infra.repository.MemberTrustGradeRepository
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.time.LocalDateTime

/**
 * 신뢰 등급 자정 집계.
 * 좋아요·평가가 달릴 때마다 바로 계산하지 않고, 하루에 한 번 모든 행사 작성자의 등급을 한꺼번에 계산해 반영한다.
 * 제재·관리자·탈퇴 회원과 관리자가 직접 바꿔 고정한 회원은 건드리지 않는다.
 */
@Service
class MemberTrustGradeService(
    private val trustGrades: MemberTrustGradeRepository,
) {

    /**
     * 모든 행사 작성자의 등급을 다시 계산한다. 바뀐 회원 수를 돌려준다.
     * 다른 서버가 이미 집계하고 있으면 아무것도 하지 않고 null 을 돌려준다.
     */
    @Transactional
    fun recalculateAll(): Int? {
        if (!trustGrades.tryAcquireNightlyLock()) return null
        return trustGrades.recalculateAuthorGrades(GRADE_THRESHOLD, LocalDateTime.now())
    }

    private companion object {
        const val GRADE_THRESHOLD = 10L
    }
}
