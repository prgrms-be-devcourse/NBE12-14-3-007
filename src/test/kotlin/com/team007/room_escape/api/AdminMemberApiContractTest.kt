package com.team007.room_escape.api

import com.team007.room_escape.domain.member.infra.entity.MemberRole
import org.junit.jupiter.api.Test
import org.springframework.http.HttpHeaders
import org.springframework.http.MediaType
import org.springframework.test.web.servlet.MockHttpServletRequestDsl
import org.springframework.test.web.servlet.get
import org.springframework.test.web.servlet.patch

/** GET /admin/members, GET /admin/members/{id}, PATCH /admin/members/{id}/role */
class AdminMemberApiContractTest : ApiContractSupport() {

    @Test
    fun 관리자는_회원_목록을_조회한다() {
        mvc.get("/api/v1/admin/members") { auth(tokenOf(MemberRole.ROLE_ADMIN)) }.andExpect {
            status { isOk() }
            jsonPath("$.success") { value(true) }
            jsonPath("$.data.content") { isArray() }
        }
    }

    @Test
    fun 일반_회원은_회원_목록을_조회할_수_없다() {
        mvc.get("/api/v1/admin/members") { auth(tokenOf(MemberRole.ROLE_UNVERIFIED)) }.andExpect {
            status { isForbidden() }
        }
    }

    @Test
    fun 미인증_사용자는_회원_목록을_조회할_수_없다() {
        mvc.get("/api/v1/admin/members").andExpect {
            status { isUnauthorized() }
        }
    }

    @Test
    fun 관리자는_회원_단건을_조회한다() {
        val target = saveMember(MemberRole.ROLE_UNVERIFIED)

        mvc.get("/api/v1/admin/members/${target.id}") { auth(tokenOf(MemberRole.ROLE_ADMIN)) }.andExpect {
            status { isOk() }
            jsonPath("$.data.id") { value(target.id.toString()) }
            jsonPath("$.data.email") { value(target.email) }
        }
    }

    @Test
    fun 일반_회원은_회원_단건을_조회할_수_없다() {
        val target = saveMember(MemberRole.ROLE_UNVERIFIED)

        mvc.get("/api/v1/admin/members/${target.id}") { auth(tokenOf(MemberRole.ROLE_UNVERIFIED)) }.andExpect {
            status { isForbidden() }
        }
    }

    @Test
    fun 관리자는_회원_등급을_변경한다() {
        val target = saveMember(MemberRole.ROLE_UNVERIFIED)

        mvc.patch("/api/v1/admin/members/${target.id}/role") {
            auth(tokenOf(MemberRole.ROLE_ADMIN))
            json("""{"role":"ROLE_TRUSTED"}""")
        }.andExpect {
            status { isOk() }
            jsonPath("$.data.role") { value("ROLE_TRUSTED") }
        }
    }

    @Test
    fun 일반_회원은_등급을_변경할_수_없다() {
        val target = saveMember(MemberRole.ROLE_UNVERIFIED)

        mvc.patch("/api/v1/admin/members/${target.id}/role") {
            auth(tokenOf(MemberRole.ROLE_UNVERIFIED))
            json("""{"role":"ROLE_TRUSTED"}""")
        }.andExpect {
            status { isForbidden() }
        }
    }

    /** 관리자 권한은 화면에서 주지 않는다. DB에서 직접 바꾸는 정책이다. */
    @Test
    fun 관리자_권한은_API로_부여할_수_없다() {
        val target = saveMember(MemberRole.ROLE_UNVERIFIED)

        mvc.patch("/api/v1/admin/members/${target.id}/role") {
            auth(tokenOf(MemberRole.ROLE_ADMIN))
            json("""{"role":"ROLE_ADMIN"}""")
        }.andExpect {
            status { isForbidden() }
            jsonPath("$.code") { value("MEMBER005") }
        }
    }

    private fun MockHttpServletRequestDsl.auth(bearerToken: String) {
        header(HttpHeaders.AUTHORIZATION, bearerToken)
    }

    private fun MockHttpServletRequestDsl.json(body: String) {
        contentType = MediaType.APPLICATION_JSON
        content = body
    }
}
