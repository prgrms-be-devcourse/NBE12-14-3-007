package com.team007.room_escape.domain.member.service

import com.team007.room_escape.domain.festival.infra.entity.Festival
import com.team007.room_escape.domain.festival.infra.entity.ProviderType
import com.team007.room_escape.domain.festival.infra.repository.FestivalAccuracyVoteRepository
import com.team007.room_escape.domain.like.infra.repository.LikeRepository
import com.team007.room_escape.domain.member.infra.entity.MemberRole
import com.team007.room_escape.domain.member.infra.repository.MemberRepository
import jakarta.persistence.EntityManager
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.time.LocalDateTime

@Service
class MemberTrustGradeService(
    private val likeRepository: LikeRepository,
    private val accuracyVoteRepository: FestivalAccuracyVoteRepository,
    private val memberRepository: MemberRepository,
    private val entityManager: EntityManager,
) {

    /** 행사 반응이 바뀔 때 작성자의 현재 신뢰 등급을 다시 계산한다. */
    @Transactional
    fun refreshForFestival(festival: Festival) {
        val author = festival.member
        if (festival.providerType != ProviderType.MEMBER || author == null) return
        if (author.role == MemberRole.ROLE_WARNING || author.role == MemberRole.ROLE_ADMIN) return

        val enoughLikes = likeRepository.countReceivedFestivalLikesByAuthorId(author.id) >= GRADE_THRESHOLD
        val enoughAccurateVotes = accuracyVoteRepository.countReceivedAccurateVotesByAuthorId(author.id) >= GRADE_THRESHOLD

        val grade = when {
            enoughLikes && enoughAccurateVotes -> MemberRole.ROLE_TRUSTED
            enoughLikes || enoughAccurateVotes -> MemberRole.ROLE_RECOGNIZED
            else -> MemberRole.ROLE_UNVERIFIED
        }

        memberRepository.updateTrustGrade(author.id, grade, LocalDateTime.now())
        // 직접 UPDATE는 이미 조회한 객체를 바꾸지 않는다. 전체 clear 없이 이 회원만 갱신한다.
        if (entityManager.contains(author)) entityManager.refresh(author)
    }

    private companion object {
        const val GRADE_THRESHOLD = 10L
    }
}
