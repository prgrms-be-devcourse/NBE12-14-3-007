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

/** 커뮤니티 9개: 글 목록·상세·작성·수정·삭제, 댓글 목록·작성·수정·삭제 */
class CommunityApiContractTest : ApiContractSupport() {

    @Test
    fun 글_목록은_비로그인도_조회한다() {
        mvc.get("/api/v1/community/posts").andExpect {
            status { isOk() }
            jsonPath("$.data.content") { isArray() }
        }
    }

    @Test
    fun 카테고리로_글_목록을_거른다() {
        mvc.get("/api/v1/community/posts?category=FREE").andExpect {
            status { isOk() }
            jsonPath("$.data.content") { isArray() }
        }
    }

    @Test
    fun 없는_카테고리를_주면_거부한다() {
        mvc.get("/api/v1/community/posts?category=NOPE").andExpect { status { isBadRequest() } }
    }

    @Test
    fun 회원은_글을_작성한다() {
        mvc.post("/api/v1/community/posts") {
            auth(tokenOf(MemberRole.ROLE_UNVERIFIED))
            json(postBody("커뮤니티 글 제목", "내용"))
        }.andExpect {
            status { isOk() }
            jsonPath("$.data.id") { isNotEmpty() }
            jsonPath("$.data.category") { value("FREE") }
        }
    }

    @Test
    fun 제목이_한_글자면_글을_작성할_수_없다() {
        mvc.post("/api/v1/community/posts") {
            auth(tokenOf(MemberRole.ROLE_UNVERIFIED))
            json(postBody("짧", "내용"))
        }.andExpect { status { isBadRequest() } }
    }

    @Test
    fun 활동_제한_회원은_글을_작성할_수_없다() {
        mvc.post("/api/v1/community/posts") {
            auth(tokenOf(MemberRole.ROLE_WARNING))
            json(postBody("제한 회원 글", "내용"))
        }.andExpect { status { isForbidden() } }
    }

    @Test
    fun 미인증_사용자는_글을_작성할_수_없다() {
        mvc.post("/api/v1/community/posts") {
            json(postBody("비로그인 글", "내용"))
        }.andExpect { status { isUnauthorized() } }
    }

    @Test
    fun 글_상세는_비로그인도_조회한다() {
        val postId = createPost(tokenOf(MemberRole.ROLE_UNVERIFIED))

        mvc.get("/api/v1/community/posts/$postId").andExpect {
            status { isOk() }
            jsonPath("$.data.id") { value(postId.toString()) }
        }
    }

    @Test
    fun 없는_글을_조회하면_404다() {
        mvc.get("/api/v1/community/posts/${UUID.randomUUID()}").andExpect { status { isNotFound() } }
    }

    @Test
    fun 작성자는_글을_수정한다() {
        val author = tokenOf(MemberRole.ROLE_UNVERIFIED)
        val postId = createPost(author)

        mvc.patch("/api/v1/community/posts/$postId") {
            auth(author)
            json(postBody("수정된 제목", "수정된 내용"))
        }.andExpect {
            status { isOk() }
            jsonPath("$.data.title") { value("수정된 제목") }
        }
    }

    @Test
    fun 남의_글은_수정할_수_없다() {
        val postId = createPost(tokenOf(MemberRole.ROLE_UNVERIFIED))

        mvc.patch("/api/v1/community/posts/$postId") {
            auth(tokenOf(MemberRole.ROLE_UNVERIFIED))
            json(postBody("남의 글 수정", "내용"))
        }.andExpect { status { isForbidden() } }
    }

    @Test
    fun 작성자는_글을_삭제한다() {
        val author = tokenOf(MemberRole.ROLE_UNVERIFIED)
        val postId = createPost(author)

        mvc.delete("/api/v1/community/posts/$postId") { auth(author) }.andExpect { status { isOk() } }
        mvc.get("/api/v1/community/posts/$postId").andExpect { status { isNotFound() } }
    }

    @Test
    fun 남의_글은_삭제할_수_없다() {
        val postId = createPost(tokenOf(MemberRole.ROLE_UNVERIFIED))

        mvc.delete("/api/v1/community/posts/$postId") { auth(tokenOf(MemberRole.ROLE_UNVERIFIED)) }
            .andExpect { status { isForbidden() } }
    }

    @Test
    fun 댓글_목록은_비로그인도_조회한다() {
        val postId = createPost(tokenOf(MemberRole.ROLE_UNVERIFIED))

        mvc.get("/api/v1/community/posts/$postId/comments").andExpect {
            status { isOk() }
            jsonPath("$.data.content") { isArray() }
        }
    }

    @Test
    fun 회원은_댓글을_작성한다() {
        val postId = createPost(tokenOf(MemberRole.ROLE_UNVERIFIED))

        mvc.post("/api/v1/community/posts/$postId/comments") {
            auth(tokenOf(MemberRole.ROLE_UNVERIFIED))
            json(commentBody("댓글 내용"))
        }.andExpect {
            status { isOk() }
            jsonPath("$.data.content") { value("댓글 내용") }
        }
    }

    @Test
    fun 활동_제한_회원은_댓글을_작성할_수_없다() {
        val postId = createPost(tokenOf(MemberRole.ROLE_UNVERIFIED))

        mvc.post("/api/v1/community/posts/$postId/comments") {
            auth(tokenOf(MemberRole.ROLE_WARNING))
            json(commentBody("제한 회원 댓글"))
        }.andExpect { status { isForbidden() } }
    }

    @Test
    fun 대댓글은_부모의_replies에_담긴다() {
        val postId = createPost(tokenOf(MemberRole.ROLE_UNVERIFIED))
        // 댓글 쿨다운이 5초라, 대댓글은 다른 회원으로 단다.
        val parentId = createComment(postId, tokenOf(MemberRole.ROLE_UNVERIFIED))
        createComment(postId, tokenOf(MemberRole.ROLE_UNVERIFIED), parentId)

        mvc.get("/api/v1/community/posts/$postId/comments").andExpect {
            status { isOk() }
            jsonPath("$.data.content[0].id") { value(parentId.toInt()) }
            jsonPath("$.data.content[0].replies[0].parentId") { value(parentId.toInt()) }
        }
    }

    @Test
    fun 작성자는_댓글을_수정한다() {
        val postId = createPost(tokenOf(MemberRole.ROLE_UNVERIFIED))
        val author = tokenOf(MemberRole.ROLE_UNVERIFIED)
        val commentId = createComment(postId, author)

        mvc.patch("/api/v1/community/comments/$commentId") {
            auth(author)
            json(commentBody("수정된 댓글"))
        }.andExpect {
            status { isOk() }
            jsonPath("$.data.content") { value("수정된 댓글") }
        }
    }

    @Test
    fun 남의_댓글은_수정할_수_없다() {
        val postId = createPost(tokenOf(MemberRole.ROLE_UNVERIFIED))
        val commentId = createComment(postId, tokenOf(MemberRole.ROLE_UNVERIFIED))

        mvc.patch("/api/v1/community/comments/$commentId") {
            auth(tokenOf(MemberRole.ROLE_UNVERIFIED))
            json(commentBody("남의 댓글 수정"))
        }.andExpect { status { isForbidden() } }
    }

    /** 후기 댓글과 같은 정책이다. 삭제해도 행은 남기고 안내 문구로 내려간다. */
    @Test
    fun 삭제된_댓글은_목록에서_안내_문구로_내려간다() {
        val postId = createPost(tokenOf(MemberRole.ROLE_UNVERIFIED))
        val author = tokenOf(MemberRole.ROLE_UNVERIFIED)
        val commentId = createComment(postId, author)

        mvc.delete("/api/v1/community/comments/$commentId") { auth(author) }.andExpect { status { isOk() } }

        mvc.get("/api/v1/community/posts/$postId/comments").andExpect {
            status { isOk() }
            jsonPath("$.data.content[0].id") { value(commentId.toInt()) }
            jsonPath("$.data.content[0].deleted") { value(true) }
        }
    }

    @Test
    fun 남의_댓글은_삭제할_수_없다() {
        val postId = createPost(tokenOf(MemberRole.ROLE_UNVERIFIED))
        val commentId = createComment(postId, tokenOf(MemberRole.ROLE_UNVERIFIED))

        mvc.delete("/api/v1/community/comments/$commentId") { auth(tokenOf(MemberRole.ROLE_UNVERIFIED)) }
            .andExpect { status { isForbidden() } }
    }

    /** 도배 방지. 같은 회원은 게시글을 30초에 한 번만 쓸 수 있다. */
    @Test
    fun 게시글을_연달아_쓰면_거부한다() {
        val author = tokenOf(MemberRole.ROLE_UNVERIFIED)
        createPost(author)

        // 내용이 같으면 중복 검사(409)가 먼저 걸려서, 쿨다운을 보려면 내용을 달리한다.
        mvc.post("/api/v1/community/posts") {
            auth(author)
            json(postBody("연달아 쓴 글", "다른 내용 ${shortToken()}"))
        }.andExpect {
            status { isTooManyRequests() }
            jsonPath("$.code") { value("COMMUNITY004") }
        }
    }

    /** 같은 내용을 60초 안에 다시 올리면 중복으로 본다. 쿨다운보다 먼저 걸린다. */
    @Test
    fun 같은_내용의_게시글은_거부한다() {
        val author = tokenOf(MemberRole.ROLE_UNVERIFIED)
        val content = "똑같은 내용 ${shortToken()}"
        mvc.post("/api/v1/community/posts") {
            auth(author)
            json(postBody("첫 글", content))
        }.andExpect { status { isOk() } }

        mvc.post("/api/v1/community/posts") {
            auth(author)
            json(postBody("제목만 다른 글", content))
        }.andExpect {
            status { isConflict() }
            jsonPath("$.code") { value("COMMUNITY006") }
        }
    }

    @Test
    fun 같은_내용의_댓글은_거부한다() {
        val postId = createPost(tokenOf(MemberRole.ROLE_UNVERIFIED))
        val author = tokenOf(MemberRole.ROLE_UNVERIFIED)
        val content = "똑같은 댓글 ${shortToken()}"
        mvc.post("/api/v1/community/posts/$postId/comments") {
            auth(author)
            json(commentBody(content))
        }.andExpect { status { isOk() } }

        mvc.post("/api/v1/community/posts/$postId/comments") {
            auth(author)
            json(commentBody(content))
        }.andExpect {
            status { isConflict() }
            jsonPath("$.code") { value("COMMUNITY007") }
        }
    }

    /** 도배 방지. 같은 회원은 댓글을 5초에 한 번만 쓸 수 있다. */
    @Test
    fun 댓글을_연달아_쓰면_거부한다() {
        val postId = createPost(tokenOf(MemberRole.ROLE_UNVERIFIED))
        val author = tokenOf(MemberRole.ROLE_UNVERIFIED)
        createComment(postId, author)

        mvc.post("/api/v1/community/posts/$postId/comments") {
            auth(author)
            json(commentBody("연달아 쓴 댓글"))
        }.andExpect {
            status { isTooManyRequests() }
            jsonPath("$.code") { value("COMMUNITY005") }
        }
    }

    private fun MockHttpServletRequestDsl.auth(bearerToken: String) {
        header(HttpHeaders.AUTHORIZATION, bearerToken)
    }

    private fun MockHttpServletRequestDsl.json(body: String) {
        contentType = MediaType.APPLICATION_JSON
        content = body
    }

    private fun createPost(bearerToken: String): UUID {
        val result = mvc.post("/api/v1/community/posts") {
            auth(bearerToken)
            json(postBody("계약테스트 글 ${shortToken()}", "내용 ${shortToken()}"))
        }.andExpect { status { isOk() } }.andReturn()
        return UUID.fromString(objectMapper.readTree(result.response.contentAsString).path("data").path("id").asString())
    }

    private fun createComment(postId: UUID, bearerToken: String, parentId: Long? = null): Long {
        val result = mvc.post("/api/v1/community/posts/$postId/comments") {
            auth(bearerToken)
            json(commentBody(if (parentId == null) "댓글 내용" else "대댓글 내용", parentId))
        }.andExpect { status { isOk() } }.andReturn()
        return objectMapper.readTree(result.response.contentAsString).path("data").path("id").asLong()
    }

    private fun postBody(title: String, content: String): String =
        """{"category":"FREE","title":"$title","content":"$content"}"""

    private fun commentBody(content: String, parentId: Long? = null): String =
        if (parentId == null) """{"content":"$content"}""" else """{"content":"$content","parentId":$parentId}"""

    private fun shortToken(): String = UUID.randomUUID().toString().substring(0, 8)
}
