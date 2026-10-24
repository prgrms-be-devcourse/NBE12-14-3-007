package com.team007.room_escape.domain.community.service

import com.team007.room_escape.domain.community.dto.CommunityRequest
import com.team007.room_escape.domain.community.dto.CommunityResponse
import com.team007.room_escape.domain.community.infra.entity.CommunityPost
import com.team007.room_escape.domain.community.infra.repository.CommunityPostRepository
import com.team007.room_escape.domain.community.type.CommunityCategory
import com.team007.room_escape.domain.deletion.dto.AdminDeletionRequest
import com.team007.room_escape.domain.deletion.infra.entity.DeletionReason
import com.team007.room_escape.domain.deletion.infra.entity.DeletionTargetType
import com.team007.room_escape.domain.deletion.service.AdminDeletionFacade
import com.team007.room_escape.domain.inquiry.infra.entity.InquiryTargetType
import com.team007.room_escape.domain.inquiry.service.InquiryTargetValidator
import com.team007.room_escape.domain.member.infra.entity.Member
import com.team007.room_escape.domain.member.infra.entity.MemberRole
import com.team007.room_escape.domain.member.infra.repository.MemberRepository
import com.team007.room_escape.global.exception.BusinessException
import com.team007.room_escape.global.exception.ExceptionCode
import com.team007.room_escape.global.response.code.CommunityExceptionCode
import com.team007.room_escape.global.response.code.InquiryExceptionCode
import jakarta.persistence.EntityManager
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.assertThrows
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.data.domain.PageRequest
import org.springframework.data.domain.Sort
import org.springframework.jdbc.core.JdbcTemplate
import org.springframework.transaction.annotation.Transactional
import java.util.UUID

/**
 * 커뮤니티 댓글의 정렬, 대댓글, soft delete를 실제 DB로 확인한다.
 * 같은 회원은 5초 안에 댓글을 다시 쓸 수 없어서 댓글마다 새 회원으로 쓴다.
 */
@SpringBootTest
@Transactional
class CommunityCommentTest @Autowired constructor(
    private val communityService: CommunityService,
    private val inquiryTargetValidator: InquiryTargetValidator,
    private val memberRepository: MemberRepository,
    private val postRepository: CommunityPostRepository,
    private val entityManager: EntityManager,
    private val jdbcTemplate: JdbcTemplate,
    private val adminDeletions: AdminDeletionFacade,
) {

    private val firstPage = PageRequest.of(0, 20)

    private lateinit var postId: UUID

    @BeforeEach
    fun setUp() {
        postId = postRepository.save(post(newMember())).id
    }

    @Test
    fun 일반_댓글은_오래된_순이고_대댓글은_부모_아래에_오래된_순으로_붙는다() {
        val first = write("첫 댓글").id
        val second = write("둘째 댓글").id
        val reply1 = reply(first, "첫 답글").id
        val reply2 = reply(first, "둘째 답글").id

        val roots = comments()

        assertThat(roots.map { it.id }).containsExactly(first, second)
        assertThat(roots[0].replies.map { it.id }).containsExactly(reply1, reply2)
        assertThat(roots[0].replies).allSatisfy { assertThat(it.parentId).isEqualTo(first) }
        assertThat(roots[1].replies).isEmpty()
    }

    @Test
    fun 클라이언트가_최신순을_요청해도_오래된_순으로_내려준다() {
        val first = write("첫 댓글").id
        val second = write("둘째 댓글").id

        val page = communityService.getComments(
            postId, PageRequest.of(0, 20, Sort.by(Sort.Direction.DESC, "createdAt"))
        )

        assertThat(page.content.map { it.id }).containsExactly(first, second)
    }

    @Test
    fun 페이지는_일반_댓글_기준으로_나눈다() {
        repeat(21) { i ->
            val root = write("댓글 $i").id
            reply(root, "답글 $i")
        }

        val page = communityService.getComments(postId, firstPage)

        assertThat(page.totalElements).isEqualTo(21)
        assertThat(page.totalPages).isEqualTo(2)
        assertThat(page.content).hasSize(20)
            .allSatisfy { assertThat(it.replies).hasSize(1) }
    }

    @Test
    fun 삭제해도_행은_남고_삭제_시각만_기록된다() {
        val comment = write("지울 댓글")

        communityService.deleteComment(comment.id, comment.writer.id)
        entityManager.flush()

        val row = jdbcTemplate.queryForMap(
            "SELECT content, deleted_at FROM community_comment WHERE id = ?", comment.id
        )
        assertThat(row["content"]).isEqualTo("지울 댓글")
        assertThat(row["deleted_at"]).isNotNull()
    }

    @Test
    fun 대댓글이_없는_댓글도_삭제하면_문구로_자리가_남는다() {
        val comment = write("지울 댓글")

        communityService.deleteComment(comment.id, comment.writer.id)
        val deleted = comments()[0]

        assertThat(deleted.id).isEqualTo(comment.id)
        assertThat(deleted.deleted).isTrue()
        assertThat(deleted.content).isEqualTo(CommunityResponse.DELETED_COMMENT_CONTENT)
        assertThat(deleted.member).isNull()
    }

    @Test
    fun 부모_댓글을_지워도_대댓글은_그대로_남는다() {
        val root = write("부모 댓글")
        val reply = reply(root.id, "남아야 하는 답글")

        communityService.deleteComment(root.id, root.writer.id)
        val deletedRoot = comments()[0]

        assertThat(deletedRoot.deleted).isTrue()
        assertThat(deletedRoot.content).isEqualTo(CommunityResponse.DELETED_COMMENT_CONTENT)
        assertThat(deletedRoot.replies).singleElement().satisfies({ r ->
            assertThat(r.id).isEqualTo(reply.id)
            assertThat(r.deleted).isFalse()
            assertThat(r.content).isEqualTo("남아야 하는 답글")
            assertThat(r.member.nickname).isEqualTo(reply.writer.nickname)
        })
    }

    @Test
    fun 삭제된_대댓글도_문구로_자리가_남는다() {
        val root = write("부모 댓글")
        val reply = reply(root.id, "지울 답글")

        communityService.deleteComment(reply.id, reply.writer.id)
        val rootInfo = comments()[0]

        assertThat(rootInfo.deleted).isFalse()
        assertThat(rootInfo.replies).singleElement().satisfies({ r ->
            assertThat(r.deleted).isTrue()
            assertThat(r.content).isEqualTo(CommunityResponse.DELETED_COMMENT_CONTENT)
            assertThat(r.member).isNull()
        })
    }

    @Test
    fun 댓글_수는_대댓글을_포함하고_삭제된_댓글은_뺀다() {
        val root = write("부모 댓글")
        reply(root.id, "답글 1")
        reply(root.id, "답글 2")
        write("다른 댓글")

        communityService.deleteComment(root.id, root.writer.id)

        assertThat(communityService.getPost(postId).commentCount).isEqualTo(3)
        val item = communityService.getPosts(null, "", PageRequest.of(0, 50)).content
            .single { it.id == postId }
        assertThat(item.commentCount).isEqualTo(3)
    }

    @Test
    fun 삭제된_댓글은_수정할_수_없다() {
        val comment = write("지울 댓글")
        communityService.deleteComment(comment.id, comment.writer.id)

        assertExceptionCode(CommunityExceptionCode.COMMENT_NOT_FOUND) {
            communityService.updateComment(
                comment.id, CommunityRequest.CommentUpsert("되살리기"), comment.writer.id
            )
        }
    }

    @Test
    fun 이미_삭제된_댓글은_다시_삭제할_수_없다() {
        val comment = write("지울 댓글")
        communityService.deleteComment(comment.id, comment.writer.id)

        assertExceptionCode(CommunityExceptionCode.COMMENT_NOT_FOUND) {
            communityService.deleteComment(comment.id, comment.writer.id)
        }
    }

    @Test
    fun 삭제된_댓글에는_답글을_달_수_없다() {
        val comment = write("지울 댓글")
        communityService.deleteComment(comment.id, comment.writer.id)

        assertExceptionCode(CommunityExceptionCode.COMMENT_NOT_FOUND) {
            reply(comment.id, "늦은 답글")
        }
    }

    @Test
    fun 삭제된_댓글은_신고할_수_없다() {
        val comment = write("지울 댓글")
        communityService.deleteComment(comment.id, comment.writer.id)

        assertExceptionCode(InquiryExceptionCode.INQUIRY_TARGET_NOT_FOUND) {
            inquiryTargetValidator.validate(InquiryTargetType.COMMUNITY_COMMENT, comment.id.toString())
        }
    }

    @Test
    fun 삭제한_댓글은_도배_확인에서_빠져_바로_다시_쓸_수_있다() {
        val comment = write("같은 내용")
        communityService.deleteComment(comment.id, comment.writer.id)

        val again = communityService.createComment(
            postId, CommunityRequest.CommentCreate("같은 내용", null), comment.writer.id
        )

        assertThat(again.deleted).isFalse()
    }

    @Test
    fun 대댓글에_단_답글은_그_대댓글의_부모_아래에_붙는다() {
        val root = write("부모 댓글").id
        val reply = reply(root, "답글").id

        val replyOfReply = reply(reply, "답글의 답글").id

        val replies = comments()[0].replies
        assertThat(replies.map { it.id }).containsExactly(reply, replyOfReply)
        assertThat(replies).allSatisfy { assertThat(it.parentId).isEqualTo(root) }
    }

    @Test
    fun 다른_글의_댓글에는_답글을_달_수_없다() {
        val otherPostId = postRepository.save(post(newMember())).id
        val otherPostComment = communityService.createComment(
            otherPostId, CommunityRequest.CommentCreate("다른 글 댓글", null), newMember().id
        ).id

        assertExceptionCode(CommunityExceptionCode.COMMENT_PARENT_MISMATCH) {
            reply(otherPostComment, "엉뚱한 답글")
        }
    }

    @Test
    fun 남의_댓글은_삭제할_수_없고_관리자는_삭제할_수_있다() {
        val comment = write("남의 댓글")
        val otherId = newMember().id

        assertExceptionCode(CommunityExceptionCode.COMMENT_FORBIDDEN) {
            communityService.deleteComment(comment.id, otherId)
        }

        val admin = memberRepository.save(
            Member.builder()
                .email("${UUID.randomUUID()}@test.com")
                .password("encoded")
                .nickname("관리자")
                .role(MemberRole.ROLE_ADMIN)
                .build()
        )
        adminDeletions.delete(
            admin.id,
            AdminDeletionRequest.Create(
                DeletionTargetType.COMMUNITY_COMMENT, comment.id.toString(), DeletionReason.SPAM, null, null
            )
        )
        assertThat(comments()[0].deleted).isTrue()
    }

    private data class Written(val id: Long, val writer: Member)

    private fun comments(): List<CommunityResponse.CommentInfo> =
        communityService.getComments(postId, firstPage).content

    private fun write(content: String): Written = create(content, parentId = null)

    private fun reply(parentId: Long, content: String): Written = create(content, parentId)

    private fun create(content: String, parentId: Long?): Written {
        val writer = newMember()
        val id = communityService.createComment(
            postId, CommunityRequest.CommentCreate(content, parentId), writer.id
        ).id
        return Written(id, writer)
    }

    private fun assertExceptionCode(expected: ExceptionCode, action: () -> Unit) {
        val e = assertThrows<BusinessException> { action() }
        assertThat(e.exceptionCode).isEqualTo(expected)
    }

    private fun newMember(): Member {
        val nickname = "커뮤" + UUID.randomUUID().toString().substring(0, 8)
        return memberRepository.save(
            Member.builder()
                .email("$nickname@test.com")
                .password("encoded")
                .role(MemberRole.ROLE_UNVERIFIED)
                .nickname(nickname)
                .build()
        )
    }

    private fun post(member: Member): CommunityPost =
        CommunityPost.builder()
            .member(member)
            .category(CommunityCategory.FREE)
            .title("댓글 테스트 글")
            .content("<p>본문</p>")
            .build()
}
