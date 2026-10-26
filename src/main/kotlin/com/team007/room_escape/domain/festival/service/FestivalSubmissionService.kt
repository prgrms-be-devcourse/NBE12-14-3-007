package com.team007.room_escape.domain.festival.service

import com.team007.room_escape.domain.deletion.infra.entity.DeletionTargetType
import com.team007.room_escape.domain.deletion.service.DeletionHistoryService
import com.team007.room_escape.domain.festival.dto.FestivalSubmissionRequest
import com.team007.room_escape.domain.festival.dto.FestivalSubmissionResponse
import com.team007.room_escape.domain.festival.infra.entity.Festival
import com.team007.room_escape.domain.festival.infra.entity.FestivalStatus
import com.team007.room_escape.domain.festival.infra.entity.FestivalSubmission
import com.team007.room_escape.domain.festival.infra.entity.ProviderType
import com.team007.room_escape.domain.festival.infra.repository.FestivalRepository
import com.team007.room_escape.domain.festival.infra.repository.FestivalSubmissionRepository
import com.team007.room_escape.domain.member.service.MemberReader
import com.team007.room_escape.global.exception.BusinessException
import com.team007.room_escape.global.response.code.FestivalExceptionCode
import com.team007.room_escape.global.util.RichTextSanitizer
import org.hibernate.exception.ConstraintViolationException
import org.springframework.dao.DataIntegrityViolationException
import org.springframework.dao.OptimisticLockingFailureException
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.util.UUID

@Service
class FestivalSubmissionService(
    private val festivalRepository: FestivalRepository,
    private val festivalSubmissionRepository: FestivalSubmissionRepository,
    private val memberReader: MemberReader,
    private val richTextSanitizer: RichTextSanitizer,
    private val festivalDeletionService: FestivalDeletionService,
    private val deletionHistories: DeletionHistoryService,
    private val duplicateValidator: FestivalDuplicateValidator
) {
    @Transactional
    fun create(memberId: UUID, request: FestivalSubmissionRequest.Upsert): FestivalSubmissionResponse.Create {
        val member = memberReader.getUnrestrictedMember(memberId)
        val normalizedReferenceUrl = validateNotDuplicated(null, request)
        val festival = Festival(
            member = member, providerType = ProviderType.MEMBER,
            title = request.title, category = request.category,
            content = richTextSanitizer.sanitize(request.festivalContent), url = normalizedReferenceUrl,
            region = request.region, regionDetail = request.regionDetail, imgUrl = request.imgUrl,
            beginDe = request.beginDe, endDe = request.endDe,
            partcptExpnInfo = request.partcptExpnInfo, telnoInfo = request.telnoInfo,
            status = FestivalStatus.from(request.endDe)
        )
        val savedFestival = saveFestival(festival)
        val savedSubmission = festivalSubmissionRepository.save(FestivalSubmission(festival = savedFestival))
        return FestivalSubmissionResponse.Create.from(savedFestival, savedSubmission)
    }

    @Transactional(readOnly = true)
    fun findAllByMemberId(memberId: UUID): List<FestivalSubmissionResponse.ListItem> {
        val submissions = festivalSubmissionRepository
            .findAllByFestival_Member_IdAndFestival_ProviderTypeOrderByCreatedAtDesc(memberId, ProviderType.MEMBER)
        val histories = deletionHistories.findLatestForTargets(
            DeletionTargetType.FESTIVAL,
            submissions.map { it.festival }.filter { it.isDeleted() }.map { it.requiredId.toString() }
        )
        return submissions.map {
            FestivalSubmissionResponse.ListItem.from(it, histories[it.festival.requiredId.toString()])
        }
    }

    @Transactional(readOnly = true)
    fun findById(memberId: UUID, submissionId: UUID): FestivalSubmissionResponse.Detail {
        val submission = findSubmission(memberId, submissionId)
        val festival = submission.festival
        val latest = if (festival.isDeleted()) {
            deletionHistories.findLatest(DeletionTargetType.FESTIVAL, festival.requiredId.toString())
        } else null
        return FestivalSubmissionResponse.Detail.from(submission, latest)
    }

    @Transactional
    fun update(memberId: UUID, submissionId: UUID, request: FestivalSubmissionRequest.Upsert): FestivalSubmissionResponse.Detail {
        memberReader.getUnrestrictedMember(memberId)
        val submission = findSubmission(memberId, submissionId)
        val festival = submission.festival
        if (festival.isDeleted()) throw BusinessException(FestivalExceptionCode.FESTIVAL_NOT_FOUND)
        val version = request.version
            ?: throw BusinessException(FestivalExceptionCode.EDIT_VERSION_REQUIRED)
        if (version != festival.version) throw BusinessException(FestivalExceptionCode.EDIT_CONFLICT)
        val normalizedReferenceUrl = validateNotDuplicated(festival.id, request)
        festival.updateDetails(
            request.title, request.category, richTextSanitizer.sanitize(request.festivalContent),
            normalizedReferenceUrl, request.region, request.regionDetail, request.imgUrl,
            request.beginDe, request.endDe, request.partcptExpnInfo, request.telnoInfo
        )
        flushFestivalChanges()
        return FestivalSubmissionResponse.Detail.from(submission, null)
    }

    @Transactional
    fun delete(memberId: UUID, submissionId: UUID) {
        val submission = findSubmission(memberId, submissionId)
        val festival = festivalRepository.findForDeletion(submission.festival.requiredId)
            ?: throw BusinessException(FestivalExceptionCode.FESTIVAL_NOT_FOUND)
        festivalDeletionService.deleteByAuthor(festival, memberId)
    }

    /**
     * 같은 기간·지역·주소의 행사가 이미 있는지 확인하고, 비교에 쓴 정규화된 주소를 돌려준다.
     * 요청 검증(@NotNull)을 통과했다면 이 값들은 항상 있다.
     */
    private fun validateNotDuplicated(currentFestivalId: Long?, request: FestivalSubmissionRequest.Upsert): String {
        val normalizedReferenceUrl = duplicateValidator.normalizeReferenceUrl(
            requireNotNull(request.referenceUrl) { "검증을 통과한 요청에는 참고 주소가 있다." },
        )
        duplicateValidator.validate(
            currentFestivalId,
            requireNotNull(request.beginDe) { "검증을 통과한 요청에는 시작 일시가 있다." },
            requireNotNull(request.endDe) { "검증을 통과한 요청에는 종료 일시가 있다." },
            requireNotNull(request.region) { "검증을 통과한 요청에는 지역이 있다." },
            normalizedReferenceUrl,
        )
        return normalizedReferenceUrl
    }

    private fun findSubmission(memberId: UUID, submissionId: UUID): FestivalSubmission =
        festivalSubmissionRepository.findByIdAndFestival_Member_Id(submissionId, memberId)
            ?: throw BusinessException(FestivalExceptionCode.FESTIVAL_SUBMISSION_NOT_FOUND)

    private fun saveFestival(festival: Festival): Festival {
        try {
            return festivalRepository.saveAndFlush(festival)
        } catch (exception: DataIntegrityViolationException) {
            throw translateDuplicateConstraint(exception)
        }
    }

    private fun flushFestivalChanges() {
        try {
            festivalRepository.flush()
        } catch (exception: OptimisticLockingFailureException) {
            throw BusinessException(FestivalExceptionCode.EDIT_CONFLICT)
        } catch (exception: DataIntegrityViolationException) {
            throw translateDuplicateConstraint(exception)
        }
    }

    private fun translateDuplicateConstraint(exception: DataIntegrityViolationException): RuntimeException {
        val duplicated = generateSequence<Throwable>(exception) { it.cause }.any {
            it is ConstraintViolationException && it.constraintName == DUPLICATE_CONSTRAINT_NAME
        }
        return if (duplicated) BusinessException(FestivalExceptionCode.DUPLICATE_FESTIVAL) else exception
    }

    companion object {
        private const val DUPLICATE_CONSTRAINT_NAME = "uk_member_festival_schedule_region_url"
    }
}
