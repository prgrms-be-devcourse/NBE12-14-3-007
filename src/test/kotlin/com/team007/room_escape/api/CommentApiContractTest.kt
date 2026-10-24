package com.team007.room_escape.api

import com.team007.room_escape.domain.member.infra.entity.MemberRole
import org.junit.jupiter.api.Test
import org.springframework.http.HttpHeaders
import org.springframework.http.MediaType
import org.springframework.test.web.servlet.MockHttpServletRequestDsl
import org.springframework.test.web.servlet.delete
import org.springframework.test.web.servlet.get
import org.springframework.test.web.servlet.patch
import org.springframework.test.web.servlet.post
import java.util.UUID

/** 후기 댓글 5개: 어드민 목록, 작성, 목록, 수정, 삭제 */
class CommentApiContractTest : ApiContractSupport() {

    @Test
    fun 댓글_목록은_비로그인도_조회한다() {
        val postId = createPost()

        mvc.get("/api/v1/posts/$postId/comments").andExpect {
            status { isOk() }
            jsonPath("$.data.content") { isArray() }
        }
    }

    @Test
    fun 회원은_댓글을_작성한다() {
        val postId = createPost()

        mvc.post("/api/v1/posts/$postId/comments") {
            auth(tokenOf(MemberRole.ROLE_UNVERIFIED))
            json("""{"content":"댓글 내용"}""")
        }.andExpect {
            status { isOk() }
            jsonPath("$.data.id") { isNotEmpty() }
            jsonPath("$.data.content") { value("댓글 내용") }
        }
    }

    @Test
    fun 빈_댓글은_작성할_수_없다() {
        val postId = createPost()

        mvc.post("/api/v1/posts/$postId/comments") {
            auth(tokenOf(MemberRole.ROLE_UNVERIFIED))
            json("""{"content":"   "}""")
        }.andExpect {
            status { isBadRequest() }
        }
    }

    @Test
    fun 활동_제한_회원은_댓글을_작성할_수_없다() {
        val postId = createPost()

        mvc.post("/api/v1/posts/$postId/comments") {
            auth(tokenOf(MemberRole.ROLE_WARNING))
            json("""{"content":"제한 회원 댓글"}""")
        }.andExpect {
            status { isForbidden() }
        }
    }

    @Test
    fun 미인증_사용자는_댓글을_작성할_수_없다() {
        val postId = createPost()

        mvc.post("/api/v1/posts/$postId/comments") {
            json("""{"content":"비로그인 댓글"}""")
        }.andExpect {
            status { isUnauthorized() }
        }
    }

    /** 대댓글은 parentId 로 달리고, 응답에서 부모의 replies 에 담긴다. */
    @Test
    fun 대댓글은_부모의_replies에_담긴다() {
        val postId = createPost()
        val author = tokenOf(MemberRole.ROLE_UNVERIFIED)
        val parentId = createComment(postId, author, null)
        createComment(postId, author, parentId)

        mvc.get("/api/v1/posts/$postId/comments").andExpect {
            status { isOk() }
            jsonPath("$.data.content[0].id") { value(parentId.toInt()) }
            jsonPath("$.data.content[0].replies") { isArray() }
            jsonPath("$.data.content[0].replies[0].parentId") { value(parentId.toInt()) }
        }
    }

    @Test
    fun 작성자는_댓글을_수정한다() {
        val postId = createPost()
        val author = tokenOf(MemberRole.ROLE_UNVERIFIED)
        val commentId = createComment(postId, author, null)

        mvc.patch("/api/v1/comments/$commentId") {
            auth(author)
            json("""{"content":"수정된 댓글"}""")
        }.andExpect {
            status { isOk() }
            jsonPath("$.data.content") { value("수정된 댓글") }
        }
    }

    @Test
    fun 남의_댓글은_수정할_수_없다() {
        val postId = createPost()
        val commentId = createComment(postId, tokenOf(MemberRole.ROLE_UNVERIFIED), null)

        mvc.patch("/api/v1/comments/$commentId") {
            auth(tokenOf(MemberRole.ROLE_UNVERIFIED))
            json("""{"content":"남의 댓글 수정"}""")
        }.andExpect {
            status { isForbidden() }
        }
    }

    /** 삭제해도 행은 남기고 "삭제된 댓글입니다"로 내려간다. 대댓글 흐름이 끊기지 않게 하는 정책이다. */
    @Test
    fun 삭제된_댓글은_목록에서_안내_문구로_내려간다() {
        val postId = createPost()
        val author = tokenOf(MemberRole.ROLE_UNVERIFIED)
        val commentId = createComment(postId, author, null)

        mvc.delete("/api/v1/comments/$commentId") { auth(author) }
            .andExpect { status { isOk() } }

        mvc.get("/api/v1/posts/$postId/comments").andExpect {
            status { isOk() }
            jsonPath("$.data.content[0].id") { value(commentId.toInt()) }
            jsonPath("$.data.content[0].deleted") { value(true) }
        }
    }

    @Test
    fun 남의_댓글은_삭제할_수_없다() {
        val postId = createPost()
        val commentId = createComment(postId, tokenOf(MemberRole.ROLE_UNVERIFIED), null)

        mvc.delete("/api/v1/comments/$commentId") { auth(tokenOf(MemberRole.ROLE_UNVERIFIED)) }
            .andExpect { status { isForbidden() } }
    }

    @Test
    fun 관리자는_삭제된_댓글의_원문을_조회한다() {
        val postId = createPost()

        mvc.get("/api/v1/admin/posts/$postId/comments") { auth(tokenOf(MemberRole.ROLE_ADMIN)) }
            .andExpect {
                status { isOk() }
                jsonPath("$.data.content") { isArray() }
            }
    }

    @Test
    fun 일반_회원은_어드민_댓글_목록을_조회할_수_없다() {
        val postId = createPost()

        mvc.get("/api/v1/admin/posts/$postId/comments") { auth(tokenOf(MemberRole.ROLE_UNVERIFIED)) }
            .andExpect { status { isForbidden() } }
    }

    private fun MockHttpServletRequestDsl.auth(bearerToken: String) {
        header(HttpHeaders.AUTHORIZATION, bearerToken)
    }

    private fun MockHttpServletRequestDsl.json(body: String) {
        contentType = MediaType.APPLICATION_JSON
        content = body
    }

    private fun createPost(): UUID {
        val title = "댓글테스트 후기 ${UUID.randomUUID().toString().substring(0, 8)}"
        val result = mvc.post("/api/v1/festivals/${festivalId()}/posts") {
            auth(tokenOf(MemberRole.ROLE_UNVERIFIED))
            json("""{"title":"$title","content":"내용"}""")
        }.andExpect { status { isOk() } }.andReturn()
        return UUID.fromString(
            objectMapper.readTree(result.response.contentAsString).path("data").path("id").asString()
        )
    }

    private fun createComment(postId: UUID, bearerToken: String, parentId: Long?): Long {
        val body = if (parentId == null) {
            """{"content":"댓글 내용"}"""
        } else {
            """{"content":"대댓글 내용","parentId":$parentId}"""
        }
        val result = mvc.post("/api/v1/posts/$postId/comments") {
            auth(bearerToken)
            json(body)
        }.andExpect { status { isOk() } }.andReturn()
        return objectMapper.readTree(result.response.contentAsString).path("data").path("id").asLong()
    }
}
