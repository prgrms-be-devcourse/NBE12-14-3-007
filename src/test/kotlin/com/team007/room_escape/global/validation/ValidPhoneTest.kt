package com.team007.room_escape.global.validation

import jakarta.validation.Validation
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test
import org.junit.jupiter.params.ParameterizedTest
import org.junit.jupiter.params.provider.ValueSource

class ValidPhoneTest {

    private val validator = Validation.buildDefaultValidatorFactory().validator

    private class Form(@field:ValidPhone val phone: String?)

    private fun violationsOf(phone: String?) = validator.validate(Form(phone)).map { it.message }

    @ParameterizedTest(name = "[{index}] {0}")
    @ValueSource(
        strings = [
            "01012345678", // 010 + 8자리
            "0101234567",  // 010 + 7자리
            "01112345678",
            "01612345678",
            "01712345678",
            "01812345678",
            "01912345678",
        ]
    )
    fun `01로 시작하고 하이픈 없이 숫자만 10~11자리면 통과한다`(phone: String) {
        assertThat(violationsOf(phone)).isEmpty()
    }

    @Test
    fun `빈 문자열은 번호 지우기라서 통과한다`() {
        assertThat(violationsOf("")).isEmpty()
    }

    @Test
    fun `null은 다른 검증이 판단하도록 통과시킨다`() {
        assertThat(violationsOf(null)).isEmpty()
    }

    @ParameterizedTest(name = "[{index}] {0}")
    @ValueSource(
        strings = [
            "010-1234-5678", // 하이픈
            "01212345678",   // 012 는 없는 식별번호
            "010123456",     // 9자리
            "010123456789",  // 12자리
            "02012345678",   // 01 로 시작하지 않음
            "010 1234 5678", // 공백
            "0101234567a",   // 숫자가 아닌 문자
        ]
    )
    fun `형식이 맞지 않으면 숫자만 입력하라는 오류다`(phone: String) {
        assertThat(violationsOf(phone)).containsExactly("휴대폰 번호는 하이픈 없이 숫자만 입력해 주세요.")
    }
}
