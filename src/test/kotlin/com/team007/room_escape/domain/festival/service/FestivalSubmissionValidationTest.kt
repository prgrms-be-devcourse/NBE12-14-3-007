package com.team007.room_escape.domain.festival.service

import com.team007.room_escape.domain.festival.dto.FestivalSubmissionRequest
import com.team007.room_escape.domain.festival.dto.SubmissionReferenceUrl
import com.team007.room_escape.domain.festival.infra.entity.FestivalRegion
import com.team007.room_escape.domain.festival.infra.repository.FestivalRepository
import com.team007.room_escape.global.exception.BusinessException
import jakarta.validation.Validation
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.assertThrows
import org.junit.jupiter.params.ParameterizedTest
import org.junit.jupiter.params.provider.ValueSource
import org.mockito.Mockito.mock
import java.time.LocalDateTime

class FestivalSubmissionValidationTest {
    private fun request() = FestivalSubmissionRequest.Upsert(
        title = "행사", category = "축제", region = FestivalRegion.SEOUL, district = "강남구",
        referenceUrl = "https://example.com/event", beginDe = LocalDateTime.of(2026, 11, 1, 10, 0),
        endDe = LocalDateTime.of(2026, 11, 2, 18, 0)
    )

    @ParameterizedTest
    @ValueSource(strings = ["///", "https:///", "행사링크", "example.com", "ftp://example.com",
        "javascript:alert(1)", "https://user:password@example.com", "https://example.com/a b", "https://example.com:99999"])
    fun invalidUrlIsRejectedByRequestValidationAndServiceBoundary(url: String) {
        Validation.buildDefaultValidatorFactory().use { factory ->
            assertThat(factory.validator.validate(request().copy(referenceUrl = url)))
                .anySatisfy { assertThat(it.message).isEqualTo(SubmissionReferenceUrl.INVALID_MESSAGE) }
        }
        val validator = FestivalDuplicateValidator(mock(FestivalRepository::class.java))
        assertThrows<BusinessException> { validator.normalizeReferenceUrl(url) }
    }

    @ParameterizedTest
    @ValueSource(strings = ["https://example.com", "http://localhost:8080/event", " https://example.com/event/// ",
        "https://example.com/event?q=test&lang=ko#info"])
    fun validUrlsAreAccepted(url: String) {
        assertThat(SubmissionReferenceUrl.isValid(url)).isTrue()
    }

    @Test
    fun validatesFieldLengthBoundariesWithoutChangingExpectedLimits() {
        Validation.buildDefaultValidatorFactory().use { factory ->
            val valid = request().copy(title = "가".repeat(255), category = "가".repeat(50), regionDetail = "가".repeat(255))
            assertThat(factory.validator.validate(valid)).isEmpty()
            assertThat(factory.validator.validate(valid.copy(title = "가".repeat(256))))
                .anySatisfy { assertThat(it.message).isEqualTo("행사 이름은 255자 이하여야 합니다.") }
            assertThat(factory.validator.validate(valid.copy(category = "가".repeat(51))))
                .anySatisfy { assertThat(it.propertyPath.toString()).isEqualTo("category") }
            assertThat(factory.validator.validate(valid.copy(regionDetail = "가".repeat(256))))
                .anySatisfy { assertThat(it.propertyPath.toString()).isEqualTo("regionDetail") }
        }
    }

    @Test
    fun normalizesUrlAndKeepsMissingUrlAsRequiredFieldFailure() {
        val validator = FestivalDuplicateValidator(mock(FestivalRepository::class.java))
        assertThat(validator.normalizeReferenceUrl(" https://example.com/event/// ")).isEqualTo("https://example.com/event")
        Validation.buildDefaultValidatorFactory().use { factory ->
            assertThat(factory.validator.validate(request().copy(referenceUrl = " ")))
                .anySatisfy { assertThat(it.message).isEqualTo("행사 참고 링크는 필수입니다.") }
        }
    }
}
