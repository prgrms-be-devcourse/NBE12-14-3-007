package com.team007.room_escape.global.security

import com.team007.room_escape.api.ApiContractSupport
import com.team007.room_escape.domain.member.infra.entity.MemberRole
import org.junit.jupiter.api.Test
import org.springframework.http.HttpHeaders
import org.springframework.http.MediaType
import org.springframework.test.web.servlet.MockHttpServletRequestDsl
import org.springframework.test.web.servlet.get
import org.springframework.test.web.servlet.post

/** SecurityConfig의 URL별 접근 규칙을 실제 필터 체인으로 확인한다. */
class SecurityRulesApiTest : ApiContractSupport() {

    private fun MockHttpServletRequestDsl.auth(role: MemberRole) {
        header(HttpHeaders.AUTHORIZATION, tokenOf(role))
    }

    @Test
    fun `관리자 API는 관리자만 쓸 수 있다`() {
        mvc.get("/api/v1/admin/inquiries") { auth(MemberRole.ROLE_TRUSTED) }.andExpect { status { isForbidden() } }
        mvc.get("/api/v1/admin/inquiries") { auth(MemberRole.ROLE_ADMIN) }.andExpect { status { isOk() } }
    }

    @Test
    fun `관리자 API에 토큰이 없으면 401이다`() {
        mvc.get("/api/v1/admin/inquiries").andExpect { status { isUnauthorized() } }
    }

    @Test
    fun `이미지 업로드는 로그인한 정상 회원만 접근할 수 있다`() {
        // 파일 없이 보내므로 접근이 허용된 쪽은 400이다.
        mvc.post("/api/v1/images").andExpect { status { isUnauthorized() } }
        mvc.post("/api/v1/images") { auth(MemberRole.ROLE_WARNING) }.andExpect { status { isForbidden() } }
        mvc.post("/api/v1/images") {
            auth(MemberRole.ROLE_UNVERIFIED)
            contentType = MediaType.MULTIPART_FORM_DATA
        }.andExpect { status { isBadRequest() } }
    }

    @Test
    fun `행사 후기 날씨 조회는 비로그인도 열려 있다`() {
        mvc.get("/api/v1/festivals").andExpect { status { isOk() } }
        mvc.get("/api/v1/posts").andExpect { status { isOk() } }
    }

    @Test
    fun `공개 경로가 아닌 곳은 토큰이 없으면 401이다`() {
        mvc.get("/api/v1/inquiries/me").andExpect { status { isUnauthorized() } }
    }
}
