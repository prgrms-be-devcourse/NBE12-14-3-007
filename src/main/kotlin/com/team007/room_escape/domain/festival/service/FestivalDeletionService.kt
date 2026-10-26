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

    /** 복구도 등록·수정과 같은 행사명·지역·날짜 기준으로 확인한다. */
    private fun validateRestoreDuplicate(festival: Festival) {
        if (festival.providerType != ProviderType.MEMBER) return
        val beginDe = festival.beginDe
        val endDe = festival.endDe
        val region = festival.region
        val title = festival.title
        val district = festival.district
        if (beginDe == null || endDe == null || region == null || title.isNullOrBlank() || district == null) {
            throw BusinessException(FestivalExceptionCode.RESTORE_DATA_INCOMPLETE)
        }
        duplicateValidator.validate(festival.id, beginDe, endDe, region, title,
            SubmissionRegions.validate(region, district))
    }

    private fun refreshGrade(festival: Festival) {
        // 집계 쿼리 전에 삭제/복구 상태를 DB에 반영한다.
        festivalRepository.flush()
        memberTrustGradeService.refreshForFestival(festival)
    }
}
