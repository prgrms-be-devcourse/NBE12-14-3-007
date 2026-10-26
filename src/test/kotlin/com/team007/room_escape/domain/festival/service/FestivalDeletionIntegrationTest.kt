package com.team007.room_escape.domain.festival.service

import com.team007.room_escape.domain.deletion.dto.AdminDeletionRequest
import com.team007.room_escape.domain.deletion.infra.entity.DeletionActorType
import com.team007.room_escape.domain.deletion.infra.entity.DeletionReason
import com.team007.room_escape.domain.deletion.infra.entity.DeletionTargetType
import com.team007.room_escape.domain.deletion.service.AdminDeletionFacade
import com.team007.room_escape.domain.deletion.service.DeletionHistoryService
import com.team007.room_escape.domain.festival.dto.FestivalAccuracyVoteRequest
import com.team007.room_escape.domain.festival.infra.entity.Festival
import com.team007.room_escape.domain.festival.infra.entity.FestivalAccuracyVote
import com.team007.room_escape.domain.festival.infra.entity.FestivalAccuracyVoteType
import com.team007.room_escape.domain.festival.infra.entity.FestivalRegion
import com.team007.room_escape.domain.festival.infra.entity.FestivalSubmission
import com.team007.room_escape.domain.festival.infra.entity.ProviderType
import com.team007.room_escape.domain.festival.infra.repository.FestivalAccuracyVoteRepository
import com.team007.room_escape.domain.festival.infra.repository.FestivalRepository
import com.team007.room_escape.domain.festival.infra.repository.FestivalSubmissionRepository
import com.team007.room_escape.domain.inquiry.service.InquiryDeletionProcessor
import com.team007.room_escape.domain.like.infra.entity.Like
import com.team007.room_escape.domain.like.infra.repository.LikeRepository
import com.team007.room_escape.domain.member.infra.entity.Member
import com.team007.room_escape.domain.member.infra.entity.MemberRole
import com.team007.room_escape.domain.member.infra.repository.MemberRepository
import com.team007.room_escape.domain.member.service.MemberReader
import com.team007.room_escape.domain.member.service.MemberTrustGradeService
import com.team007.room_escape.global.config.R2Properties
import com.team007.room_escape.global.exception.BusinessException
import com.team007.room_escape.global.response.code.FestivalExceptionCode
import com.team007.room_escape.global.util.RichTextSanitizer
import com.team007.room_escape.support.TestDatabase
import jakarta.persistence.EntityManager
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.assertThrows
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.data.jpa.test.autoconfigure.DataJpaTest
import org.springframework.boot.context.properties.EnableConfigurationProperties
import org.springframework.boot.jdbc.test.autoconfigure.AutoConfigureTestDatabase
import org.springframework.boot.test.context.TestConfiguration
import org.springframework.context.annotation.Import
import org.springframework.test.context.DynamicPropertyRegistry
import org.springframework.test.context.DynamicPropertySource
import java.time.LocalDateTime
import java.util.UUID

@DataJpaTest(properties = [
    "spring.datasource.username=roomescape",
    "spring.datasource.password=roomescape",
    "spring.flyway.locations=classpath:db/migration,classpath:db/migration_v2",
])
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.NONE)
@Import(
    FestivalDeletionService::class, FestivalSubmissionService::class, AdminDeletionFacade::class,
    FestivalDuplicateValidator::class, DeletionHistoryService::class, FestivalDeletionHandler::class,
    InquiryDeletionProcessor::class, MemberReader::class, MemberTrustGradeService::class,
    RichTextSanitizer::class, FestivalAccuracyVoteService::class,
)
class FestivalDeletionIntegrationTest @Autowired constructor(
    private val submissions: FestivalSubmissionService,
    private val admin: AdminDeletionFacade,
    private val festivals: FestivalRepository,
    private val histories: FestivalSubmissionRepository,
    private val members: MemberRepository,
    private val em: EntityManager,
    private val accuracy: FestivalAccuracyVoteService,
    private val likes: LikeRepository,
    private val votes: FestivalAccuracyVoteRepository,
) {
    companion object {
        private val TEST_SCHEMA = "festival_deletion_${UUID.randomUUID().toString().replace("-", "")}"

        @JvmStatic
        @DynamicPropertySource
        fun isolatedDatabase(properties: DynamicPropertyRegistry) {
            TestDatabase.configure(properties, TEST_SCHEMA)
            mapOf(
                "r2.account-id" to "test",
                "r2.access-key" to "test",
                "r2.secret-key" to "test",
                "r2.bucket" to "test",
                "r2.public-url" to "https://images.example.com",
            ).forEach { (key, value) -> properties.add(key) { value } }
        }
    }

    /** @DataJpaTest는 설정 클래스를 올리지 않아서, 본문 정제기가 쓰는 R2 설정만 직접 등록한다. */
    @TestConfiguration
    @EnableConfigurationProperties(R2Properties::class)
    class StorageConfiguration

    private fun operator(): UUID = members.saveAndFlush(
        Member.builder().email("${UUID.randomUUID()}@example.com")
            .password("test").nickname("관리자").role(MemberRole.ROLE_ADMIN).build(),
    ).id

    private fun deleteAsAdmin(id: Long, actor: UUID, reason: String) {
        admin.delete(actor, AdminDeletionRequest.Create(
            DeletionTargetType.FESTIVAL, id.toString(), DeletionReason.OTHER, reason, null,
        ))
    }

    private fun history(): FestivalSubmission {
        val author = members.save(
            Member.builder().email("${UUID.randomUUID()}@example.com")
                .password("test").nickname("작성자").role(MemberRole.ROLE_UNVERIFIED).build(),
        )
        val festival = festivals.save(
            Festival.builder().member(author).title("행사")
                .providerType(ProviderType.MEMBER).url("https://example.com/${UUID.randomUUID()}")
                .region(FestivalRegion.SEOUL).beginDe(LocalDateTime.of(2026, 10, 20, 10, 0))
                .endDe(LocalDateTime.of(2026, 10, 21, 18, 0)).build(),
        )
        return histories.saveAndFlush(FestivalSubmission.builder().festival(festival).build())
    }

    @Test
    fun authorDeletionSurvivesReloadAndRemainsInOwnHistoryButNotPublicLookup() {
        val history = history()
        val owner = history.festival.member.id
        val id = history.id
        val eventId = history.festival.id

        submissions.delete(owner, id)
        em.clear()
        assertThat(festivals.findByIdAndDeletedAtIsNull(eventId)).isEmpty()
        val item = submissions.findAllByMemberId(owner).first()
        assertThat(item.deletion().type()).isEqualTo(DeletionActorType.AUTHOR)
        assertThat(submissions.findById(owner, id).submission().festival().deletion().reason())
            .isEqualTo("작성자 직접 삭제")
        val operator = operator()
        assertThrows<BusinessException> { admin.restore(operator, DeletionTargetType.FESTIVAL, eventId.toString()) }
        assertThrows<BusinessException> { submissions.findById(UUID.randomUUID(), id) }
    }

    @Test
    fun administratorCanRestoreMemberSubmittedEventAndGradeIsRecalculated() {
        val history = history()
        val author = history.festival.member
        repeat(10) {
            val voter = members.save(
                Member.builder().email("${UUID.randomUUID()}@example.com")
                    .password("test").nickname("평가자").role(MemberRole.ROLE_UNVERIFIED).build(),
            )
            likes.save(Like.of(history.festival, voter))
            votes.save(FestivalAccuracyVote.builder().member(voter).festival(history.festival)
                .voteType(FestivalAccuracyVoteType.ACCURATE).build())
        }
        em.flush()
        val operator = operator()
        val id = history.festival.id
        deleteAsAdmin(id, operator, "  행사 취소 확인  ")
        assertThat(author.role).isEqualTo(MemberRole.ROLE_UNVERIFIED)

        em.clear()
        assertThat(admin.latest(operator, DeletionTargetType.FESTIVAL, id.toString()).actorType())
            .isEqualTo(DeletionActorType.ADMIN)
        admin.restore(operator, DeletionTargetType.FESTIVAL, id.toString())
        em.flush()
        em.clear()
        assertThat(festivals.findByIdAndDeletedAtIsNull(id)).isPresent()
        assertThat(members.findById(author.id).orElseThrow().role).isEqualTo(MemberRole.ROLE_TRUSTED)
    }

    @Test
    fun adminDeletionRequiresReasonWithoutChangingEvent() {
        val history = history()
        val operator = operator()

        assertThrows<BusinessException> { deleteAsAdmin(history.festival.id, operator, " ") }
        assertThat(history.festival.isDeleted()).isFalse()
    }

    @Test
    fun restoreIsRejectedWhenActiveDuplicateExists() {
        val history = history()
        val event = history.festival
        val operator = operator()
        deleteAsAdmin(event.id, operator, "오등록")
        festivals.saveAndFlush(Festival.builder().providerType(ProviderType.MEMBER)
            .url(event.url).region(event.region)
            .beginDe(event.beginDe.plusHours(1)).endDe(event.endDe.plusHours(1)).build())

        assertThrows<BusinessException> { admin.restore(operator, DeletionTargetType.FESTIVAL, event.id.toString()) }
        assertThat(event.isDeleted()).isTrue()
    }

    @Test
    fun deletedEventRejectsAccuracyVoteAndCancellation() {
        val history = history()
        val owner = history.festival.member.id
        val id = history.festival.id

        submissions.delete(owner, history.id)
        val exception = assertThrows<BusinessException> {
            accuracy.vote(owner, id, FestivalAccuracyVoteRequest.Upsert(FestivalAccuracyVoteType.ACCURATE))
        }
        assertThat(exception.exceptionCode).isEqualTo(FestivalExceptionCode.FESTIVAL_NOT_FOUND)
        assertThrows<BusinessException> { accuracy.cancelVote(owner, id) }
    }

    @Test
    fun publicEventDeletedByAdminCanBeRestored() {
        val event = history().festival
        // 공공행사는 작성자가 없어도 삭제·복구할 수 있다.
        val publicEvent = festivals.saveAndFlush(Festival.builder().providerType(ProviderType.PUBLIC)
            .beginDe(event.beginDe).endDe(event.endDe).build())
        val operator = operator()
        deleteAsAdmin(publicEvent.id, operator, "중복 수집 확인")
        admin.restore(operator, DeletionTargetType.FESTIVAL, publicEvent.id.toString())
        assertThat(publicEvent.isDeleted()).isFalse()
    }

    @Test
    fun repeatedDeleteDoesNotOverwriteOriginalReason() {
        val event = history().festival
        val operator = operator()
        deleteAsAdmin(event.id, operator, "최초 사유")

        assertThrows<BusinessException> { deleteAsAdmin(event.id, operator, "다른 사유") }
        assertThat(admin.latest(operator, DeletionTargetType.FESTIVAL, event.id.toString()).reasonDetail())
            .isEqualTo("최초 사유")
    }
}
