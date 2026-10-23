package com.team007.room_escape.domain.weather.dto

import io.swagger.v3.oas.annotations.media.Schema
import java.time.LocalDate

@Schema(description = "지역·날짜별 간단 날씨")
data class WeatherResponse(

    @field:Schema(description = "날씨 상태", example = "SUNNY")
    val condition: WeatherCondition,

    @field:Schema(description = "강수확률(%). 값이 없으면 null", example = "30")
    val precipitationProbability: Int?,

    @field:Schema(description = "조회한 날짜", example = "2026-09-25")
    val date: LocalDate
) {

    companion object {

        @JvmStatic
        fun unknown(date: LocalDate): WeatherResponse {
            return WeatherResponse(WeatherCondition.UNKNOWN, null, date)
        }
    }
}
