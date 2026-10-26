package com.team007.room_escape.domain.festival.dto

import com.team007.room_escape.domain.festival.infra.entity.FestivalRegion
import io.swagger.v3.oas.annotations.media.Schema
import jakarta.validation.constraints.AssertTrue
import jakarta.validation.constraints.NotBlank
import jakarta.validation.constraints.NotNull
import jakarta.validation.constraints.Size
import java.time.LocalDateTime

class FestivalSubmissionRequest private constructor() {
    @Schema(name = "FestivalSubmissionUpsertRequest", description = "행사 제보 등록·수정 요청")
    @JvmRecord
    data class Upsert(
        @field:NotBlank(message = "행사 이름은 필수입니다.")
        @field:Schema(description = "행사 이름", example = "성수 독립 플리마켓")
        val title: String?,

        @field:NotBlank(message = "제보 행사 카테고리는 필수입니다.")
        @field:Size(max = 50, message = "제보 행사 카테고리는 50자 이하여야 합니다.")
        @field:Schema(description = "제보 행사 카테고리", example = "플리마켓")
        val category: String?,

        @field:Schema(description = "공개할 행사 상세 내용")
        val festivalContent: String?,

        @field:NotBlank(message = "행사 참고 링크는 필수입니다.")
        @field:Size(max = 2048, message = "행사 참고 링크는 2,048자 이하여야 합니다.")
        @field:Schema(description = "행사 정보를 확인할 수 있는 참고 링크", example = "https://www.instagram.com/example-event")
        val referenceUrl: String?,

        @field:NotNull(message = "행사 지역은 필수입니다.")
        @field:Schema(description = "행사 지역", example = "GYEONGGI")
        val region: FestivalRegion?,

        @field:Size(max = 255, message = "행사 상세 주소는 255자 이하여야 합니다.")
        @field:Schema(description = "행사 상세 주소", example = "팔달구 효원로 1")
        val regionDetail: String?,

        @field:Size(max = 2048, message = "이미지 URL은 2,048자 이하여야 합니다.")
        @field:Schema(description = "행사 이미지 URL")
        val imgUrl: String?,

        @field:NotNull(message = "행사 시작 일시는 필수입니다.")
        @field:Schema(description = "행사 시작 일시", example = "2026-09-20T10:00:00")
        val beginDe: LocalDateTime?,

        @field:NotNull(message = "행사 종료 일시는 필수입니다.")
        @field:Schema(description = "행사 종료 일시", example = "2026-09-20T18:00:00")
        val endDe: LocalDateTime?,

        @field:Schema(description = "참가 비용 정보", example = "무료")
        val partcptExpnInfo: String?,

        @field:Schema(description = "전화번호", example = "010-1234-5678")
        val telnoInfo: String?,

        @field:Schema(description = "상세 조회에서 받은 행사 버전. 수정 시 필수")
        val version: Long? = null
    ) {
        @AssertTrue(message = "행사 종료 일시는 시작 일시보다 빠를 수 없습니다.")
        fun isValidPeriod(): Boolean = beginDe == null || endDe == null || !endDe.isBefore(beginDe)

        companion object {
            fun builder(): UpsertBuilder = UpsertBuilder()
        }

        class UpsertBuilder {
            private var version: Long? = null
            fun version(version: Long?): UpsertBuilder = apply { this.version = version }
            private var title: String? = null
            private var category: String? = null
            private var festivalContent: String? = null
            private var referenceUrl: String? = null
            private var region: FestivalRegion? = null
            private var regionDetail: String? = null
            private var imgUrl: String? = null
            private var beginDe: LocalDateTime? = null
            private var endDe: LocalDateTime? = null
            private var partcptExpnInfo: String? = null
            private var telnoInfo: String? = null

            fun title(title: String?): UpsertBuilder = apply { this.title = title }

            fun category(category: String?): UpsertBuilder = apply { this.category = category }

            fun festivalContent(festivalContent: String?): UpsertBuilder = apply { this.festivalContent = festivalContent }

            fun referenceUrl(referenceUrl: String?): UpsertBuilder = apply { this.referenceUrl = referenceUrl }

            fun region(region: FestivalRegion?): UpsertBuilder = apply { this.region = region }

            fun regionDetail(regionDetail: String?): UpsertBuilder = apply { this.regionDetail = regionDetail }

            fun imgUrl(imgUrl: String?): UpsertBuilder = apply { this.imgUrl = imgUrl }

            fun beginDe(beginDe: LocalDateTime?): UpsertBuilder = apply { this.beginDe = beginDe }

            fun endDe(endDe: LocalDateTime?): UpsertBuilder = apply { this.endDe = endDe }

            fun partcptExpnInfo(partcptExpnInfo: String?): UpsertBuilder = apply { this.partcptExpnInfo = partcptExpnInfo }

            fun telnoInfo(telnoInfo: String?): UpsertBuilder = apply { this.telnoInfo = telnoInfo }

            fun build(): Upsert = Upsert(title, category, festivalContent, referenceUrl, region, regionDetail, imgUrl, beginDe, endDe, partcptExpnInfo, telnoInfo, version)
        }
    }
}
