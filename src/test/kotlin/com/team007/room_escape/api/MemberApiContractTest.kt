package com.team007.room_escape.api

import com.team007.room_escape.domain.member.infra.entity.MemberRole
import com.team007.room_escape.global.util.CookieUtil
import org.junit.jupiter.api.Test
import org.springframework.http.HttpHeaders
import org.springframework.http.MediaType
import org.springframework.test.web.servlet.MockHttpServletRequestDsl
import org.springframework.test.web.servlet.delete
import org.springframework.test.web.servlet.get
import org.springframework.test.web.servlet.patch
import org.springframework.test.web.servlet.post
import java.util.UUID

/**
 * 회원 6개 + 내 콘텐츠 2개.
 *
 * 비밀번호 변경은 메일 인증 코드를 거쳐야 해서, 코드 발송까지만 확인하고
 * 인증·변경은 코드 없이 호출했을 때 거부되는지로 계약을 고정한다.
 */
class MemberApiContractTest : ApiContractSupport() {

    @Test
    fun 내_정보를_조회한다() {
        val me = saveMember(MemberRole.ROLE_UNVERIFIED)

        mvc.get("/api/v1/members/me") { auth(bearer(me)) }.andExpect {
            status { isOk() }
            jsonPath("$.data.id") { value(me.id.toString()) }
            jsonPath("$.data.email") { value(me.email) }
            jsonPath("$.data.nickname") { value(me.nickname) }
        }
    }

    @Test
    fun 미인증_사용자는_내_정보를_조회할_수_없다() {
        mvc.get("/api/v1/members/me").andExpect {
            status { isUnauthorized() }
        }
    }

    @Test
    fun 활동_제한_회원도_내_정보는_조회한다() {
        val restricted = saveMember(MemberRole.ROLE_WARNING)

        mvc.get("/api/v1/members/me") { auth(bearer(restricted)) }.andExpect {
            status { isOk() }
        }
    }

    @Test
    fun 닉네임을_수정한다() {
        val me = saveMember(MemberRole.ROLE_UNVERIFIED)
        val nickname = "바꾼닉네임${shortToken()}"

        mvc.patch("/api/v1/members/me") {
            auth(bearer(me))
            json("""{"nickname":"$nickname"}""")
        }.andExpect {
            status { isOk() }
            jsonPath("$.data.nickname") { value(nickname) }
        }
    }

    @Test
    fun 한_글자_닉네임으로는_수정할_수_없다() {
        val me = saveMember(MemberRole.ROLE_UNVERIFIED)

        mvc.patch("/api/v1/members/me") {
            auth(bearer(me))
            json("""{"nickname":"짧"}""")
        }.andExpect {
            status { isBadRequest() }
        }
    }

    @Test
    fun 남이_쓰는_닉네임으로는_수정할_수_없다() {
        val other = saveMember(MemberRole.ROLE_UNVERIFIED)
        val me = saveMember(MemberRole.ROLE_UNVERIFIED)

        mvc.patch("/api/v1/members/me") {
            auth(bearer(me))
            json("""{"nickname":"${other.nickname}"}""")
        }.andExpect {
            status { isConflict() }
            jsonPath("$.code") { value("MEMBER002") }
        }
    }

    @Test
    fun 미인증_사용자는_내_정보를_수정할_수_없다() {
        mvc.patch("/api/v1/members/me") {
            json("""{"nickname":"비로그인"}""")
        }.andExpect {
            status { isUnauthorized() }
        }
    }

    /** 인증 코드 없이 바로 비밀번호를 바꿀 수는 없다. */
    @Test
    fun 메일_인증_없이는_비밀번호를_바꿀_수_없다() {
        val me = saveMember(MemberRole.ROLE_UNVERIFIED)

        mvc.patch("/api/v1/members/me/password") {
            auth(bearer(me))
            json("""{"newPassword":"NewPass1!"}""")
        }.andExpect {
            status { is4xxClientError() }
        }
    }

    @Test
    fun 틀린_인증_코드는_거부한다() {
        val me = saveMember(MemberRole.ROLE_UNVERIFIED)

        mvc.post("/api/v1/members/me/password/verify") {
            auth(bearer(me))
            json("""{"code":"000000"}""")
        }.andExpect {
            status { is4xxClientError() }
        }
    }

    @Test
    fun 미인증_사용자는_인증_코드를_받을_수_없다() {
        mvc.post("/api/v1/members/me/password/verification-code").andExpect {
            status { isUnauthorized() }
        }
    }

    @Test
    fun 비밀번호가_틀리면_탈퇴할_수_없다() {
        val me = saveMember(MemberRole.ROLE_UNVERIFIED)

        mvc.delete("/api/v1/members/me") {
            auth(bearer(me))
            json("""{"password":"WrongPass1!"}""")
        }.andExpect {
            status { is4xxClientError() }
        }
    }

    @Test
    fun 빈_비밀번호로는_탈퇴할_수_없다() {
        val me = saveMember(MemberRole.ROLE_UNVERIFIED)

        mvc.delete("/api/v1/members/me") {
            auth(bearer(me))
            json("""{"password":""}""")
        }.andExpect {
            status { isBadRequest() }
        }
    }

    /** 탈퇴하면 소프트 삭제되고 브라우저의 리프레시 쿠키도 지운다. */
    @Test
    fun 탈퇴하면_내_정보_조회가_막히고_쿠키가_만료된다() {
        val email = signedUpEmail()
        val me = memberRepository.findByEmailAndDeletedAtIsNull(email) ?: error("가입한 회원이 없다: $email")
        val token = bearer(me)

        mvc.delete("/api/v1/members/me") {
            auth(token)
            json("""{"password":"$SIGNUP_PASSWORD"}""")
        }.andExpect {
            status { isOk() }
            cookie { maxAge(CookieUtil.REFRESH_TOKEN_COOKIE, 0) }
        }

        // 토큰은 아직 유효하지만 회원이 탈퇴 상태라 조회가 막힌다.
        mvc.get("/api/v1/members/me") { auth(token) }.andExpect {
            status { is4xxClientError() }
        }
    }

    @Test
    fun 미인증_사용자는_탈퇴할_수_없다() {
        mvc.delete("/api/v1/members/me") {
            json("""{"password":"Password1!"}""")
        }.andExpect {
            status { isUnauthorized() }
        }
    }

    @Test
    fun 내가_쓴_후기_목록을_조회한다() {
        val me = saveMember(MemberRole.ROLE_UNVERIFIED)

        mvc.get("/api/v1/members/me/posts") { auth(bearer(me)) }.andExpect {
            status { isOk() }
            jsonPath("$.data.content") { isArray() }
        }
    }

    @Test
    fun 내가_쓴_댓글_목록을_조회한다() {
        val me = saveMember(MemberRole.ROLE_UNVERIFIED)

        mvc.get("/api/v1/members/me/comments") { auth(bearer(me)) }.andExpect {
            status { isOk() }
            jsonPath("$.data.content") { isArray() }
        }
    }

    @Test
    fun 미인증_사용자는_내_콘텐츠를_조회할_수_없다() {
        mvc.get("/api/v1/members/me/posts").andExpect { status { isUnauthorized() } }
        mvc.get("/api/v1/members/me/comments").andExpect { status { isUnauthorized() } }
    }

    /** 가입 API 로 만들어야 비밀번호가 인코딩되어 탈퇴까지 확인할 수 있다. */
    private fun signedUpEmail(): String {
        val email = "contract-${UUID.randomUUID()}@example.com"
        mvc.post("/api/v1/auth/signup") {
            json("""{"email":"$email","password":"$SIGNUP_PASSWORD","nickname":"탈퇴테스트${shortToken()}"}""")
        }.andExpect {
            status { isCreated() }
        }
        return email
    }

    private fun shortToken() = UUID.randomUUID().toString().substring(0, 8)

    private fun MockHttpServletRequestDsl.auth(bearerToken: String) {
        header(HttpHeaders.AUTHORIZATION, bearerToken)
    }

    private fun MockHttpServletRequestDsl.json(body: String) {
        contentType = MediaType.APPLICATION_JSON
        content = body
    }

    private companion object {
        const val SIGNUP_PASSWORD = "Password1!"
    }
}
