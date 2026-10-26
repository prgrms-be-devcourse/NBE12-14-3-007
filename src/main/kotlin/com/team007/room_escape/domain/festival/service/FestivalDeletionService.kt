package com.team007.room_escape.domain.festival.service

import com.team007.room_escape.domain.deletion.infra.entity.DeletionTargetType
import com.team007.room_escape.domain.deletion.service.DeletionHistoryService
import com.team007.room_escape.domain.festival.infra.entity.Festival
import com.team007.room_escape.domain.festival.infra.entity.ProviderType
import com.team007.room_escape.domain.festival.infra.repository.FestivalRepository
import com.team007.room_escape.domain.member.service.MemberTrustGradeService
import com.team007.room_escape.global.exception.BusinessException
import com.team007.room_escape.global.response.code.FestivalExceptionCode
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.util.UUID

/** 삭제와 복구 후 등급 계산을 모든 호출 경로에서 동일하게 처리한다. */
@Service
class FestivalDeletionService(
    private val festivalRepository: FestivalRepository,
    private val memberTrustGradeService: MemberTrustGradeService,
    private val deletionHistoryService: DeletionHistoryService,
    private val duplicateValidator: FestivalDuplicateValidator
) {
    @Transactional
    fun delete(festival: Festival) {
        festival.delete()
        refreshGrade(festival)
    }

    @Transactional
    fun deleteByAuthor(festival: Festival, actorId: UUID) {
        delete(festival)
        deletionHistoryService.recordAuthorDeletion(
            DeletionTargetType.FESTIVAL, festival.id!!.toString(), actorId
        )
    }

    @Transactional
    fun restore(festival: Festival) {
        validateRestoreDuplicate(festival)
        festival.restore()
        refreshGrade(festival)
    }

    /** 새 중복 정책은 적용하지 않고 기존 회원 제보의 날짜·지역·링크 기준을 사용한다. */
    private fun validateRestoreDuplicate(festival: Festival) {
        if (festival.providerType != ProviderType.MEMBER) {
            return
        }
        val beginDe = festival.beginDe
        val endDe = festival.endDe
        val region = festival.region
        val url = festival.url
        // Java String.isBlank()와 같은 공백 판정을 유지한다.
        if (beginDe == null || endDe == null || region == null || url == null
            || url.codePoints().allMatch { Character.isWhitespace(it) }
        ) {
            throw BusinessException(FestivalExceptionCode.RESTORE_DATA_INCOMPLETE)
        }
        duplicateValidator.validate(festival.id, beginDe, endDe, region, url)
    }

    private fun refreshGrade(festival: Festival) {
        // 집계 쿼리 전에 삭제/복구 상태를 DB에 반영한다.
        festivalRepository.flush()
        memberTrustGradeService.refreshForFestival(festival)
    }
}
