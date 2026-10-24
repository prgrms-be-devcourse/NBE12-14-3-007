package com.team007.room_escape.v2.global.validation

import com.team007.room_escape.global.validation.ValidPassword
import jakarta.validation.Validation
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test
import org.junit.jupiter.params.ParameterizedTest
import org.junit.jupiter.params.provider.ValueSource

class ValidPasswordTest {

    private val validator = Validation.buildDefaultValidatorFactory().validator

    private class Form(@field:ValidPassword val password: String?)

    private fun violationsOf(password: String?) = validator.validate(Form(password)).map { it.message }

    @ParameterizedTest(name = "[{index}] {0}")
    @ValueSource(
        strings = [
            "Abcdef1!",                // 최소 길이 8자
            "Abcdefghijklmnopqrst1!@#", // 24자
            "password1!",
            "한글도많이Ok1!",           // 한글이 섞여도 글자 수로 센다 (9자)
            "A1!A1!A1!",
            "Zz9%^&*()",
        ]
    )
    fun `영문 숫자 특수문자를 모두 포함한 8~25자는 통과한다`(password: String) {
        assertThat(violationsOf(password)).isEmpty()
    }

    @Test
    fun `정확히 25자는 통과하고 26자는 길이 오류다`() {
        val twentyFive = "Abcdefghijklmnopqrstuv1!@" // 25자
        val twentySix = twentyFive + "a"

        assertThat(twentyFive).hasSize(25)
        assertThat(violationsOf(twentyFive)).isEmpty()
        assertThat(violationsOf(twentySix)).containsExactly("비밀번호는 8~25자여야 합니다.")
    }

    @Test
    fun `7자는 길이 오류다`() {
        assertThat(violationsOf("Abcde1!")).containsExactly("비밀번호는 8~25자여야 합니다.")
    }

    @ParameterizedTest(name = "[{index}] {0}")
    @ValueSource(
        strings = [
            "12345678!",   // 영문 없음
            "Abcdefgh!",   // 숫자 없음
            "Abcdefg12",   // 특수문자 없음
            "Abcdef1?",    // ? 는 허용된 특수문자가 아니다 (!@#%^&* 만 허용)
            "Abcdef1$",    // $ 도 아니다
        ]
    )
    fun `영문 숫자 특수문자 중 하나라도 빠지면 형식 오류다`(password: String) {
        assertThat(violationsOf(password)).containsExactly("비밀번호는 영문, 숫자, 특수문자를 모두 포함해야 합니다.")
    }

    @Test
    fun `null은 다른 검증이 판단하도록 통과시킨다`() {
        assertThat(violationsOf(null)).isEmpty()
    }

    @Test
    fun `길이와 형식이 모두 틀리면 두 오류가 함께 나온다`() {
        assertThat(violationsOf("abc")).containsExactlyInAnyOrder(
            "비밀번호는 8~25자여야 합니다.",
            "비밀번호는 영문, 숫자, 특수문자를 모두 포함해야 합니다.",
        )
    }
}
