package com.team007.room_escape.domain.inquiry.dto

import com.team007.room_escape.domain.inquiry.infra.entity.InquiryCategory
import com.team007.room_escape.domain.inquiry.infra.entity.InquiryTargetType
import jakarta.validation.Validation
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test
import org.junit.jupiter.params.ParameterizedTest
import org.junit.jupiter.params.provider.CsvSource

class InquiryRequestTest {

    private val validator = Validation.buildDefaultValidatorFactory().validator

    private fun create(
        category: InquiryCategory? = InquiryCategory.QUESTION,
        targetType: InquiryTargetType? = null,
        targetId: String? = null,
        title: String? = "제목",
        content: String? = "내용",
        img: String? = null,
    ) = InquiryRequest.Create(category, targetType, targetId, title, content, img)

    // 기본 메시지는 실행 환경의 언어를 따라가서, 언어와 상관없는 메시지 템플릿으로 비교한다.
    private fun violationsOf(target: Any): Set<String> =
        validator.validate(target).map { "${it.propertyPath}: ${it.messageTemplate}" }.toSet()

    @Test
    fun `올바른 문의 등록 요청은 위반이 없다`() {
        assertThat(violationsOf(create())).isEmpty()
        assertThat(violationsOf(create(InquiryCategory.REPORT, InquiryTargetType.POST, "id", img = "inquiries/a.png"))).isEmpty()
    }

    @Test
    fun `종류가 없으면 거절한다`() {
        assertThat(violationsOf(create(category = null))).containsExactly("category: {jakarta.validation.constraints.NotNull.message}")
    }

    @Test
    fun `제목과 내용이 공백이면 거절한다`() {
        assertThat(violationsOf(create(title = "  ", content = "")))
            .containsExactlyInAnyOrder(
                "title: {jakarta.validation.constraints.NotBlank.message}",
                "content: {jakarta.validation.constraints.NotBlank.message}",
            )
    }

    @Test
    fun `제목은 255자 첨부 key는 2048자 대상 ID는 255자까지다`() {
        assertThat(violationsOf(create(title = "가".repeat(255)))).isEmpty()
        assertThat(violationsOf(create(title = "가".repeat(256)))).containsExactly("title: {jakarta.validation.constraints.Size.message}")
        assertThat(violationsOf(create(img = "a".repeat(2049)))).containsExactly("img: {jakarta.validation.constraints.Size.message}")
        assertThat(violationsOf(create(category = InquiryCategory.REPORT, targetType = InquiryTargetType.POST, targetId = "1".repeat(256))))
            .containsExactly("targetId: {jakarta.validation.constraints.Size.message}")
    }

    /** 일반 문의(QUESTION)는 대상이 없어야 하고, 신고·제보는 대상 종류와 ID를 함께 주거나 아예 안 줘야 한다 */
    @ParameterizedTest(name = "{0}, 종류={1}, ID={2} -> 유효 {3}")
    @CsvSource(
        "QUESTION,,,true",
        "QUESTION,POST,abc,false",
        "QUESTION,POST,,false",
        "QUESTION,,abc,false",
        "REPORT,,,true",
        "REPORT,POST,abc,true",
        "REPORT,POST,,false",
        "REPORT,,abc,false",
        "TIP,FESTIVAL,12,true",
        "TIP,FESTIVAL,'   ',false",
    )
    fun `대상 종류와 ID는 함께 입력해야 한다`(category: InquiryCategory, type: InquiryTargetType?, id: String?, valid: Boolean) {
        assertThat(create(category = category, targetType = type, targetId = id).isTargetValid()).isEqualTo(valid)
    }

    @Test
    fun `대상 규칙을 어기면 검증에서 거절한다`() {
        val violations = validator.validate(create(category = InquiryCategory.REPORT, targetType = InquiryTargetType.POST))

        assertThat(violations.map { it.message }).containsExactly("신고·제보 대상 종류와 대상 ID는 함께 입력해야 합니다.")
    }

    @Test
    fun `수정 요청은 모두 선택이고 길이만 제한한다`() {
        assertThat(violationsOf(InquiryRequest.Update(null, null, null, null))).isEmpty()
        assertThat(violationsOf(InquiryRequest.Update(null, "가".repeat(256), null, "a".repeat(2049))))
            .containsExactlyInAnyOrder(
                "title: {jakarta.validation.constraints.Size.message}",
                "img: {jakarta.validation.constraints.Size.message}",
            )
    }
}
