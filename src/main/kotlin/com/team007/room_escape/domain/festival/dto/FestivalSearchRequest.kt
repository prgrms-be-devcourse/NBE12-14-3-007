package com.team007.room_escape.domain.festival.dto

import com.team007.room_escape.domain.festival.infra.entity.FestivalRegion
import com.team007.room_escape.domain.festival.infra.entity.ProviderType
import io.swagger.v3.oas.annotations.media.Schema
import java.time.LocalDate
import org.springframework.format.annotation.DateTimeFormat

@Schema(description = "행사 검색 조건")
@JvmRecord
data class FestivalSearchRequest(
    @field:Schema(description = "검색어", example = "수원")
    val keyword: String?,

    @field:Schema(description = "행사 지역", example = "GYEONGGI")
    val region: FestivalRegion?,

    @field:Schema(description = "행사 지역 상세(시·군·구)", example = "수원시")
    val regionDetail: String?,

    @field:Schema(description = "데이터 출처", example = "PUBLIC")
    val providerType: ProviderType?,

    @field:Schema(description = "행사 카테고리", example = "축제")
    val category: String?,

    @field:DateTimeFormat(iso = DateTimeFormat.ISO.DATE)
    @param:DateTimeFormat(iso = DateTimeFormat.ISO.DATE)
    @field:Schema(description = "행사 진행 일자", example = "2026-09-21")
    val date: LocalDate?,

    @field:Schema(description = "종료 행사 제외 여부", example = "false", defaultValue = "false")
    val excludeClosed: Boolean?
)
