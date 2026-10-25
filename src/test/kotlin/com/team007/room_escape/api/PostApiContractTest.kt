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

/** 후기 7개: 작성, 목록, 어드민 목록, 행사별 목록, 상세, 수정, 삭제 */
class PostApiContractTest : ApiContractSupport() {

    @Test
    fun 후기_목록은_비로그인도_조회한다() {
        mvc.get("/api/v1/posts").andExpect {
            status { isOk() }
            jsonPath("$.data.content") { isArray() }
        }
    }

    @Test
    fun 행사별_후기_목록은_비로그인도_조회한다() {
        mvc.get("/api/v1/festivals/${festivalId()}/posts").andExpect {
            status { isOk() }
            jsonPath("$.data.content") { isArray() }
        }
    }

    @Test
    fun 회원은_행사에_후기를_작성한다() {
        mvc.post("/api/v1/festivals/${festivalId()}/posts") {
            auth(tokenOf(MemberRole.ROLE_UNVERIFIED))
            json(postBody("후기 제목입니다", "후기 내용"))
        }.andExpect {
            status { isOk() }
            jsonPath("$.data.id") { isNotEmpty() }
        }
    }

    @Test
    fun 제목이_한_글자면_후기를_작성할_수_없다() {
        mvc.post("/api/v1/festivals/${festivalId()}/posts") {
            auth(tokenOf(MemberRole.ROLE_UNVERIFIED))
            json(postBody("짧", "내용"))
        }.andExpect { status { isBadRequest() } }
    }

    /** 활동 제한 회원은 후기를 쓸 수 없다. 지금은 등급 계층의 최하단으로 표현된다. */
    @Test
    fun 활동_제한_회원은_후기를_작성할_수_없다() {
        mvc.post("/api/v1/festivals/${festivalId()}/posts") {
            auth(tokenOf(MemberRole.ROLE_WARNING))
            json(postBody("제한 회원 후기", "내용"))
        }.andExpect { status { isForbidden() } }
    }

    @Test
    fun 미인증_사용자는_후기를_작성할_수_없다() {
        mvc.post("/api/v1/festivals/${festivalId()}/posts") {
            json(postBody("비로그인 후기", "내용"))
        }.andExpect { status { isUnauthorized() } }
    }

    @Test
    fun 후기_상세는_비로그인도_조회한다() {
        val postId = createPost(tokenOf(MemberRole.ROLE_UNVERIFIED))

        mvc.get("/api/v1/posts/$postId").andExpect {
            status { isOk() }
            jsonPath("$.data.id") { value(postId.toString()) }
            jsonPath("$.data.member") { exists() }
        }
    }

    @Test
    fun 없는_후기를_조회하면_404다() {
        mvc.get("/api/v1/posts/${UUID.randomUUID()}").andExpect { status { isNotFound() } }
    }

    @Test
    fun 작성자는_후기를_수정한다() {
        val author = tokenOf(MemberRole.ROLE_UNVERIFIED)
        val postId = createPost(author)

        mvc.patch("/api/v1/posts/$postId") {
            auth(author)
            json(postBody("수정된 제목", "수정된 내용"))
        }.andExpect {
            status { isOk() }
            jsonPath("$.data.title") { value("수정된 제목") }
        }
    }

    @Test
    fun 남의_후기는_수정할_수_없다() {
        val postId = createPost(tokenOf(MemberRole.ROLE_UNVERIFIED))

        mvc.patch("/api/v1/posts/$postId") {
            auth(tokenOf(MemberRole.ROLE_UNVERIFIED))
            json(postBody("남의 글 수정", "내용"))
        }.andExpect { status { isForbidden() } }
    }

    @Test
    fun 작성자는_후기를_삭제한다() {
        val author = tokenOf(MemberRole.ROLE_UNVERIFIED)
        val postId = createPost(author)

        mvc.delete("/api/v1/posts/$postId") { auth(author) }.andExpect { status { isOk() } }
        mvc.get("/api/v1/posts/$postId").andExpect { status { isNotFound() } }
    }

    @Test
    fun 남의_후기는_삭제할_수_없다() {
        val postId = createPost(tokenOf(MemberRole.ROLE_UNVERIFIED))

        mvc.delete("/api/v1/posts/$postId") { auth(tokenOf(MemberRole.ROLE_UNVERIFIED)) }
            .andExpect { status { isForbidden() } }
    }

    @Test
    fun 관리자는_삭제된_후기까지_조회한다() {
        mvc.get("/api/v1/admin/posts") { auth(tokenOf(MemberRole.ROLE_ADMIN)) }.andExpect {
            status { isOk() }
            jsonPath("$.data.content") { isArray() }
        }
    }

    @Test
    fun 일반_회원은_어드민_후기_목록을_조회할_수_없다() {
        mvc.get("/api/v1/admin/posts") { auth(tokenOf(MemberRole.ROLE_UNVERIFIED)) }
            .andExpect { status { isForbidden() } }
    }

    private fun MockHttpServletRequestDsl.auth(bearerToken: String) {
        header(HttpHeaders.AUTHORIZATION, bearerToken)
    }

    private fun MockHttpServletRequestDsl.json(body: String) {
        contentType = MediaType.APPLICATION_JSON
        content = body
    }

    private fun createPost(bearerToken: String): UUID {
        val result = mvc.post("/api/v1/festivals/${festivalId()}/posts") {
            auth(bearerToken)
            json(postBody("계약테스트 후기 ${UUID.randomUUID().toString().substring(0, 8)}", "내용"))
        }.andExpect { status { isOk() } }.andReturn()
        return UUID.fromString(
            objectMapper.readTree(result.response.contentAsString).path("data").path("id").asString()
        )
    }

    private fun postBody(title: String, content: String): String = """{"title":"$title","content":"$content"}"""
}
