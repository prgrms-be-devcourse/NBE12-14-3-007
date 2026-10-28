package com.team007.room_escape.domain.deletion

import com.team007.room_escape.domain.comment.infra.entity.Comment
import com.team007.room_escape.domain.comment.service.CommentDeletionHandler
import com.team007.room_escape.domain.comment.service.CommentService
import com.team007.room_escape.domain.community.infra.entity.CommunityComment
import com.team007.room_escape.domain.community.infra.entity.CommunityPost
import com.team007.room_escape.domain.community.service.CommunityCommentDeletionHandler
import com.team007.room_escape.domain.community.service.CommunityPostDeletionHandler
import com.team007.room_escape.domain.community.service.CommunityService
import com.team007.room_escape.domain.community.type.CommunityCategory
import com.team007.room_escape.domain.deletion.dto.AdminDeletionRequest
import com.team007.room_escape.domain.deletion.infra.entity.DeletionAction
import com.team007.room_escape.domain.deletion.infra.entity.DeletionActorType
import com.team007.room_escape.domain.deletion.infra.entity.DeletionHistory
import com.team007.room_escape.domain.deletion.infra.entity.DeletionReason
import com.team007.room_escape.domain.deletion.infra.entity.DeletionTargetType
import com.team007.room_escape.domain.deletion.infra.repository.DeletionHistoryRepository
import com.team007.room_escape.domain.deletion.service.AdminDeletionFacade
import com.team007.room_escape.domain.deletion.service.DeletionHistoryService
import com.team007.room_escape.domain.festival.dto.AdminFestivalRequest
import com.team007.room_escape.domain.festival.infra.entity.Festival
import com.team007.room_escape.domain.festival.infra.entity.FestivalSubmission
import com.team007.room_escape.domain.festival.infra.entity.ProviderType
import com.team007.room_escape.domain.festival.infra.repository.FestivalRepository
import com.team007.room_escape.domain.festival.service.AdminFestivalService
import com.team007.room_escape.domain.festival.service.FestivalDeletionHandler
import com.team007.room_escape.domain.festival.service.FestivalDeletionService
import com.team007.room_escape.domain.festival.service.FestivalDuplicateValidator
import com.team007.room_escape.domain.festival.service.FestivalSubmissionService
import com.team007.room_escape.domain.inquiry.infra.entity.Inquiry
import com.team007.room_escape.domain.inquiry.infra.entity.InquiryCategory
import com.team007.room_escape.domain.inquiry.infra.entity.InquiryStatus
import com.team007.room_escape.domain.inquiry.infra.entity.InquiryTargetType
import com.team007.room_escape.domain.inquiry.service.InquiryDeletionProcessor
import com.team007.room_escape.domain.member.infra.entity.Member
import com.team007.room_escape.domain.member.infra.entity.MemberRole
import com.team007.room_escape.domain.member.infra.repository.MyContentRepository
import com.team007.room_escape.domain.member.service.MemberReader
import com.team007.room_escape.domain.member.service.MyContentService
import com.team007.room_escape.domain.post.infra.entity.Post
import com.team007.room_escape.domain.post.service.PostDeletionHandler
import com.team007.room_escape.domain.post.service.PostService
import com.team007.room_escape.global.exception.BusinessException
import com.team007.room_escape.global.storage.ImageUrlResolver
import com.team007.room_escape.global.storage.R2StorageService
import com.team007.room_escape.global.util.RichTextSanitizer
import com.team007.room_escape.support.TestDatabase
import jakarta.persistence.EntityManager
import org.assertj.core.api.Assertions.assertThat
import org.assertj.core.api.Assertions.assertThatThrownBy
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.assertThrows
import org.junit.jupiter.params.ParameterizedTest
import org.junit.jupiter.params.provider.EnumSource
import org.junit.jupiter.params.provider.ValueSource
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.data.jpa.test.autoconfigure.DataJpaTest
import org.springframework.boot.jdbc.test.autoconfigure.AutoConfigureTestDatabase
import org.springframework.context.annotation.Import
import org.springframework.data.domain.PageRequest
import org.springframework.security.access.AccessDeniedException
import org.springframework.test.context.DynamicPropertyRegistry
import org.springframework.test.context.DynamicPropertySource
import org.springframework.test.context.bean.override.mockito.MockitoBean
import org.springframework.test.context.transaction.TestTransaction
import java.util.UUID
import java.util.function.Consumer

@DataJpaTest(properties = [
    "spring.datasource.username=roomescape", "spring.datasource.password=roomescape",
    "spring.flyway.locations=classpath:db/migration,classpath:db/migration_v2",
    "spring.jpa.hibernate.ddl-auto=validate",
])
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.NONE)
@Import(
    AdminDeletionFacade::class, InquiryDeletionProcessor::class, DeletionHistoryService::class,
    FestivalDeletionHandler::class, PostDeletionHandler::class, CommentDeletionHandler::class,
    CommunityPostDeletionHandler::class, CommunityCommentDeletionHandler::class,
    FestivalDeletionService::class, AdminFestivalService::class, FestivalSubmissionService::class,
    FestivalDuplicateValidator::class, MyContentService::class, MyContentRepository::class,
    MemberReader::class, PostService::class, CommentService::class, CommunityService::class,
)
class DeletionHistoryRepositoryTest @Autowired constructor(
    private val entityManager: EntityManager,
    private val histories: DeletionHistoryRepository,
    private val historyService: DeletionHistoryService,
    private val facade: AdminDeletionFacade,
    private val festivals: FestivalRepository,
    private val festivalDeletionService: FestivalDeletionService,
    private val adminFestivals: AdminFestivalService,
    private val submissions: FestivalSubmissionService,
    private val myContents: MyContentService,
    private val postService: PostService,
    private val commentService: CommentService,
    private val communityService: CommunityService,
) {
    companion object {
        private val SCHEMA = "history_${UUID.randomUUID().toString().replace("-", "")}"

        @JvmStatic
        @DynamicPropertySource
        fun database(registry: DynamicPropertyRegistry) {
            TestDatabase.configure(registry, SCHEMA)
        }
    }

    @field:MockitoBean
    private lateinit var sanitizer: RichTextSanitizer

    @field:MockitoBean
    private lateinit var imageUrlResolver: ImageUrlResolver

    @field:MockitoBean
    private lateinit var storageService: R2StorageService

    private fun member(nickname: String, role: MemberRole): Member =
        Member(
            email = "${UUID.randomUUID()}@example.com",
            password = "test",
            role = role,
            nickname = nickname,
        ).also(entityManager::persist)

    private fun publicFestival(title: String): Festival = festivals.saveAndFlush(
        Festival(providerType = ProviderType.PUBLIC, title = title),
    )

    @Test
    fun administratorCommentListKeepsOriginalAndHistoryWhilePublicListRedactsDeletedComments() {
        val admin = member("관리자", MemberRole.ROLE_ADMIN)
        val author = member("작성자", MemberRole.ROLE_UNVERIFIED)
        val post = Post(member = author, title = "댓글 관리 후기", content = "내용")
        entityManager.persist(post)
        val comment = Comment(post = post, member = author, content = "삭제 후에도 관리자가 확인할 댓글")
        entityManager.persist(comment)
        entityManager.flush()
        facade.delete(admin.id, AdminDeletionRequest.Create(
            DeletionTargetType.COMMENT, comment.id.toString(), DeletionReason.SPAM, "반복 게시 확인", null,
        ))
        entityManager.flush()
        entityManager.clear()
        val page = PageRequest.of(0, 20)
        val removed = commentService.getCommentsForAdmin(checkNotNull(post.id), admin.id, page).content.first()
        assertThat(removed.content).isEqualTo("삭제 후에도 관리자가 확인할 댓글")
        assertThat(removed.deletedAt).isNotNull()
        assertThat(removed.deletion?.actorType()).isEqualTo(DeletionActorType.ADMIN)
        assertThat(removed.deletion?.reasonDetail()).isEqualTo("반복 게시 확인")
        assertThat(removed.parentDeleted).isFalse()
        val publicComment = commentService.getComments(checkNotNull(post.id), page).content.first()
        assertThat(publicComment.deleted).isTrue()
        assertThat(publicComment.content).isEqualTo("삭제된 댓글입니다")
        assertThat(publicComment.member).isNull()
        facade.restore(admin.id, DeletionTargetType.COMMENT, comment.id.toString())
        entityManager.flush()
        entityManager.clear()
        assertThat(commentService.getCommentsForAdmin(checkNotNull(post.id), admin.id, page).content.first().deletedAt).isNull()
        assertThat(commentService.getComments(checkNotNull(post.id), page)).hasSize(1)
    }

    @Test
    fun administratorCommentListRetainsAuthorDeletionAndDeletedParentButRejectsOrdinaryMembers() {
        val admin = member("관리자", MemberRole.ROLE_ADMIN)
        val author = member("작성자", MemberRole.ROLE_UNVERIFIED)
        val post = Post(member = author, title = "삭제된 부모 후기", content = "내용")
        entityManager.persist(post)
        val comment = Comment(post = post, member = author, content = "작성자가 삭제한 댓글")
        entityManager.persist(comment)
        entityManager.flush()
        commentService.deleteComment(checkNotNull(comment.id), author.id)
        post.delete()
        entityManager.flush()
        entityManager.clear()
        val page = PageRequest.of(0, 20)
        val removed = commentService.getCommentsForAdmin(checkNotNull(post.id), admin.id, page).content.first()
        assertThat(removed.parentDeleted).isTrue()
        assertThat(removed.deletion?.actorType()).isEqualTo(DeletionActorType.AUTHOR)
        assertThat(commentService.getCommentsForAdmin(checkNotNull(post.id), admin.id, PageRequest.of(1, 20))).isEmpty()
        assertThrows<AccessDeniedException> { commentService.getCommentsForAdmin(checkNotNull(post.id), author.id, page) }
    }

    @Test
    fun adminReplyRestorationPreservesThreadAndIndependentDeletionAfterParentPostRestoration() {
        val admin = member("관리자", MemberRole.ROLE_ADMIN)
        val author = member("작성자", MemberRole.ROLE_UNVERIFIED)
        val post = Post(member = author, title = "대댓글 복구 검증", content = "본문")
        entityManager.persist(post)
        val root = Comment(post = post, member = author, content = "부모 댓글")
        entityManager.persist(root)
        val reply = Comment(post = post, member = author, parent = root, content = "관리자가 삭제할 답글")
        entityManager.persist(reply)
        entityManager.flush()
        facade.delete(admin.id, AdminDeletionRequest.Create(
            DeletionTargetType.COMMENT, reply.id.toString(), DeletionReason.SPAM, "답글 삭제 사유", null,
        ))
        facade.delete(admin.id, AdminDeletionRequest.Create(
            DeletionTargetType.POST, post.id.toString(), DeletionReason.SPAM, null, null,
        ))
        facade.restore(admin.id, DeletionTargetType.POST, post.id.toString())
        entityManager.flush()
        entityManager.clear()
        val page = PageRequest.of(0, 1)
        val adminPage = commentService.getCommentsForAdmin(checkNotNull(post.id), admin.id, page)
        assertThat(adminPage.totalElements).isEqualTo(1)
        val replyInfo = adminPage.content.first().replies.first()
        assertThat(replyInfo.parentId).isEqualTo(root.id)
        assertThat(replyInfo.deletedAt).isNotNull()
        assertThat(replyInfo.content).isEqualTo("관리자가 삭제할 답글")
        assertThat(replyInfo.deletion?.reasonDetail()).isEqualTo("답글 삭제 사유")
        val publicReply = commentService.getComments(checkNotNull(post.id), page).content.first().replies.first()
        assertThat(publicReply.content).isEqualTo("삭제된 댓글입니다")
        assertThat(publicReply.member).isNull()
        facade.restore(admin.id, DeletionTargetType.COMMENT, reply.id.toString())
        entityManager.flush()
        entityManager.clear()
        assertThat(commentService.getComments(checkNotNull(post.id), page).content.first().replies.first().content)
            .isEqualTo("관리자가 삭제할 답글")
    }

    @Test
    fun myContentCombinesTypesAndPreservesDeletionWithoutExposingOtherMembers() {
        val author = member("작성자", MemberRole.ROLE_ADMIN)
        val other = member("타인", MemberRole.ROLE_UNVERIFIED)
        val post = Post(member = author, title = "내 후기", content = "내용")
        val community = CommunityPost(member = author, category = CommunityCategory.FREE, title = "내 글", content = "내용")
        entityManager.persist(post)
        entityManager.persist(community)
        entityManager.persist(Post(member = other, title = "타인의 후기", content = "내용"))
        val comment = Comment(post = post, member = author, content = "내 댓글")
        val communityComment = CommunityComment(post = community, member = author, content = "내 커뮤니티 댓글")
        entityManager.persist(comment)
        entityManager.persist(communityComment)
        val festival = festivals.saveAndFlush(Festival(
            member = author,
            providerType = ProviderType.MEMBER,
            title = "내 제보",
        ))
        entityManager.persist(FestivalSubmission(festival = festival))
        entityManager.flush()
        facade.delete(author.id, AdminDeletionRequest.Create(
            DeletionTargetType.POST, post.id.toString(), DeletionReason.SPAM, "마이페이지 사유", null,
        ))
        entityManager.flush()
        entityManager.clear()
        val posts = myContents.findMine(author.id, false, PageRequest.of(0, 20))
        assertThat(posts.totalElements).isEqualTo(3)
        assertThat(posts.content.map { it.type }).containsExactlyInAnyOrder(
            DeletionTargetType.FESTIVAL, DeletionTargetType.POST, DeletionTargetType.COMMUNITY_POST,
        )
        val removed = posts.content.first { it.type == DeletionTargetType.POST }
        assertThat(removed.deletedAt).isNotNull()
        assertThat(removed.originalPath).isNull()
        assertThat(removed.deletion?.reasonDetail).isEqualTo("마이페이지 사유")
        val comments = myContents.findMine(author.id, true, PageRequest.of(0, 20))
        assertThat(comments.totalElements).isEqualTo(2)
        val orphan = comments.content.first { it.type == DeletionTargetType.COMMENT }
        assertThat(orphan.parentDeleted).isTrue()
        assertThat(orphan.originalPath).isNull()
        assertThat(myContents.findMine(author.id, false, PageRequest.of(1, 2)).content).hasSize(1)
    }

    @Test
    fun ownSubmissionListAndDetailReadTypedDeletionReasonFromHistory() {
        val author = member("작성자", MemberRole.ROLE_UNVERIFIED)
        val admin = member("관리자", MemberRole.ROLE_ADMIN)
        val festival = festivals.saveAndFlush(Festival(
            member = author,
            providerType = ProviderType.MEMBER,
            title = "제보 이력 조회",
        ))
        val submission = FestivalSubmission(festival = festival)
        entityManager.persist(submission)
        entityManager.flush()
        facade.delete(admin.id, AdminDeletionRequest.Create(
            DeletionTargetType.FESTIVAL, festival.id.toString(), DeletionReason.SPAM, "이력 상세 설명", null,
        ))
        entityManager.flush()
        entityManager.clear()
        assertThat(submissions.findAllByMemberId(author.id).first().deletion?.reason)
            .contains("도배·스팸", "이력 상세 설명")
        assertThat(submissions.findById(author.id, checkNotNull(submission.id)).submission?.festival?.deletion?.reason)
            .contains("도배·스팸", "이력 상세 설명")
    }

    @Test
    fun batchHistoryLookupSeparatesTypesAndReturnsLatestActionPerTarget() {
        val actor = member("관리자", MemberRole.ROLE_ADMIN)
        histories.save(DeletionHistory.record(DeletionTargetType.FESTIVAL, "12", DeletionAction.DELETE,
            actor.id, DeletionActorType.ADMIN, DeletionReason.SPAM, null))
        histories.save(DeletionHistory.record(DeletionTargetType.FESTIVAL, "12", DeletionAction.RESTORE,
            actor.id, DeletionActorType.ADMIN, DeletionReason.ADMIN_RESTORE, null))
        histories.save(DeletionHistory.record(DeletionTargetType.COMMENT, "12", DeletionAction.DELETE,
            actor.id, DeletionActorType.ADMIN, DeletionReason.ABUSIVE_CONTENT, null))
        histories.save(DeletionHistory.record(DeletionTargetType.FESTIVAL, "13", DeletionAction.DELETE,
            actor.id, DeletionActorType.AUTHOR, DeletionReason.AUTHOR_REQUEST, null))
        entityManager.flush()
        entityManager.clear()
        val latest = historyService.findLatestForTargets(DeletionTargetType.FESTIVAL, listOf("12", "13", "14"))
        assertThat(latest).hasSize(2)
        assertThat(latest.getValue("12").action).isEqualTo(DeletionAction.RESTORE)
        assertThat(latest.getValue("13").actorType).isEqualTo(DeletionActorType.AUTHOR)
        assertThat(historyService.findLatestForTargets(DeletionTargetType.FESTIVAL, emptyList())).isEmpty()
    }

    @Test
    fun administratorFestivalListUsesHistoryInsteadOfLegacyDeletionFields() {
        val admin = member("관리자", MemberRole.ROLE_ADMIN)
        val prefix = "이력전환${UUID.randomUUID()}"
        val legacy = publicFestival(prefix + "과거")
        legacy.delete()
        val current = publicFestival(prefix + "현재")
        facade.delete(admin.id, AdminDeletionRequest.Create(
            DeletionTargetType.FESTIVAL, current.id.toString(), DeletionReason.SPAM, "이력의 상세 사유", null,
        ))
        // 기존 컬럼의 사유가 아닌 이력의 분류와 상세가 함께 내려와야 한다.
        val page = adminFestivals.search(AdminFestivalRequest.Search(prefix, null, false, true, false), PageRequest.of(0, 20))
        assertThat(page.content).hasSize(2)
        assertThat(page.content.first { it.festivalId == legacy.id }.deletion).isNull()
        val item = page.content.first { it.festivalId == current.id }
        assertThat(item.deletion?.type).isEqualTo(DeletionActorType.ADMIN)
        assertThat(item.deletion?.reason).contains("도배·스팸", "이력의 상세 사유")
    }

    @Test
    fun administratorReadsLatestHistoryAndCannotMistakeRestorationForDeletion() {
        val admin = member("관리자", MemberRole.ROLE_ADMIN)
        val festival = publicFestival("이력 조회")
        val id = festival.id.toString()
        assertThat(facade.latest(admin.id, DeletionTargetType.FESTIVAL, id)).isNull()
        facade.delete(admin.id, AdminDeletionRequest.Create(
            DeletionTargetType.FESTIVAL, id, DeletionReason.SPAM, "도배 확인", null,
        ))
        val deleted = facade.latest(admin.id, DeletionTargetType.FESTIVAL, id)
        assertThat(deleted).isNotNull()
        assertThat(deleted?.action()).isEqualTo(DeletionAction.DELETE)
        assertThat(deleted?.actorType()).isEqualTo(DeletionActorType.ADMIN)
        assertThat(deleted?.reasonLabel()).isEqualTo("도배·스팸")
        assertThat(deleted?.reasonDetail()).isEqualTo("도배 확인")
        facade.restore(admin.id, DeletionTargetType.FESTIVAL, id)
        assertThat(facade.latest(admin.id, DeletionTargetType.FESTIVAL, id)?.action()).isEqualTo(DeletionAction.RESTORE)
    }

    @Test
    fun nonAdministratorCannotReadDeletionHistory() {
        val member = member("일반회원", MemberRole.ROLE_UNVERIFIED)
        assertThrows<AccessDeniedException> {
            facade.latest(member.id, DeletionTargetType.POST, UUID.randomUUID().toString())
        }
    }

    @Test
    fun deletionCompletesMatchingPendingReportWithReason() {
        val admin = member("관리자", MemberRole.ROLE_ADMIN)
        val festival = publicFestival("신고 대상")
        val report = Inquiry(
            member = admin, category = InquiryCategory.REPORT, title = "신고", content = "잘못된 정보",
            targetType = InquiryTargetType.FESTIVAL, targetId = festival.id.toString(), status = InquiryStatus.PENDING,
        )
        entityManager.persist(report)
        entityManager.flush()
        facade.delete(admin.id, AdminDeletionRequest.Create(
            DeletionTargetType.FESTIVAL, festival.id.toString(), DeletionReason.INCORRECT_INFORMATION,
            "행사 장소가 다릅니다", report.id,
        ))
        entityManager.flush()
        entityManager.clear()
        val reloaded = entityManager.find(Inquiry::class.java, report.id)
        assertThat(reloaded.status).isEqualTo(InquiryStatus.ANSWERED)
        assertThat(reloaded.answer).contains("삭제", "잘못된 정보", "행사 장소가 다릅니다")
        assertThat(festivals.findByIdAndDeletedAtIsNull(festival.requiredId)).isNull()
        assertThat(histories.findAllByTargetTypeAndTargetIdOrderByIdDesc(
            DeletionTargetType.FESTIVAL, festival.id.toString(),
        )).hasSize(1)
    }

    @ParameterizedTest
    @ValueSource(strings = ["OTHER_TARGET", "OTHER_TYPE", "ANSWERED", "ANSWER_ONLY", "DELETED", "QUESTION", "TIP", "MISSING"])
    fun invalidReportRollsBackDeletionAndHistory(scenario: String) {
        val admin = member("관리자", MemberRole.ROLE_ADMIN)
        val festival = publicFestival("취소 검증")
        val report = Inquiry(
            member = admin,
            category = when (scenario) {
                "QUESTION" -> InquiryCategory.QUESTION
                "TIP" -> InquiryCategory.TIP
                else -> InquiryCategory.REPORT
            },
            title = "연결 불가 신고",
            content = "내용",
            targetType = if (scenario == "OTHER_TYPE") InquiryTargetType.COMMENT else InquiryTargetType.FESTIVAL,
            targetId = if (scenario == "OTHER_TARGET") "999999999" else festival.id.toString(),
            answer = if (scenario == "ANSWER_ONLY") "기존 답변" else null,
            status = if (scenario == "ANSWERED") InquiryStatus.ANSWERED else InquiryStatus.PENDING,
        )
        if (scenario == "DELETED") report.delete()
        entityManager.persist(report)
        entityManager.flush()
        val adminId = admin.id
        val festivalId = festival.requiredId
        val reportId = report.id
        val originalAnswer = report.answer
        val originalStatus = report.status
        // 준비 데이터만 커밋하고, 삭제 요청 실패 후 별도 트랜잭션에서 DB를 다시 확인한다.
        TestTransaction.flagForCommit()
        TestTransaction.end()
        TestTransaction.start()
        assertThrows<BusinessException> {
            facade.delete(adminId, AdminDeletionRequest.Create(
                DeletionTargetType.FESTIVAL, festivalId.toString(), DeletionReason.SPAM, null,
                if (scenario == "MISSING") UUID.randomUUID() else reportId,
            ))
        }
        TestTransaction.end()
        TestTransaction.start()
        assertThat(festivals.findByIdAndDeletedAtIsNull(festivalId)).isNotNull()
        assertThat(histories.findAllByTargetTypeAndTargetIdOrderByIdDesc(DeletionTargetType.FESTIVAL, festivalId.toString())).isEmpty()
        val unchanged = entityManager.find(Inquiry::class.java, reportId)
        assertThat(unchanged.answer).isEqualTo(originalAnswer)
        assertThat(unchanged.status).isEqualTo(originalStatus)
    }

    @Test
    fun restoringAdministratorDeletedFestivalKeepsOriginalReason() {
        val admin = member("관리자", MemberRole.ROLE_ADMIN)
        val festival = publicFestival("복구 대상")
        val id = festival.id.toString()
        facade.delete(admin.id, AdminDeletionRequest.Create(
            DeletionTargetType.FESTIVAL, id, DeletionReason.SPAM, "도배 확인", null,
        ))
        facade.restore(admin.id, DeletionTargetType.FESTIVAL, id)
        entityManager.flush()
        entityManager.clear()
        assertThat(festivals.findByIdAndDeletedAtIsNull(festival.requiredId)).isNotNull()
        val records = histories.findAllByTargetTypeAndTargetIdOrderByIdDesc(DeletionTargetType.FESTIVAL, id)
        assertThat(records.map { it.action }).containsExactly(DeletionAction.RESTORE, DeletionAction.DELETE)
        assertThat(records[1].reasonDetail).isEqualTo("도배 확인")
    }

    @Test
    fun authorDeletedFestivalCannotBeRestored() {
        assertFestivalRestoreRejected(true, true)
    }

    @Test
    fun legacyDeletionWithoutHistoryCannotBeRestored() {
        assertFestivalRestoreRejected(false, true)
    }

    @Test
    fun nonAdministratorCannotRestoreFestival() {
        assertFestivalRestoreRejected(false, false)
    }

    private fun assertFestivalRestoreRejected(authorDeletion: Boolean, administrator: Boolean) {
        val actor = member("처리자", if (administrator) MemberRole.ROLE_ADMIN else MemberRole.ROLE_UNVERIFIED)
        val festival = publicFestival("복구 거절")
        festival.delete()
        val id = festival.id.toString()
        if (authorDeletion) {
            histories.save(DeletionHistory.record(DeletionTargetType.FESTIVAL, id, DeletionAction.DELETE,
                actor.id, DeletionActorType.AUTHOR, DeletionReason.AUTHOR_REQUEST, null))
        }
        assertThatThrownBy { facade.restore(actor.id, DeletionTargetType.FESTIVAL, id) }
            .isInstanceOf(if (administrator) BusinessException::class.java else AccessDeniedException::class.java)
        assertThat(festival.isDeleted()).isTrue()
        assertThat(histories.findAllByTargetTypeAndTargetIdOrderByIdDesc(DeletionTargetType.FESTIVAL, id))
            .noneMatch { it.action == DeletionAction.RESTORE }
    }

    @Test
    fun authorFestivalDeletionRetainsAuthorHistory() {
        val author = member("작성자", MemberRole.ROLE_UNVERIFIED)
        val festival = festivals.saveAndFlush(Festival(
            member = author,
            providerType = ProviderType.MEMBER,
            title = "작성자 삭제 대상",
        ))
        festivalDeletionService.deleteByAuthor(festival, author.id)
        entityManager.flush()
        entityManager.clear()
        assertThat(festivals.findByIdAndDeletedAtIsNull(festival.requiredId)).isNull()
        assertThat(histories.findAllByTargetTypeAndTargetIdOrderByIdDesc(DeletionTargetType.FESTIVAL, festival.id.toString()))
            .singleElement().satisfies(Consumer<DeletionHistory> {
                assertThat(it.actorId).isEqualTo(author.id)
                assertThat(it.actorType).isEqualTo(DeletionActorType.AUTHOR)
                assertThat(it.reason).isEqualTo(DeletionReason.AUTHOR_REQUEST)
            })
    }

    @ParameterizedTest
    @EnumSource(value = DeletionTargetType::class, names = ["POST", "COMMENT", "COMMUNITY_POST", "COMMUNITY_COMMENT"])
    fun facadeDeletesEachContentAndRecordsAdministratorReason(type: DeletionTargetType) {
        deleteContentAndVerifyHistory(type, false)
    }

    @ParameterizedTest
    @EnumSource(value = DeletionTargetType::class, names = ["POST", "COMMENT", "COMMUNITY_POST", "COMMUNITY_COMMENT"])
    fun authorDeletesContentAndRetainsAuthorHistory(type: DeletionTargetType) {
        deleteContentAndVerifyHistory(type, true)
    }

    @ParameterizedTest
    @EnumSource(value = DeletionTargetType::class, names = ["POST", "COMMENT", "COMMUNITY_POST", "COMMUNITY_COMMENT"])
    fun administratorCannotDeleteOthersThroughAuthorApi(type: DeletionTargetType) {
        deleteContentAndVerifyHistory(type, true, true)
    }

    @ParameterizedTest
    @EnumSource(value = DeletionTargetType::class, names = ["POST", "COMMENT", "COMMUNITY_POST", "COMMUNITY_COMMENT"])
    fun administratorRestoresContentWithoutLosingDeletionReason(type: DeletionTargetType) {
        deleteContentAndVerifyHistory(type, false, false, true)
    }

    @ParameterizedTest
    @EnumSource(value = DeletionTargetType::class, names = ["POST", "COMMENT", "COMMUNITY_POST", "COMMUNITY_COMMENT"])
    fun authorDeletedContentCannotBeRestored(type: DeletionTargetType) {
        deleteContentAndVerifyHistory(type, true, false, true)
    }

    @ParameterizedTest
    @EnumSource(value = DeletionTargetType::class, names = ["COMMENT", "COMMUNITY_COMMENT"])
    fun commentCannotBeRestoredWhileParentIsDeleted(type: DeletionTargetType) {
        deleteContentAndVerifyHistory(type, false, false, true, true)
    }

    private fun deleteContentAndVerifyHistory(
        type: DeletionTargetType,
        authorDeletion: Boolean,
        unauthorized: Boolean = false,
        restore: Boolean = false,
        deletedParent: Boolean = false,
    ) {
        val author = member("작성자", MemberRole.ROLE_UNVERIFIED)
        val admin = member("관리자", MemberRole.ROLE_ADMIN)
        val post = Post(member = author, title = "후기", content = "본문")
        val communityPost = CommunityPost(member = author, category = CommunityCategory.FREE, title = "커뮤니티", content = "본문")
        entityManager.persist(post)
        entityManager.persist(communityPost)
        val comment = Comment(post = post, member = author, content = "후기 댓글")
        val communityComment = CommunityComment(post = communityPost, member = author, content = "커뮤니티 댓글")
        entityManager.persist(comment)
        entityManager.persist(communityComment)
        entityManager.flush()
        val targetId = when (type) {
            DeletionTargetType.POST -> post.id.toString()
            DeletionTargetType.COMMENT -> comment.id.toString()
            DeletionTargetType.COMMUNITY_POST -> communityPost.id.toString()
            DeletionTargetType.COMMUNITY_COMMENT -> communityComment.id.toString()
            else -> throw IllegalArgumentException()
        }
        val authorDelete: () -> Unit = {
            val actorId = if (unauthorized) admin.id else author.id
            when (type) {
                DeletionTargetType.POST -> postService.deletePost(checkNotNull(post.id), actorId)
                DeletionTargetType.COMMENT -> commentService.deleteComment(checkNotNull(comment.id), actorId)
                DeletionTargetType.COMMUNITY_POST -> communityService.deletePost(checkNotNull(communityPost.id), actorId)
                DeletionTargetType.COMMUNITY_COMMENT -> communityService.deleteComment(checkNotNull(communityComment.id), actorId)
                else -> throw IllegalArgumentException()
            }
        }
        if (unauthorized) {
            assertThrows<BusinessException> { authorDelete() }
            assertThat(histories.findAllByTargetTypeAndTargetIdOrderByIdDesc(type, targetId)).isEmpty()
            assertThat(post.isDeleted()).isFalse()
            assertThat(comment.isDeleted()).isFalse()
            assertThat(communityPost.isDeleted()).isFalse()
            assertThat(communityComment.isDeleted()).isFalse()
            return
        }
        if (restore && !authorDeletion && (type == DeletionTargetType.POST || type == DeletionTargetType.COMMUNITY_POST)) {
            facade.delete(admin.id, AdminDeletionRequest.Create(
                if (type == DeletionTargetType.POST) DeletionTargetType.COMMENT else DeletionTargetType.COMMUNITY_COMMENT,
                if (type == DeletionTargetType.POST) comment.id.toString() else communityComment.id.toString(),
                DeletionReason.SPAM, null, null,
            ))
        }
        if (authorDeletion) {
            authorDelete()
        } else {
            facade.delete(admin.id, AdminDeletionRequest.Create(type, targetId, DeletionReason.ABUSIVE_CONTENT, "욕설 포함", null))
        }
        entityManager.flush()
        entityManager.clear()
        val table = when (type) {
            DeletionTargetType.POST -> "post"
            DeletionTargetType.COMMENT -> "comment"
            DeletionTargetType.COMMUNITY_POST -> "community_post"
            DeletionTargetType.COMMUNITY_COMMENT -> "community_comment"
            else -> throw IllegalArgumentException()
        }
        val deletedAt = entityManager.createNativeQuery("select deleted_at from $table where cast(id as text) = :id")
            .setParameter("id", targetId).singleResult
        assertThat(deletedAt).isNotNull()
        assertThat(histories.findAllByTargetTypeAndTargetIdOrderByIdDesc(type, targetId))
            .singleElement().satisfies(Consumer<DeletionHistory> {
                assertThat(it.actorId).isEqualTo(if (authorDeletion) author.id else admin.id)
                assertThat(it.actorType).isEqualTo(if (authorDeletion) DeletionActorType.AUTHOR else DeletionActorType.ADMIN)
                assertThat(it.reason).isEqualTo(if (authorDeletion) DeletionReason.AUTHOR_REQUEST else DeletionReason.ABUSIVE_CONTENT)
            })
        if (restore) {
            if (deletedParent) {
                facade.delete(admin.id, AdminDeletionRequest.Create(
                    if (type == DeletionTargetType.COMMENT) DeletionTargetType.POST else DeletionTargetType.COMMUNITY_POST,
                    if (type == DeletionTargetType.COMMENT) post.id.toString() else communityPost.id.toString(),
                    DeletionReason.SPAM, null, null,
                ))
                entityManager.flush()
                entityManager.clear()
            }
            if (authorDeletion || deletedParent) {
                assertThrows<BusinessException> { facade.restore(admin.id, type, targetId) }
                assertThat(histories.findAllByTargetTypeAndTargetIdOrderByIdDesc(type, targetId))
                    .noneMatch { it.action == DeletionAction.RESTORE }
                return
            }
            facade.restore(admin.id, type, targetId)
            entityManager.flush()
            entityManager.clear()
            assertThat(entityManager.createNativeQuery("select deleted_at from $table where cast(id as text) = :id")
                .setParameter("id", targetId).singleResult).isNull()
            val records = histories.findAllByTargetTypeAndTargetIdOrderByIdDesc(type, targetId)
            assertThat(records.map { it.action }).containsExactly(DeletionAction.RESTORE, DeletionAction.DELETE)
            assertThat(records[1].reasonDetail).isEqualTo("욕설 포함")
            if (type == DeletionTargetType.POST || type == DeletionTargetType.COMMUNITY_POST) {
                val childTable = if (type == DeletionTargetType.POST) "comment" else "community_comment"
                val childId = if (type == DeletionTargetType.POST) comment.id else communityComment.id
                assertThat(entityManager.createNativeQuery("select deleted_at from $childTable where id = :id")
                    .setParameter("id", childId).singleResult).isNotNull()
            }
        }
    }

    @Test
    fun facadeDeletesFestivalAndRetainsTypedReasonAfterReload() {
        val admin = member("관리자", MemberRole.ROLE_ADMIN)
        val festival = publicFestival("삭제 대상")
        facade.delete(admin.id, AdminDeletionRequest.Create(
            DeletionTargetType.FESTIVAL, festival.id.toString(), DeletionReason.SPAM, "도배", null,
        ))
        entityManager.flush()
        entityManager.clear()
        assertThat(festivals.findByIdAndDeletedAtIsNull(festival.requiredId)).isNull()
        assertThat(histories.findFirstByTargetTypeAndTargetIdOrderByIdDesc(DeletionTargetType.FESTIVAL, festival.id.toString())?.reason)
            .isEqualTo(DeletionReason.SPAM)
    }

    @Test
    fun deletionAndRestorationRemainRetrievableAsSeparateRecords() {
        val admin = member("관리자", MemberRole.ROLE_ADMIN)
        val deleted = histories.save(DeletionHistory.record(DeletionTargetType.FESTIVAL, "12",
            DeletionAction.DELETE, admin.id, DeletionActorType.ADMIN, DeletionReason.SPAM, "도배 삭제"))
        val restored = histories.save(DeletionHistory.record(DeletionTargetType.FESTIVAL, "12",
            DeletionAction.RESTORE, admin.id, DeletionActorType.ADMIN, DeletionReason.ADMIN_RESTORE, null))
        entityManager.flush()
        entityManager.clear()
        val records = histories.findAllByTargetTypeAndTargetIdOrderByIdDesc(DeletionTargetType.FESTIVAL, "12")
        assertThat(records.map { it.action }).containsExactly(DeletionAction.RESTORE, DeletionAction.DELETE)
        assertThat(records[1].reasonDetail).isEqualTo("도배 삭제")
        assertThat(histories.findFirstByTargetTypeAndTargetIdOrderByIdDesc(DeletionTargetType.FESTIVAL, "12")?.id)
            .isEqualTo(restored.id)
        assertThat(deleted.id).isNotEqualTo(restored.id)
    }
}
