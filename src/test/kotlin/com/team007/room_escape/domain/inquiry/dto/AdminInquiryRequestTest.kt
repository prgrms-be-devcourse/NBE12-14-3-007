package com.team007.room_escape.domain.inquiry.dto

import jakarta.validation.Validation
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test

class AdminInquiryRequestTest {

    private val validator = Validation.buildDefaultValidatorFactory().validator

    private fun search(title: String?, includeDeleted: Boolean? = null) =
        AdminInquiryRequest.Search(title, null, null, includeDeleted)

    @Test
    fun `검색어는 앞뒤 공백을 지우고 소문자로 바꾼다`() {
        assertThat(search("  취소 Request  ").titleOrEmpty()).isEqualTo("취소 request")
    }

    @Test
    fun `검색어가 없거나 공백뿐이면 빈 문자열이다`() {
        assertThat(search(null).titleOrEmpty()).isEmpty()
        assertThat(search("").titleOrEmpty()).isEmpty()
        assertThat(search(" \n\t").titleOrEmpty()).isEmpty()
    }

    @Test
    fun `검색어 앞뒤는 U+0020 이하만 자르고 NBSP는 남긴다`() {
        assertThat(search(" a").titleOrEmpty()).isEqualTo(" a")
    }

    @Test
    fun `삭제 포함 여부는 true일 때만 켜진다`() {
        assertThat(search(null, true).includeDeletedOrFalse()).isTrue()
        assertThat(search(null, false).includeDeletedOrFalse()).isFalse()
        assertThat(search(null, null).includeDeletedOrFalse()).isFalse()
    }

    @Test
    fun `답변은 앞뒤 공백을 지운다`() {
        assertThat(AdminInquiryRequest.Answer("  확인했습니다  \n").trimmed()).isEqualTo("확인했습니다")
    }

    @Test
    fun `답변은 비어 있을 수 없고 2000자까지다`() {
        fun violations(answer: String?) =
            validator.validate(AdminInquiryRequest.Answer(answer)).map { it.messageTemplate }

        assertThat(violations("확인")).isEmpty()
        assertThat(violations("가".repeat(2000))).isEmpty()
        assertThat(violations("가".repeat(2001))).containsExactly("{jakarta.validation.constraints.Size.message}")
        assertThat(violations("   ")).containsExactly("{jakarta.validation.constraints.NotBlank.message}")
        assertThat(violations(null)).containsExactly("{jakarta.validation.constraints.NotBlank.message}")
    }
}
