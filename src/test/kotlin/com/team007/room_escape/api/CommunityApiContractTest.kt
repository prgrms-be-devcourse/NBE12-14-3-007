package com.team007.room_escape.api

import com.team007.room_escape.domain.member.infra.entity.MemberRole
import org.junit.jupiter.api.Test
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.patch
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.status
import java.util.UUID

/** 커뮤니티 9개: 글 목록·상세·작성·수정·삭제, 댓글 목록·작성·수정·삭제 */
class CommunityApiContractTest : ApiContractSupport() {

    @Test
    fun 글_목록은_비로그인도_조회한다() {
        mvc.perform(get("/api/v1/community/posts"))
            .andExpect(status().isOk)
            .andExpect(jsonPath("$.data.content").isArray())
    }

    @Test
    fun 카테고리로_글_목록을_거른다() {
        mvc.perform(get("/api/v1/community/posts?category=FREE"))
            .andExpect(status().isOk)
            .andExpect(jsonPath("$.data.content").isArray())
    }

    @Test
    fun 없는_카테고리를_주면_거부한다() {
        mvc.perform(get("/api/v1/community/posts?category=NOPE"))
            .andExpect(status().isBadRequest)
    }

    @Test
    fun 회원은_글을_작성한다() {
        mvc.perform(`as`(post("/api/v1/community/posts"), tokenOf(MemberRole.ROLE_UNVERIFIED))
            .contentType("application/json")
            .content(postBody("커뮤니티 글 제목", "내용")))
            .andExpect(status().isOk)
            .andExpect(jsonPath("$.data.id").isNotEmpty())
            .andExpect(jsonPath("$.data.category").value("FREE"))
    }

    @Test
    fun 제목이_한_글자면_글을_작성할_수_없다() {
        mvc.perform(`as`(post("/api/v1/community/posts"), tokenOf(MemberRole.ROLE_UNVERIFIED))
            .contentType("application/json")
            .content(postBody("짧", "내용")))
            .andExpect(status().isBadRequest)
    }

    @Test
    fun 활동_제한_회원은_글을_작성할_수_없다() {
        mvc.perform(`as`(post("/api/v1/community/posts"), tokenOf(MemberRole.ROLE_WARNING))
            .contentType("application/json")
            .content(postBody("제한 회원 글", "내용")))
            .andExpect(status().isForbidden)
    }

    @Test
    fun 미인증_사용자는_글을_작성할_수_없다() {
        mvc.perform(post("/api/v1/community/posts")
            .contentType("application/json")
            .content(postBody("비로그인 글", "내용")))
            .andExpect(status().isUnauthorized)
    }

    @Test
    fun 글_상세는_비로그인도_조회한다() {
        val postId = createPost(tokenOf(MemberRole.ROLE_UNVERIFIED))

        mvc.perform(get("/api/v1/community/posts/$postId"))
            .andExpect(status().isOk)
            .andExpect(jsonPath("$.data.id").value(postId.toString()))
    }

    @Test
    fun 없는_글을_조회하면_404다() {
        mvc.perform(get("/api/v1/community/posts/${UUID.randomUUID()}"))
            .andExpect(status().isNotFound)
    }

    @Test
    fun 작성자는_글을_수정한다() {
        val author = tokenOf(MemberRole.ROLE_UNVERIFIED)
        val postId = createPost(author)

        mvc.perform(`as`(patch("/api/v1/community/posts/$postId"), author)
            .contentType("application/json")
            .content(postBody("수정된 제목", "수정된 내용")))
            .andExpect(status().isOk)
            .andExpect(jsonPath("$.data.title").value("수정된 제목"))
    }

    @Test
    fun 남의_글은_수정할_수_없다() {
        val postId = createPost(tokenOf(MemberRole.ROLE_UNVERIFIED))

        mvc.perform(`as`(patch("/api/v1/community/posts/$postId"), tokenOf(MemberRole.ROLE_UNVERIFIED))
            .contentType("application/json")
            .content(postBody("남의 글 수정", "내용")))
            .andExpect(status().isForbidden)
    }

    @Test
    fun 작성자는_글을_삭제한다() {
        val author = tokenOf(MemberRole.ROLE_UNVERIFIED)
        val postId = createPost(author)

        mvc.perform(`as`(delete("/api/v1/community/posts/$postId"), author))
            .andExpect(status().isOk)
        mvc.perform(get("/api/v1/community/posts/$postId"))
            .andExpect(status().isNotFound)
    }

    @Test
    fun 남의_글은_삭제할_수_없다() {
        val postId = createPost(tokenOf(MemberRole.ROLE_UNVERIFIED))

        mvc.perform(`as`(delete("/api/v1/community/posts/$postId"), tokenOf(MemberRole.ROLE_UNVERIFIED)))
            .andExpect(status().isForbidden)
    }

    @Test
    fun 댓글_목록은_비로그인도_조회한다() {
        val postId = createPost(tokenOf(MemberRole.ROLE_UNVERIFIED))

        mvc.perform(get("/api/v1/community/posts/$postId/comments"))
            .andExpect(status().isOk)
            .andExpect(jsonPath("$.data.content").isArray())
    }

    @Test
    fun 회원은_댓글을_작성한다() {
        val postId = createPost(tokenOf(MemberRole.ROLE_UNVERIFIED))

        mvc.perform(`as`(post("/api/v1/community/posts/$postId/comments"),
            tokenOf(MemberRole.ROLE_UNVERIFIED))
            .contentType("application/json")
            .content(commentBody("댓글 내용", null)))
            .andExpect(status().isOk)
            .andExpect(jsonPath("$.data.content").value("댓글 내용"))
    }

    @Test
    fun 활동_제한_회원은_댓글을_작성할_수_없다() {
        val postId = createPost(tokenOf(MemberRole.ROLE_UNVERIFIED))

        mvc.perform(`as`(post("/api/v1/community/posts/$postId/comments"),
            tokenOf(MemberRole.ROLE_WARNING))
            .contentType("application/json")
            .content(commentBody("제한 회원 댓글", null)))
            .andExpect(status().isForbidden)
    }

    @Test
    fun 대댓글은_부모의_replies에_담긴다() {
        val postId = createPost(tokenOf(MemberRole.ROLE_UNVERIFIED))
        // 댓글 쿨다운이 5초라, 대댓글은 다른 회원으로 단다.
        val parentId = createComment(postId, tokenOf(MemberRole.ROLE_UNVERIFIED), null)
        createComment(postId, tokenOf(MemberRole.ROLE_UNVERIFIED), parentId)

        mvc.perform(get("/api/v1/community/posts/$postId/comments"))
            .andExpect(status().isOk)
            .andExpect(jsonPath("$.data.content[0].id").value(parentId.toInt()))
            .andExpect(jsonPath("$.data.content[0].replies[0].parentId").value(parentId.toInt()))
    }

    @Test
    fun 작성자는_댓글을_수정한다() {
        val postId = createPost(tokenOf(MemberRole.ROLE_UNVERIFIED))
        val author = tokenOf(MemberRole.ROLE_UNVERIFIED)
        val commentId = createComment(postId, author, null)

        mvc.perform(`as`(patch("/api/v1/community/comments/$commentId"), author)
            .contentType("application/json")
            .content(commentBody("수정된 댓글", null)))
            .andExpect(status().isOk)
            .andExpect(jsonPath("$.data.content").value("수정된 댓글"))
    }

    @Test
    fun 남의_댓글은_수정할_수_없다() {
        val postId = createPost(tokenOf(MemberRole.ROLE_UNVERIFIED))
        val commentId = createComment(postId, tokenOf(MemberRole.ROLE_UNVERIFIED), null)

        mvc.perform(`as`(patch("/api/v1/community/comments/$commentId"),
            tokenOf(MemberRole.ROLE_UNVERIFIED))
            .contentType("application/json")
            .content(commentBody("남의 댓글 수정", null)))
            .andExpect(status().isForbidden)
    }

    /** 후기 댓글과 같은 정책이다. 삭제해도 행은 남기고 안내 문구로 내려간다. */
    @Test
    fun 삭제된_댓글은_목록에서_안내_문구로_내려간다() {
        val postId = createPost(tokenOf(MemberRole.ROLE_UNVERIFIED))
        val author = tokenOf(MemberRole.ROLE_UNVERIFIED)
        val commentId = createComment(postId, author, null)

        mvc.perform(`as`(delete("/api/v1/community/comments/$commentId"), author))
            .andExpect(status().isOk)

        mvc.perform(get("/api/v1/community/posts/$postId/comments"))
            .andExpect(status().isOk)
            .andExpect(jsonPath("$.data.content[0].id").value(commentId.toInt()))
            .andExpect(jsonPath("$.data.content[0].deleted").value(true))
    }

    @Test
    fun 남의_댓글은_삭제할_수_없다() {
        val postId = createPost(tokenOf(MemberRole.ROLE_UNVERIFIED))
        val commentId = createComment(postId, tokenOf(MemberRole.ROLE_UNVERIFIED), null)

        mvc.perform(`as`(delete("/api/v1/community/comments/$commentId"),
            tokenOf(MemberRole.ROLE_UNVERIFIED)))
            .andExpect(status().isForbidden)
    }

    /** 도배 방지. 같은 회원은 게시글을 30초에 한 번만 쓸 수 있다. */
    @Test
    fun 게시글을_연달아_쓰면_거부한다() {
        val author = tokenOf(MemberRole.ROLE_UNVERIFIED)
        createPost(author)

        // 내용이 같으면 중복 검사(409)가 먼저 걸려서, 쿨다운을 보려면 내용을 달리한다.
        mvc.perform(`as`(post("/api/v1/community/posts"), author)
            .contentType("application/json")
            .content(postBody("연달아 쓴 글", "다른 내용 ${shortToken()}")))
            .andExpect(status().isTooManyRequests)
            .andExpect(jsonPath("$.code").value("COMMUNITY004"))
    }

    /** 같은 내용을 60초 안에 다시 올리면 중복으로 본다. 쿨다운보다 먼저 걸린다. */
    @Test
    fun 같은_내용의_게시글은_거부한다() {
        val author = tokenOf(MemberRole.ROLE_UNVERIFIED)
        val content = "똑같은 내용 ${shortToken()}"
        mvc.perform(`as`(post("/api/v1/community/posts"), author)
            .contentType("application/json")
            .content(postBody("첫 글", content)))
            .andExpect(status().isOk)

        mvc.perform(`as`(post("/api/v1/community/posts"), author)
            .contentType("application/json")
            .content(postBody("제목만 다른 글", content)))
            .andExpect(status().isConflict)
            .andExpect(jsonPath("$.code").value("COMMUNITY006"))
    }

    @Test
    fun 같은_내용의_댓글은_거부한다() {
        val postId = createPost(tokenOf(MemberRole.ROLE_UNVERIFIED))
        val author = tokenOf(MemberRole.ROLE_UNVERIFIED)
        val content = "똑같은 댓글 ${shortToken()}"
        mvc.perform(`as`(post("/api/v1/community/posts/$postId/comments"), author)
            .contentType("application/json")
            .content(commentBody(content, null)))
            .andExpect(status().isOk)

        mvc.perform(`as`(post("/api/v1/community/posts/$postId/comments"), author)
            .contentType("application/json")
            .content(commentBody(content, null)))
            .andExpect(status().isConflict)
            .andExpect(jsonPath("$.code").value("COMMUNITY007"))
    }

    /** 도배 방지. 같은 회원은 댓글을 5초에 한 번만 쓸 수 있다. */
    @Test
    fun 댓글을_연달아_쓰면_거부한다() {
        val postId = createPost(tokenOf(MemberRole.ROLE_UNVERIFIED))
        val author = tokenOf(MemberRole.ROLE_UNVERIFIED)
        createComment(postId, author, null)

        mvc.perform(`as`(post("/api/v1/community/posts/$postId/comments"), author)
            .contentType("application/json")
            .content(commentBody("연달아 쓴 댓글", null)))
            .andExpect(status().isTooManyRequests)
            .andExpect(jsonPath("$.code").value("COMMUNITY005"))
    }

    private fun createPost(bearerToken: String): UUID {
        val result = mvc.perform(`as`(post("/api/v1/community/posts"), bearerToken)
            .contentType("application/json")
            .content(postBody("계약테스트 글 ${shortToken()}", "내용 ${shortToken()}")))
            .andExpect(status().isOk)
            .andReturn()
        return UUID.fromString(objectMapper.readTree(result.response.contentAsString)
            .path("data").path("id").asString())
    }

    private fun createComment(postId: UUID, bearerToken: String, parentId: Long?): Long {
        val result = mvc.perform(`as`(post("/api/v1/community/posts/$postId/comments"), bearerToken)
            .contentType("application/json")
            .content(commentBody(if (parentId == null) "댓글 내용" else "대댓글 내용", parentId)))
            .andExpect(status().isOk)
            .andReturn()
        return objectMapper.readTree(result.response.contentAsString)
            .path("data").path("id").asLong()
    }

    private fun postBody(title: String, content: String): String = """
        {"category":"FREE","title":"%s","content":"%s"}
        """.trimIndent().format(title, content)

    private fun commentBody(content: String, parentId: Long?): String =
        if (parentId == null) {
            """
            {"content":"%s"}
            """.trimIndent().format(content)
        } else {
            """
            {"content":"%s","parentId":%d}
            """.trimIndent().format(content, parentId)
        }

    private fun shortToken(): String = UUID.randomUUID().toString().substring(0, 8)
}
