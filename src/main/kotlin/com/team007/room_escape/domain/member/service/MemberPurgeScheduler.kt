package com.team007.room_escape.domain.member.service

import com.team007.room_escape.domain.member.infra.repository.MemberRepository
import com.team007.room_escape.global.storage.R2StorageService
import org.slf4j.LoggerFactory
import org.springframework.beans.factory.annotation.Value
import org.springframework.scheduling.annotation.Scheduled
import org.springframework.stereotype.Component
import org.springframework.transaction.annotation.Transactional
import java.time.LocalDateTime

/** 보관 기간이 지난 탈퇴 회원의 개인정보를 파기한다. 보관 기간이 곧 재가입 차단 기간이다. */
@Component
class MemberPurgeScheduler(
    private val memberRepository: MemberRepository,
    private val storage: R2StorageService,
    /** 탈퇴 후 개인정보를 보관하는 기간(개월). */
    @Value("\${privacy.withdrawn-retention-months:6}") private val retentionMonths: Int,
) {

    private val log = LoggerFactory.getLogger(javaClass)

    @Scheduled(cron = "\${privacy.purge-cron:0 30 4 * * *}")
    @Transactional
    fun purgeWithdrawnMembers() {
        val threshold = LocalDateTime.now().minusMonths(retentionMonths.toLong())

        // 파기 쿼리가 프로필 이미지 key를 지우기 전에 읽어 둔다. DB만 비우면 사진이 공개 URL로 계속 열린다.
        val profileImages = memberRepository.findProfileImagesToPurge(threshold)

        val purged = memberRepository.purgeWithdrawnBefore(threshold)

        profileImages.forEach { storage.discardOwnedBy(it.key, it.memberId) }

        // 배치가 도는지 확인하려고 0건이어도 남긴다.
        log.info("[privacy] 탈퇴 회원 개인정보 파기 {}건 (기준 {}개월, {} 이전)", purged, retentionMonths, threshold)
    }
}
