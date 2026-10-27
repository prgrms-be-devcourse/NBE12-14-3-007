package com.team007.room_escape.api

import com.team007.room_escape.domain.member.infra.entity.MemberRole
import org.hamcrest.Matchers.hasItem
import org.hamcrest.Matchers.not
import org.junit.jupiter.api.Test
import org.springframework.http.HttpHeaders
import org.springframework.http.MediaType
import org.springframework.test.web.servlet.MockHttpServletRequestDsl
import org.springframework.test.web.servlet.delete
import org.springframework.test.web.servlet.get
import org.springframework.test.web.servlet.post
import org.springframework.test.web.servlet.put
import java.util.UUID

/**
 * 고객센터 공지사항·자주 묻는 질문.
 * 조회는 누구나, 쓰기·수정·삭제는 관리자만 한다.
 *
 * GET /support/notices, GET /support/faqs,
 * POST /admin/support/articles, PUT·DELETE /admin/support/articles/{id}
 */
class SupportArticleApiContractTest : ApiContractSupport() {

    /** 프론트에 고정해 두었던 공지 3개와 질문 7개를 마이그레이션이 같은 순서로 옮겨 둔다. */
    @Test
    fun 기존에_화면에_고정했던_내용이_같은_순서로_들어_있다() {
        mvc.get("/api/v1/support/notices").andExpect {
            status { isOk() }
            jsonPath("$.data.content[0].title") { value("고객센터를 열었어요") }
            jsonPath("$.data.content[2].title") { value("커뮤니티에서 함께 지켜 주세요") }
            jsonPath("$.data.content[0].content") { value(org.hamcrest.Matchers.containsString("\n")) }
        }
        mvc.get("/api/v1/support/faqs").andExpect {
            status { isOk() }
            jsonPath("$.data.length()") { value(7) }
            jsonPath("$.data[0].title") { value("행사는 어떻게 제보하나요?") }
            jsonPath("$.data[6].title") { value("회원 탈퇴는 어디서 하나요?") }
        }
    }

    @Test
    fun 비회원도_공지사항을_최신순으로_본다() {
        val title = uniqueTitle("새 공지")
        create("NOTICE", title, "공지 내용")

        mvc.get("/api/v1/support/notices").andExpect {
            status { isOk() }
            jsonPath("$.data.content[0].title") { value(title) }
            jsonPath("$.data.content[0].type") { value("NOTICE") }
            jsonPath("$.data.content[0].content") { value("공지 내용") }
            jsonPath("$.data.content[0].createdAt") { isString() }
        }
    }

    @Test
    fun 공지사항은_페이지로_나눠_받는다() {
        create("NOTICE", uniqueTitle("공지"), "내용")

        mvc.get("/api/v1/support/notices?page=0&size=1").andExpect {
            status { isOk() }
            jsonPath("$.data.content.length()") { value(1) }
            jsonPath("$.data.totalPages") { isNumber() }
        }
    }

    @Test
    fun 비회원도_자주_묻는_질문을_표시_순서대로_본다() {
        val first = uniqueTitle("맨 위 질문")
        val last = uniqueTitle("맨 아래 질문")
        create("FAQ", last, "답변")
        create("FAQ", first, "답변", displayOrder = 0)

        mvc.get("/api/v1/support/faqs").andExpect {
            status { isOk() }
            jsonPath("$.data[0].title") { value(first) }
            jsonPath("$.data[-1].title") { value(last) }
        }
    }

    @Test
    fun 공지사항과_질문은_서로의_목록에_섞이지_않는다() {
        val notice = uniqueTitle("공지")
        val faq = uniqueTitle("질문")
        create("NOTICE", notice, "내용")
        create("FAQ", faq, "내용")

        mvc.get("/api/v1/support/notices?size=50").andExpect {
            jsonPath("$.data.content[*].title") { value(not(hasItem(faq))) }
        }
        mvc.get("/api/v1/support/faqs").andExpect {
            jsonPath("$.data[*].title") { value(not(hasItem(notice))) }
        }
    }

    @Test
    fun 제목과_내용의_앞뒤_공백을_지우고_줄바꿈을_맞춰_저장한다() {
        val title = uniqueTitle("공백")
        mvc.post("/api/v1/admin/support/articles") {
            auth(tokenOf(MemberRole.ROLE_ADMIN))
            json("""{"type":"NOTICE","title":"  $title  ","content":"  첫 줄\r\n둘째 줄  "}""")
        }.andExpect {
            status { isOk() }
            jsonPath("$.data.title") { value(title) }
            jsonPath("$.data.content") { value("첫 줄\n둘째 줄") }
        }
    }

    @Test
    fun 관리자는_글을_고친다() {
        val id = create("FAQ", uniqueTitle("고치기 전"), "답변")
        val title = uniqueTitle("고친 질문")

        mvc.put("/api/v1/admin/support/articles/$id") {
            auth(tokenOf(MemberRole.ROLE_ADMIN))
            json("""{"title":"$title","content":"고친 답변","displayOrder":0}""")
        }.andExpect {
            status { isOk() }
            jsonPath("$.data.id") { value(id) }
            jsonPath("$.data.title") { value(title) }
            jsonPath("$.data.content") { value("고친 답변") }
            jsonPath("$.data.displayOrder") { value(0) }
        }
        mvc.get("/api/v1/support/faqs").andExpect {
            jsonPath("$.data[0].title") { value(title) }
        }
    }

    @Test
    fun 표시_순서를_보내지_않고_고치면_순서는_그대로다() {
        val id = create("FAQ", uniqueTitle("질문"), "답변", displayOrder = 3)

        mvc.put("/api/v1/admin/support/articles/$id") {
            auth(tokenOf(MemberRole.ROLE_ADMIN))
            json("""{"title":"${uniqueTitle("질문")}","content":"답변"}""")
        }.andExpect {
            status { isOk() }
            jsonPath("$.data.displayOrder") { value(3) }
        }
    }

    @Test
    fun 관리자가_지운_글은_목록에서_빠지고_다시_고칠_수_없다() {
        val title = uniqueTitle("지울 공지")
        val id = create("NOTICE", title, "내용")
        val admin = tokenOf(MemberRole.ROLE_ADMIN)

        mvc.delete("/api/v1/admin/support/articles/$id") { auth(admin) }.andExpect {
            status { isOk() }
        }
        mvc.get("/api/v1/support/notices?size=50").andExpect {
            jsonPath("$.data.content[*].title") { value(not(hasItem(title))) }
        }
        mvc.put("/api/v1/admin/support/articles/$id") {
            auth(admin)
            json("""{"title":"다시","content":"다시"}""")
        }.andExpect {
            status { isNotFound() }
            jsonPath("$.code") { value("SUPPORT000") }
        }
    }

    @Test
    fun 없는_글을_고치거나_지우면_404다() {
        val admin = tokenOf(MemberRole.ROLE_ADMIN)

        mvc.put("/api/v1/admin/support/articles/$MISSING_ID") {
            auth(admin)
            json("""{"title":"제목","content":"내용"}""")
        }.andExpect { status { isNotFound() } }
        mvc.delete("/api/v1/admin/support/articles/$MISSING_ID") { auth(admin) }.andExpect {
            status { isNotFound() }
        }
    }

    @Test
    fun 일반_회원은_쓰거나_고치거나_지울_수_없다() {
        val id = create("NOTICE", uniqueTitle("공지"), "내용")
        val member = tokenOf(MemberRole.ROLE_TRUSTED)

        mvc.post("/api/v1/admin/support/articles") {
            auth(member)
            json("""{"type":"NOTICE","title":"제목","content":"내용"}""")
        }.andExpect { status { isForbidden() } }
        mvc.put("/api/v1/admin/support/articles/$id") {
            auth(member)
            json("""{"title":"제목","content":"내용"}""")
        }.andExpect { status { isForbidden() } }
        mvc.delete("/api/v1/admin/support/articles/$id") { auth(member) }.andExpect {
            status { isForbidden() }
        }
    }

    @Test
    fun 로그인하지_않으면_쓸_수_없다() {
        mvc.post("/api/v1/admin/support/articles") {
            json("""{"type":"NOTICE","title":"제목","content":"내용"}""")
        }.andExpect { status { isUnauthorized() } }
    }

    @Test
    fun 종류가_없거나_제목과_내용이_비었거나_너무_길면_400이다() {
        val admin = tokenOf(MemberRole.ROLE_ADMIN)
        listOf(
            """{"title":"제목","content":"내용"}""",
            """{"type":"NOTICE","title":"   ","content":"내용"}""",
            """{"type":"NOTICE","title":"제목","content":""}""",
            """{"type":"NOTICE","title":"${"가".repeat(101)}","content":"내용"}""",
            """{"type":"NOTICE","title":"제목","content":"${"가".repeat(5001)}"}""",
            """{"type":"FAQ","title":"제목","content":"내용","displayOrder":-1}""",
            """{"type":"EVENT","title":"제목","content":"내용"}""",
        ).forEach { body ->
            mvc.post("/api/v1/admin/support/articles") {
                auth(admin)
                json(body)
            }.andExpect { status { isBadRequest() } }
        }
    }

    /** 관리자로 글을 쓰고 id를 돌려준다. */
    private fun create(type: String, title: String, content: String, displayOrder: Int? = null): Long {
        val order = displayOrder?.let { ""","displayOrder":$it""" }.orEmpty()
        val response = mvc.post("/api/v1/admin/support/articles") {
            auth(tokenOf(MemberRole.ROLE_ADMIN))
            json("""{"type":"$type","title":"$title","content":"$content"$order}""")
        }.andExpect {
            status { isOk() }
        }.andReturn().response.contentAsString
        return objectMapper.readTree(response).path("data").path("id").asLong()
    }

    private fun uniqueTitle(prefix: String) = "$prefix ${UUID.randomUUID().toString().take(8)}"

    private fun MockHttpServletRequestDsl.auth(bearerToken: String) {
        header(HttpHeaders.AUTHORIZATION, bearerToken)
    }

    private fun MockHttpServletRequestDsl.json(body: String) {
        contentType = MediaType.APPLICATION_JSON
        content = body
    }

    companion object {
        private const val MISSING_ID = 999_999_999L
    }
}
