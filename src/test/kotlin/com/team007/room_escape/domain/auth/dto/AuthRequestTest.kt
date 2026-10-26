package com.team007.room_escape.domain.auth.dto

import jakarta.validation.Validation
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test
import org.junit.jupiter.params.ParameterizedTest
import org.junit.jupiter.params.provider.ValueSource

class AuthRequestTest {

    private val validator = Validation.buildDefaultValidatorFactory().validator

    private fun signup(
        email: String? = "user@example.com",
        password: String? = "Password1!",
        nickname: String? = "축제좋아",
        phone: String? = null,
    ) = AuthRequest.Signup(email, password, nickname, phone)

    // 기본 메시지는 실행 환경의 언어를 따라가서, 언어와 상관없는 메시지 템플릿으로 비교한다.
    private val notBlank = "{jakarta.validation.constraints.NotBlank.message}"
    private val wellFormedEmail = "{jakarta.validation.constraints.Email.message}"
    private val sizeBetween = "{jakarta.validation.constraints.Size.message}"

    /** "필드: 메시지 템플릿" 모양으로 모아서 비교한다. 위반 순서는 정해져 있지 않다. */
    private fun violationsOf(target: Any): Set<String> =
        validator.validate(target).map { "${it.propertyPath}: ${it.messageTemplate}" }.toSet()

    @Test
    fun `올바른 가입 요청은 위반이 없다`() {
        assertThat(violationsOf(signup())).isEmpty()
        assertThat(violationsOf(signup(phone = "01012345678"))).isEmpty()
        assertThat(violationsOf(signup(phone = ""))).isEmpty()
    }

    @Test
    fun `필드를 빼먹으면 비어 있을 수 없다고 알린다`() {
        assertThat(violationsOf(AuthRequest.Signup(null, null, null, null))).containsExactlyInAnyOrder(
            "email: $notBlank",
            "password: $notBlank",
            "nickname: $notBlank",
        )
    }

    @Test
    fun `이메일 형식이 아니면 거절한다`() {
        assertThat(violationsOf(signup(email = "not-an-email"))).containsExactly("email: $wellFormedEmail")
    }

    @Test
    fun `비밀번호에 특수문자가 없으면 거절한다`() {
        assertThat(violationsOf(signup(password = "Password12")))
            .containsExactly("password: 비밀번호는 영문, 숫자, 특수문자를 모두 포함해야 합니다.")
    }

    @Test
    fun `비밀번호가 8자 미만이거나 25자 초과면 길이 오류다`() {
        assertThat(violationsOf(signup(password = "Pw1!"))).containsExactly("password: 비밀번호는 8~25자여야 합니다.")
        assertThat(violationsOf(signup(password = "Abcdefghijklmnopqrstuv1!@x")))
            .containsExactly("password: 비밀번호는 8~25자여야 합니다.")
    }

    @ParameterizedTest(name = "닉네임 \"{0}\"")
    @ValueSource(strings = ["a", "가나다라마바사아자차카타파하가나다라마바사아자차카타파하가나다라마"])
    fun `닉네임은 2자 이상 30자 이하여야 한다`(nickname: String) {
        assertThat(violationsOf(signup(nickname = nickname))).containsExactly("nickname: $sizeBetween")
    }

    @ParameterizedTest(name = "전화번호 \"{0}\"")
    @ValueSource(strings = ["010-1234-5678", "0212345678", "0101234", "abc"])
    fun `전화번호는 하이픈 없는 휴대폰 번호만 받는다`(phone: String) {
        assertThat(violationsOf(signup(phone = phone)))
            .containsExactly("phone: 휴대폰 번호는 하이픈 없이 숫자만 입력해 주세요.")
    }

    @Test
    fun `로그인 요청은 이메일 형식과 비밀번호 입력을 확인한다`() {
        assertThat(violationsOf(AuthRequest.Login("user@example.com", "x"))).isEmpty()
        assertThat(violationsOf(AuthRequest.Login("bad", "x"))).containsExactly("email: $wellFormedEmail")
        assertThat(violationsOf(AuthRequest.Login("user@example.com", null))).containsExactly("password: $notBlank")
        assertThat(violationsOf(AuthRequest.Login(null, "x"))).containsExactly("email: $notBlank")
    }
}
