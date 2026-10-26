package com.team007.room_escape.domain.comment.service

import com.team007.room_escape.domain.comment.dto.CommentRequest
import com.team007.room_escape.domain.comment.dto.CommentResponse
import com.team007.room_escape.domain.deletion.dto.AdminDeletionRequest
import com.team007.room_escape.domain.deletion.infra.entity.DeletionReason
import com.team007.room_escape.domain.deletion.infra.entity.DeletionTargetType
import com.team007.room_escape.domain.deletion.service.AdminDeletionFacade
import com.team007.room_escape.domain.inquiry.infra.entity.InquiryTargetType
import com.team007.room_escape.domain.inquiry.service.InquiryTargetValidator
import com.team007.room_escape.domain.member.infra.entity.Member
import com.team007.room_escape.domain.member.infra.entity.MemberRole
import com.team007.room_escape.domain.member.infra.repository.MemberRepository
import com.team007.room_escape.domain.post.infra.entity.Post
import com.team007.room_escape.domain.post.infra.repository.PostRepository
import com.team007.room_escape.global.exception.BusinessException
import com.team007.room_escape.global.exception.ExceptionCode
import com.team007.room_escape.global.response.code.CommentExceptionCode
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

/** 후기 댓글의 정렬, 대댓글, soft delete를 실제 DB로 확인한다. */
@SpringBootTest
@Transactional
class CommentServiceTest @Autowired constructor(
    private val commentService: CommentService,
    private val inquiryTargetValidator: InquiryTargetValidator,
    private val memberRepository: MemberRepository,
    private val postRepository: PostRepository,
    private val entityManager: EntityManager,
    private val jdbcTemplate: JdbcTemplate,
    private val adminDeletions: AdminDeletionFacade,
) {

    private val firstPage = PageRequest.of(0, 20)

    private lateinit var writer: Member
    private lateinit var other: Member
    private lateinit var postId: UUID

    @BeforeEach
    fun setUp() {
        writer = memberRepository.save(member())
        other = memberRepository.save(member())
        postId = checkNotNull(postRepository.save(post(writer)).id)
    }

    @Test
    fun 일반_댓글은_오래된_순이고_대댓글은_부모_아래에_오래된_순으로_붙는다() {
        val first = write("첫 댓글")
        val second = write("둘째 댓글")
        val reply1 = reply(first, "첫 답글")
        val reply2 = reply(first, "둘째 답글")

        val roots = comments()

        assertThat(roots.map { it.id }).containsExactly(first, second)
        assertThat(roots[0].replies.map { it.id }).containsExactly(reply1, reply2)
        assertThat(roots[0].replies).allSatisfy { assertThat(it.parentId).isEqualTo(first) }
        assertThat(roots[1].replies).isEmpty()
    }

    @Test
    fun 클라이언트가_최신순을_요청해도_오래된_순으로_내려준다() {
        val first = write("첫 댓글")
        val second = write("둘째 댓글")

        val page = commentService.getComments(
            postId, PageRequest.of(0, 20, Sort.by(Sort.Direction.DESC, "createdAt"))
        )

        assertThat(page.content.map { it.id }).containsExactly(first, second)
    }

    @Test
    fun 페이지는_일반_댓글_기준으로_나눈다() {
        repeat(21) { i ->
            val root = write("댓글 $i")
            reply(root, "답글 $i")
        }

        val page = commentService.getComments(postId, firstPage)

        assertThat(page.totalElements).isEqualTo(21)
        assertThat(page.totalPages).isEqualTo(2)
        assertThat(page.content).hasSize(20)
            .allSatisfy { assertThat(it.replies).hasSize(1) }
    }

    @Test
    fun 삭제해도_행은_남고_삭제_시각만_기록된다() {
        val id = write("지울 댓글")

        commentService.deleteComment(id, writer.id)
        entityManager.flush()

        val row = jdbcTemplate.queryForMap("SELECT content, deleted_at FROM \"comment\" WHERE id = ?", id)
        assertThat(row["content"]).isEqualTo("지울 댓글")
        assertThat(row["deleted_at"]).isNotNull()
    }

    @Test
    fun 대댓글이_없는_댓글도_삭제하면_문구로_자리가_남는다() {
        val id = write("지울 댓글")

        commentService.deleteComment(id, writer.id)
        val deleted = comments()[0]

        assertThat(deleted.id).isEqualTo(id)
        assertThat(deleted.deleted).isTrue()
        assertThat(deleted.content).isEqualTo(CommentResponse.DELETED_CONTENT)
        assertThat(deleted.member).isNull()
    }

    @Test
    fun 부모_댓글을_지워도_대댓글은_그대로_남는다() {
        val root = write("부모 댓글")
        val reply = reply(root, "남아야 하는 답글")

        commentService.deleteComment(root, writer.id)
        val deletedRoot = comments()[0]

        assertThat(deletedRoot.deleted).isTrue()
        assertThat(deletedRoot.content).isEqualTo(CommentResponse.DELETED_CONTENT)
        assertThat(deletedRoot.replies).singleElement().satisfies({ r ->
            assertThat(r.id).isEqualTo(reply)
            assertThat(r.deleted).isFalse()
            assertThat(r.content).isEqualTo("남아야 하는 답글")
            assertThat(r.member?.nickname).isEqualTo(other.nickname)
        })
    }

    @Test
    fun 삭제된_대댓글도_문구로_자리가_남는다() {
        val root = write("부모 댓글")
        val reply = reply(root, "지울 답글")

        commentService.deleteComment(reply, other.id)
        val rootInfo = comments()[0]

        assertThat(rootInfo.deleted).isFalse()
        assertThat(rootInfo.replies).singleElement().satisfies({ r ->
            assertThat(r.deleted).isTrue()
            assertThat(r.content).isEqualTo(CommentResponse.DELETED_CONTENT)
            assertThat(r.member).isNull()
        })
    }

    @Test
    fun 삭제된_댓글은_수정할_수_없다() {
        val id = write("지울 댓글")
        commentService.deleteComment(id, writer.id)

        assertExceptionCode(CommentExceptionCode.COMMENT_NOT_FOUND) {
            commentService.updateComment(id, CommentRequest.Upsert("되살리기"), writer.id)
        }
    }

    @Test
    fun 이미_삭제된_댓글은_다시_삭제할_수_없다() {
        val id = write("지울 댓글")
        commentService.deleteComment(id, writer.id)

        assertExceptionCode(CommentExceptionCode.COMMENT_NOT_FOUND) {
            commentService.deleteComment(id, writer.id)
        }
    }

    @Test
    fun 삭제된_댓글에는_답글을_달_수_없다() {
        val id = write("지울 댓글")
        commentService.deleteComment(id, writer.id)

        assertExceptionCode(CommentExceptionCode.COMMENT_NOT_FOUND) {
            reply(id, "늦은 답글")
        }
    }

    @Test
    fun 삭제된_댓글은_신고할_수_없다() {
        val id = write("지울 댓글")
        commentService.deleteComment(id, writer.id)

        assertExceptionCode(InquiryExceptionCode.INQUIRY_TARGET_NOT_FOUND) {
            inquiryTargetValidator.validate(InquiryTargetType.COMMENT, id.toString())
        }
    }

    @Test
    fun 대댓글에_단_답글은_그_대댓글의_부모_아래에_붙는다() {
        val root = write("부모 댓글")
        val reply = reply(root, "답글")

        val replyOfReply = commentService.createComment(
            postId, CommentRequest.Create("답글의 답글", reply), writer.id
        )

        assertThat(replyOfReply.parentId).isEqualTo(root)
        assertThat(comments()[0].replies.map { it.id }).containsExactly(reply, replyOfReply.id)
    }

    @Test
    fun 다른_후기의_댓글에는_답글을_달_수_없다() {
        val otherPostId = checkNotNull(postRepository.save(post(writer)).id)
        val otherPostComment = commentService.createComment(
            otherPostId, CommentRequest.Create("다른 후기 댓글", null), writer.id
        ).id

        assertExceptionCode(CommentExceptionCode.COMMENT_PARENT_MISMATCH) {
            reply(otherPostComment, "엉뚱한 답글")
        }
    }

    @Test
    fun 남의_댓글은_삭제할_수_없고_관리자는_삭제할_수_있다() {
        val id = write("남의 댓글")

        assertExceptionCode(CommentExceptionCode.COMMENT_FORBIDDEN) {
            commentService.deleteComment(id, other.id)
        }

        val admin = memberRepository.save(
            Member(
                email = "${UUID.randomUUID()}@test.com",
                password = "encoded",
                role = MemberRole.ROLE_ADMIN,
                nickname = "관리자",
            )
        )
        adminDeletions.delete(
            admin.id,
            AdminDeletionRequest.Create(DeletionTargetType.COMMENT, id.toString(), DeletionReason.SPAM, null, null)
        )
        assertThat(comments()[0].deleted).isTrue()
    }

    private fun comments(): List<CommentResponse.Info> = commentService.getComments(postId, firstPage).content

    private fun write(content: String): Long =
        commentService.createComment(postId, CommentRequest.Create(content, null), writer.id).id

    private fun reply(parentId: Long, content: String): Long =
        commentService.createComment(postId, CommentRequest.Create(content, parentId), other.id).id

    private fun assertExceptionCode(expected: ExceptionCode, action: () -> Unit) {
        val e = assertThrows<BusinessException> { action() }
        assertThat(e.exceptionCode).isEqualTo(expected)
    }

    private fun member(): Member {
        val nickname = "댓글" + UUID.randomUUID().toString().substring(0, 8)
        return Member(
            email = "$nickname@test.com",
            password = "encoded",
            role = MemberRole.ROLE_UNVERIFIED,
            nickname = nickname,
        )
    }

    private fun post(member: Member): Post =
        Post(member = member, title = "댓글 테스트 후기", content = "본문")
}
