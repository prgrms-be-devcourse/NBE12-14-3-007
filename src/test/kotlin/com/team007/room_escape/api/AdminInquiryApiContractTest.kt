package com.team007.room_escape.api

import com.team007.room_escape.domain.inquiry.infra.entity.Inquiry
import com.team007.room_escape.domain.inquiry.infra.entity.InquiryCategory
import com.team007.room_escape.domain.inquiry.infra.repository.InquiryRepository
import com.team007.room_escape.domain.member.infra.entity.MemberRole
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.http.HttpHeaders
import org.springframework.http.MediaType
import org.springframework.test.web.servlet.MockHttpServletRequestDsl
import org.springframework.test.web.servlet.get
import org.springframework.test.web.servlet.patch
import java.util.UUID

/** GET /admin/inquiries, GET /admin/inquiries/{id}, PATCH /admin/inquiries/{id}/answer */
class AdminInquiryApiContractTest : ApiContractSupport() {

    @Autowired
    private lateinit var inquiryRepository: InquiryRepository

    @Test
    fun 관리자는_문의_목록을_조회한다() {
        mvc.get("/api/v1/admin/inquiries") { auth(tokenOf(MemberRole.ROLE_ADMIN)) }.andExpect {
            status { isOk() }
            jsonPath("$.success") { value(true) }
            jsonPath("$.data.content") { isArray() }
        }
    }

    @Test
    fun 일반_회원은_문의_목록을_조회할_수_없다() {
        mvc.get("/api/v1/admin/inquiries") { auth(tokenOf(MemberRole.ROLE_UNVERIFIED)) }.andExpect {
            status { isForbidden() }
        }
    }

    @Test
    fun 미인증_사용자는_문의_목록을_조회할_수_없다() {
        mvc.get("/api/v1/admin/inquiries").andExpect {
            status { isUnauthorized() }
        }
    }

    @Test
    fun 관리자는_문의_상세를_조회한다() {
        val inquiry = saveInquiry()

        mvc.get("/api/v1/admin/inquiries/${inquiry.id}") { auth(tokenOf(MemberRole.ROLE_ADMIN)) }.andExpect {
            status { isOk() }
            jsonPath("$.data.id") { value(inquiry.id.toString()) }
            jsonPath("$.data.title") { value(inquiry.title) }
        }
    }

    @Test
    fun 없는_문의를_조회하면_404다() {
        mvc.get("/api/v1/admin/inquiries/${UUID.randomUUID()}") { auth(tokenOf(MemberRole.ROLE_ADMIN)) }.andExpect {
            status { isNotFound() }
        }
    }

    @Test
    fun 일반_회원은_문의_상세를_조회할_수_없다() {
        val inquiry = saveInquiry()

        mvc.get("/api/v1/admin/inquiries/${inquiry.id}") { auth(tokenOf(MemberRole.ROLE_UNVERIFIED)) }.andExpect {
            status { isForbidden() }
        }
    }

    @Test
    fun 관리자는_문의에_답변한다() {
        val inquiry = saveInquiry()

        mvc.patch("/api/v1/admin/inquiries/${inquiry.id}/answer") {
            auth(tokenOf(MemberRole.ROLE_ADMIN))
            json("""{"answer":"확인 후 처리했습니다."}""")
        }.andExpect {
            status { isOk() }
            jsonPath("$.data.answer") { value("확인 후 처리했습니다.") }
        }
    }

    @Test
    fun 빈_답변은_거부한다() {
        val inquiry = saveInquiry()

        mvc.patch("/api/v1/admin/inquiries/${inquiry.id}/answer") {
            auth(tokenOf(MemberRole.ROLE_ADMIN))
            json("""{"answer":"   "}""")
        }.andExpect {
            status { isBadRequest() }
        }
    }

    @Test
    fun 일반_회원은_문의에_답변할_수_없다() {
        val inquiry = saveInquiry()

        mvc.patch("/api/v1/admin/inquiries/${inquiry.id}/answer") {
            auth(tokenOf(MemberRole.ROLE_UNVERIFIED))
            json("""{"answer":"처리했습니다."}""")
        }.andExpect {
            status { isForbidden() }
        }
    }

    private fun saveInquiry(): Inquiry = inquiryRepository.saveAndFlush(
        Inquiry(
            member = saveMember(MemberRole.ROLE_UNVERIFIED),
            category = InquiryCategory.QUESTION,
            title = "계약테스트 문의 ${UUID.randomUUID().toString().substring(0, 8)}",
            content = "문의 내용",
        )
    )

    private fun MockHttpServletRequestDsl.auth(bearerToken: String) {
        header(HttpHeaders.AUTHORIZATION, bearerToken)
    }

    private fun MockHttpServletRequestDsl.json(body: String) {
        contentType = MediaType.APPLICATION_JSON
        content = body
    }
}
