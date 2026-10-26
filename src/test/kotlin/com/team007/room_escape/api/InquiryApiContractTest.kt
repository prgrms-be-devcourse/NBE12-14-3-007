package com.team007.room_escape.api

import com.team007.room_escape.domain.member.infra.entity.Member
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

/** 문의 5개: 작성, 내 목록, 내 상세, 수정, 삭제 */
class InquiryApiContractTest : ApiContractSupport() {

    @Test
    fun 회원은_문의를_등록한다() {
        val me = saveMember(MemberRole.ROLE_UNVERIFIED)

        mvc.post("/api/v1/inquiries") {
            auth(bearer(me))
            json(createBody("문의 제목", "문의 내용"))
        }.andExpect {
            status { isCreated() }
            jsonPath("$.data.id") { isNotEmpty() }
            jsonPath("$.data.title") { value("문의 제목") }
        }
    }

    @Test
    fun 제목이_없으면_문의를_등록할_수_없다() {
        val me = saveMember(MemberRole.ROLE_UNVERIFIED)

        mvc.post("/api/v1/inquiries") {
            auth(bearer(me))
            json(createBody("   ", "문의 내용"))
        }.andExpect {
            status { isBadRequest() }
        }
    }

    @Test
    fun 없는_대상_종류를_주면_거부한다() {
        val me = saveMember(MemberRole.ROLE_UNVERIFIED)

        mvc.post("/api/v1/inquiries") {
            auth(bearer(me))
            json("""{"category":"QUESTION","targetType":"NOPE","title":"제목","content":"내용"}""")
        }.andExpect {
            status { isBadRequest() }
        }
    }

    @Test
    fun 미인증_사용자는_문의를_등록할_수_없다() {
        mvc.post("/api/v1/inquiries") {
            json(createBody("비로그인 문의", "내용"))
        }.andExpect {
            status { isUnauthorized() }
        }
    }

    @Test
    fun 활동_제한_회원도_문의는_등록한다() {
        val restricted = saveMember(MemberRole.ROLE_WARNING)

        mvc.post("/api/v1/inquiries") {
            auth(bearer(restricted))
            json(createBody("제한 회원 문의", "내용"))
        }.andExpect {
            status { isCreated() }
        }
    }

    @Test
    fun 내가_쓴_문의_목록을_조회한다() {
        val me = saveMember(MemberRole.ROLE_UNVERIFIED)
        createInquiry(me)

        mvc.get("/api/v1/inquiries/me") { auth(bearer(me)) }.andExpect {
            status { isOk() }
            jsonPath("$.data") { isArray() }
            jsonPath("$.data[0].id") { isNotEmpty() }
        }
    }

    @Test
    fun 미인증_사용자는_내_문의_목록을_조회할_수_없다() {
        mvc.get("/api/v1/inquiries/me").andExpect {
            status { isUnauthorized() }
        }
    }

    @Test
    fun 내_문의_상세를_조회한다() {
        val me = saveMember(MemberRole.ROLE_UNVERIFIED)
        val inquiryId = createInquiry(me)

        mvc.get("/api/v1/inquiries/$inquiryId") { auth(bearer(me)) }.andExpect {
            status { isOk() }
            jsonPath("$.data.id") { value(inquiryId.toString()) }
        }
    }

    /** 남의 문의는 존재 여부도 알려주지 않는다. */
    @Test
    fun 남의_문의는_404로_가린다() {
        val inquiryId = createInquiry(saveMember(MemberRole.ROLE_UNVERIFIED))

        mvc.get("/api/v1/inquiries/$inquiryId") { auth(bearer(saveMember(MemberRole.ROLE_UNVERIFIED))) }.andExpect {
            status { isNotFound() }
        }
    }

    @Test
    fun 없는_문의를_조회하면_404다() {
        mvc.get("/api/v1/inquiries/${UUID.randomUUID()}") { auth(bearer(saveMember(MemberRole.ROLE_UNVERIFIED))) }.andExpect {
            status { isNotFound() }
        }
    }

    @Test
    fun 작성자는_문의를_수정한다() {
        val me = saveMember(MemberRole.ROLE_UNVERIFIED)
        val inquiryId = createInquiry(me)

        mvc.patch("/api/v1/inquiries/$inquiryId") {
            auth(bearer(me))
            json("""{"title":"수정된 제목"}""")
        }.andExpect {
            status { isOk() }
            jsonPath("$.data.title") { value("수정된 제목") }
        }
    }

    @Test
    fun 남의_문의는_수정할_수_없다() {
        val inquiryId = createInquiry(saveMember(MemberRole.ROLE_UNVERIFIED))

        mvc.patch("/api/v1/inquiries/$inquiryId") {
            auth(bearer(saveMember(MemberRole.ROLE_UNVERIFIED)))
            json("""{"title":"남의 문의 수정"}""")
        }.andExpect {
            status { is4xxClientError() }
        }
    }

    @Test
    fun 작성자는_문의를_삭제한다() {
        val me = saveMember(MemberRole.ROLE_UNVERIFIED)
        val inquiryId = createInquiry(me)

        mvc.delete("/api/v1/inquiries/$inquiryId") { auth(bearer(me)) }.andExpect {
            status { isOk() }
        }
        mvc.get("/api/v1/inquiries/$inquiryId") { auth(bearer(me)) }.andExpect {
            status { isNotFound() }
        }
    }

    @Test
    fun 관리자는_남의_문의도_삭제한다() {
        val inquiryId = createInquiry(saveMember(MemberRole.ROLE_UNVERIFIED))

        mvc.delete("/api/v1/inquiries/$inquiryId") { auth(tokenOf(MemberRole.ROLE_ADMIN)) }.andExpect {
            status { isOk() }
        }
    }

    @Test
    fun 남의_문의는_삭제할_수_없다() {
        val inquiryId = createInquiry(saveMember(MemberRole.ROLE_UNVERIFIED))

        mvc.delete("/api/v1/inquiries/$inquiryId") { auth(bearer(saveMember(MemberRole.ROLE_UNVERIFIED))) }.andExpect {
            status { is4xxClientError() }
        }
    }

    private fun createInquiry(author: Member): UUID {
        val result = mvc.post("/api/v1/inquiries") {
            auth(bearer(author))
            json(createBody("계약테스트 문의 ${shortToken()}", "내용"))
        }.andExpect {
            status { isCreated() }
        }.andReturn()

        return UUID.fromString(
            objectMapper.readTree(result.response.contentAsString).path("data").path("id").asString()
        )
    }

    private fun createBody(title: String, content: String) =
        """{"category":"QUESTION","title":"$title","content":"$content"}"""

    private fun shortToken() = UUID.randomUUID().toString().substring(0, 8)

    private fun MockHttpServletRequestDsl.auth(bearerToken: String) {
        header(HttpHeaders.AUTHORIZATION, bearerToken)
    }

    private fun MockHttpServletRequestDsl.json(body: String) {
        contentType = MediaType.APPLICATION_JSON
        content = body
    }
}
