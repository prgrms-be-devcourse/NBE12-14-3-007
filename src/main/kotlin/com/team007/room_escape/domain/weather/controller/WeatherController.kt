package com.team007.room_escape.domain.weather.controller

import com.team007.room_escape.domain.festival.infra.entity.FestivalRegion
import com.team007.room_escape.domain.weather.dto.WeatherResponse
import com.team007.room_escape.domain.weather.service.WeatherService
import com.team007.room_escape.global.response.ApiResponse
import io.swagger.v3.oas.annotations.Operation
import org.springframework.format.annotation.DateTimeFormat
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RequestParam
import org.springframework.web.bind.annotation.RestController
import java.time.LocalDate

@RestController
@RequestMapping("/api/v1/weather")
class WeatherController(
    private val weatherService: WeatherService
) {

    @Operation(
        summary = "지역·날짜별 날씨 조회",
        description = "단기예보 제공 범위(오늘~2일 후) 밖이거나 조회에 실패하면 UNKNOWN을 반환합니다."
    )
    @GetMapping
    fun getWeather(
        @RequestParam region: FestivalRegion,
        @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) date: LocalDate
    ): ResponseEntity<ApiResponse<WeatherResponse>> {
        val response = weatherService.getWeather(region, date)
        return ResponseEntity.ok(ApiResponse.ok(response))
    }
}
