package com.team007.room_escape.domain.festival.service

import com.team007.room_escape.domain.deletion.infra.entity.DeletionAction
import com.team007.room_escape.domain.deletion.infra.entity.DeletionActorType
import com.team007.room_escape.domain.deletion.infra.entity.DeletionHistory
import com.team007.room_escape.domain.deletion.infra.entity.DeletionReason
import com.team007.room_escape.domain.deletion.infra.entity.DeletionTargetType
import com.team007.room_escape.domain.deletion.service.DeletionHistoryService
import com.team007.room_escape.domain.festival.dto.FestivalSubmissionRequest
import com.team007.room_escape.domain.festival.dto.FestivalSubmissionResponse
import org.springframework.test.util.ReflectionTestUtils
import org.springframework.dao.OptimisticLockingFailureException
import org.mockito.Mockito.doThrow
import com.team007.room_escape.domain.festival.infra.entity.Festival
import com.team007.room_escape.domain.festival.infra.entity.FestivalRegion
import com.team007.room_escape.domain.festival.infra.entity.FestivalSubmission
import com.team007.room_escape.domain.festival.infra.entity.ProviderType
import com.team007.room_escape.domain.festival.infra.repository.FestivalRepository
import com.team007.room_escape.domain.festival.infra.repository.FestivalSubmissionRepository
import com.team007.room_escape.domain.member.service.MemberReader
import com.team007.room_escape.domain.member.service.MemberTrustGradeService
import com.team007.room_escape.global.exception.BusinessException
import com.team007.room_escape.global.response.code.FestivalExceptionCode
import com.team007.room_escape.global.util.RichTextSanitizer
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.assertThrows
import com.team007.room_escape.support.anyDateTime
import com.team007.room_escape.support.anyText
import org.mockito.ArgumentCaptor
import org.mockito.ArgumentMatchers.any
import org.mockito.ArgumentMatchers.anyLong
import org.mockito.ArgumentMatchers.eq
import org.mockito.ArgumentMatchers.isNull
import org.mockito.Mockito.`when`
import org.mockito.Mockito.inOrder
import org.mockito.Mockito.mock
import org.mockito.Mockito.never
import org.mockito.Mockito.verify
import java.time.LocalDateTime
import java.util.Optional
import java.util.UUID

class FestivalSubmissionServiceTest {
    private val festivals = mock(FestivalRepository::class.java)
    private val submissions = mock(FestivalSubmissionRepository::class.java)
    private val members = mock(MemberReader::class.java)
    private val deletionHistories = mock(DeletionHistoryService::class.java)
    private val deletion = FestivalDeletionService(
        festivals, mock(MemberTrustGradeService::class.java), deletionHistories, FestivalDuplicateValidator(festivals),
    )
    private val service = FestivalSubmissionService(
        festivals, submissions, members, mock(RichTextSanitizer::class.java), deletion,
        deletionHistories, FestivalDuplicateValidator(festivals),
    )
    private val memberId = UUID.randomUUID()
    private val submissionId = UUID.randomUUID()
    private val begin = LocalDateTime.of(2026, 10, 2, 10, 30)
    private val end = LocalDateTime.of(2026, 10, 3, 18, 0)

    private fun request(): FestivalSubmissionRequest.Upsert = FestivalSubmissionRequest.Upsert.builder()
        .title("행사").category("축제").region(FestivalRegion.GYEONGGI)
        .referenceUrl(" https://example.com/event/// ")
        .beginDe(begin).endDe(end).version(0L).build()

    @Test
    fun staleEditCannotOverwriteFestival() {
        val festival = Festival.create(id = 7L, title = "최신 제목")
        ReflectionTestUtils.setField(festival, "version", 2L)
        `when`(submissions.findByIdAndFestival_Member_Id(submissionId, memberId))
            .thenReturn(Optional.of(FestivalSubmission.create(festival = festival)))

        val exception = assertThrows<BusinessException> { service.update(memberId, submissionId, request()) }
        assertThat(exception.exceptionCode).isEqualTo(FestivalExceptionCode.EDIT_CONFLICT)
        assertThat(festival.title).isEqualTo("최신 제목")
        verify(festivals, never()).flush()
    }

    @Test
    fun updateRequiresVersion() {
        val festival = Festival.create(id = 7L)
        `when`(submissions.findByIdAndFestival_Member_Id(submissionId, memberId))
            .thenReturn(Optional.of(FestivalSubmission.create(festival = festival)))
        val exception = assertThrows<BusinessException> {
            service.update(memberId, submissionId, request().copy(version = null))
        }
        assertThat(exception.exceptionCode).isEqualTo(FestivalExceptionCode.EDIT_VERSION_REQUIRED)
        verify(festivals, never()).flush()
    }

    @Test
    fun concurrentUpdateFailureReturnsConflict() {
        val festival = Festival.create(id = 7L)
        `when`(submissions.findByIdAndFestival_Member_Id(submissionId, memberId))
            .thenReturn(Optional.of(FestivalSubmission.create(festival = festival)))
        doThrow(OptimisticLockingFailureException("concurrent update")).`when`(festivals).flush()
        val exception = assertThrows<BusinessException> { service.update(memberId, submissionId, request()) }
        assertThat(exception.exceptionCode).isEqualTo(FestivalExceptionCode.EDIT_CONFLICT)
    }

    @Test
    fun detailUsesFestivalModificationTimeAndVersion() {
        val festival = Festival.create(id = 7L)
        val submission = FestivalSubmission.create(festival = festival)
        val modified = LocalDateTime.of(2026, 10, 27, 12, 0)
        ReflectionTestUtils.setField(submission, "updatedAt", modified.minusDays(1))
        ReflectionTestUtils.setField(festival, "updatedAt", modified)
        ReflectionTestUtils.setField(festival, "version", 3L)
        val response = FestivalSubmissionResponse.SubmissionInfo.from(submission, null)
        assertThat(response.updatedAt).isEqualTo(modified)
        assertThat(response.version).isEqualTo(3L)
    }

    @Test
    fun duplicateCreateUsesDatesAndNormalizedUrlAndRejectsBeforeSaving() {
        `when`(festivals.existsSubmissionDuplicate(isNull(), anyDateTime(), anyDateTime(), anyDateTime(), anyDateTime(), anyText(), anyText()))
            .thenReturn(true)
        assertDuplicate { service.create(memberId, request()) }
        verify(festivals).existsSubmissionDuplicate(
            null, begin.toLocalDate().atStartOfDay(), begin.toLocalDate().plusDays(1).atStartOfDay(),
            end.toLocalDate().atStartOfDay(), end.toLocalDate().plusDays(1).atStartOfDay(),
            FestivalRegion.GYEONGGI.name, "https://example.com/event",
        )
        val order = inOrder(festivals)
        order.verify(festivals).lockSubmissionDuplicateKey(anyLong())
        order.verify(festivals).existsSubmissionDuplicate(isNull(), anyDateTime(), anyDateTime(), anyDateTime(), anyDateTime(), anyText(), anyText())
        verify(festivals, never()).saveAndFlush(any<Festival>())
        verify(submissions, never()).save(any<FestivalSubmission>())
    }

    @Test
    fun duplicateUpdateExcludesCurrentEvent() {
        val festival = Festival.builder().id(7L).build()
        `when`(submissions.findByIdAndFestival_Member_Id(submissionId, memberId))
            .thenReturn(Optional.of(FestivalSubmission.builder().festival(festival).build()))
        `when`(festivals.existsSubmissionDuplicate(eq(7L), anyDateTime(), anyDateTime(), anyDateTime(), anyDateTime(), anyText(), anyText()))
            .thenReturn(true)
        assertDuplicate { service.update(memberId, submissionId, request()) }
        assertThat(festival.title).isNull()
    }

    @Test
    fun deleteKeepsSubmissionHistoryAndMarksEventDeleted() {
        val festival = Festival.builder().id(7L).providerType(ProviderType.MEMBER).build()
        val submission = FestivalSubmission.builder().festival(festival).build()
        `when`(submissions.findByIdAndFestival_Member_Id(submissionId, memberId))
            .thenReturn(Optional.of(submission))
        `when`(festivals.findForDeletion(7L)).thenReturn(Optional.of(festival))
        service.delete(memberId, submissionId)
        assertThat(festival.isDeleted()).isTrue()
        verify(deletionHistories).recordAuthorDeletion(DeletionTargetType.FESTIVAL, "7", memberId)
    }

    @Test
    fun nonDuplicateCreateSavesNormalizedUrl() {
        `when`(festivals.saveAndFlush(any<Festival>())).thenAnswer { it.getArgument<Festival>(0) }
        `when`(submissions.save(any<FestivalSubmission>())).thenAnswer { it.getArgument<FestivalSubmission>(0) }
        service.create(memberId, request())
        val captor = ArgumentCaptor.forClass(Festival::class.java)
        verify(festivals).saveAndFlush(captor.capture())
        assertThat(captor.value.url).isEqualTo("https://example.com/event")
        verify(submissions).save(any<FestivalSubmission>())
    }

    @Test
    fun nonDuplicateUpdateStillAllowsEditingOwnEvent() {
        val festival = Festival.builder().id(7L).build()
        `when`(submissions.findByIdAndFestival_Member_Id(submissionId, memberId))
            .thenReturn(Optional.of(FestivalSubmission.builder().festival(festival).build()))
        service.update(memberId, submissionId, request())
        assertThat(festival.title).isEqualTo("행사")
        assertThat(festival.url).isEqualTo("https://example.com/event")
        verify(festivals).flush()
    }

    @Test
    fun cannotDeleteAnotherMembersSubmission() {
        `when`(submissions.findByIdAndFestival_Member_Id(submissionId, memberId)).thenReturn(Optional.empty())
        assertThrows<BusinessException> { service.delete(memberId, submissionId) }
    }

    private fun assertDuplicate(action: () -> Unit) {
        val exception = assertThrows<BusinessException> { action() }
        assertThat(exception.exceptionCode).isEqualTo(FestivalExceptionCode.DUPLICATE_FESTIVAL)
    }

    @Test
    fun deletedSubmissionRemainsInMyListWithDeletionReason() {
        val festival = Festival.builder().id(7L).title("삭제 이력").build()
        festival.delete()
        val submission = FestivalSubmission.builder().id(submissionId).festival(festival).build()
        `when`(submissions.findAllByFestival_Member_IdAndFestival_ProviderTypeOrderByCreatedAtDesc(
            memberId, ProviderType.MEMBER,
        )).thenReturn(listOf(submission))
        val record = DeletionHistory.record(
            DeletionTargetType.FESTIVAL, "7", DeletionAction.DELETE, memberId,
            DeletionActorType.AUTHOR, DeletionReason.AUTHOR_REQUEST, null,
        )
        `when`(
            deletionHistories.findLatestForTargets(DeletionTargetType.FESTIVAL, listOf("7"))
        ).thenReturn(mapOf("7" to record))
        val history = service.findAllByMemberId(memberId).first()
        assertThat(history.deletion?.deletedAt).isNotNull()
        assertThat(history.deletion?.reason).isEqualTo("작성자 직접 삭제")
    }

    @Test
    fun cannotModifyDeletedEvent() {
        val festival = Festival.builder().build()
        festival.delete()
        `when`(submissions.findByIdAndFestival_Member_Id(submissionId, memberId))
            .thenReturn(Optional.of(FestivalSubmission.builder().festival(festival).build()))
        assertThrows<BusinessException> { service.update(memberId, submissionId, request()) }
        assertThat(festival.title).isNull()
    }
}
