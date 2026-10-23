package com.team007.room_escape.domain.festival.dto

import com.team007.room_escape.domain.festival.infra.entity.FestivalAccuracyVoteType
import io.swagger.v3.oas.annotations.media.Schema
import jakarta.validation.constraints.NotNull

class FestivalAccuracyVoteRequest private constructor() {

    @JvmRecord
    @Schema(name = "FestivalAccuracyVoteUpsertRequest", description = "행사 정보 정확도 평가 요청")
    data class Upsert(
        @field:NotNull(message = "평가 종류는 필수입니다.")
        @field:Schema(description = "행사 정보 정확도 평가", example = "ACCURATE")
        val voteType: FestivalAccuracyVoteType?
    )
}
