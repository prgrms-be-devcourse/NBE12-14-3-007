package com.team007.room_escape.domain.festival.service

import com.team007.room_escape.domain.festival.infra.entity.FestivalRegion
import com.team007.room_escape.global.exception.BusinessException
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.assertThrows

class SubmissionRegionsTest {
    @Test
    fun requiresDistrictBelongingToProvince() {
        assertThat(SubmissionRegions.validate(FestivalRegion.SEOUL, "강남구")).isEqualTo("강남구")
        assertThrows<BusinessException> { SubmissionRegions.validate(FestivalRegion.SEOUL, null) }
        assertThrows<BusinessException> { SubmissionRegions.validate(FestivalRegion.SEOUL, "수원시") }
    }

    @Test
    fun provinceWithoutDistrictDoesNotRequireOne() {
        assertThat(SubmissionRegions.validate(FestivalRegion.SEJONG, null)).isEmpty()
        assertThrows<BusinessException> { SubmissionRegions.validate(FestivalRegion.SEJONG, "강남구") }
    }
}
