package com.team007.room_escape.api

import com.team007.room_escape.domain.member.infra.entity.Member
import com.team007.room_escape.domain.member.infra.entity.MemberRole
import com.team007.room_escape.global.util.CookieUtil
import jakarta.servlet.http.Cookie
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test
import org.springframework.http.HttpHeaders
import org.springframework.http.MediaType
import org.springframework.test.web.servlet.MockHttpServletRequestDsl
import org.springframework.test.web.servlet.MvcResult
import org.springframework.test.web.servlet.post
import java.util.UUID

/** POST /auth/signup, /auth/login, /auth/refresh, /auth/logout */
class AuthApiContractTest : ApiContractSupport() {

    @Test
    fun 가입하면_201과_빈_본문을_받는다() {
        mvc.post("/api/v1/auth/signup") {
            json(signupBody(uniqueEmail(), "가입테스트${shortToken()}"))
        }.andExpect {
            status { isCreated() }
            jsonPath("$.success") { value(true) }
        }
    }

    @Test
    fun 비밀번호_규칙에_맞지_않으면_거부한다() {
        mvc.post("/api/v1/auth/signup") {
            json("""{"email":"${uniqueEmail()}","password":"short","nickname":"규칙테스트${shortToken()}"}""")
        }.andExpect {
            status { isBadRequest() }
        }
    }

    @Test
    fun 이미_쓰는_이메일로는_가입할_수_없다() {
        val existing = saveMember(MemberRole.ROLE_UNVERIFIED)

        mvc.post("/api/v1/auth/signup") {
            json(signupBody(existing.email, "중복테스트${shortToken()}"))
        }.andExpect {
            status { isConflict() }
            jsonPath("$.code") { value("MEMBER001") }
        }
    }

    /** 탈퇴 회원의 이메일은 보관 기간 동안 재가입을 막는다. 쓰는 중인 이메일과 안내를 구분한다. */
    @Test
    fun 탈퇴한_이메일로는_재가입할_수_없다() {
        val withdrawn = saveMember(MemberRole.ROLE_UNVERIFIED)
        withdrawn.delete()

        mvc.post("/api/v1/auth/signup") {
            json(signupBody(withdrawn.email, "재가입테스트${shortToken()}"))
        }.andExpect {
            status { isConflict() }
            jsonPath("$.code") { value("MEMBER010") }
        }
    }

    @Test
    fun 로그인하면_액세스_토큰과_리프레시_쿠키를_받는다() {
        val email = signedUpEmail()

        mvc.post("/api/v1/auth/login") {
            json(loginBody(email, PASSWORD))
        }.andExpect {
            status { isOk() }
            jsonPath("$.data.accessToken") { isNotEmpty() }
            cookie {
                exists(CookieUtil.REFRESH_TOKEN_COOKIE)
                httpOnly(CookieUtil.REFRESH_TOKEN_COOKIE, true)
            }
        }
    }

    @Test
    fun 비밀번호가_틀리면_로그인할_수_없다() {
        val email = signedUpEmail()

        mvc.post("/api/v1/auth/login") {
            json(loginBody(email, "WrongPass1!"))
        }.andExpect {
            status { isUnauthorized() }
        }
    }

    @Test
    fun 리프레시_쿠키가_없으면_재발급할_수_없다() {
        mvc.post("/api/v1/auth/refresh").andExpect {
            status { isUnauthorized() }
        }
    }

    @Test
    fun 위조된_리프레시_토큰은_거부한다() {
        mvc.post("/api/v1/auth/refresh") {
            cookie(Cookie(CookieUtil.REFRESH_TOKEN_COOKIE, "not-a-token"))
        }.andExpect {
            status { isUnauthorized() }
        }
    }

    @Test
    fun 리프레시하면_새_액세스_토큰을_받는다() {
        val refresh = loginAndGetRefreshCookie(signedUpEmail())

        mvc.post("/api/v1/auth/refresh") { cookie(refresh) }.andExpect {
            status { isOk() }
            jsonPath("$.data.accessToken") { isNotEmpty() }
        }
    }

    /**
     * 등급이 내려간 뒤 재발급하면 낡은 등급이 아니라 현재 등급이 담겨야 한다.
     * 리프레시 토큰에도 role 클레임이 들어 있어, 그 값을 재사용하도록 바뀌면
     * 강등된 회원이 14일간 옛 권한을 유지하게 된다.
     */
    @Test
    fun 등급이_강등되면_재발급_토큰도_낮은_등급이다() {
        val email = signedUpEmail()
        val refresh = loginAndGetRefreshCookie(email)
        demoteToWarning(email)

        val result = mvc.post("/api/v1/auth/refresh") { cookie(refresh) }.andExpect {
            status { isOk() }
        }.andReturn()

        assertRoleClaim(readAccessToken(result), MemberRole.ROLE_WARNING)
    }

    /** 탈퇴하면 리프레시 토큰이 살아 있어도 재발급하지 않는다. */
    @Test
    fun 탈퇴한_회원은_재발급할_수_없다() {
        val email = signedUpEmail()
        val refresh = loginAndGetRefreshCookie(email)
        findByEmail(email).delete()

        mvc.post("/api/v1/auth/refresh") { cookie(refresh) }.andExpect {
            status { isUnauthorized() }
        }
    }

    @Test
    fun 로그아웃하면_리프레시_쿠키가_만료된다() {
        val email = signedUpEmail()
        val refresh = loginAndGetRefreshCookie(email)

        mvc.post("/api/v1/auth/logout") {
            header(HttpHeaders.AUTHORIZATION, bearer(findByEmail(email)))
            cookie(refresh)
        }.andExpect {
            status { isNoContent() }
            cookie { maxAge(CookieUtil.REFRESH_TOKEN_COOKIE, 0) }
        }
    }

    /**
     * 인증 경로(/api/v1/auth 아래 전부)는 permitAll 이고 로그아웃은 쿠키를 지우는 멱등 연산이다.
     * 토큰이 만료된 뒤에도 쿠키를 정리할 수 있어야 해서 인증을 요구하지 않는다.
     */
    @Test
    fun 로그아웃은_인증_없이도_호출된다() {
        mvc.post("/api/v1/auth/logout").andExpect {
            status { isNoContent() }
        }
    }

    private fun uniqueEmail() = "contract-${UUID.randomUUID()}@example.com"

    private fun shortToken() = UUID.randomUUID().toString().substring(0, 8)

    /** 가입 API 를 거쳐 만든다. 비밀번호가 인코딩되어야 로그인까지 확인할 수 있다. */
    private fun signedUpEmail(): String {
        val email = uniqueEmail()
        mvc.post("/api/v1/auth/signup") {
            json(signupBody(email, "로그인테스트${shortToken()}"))
        }.andExpect {
            status { isCreated() }
        }
        return email
    }

    private fun loginAndGetRefreshCookie(email: String): Cookie {
        val result = mvc.post("/api/v1/auth/login") {
            json(loginBody(email, PASSWORD))
        }.andExpect {
            status { isOk() }
        }.andReturn()
        return result.response.getCookie(CookieUtil.REFRESH_TOKEN_COOKIE)
            ?: error("로그인 응답에 리프레시 쿠키가 없다")
    }

    private fun signupBody(email: String, nickname: String) =
        """{"email":"$email","password":"$PASSWORD","nickname":"$nickname"}"""

    private fun loginBody(email: String, password: String) = """{"email":"$email","password":"$password"}"""

    private fun findByEmail(email: String): Member =
        memberRepository.findByEmailAndDeletedAtIsNull(email) ?: error("회원이 없다: $email")

    /** 관리자 API 를 쓰지 않고 DB 상태만 바꿔, 재발급이 DB 를 다시 읽는지 확인한다. */
    private fun demoteToWarning(email: String) {
        findByEmail(email).changeRole(MemberRole.ROLE_WARNING)
        entityManager.flush()
    }

    private fun readAccessToken(result: MvcResult): String =
        objectMapper.readTree(result.response.contentAsString).path("data").path("accessToken").asString()

    private fun assertRoleClaim(accessToken: String, expected: MemberRole) {
        assertThat(jwtProvider.parse(accessToken).get("role", String::class.java)).isEqualTo(expected.name)
    }

    private fun MockHttpServletRequestDsl.json(body: String) {
        contentType = MediaType.APPLICATION_JSON
        content = body
    }

    private companion object {
        const val PASSWORD = "Password1!"
    }
}
