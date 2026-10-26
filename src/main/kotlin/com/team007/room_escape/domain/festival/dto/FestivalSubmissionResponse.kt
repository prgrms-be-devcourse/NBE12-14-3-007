package com.team007.room_escape.domain.festival.dto

import com.team007.room_escape.domain.festival.infra.entity.Festival
import com.team007.room_escape.domain.deletion.infra.entity.DeletionHistory
import com.team007.room_escape.domain.festival.infra.entity.FestivalRegion
import com.team007.room_escape.domain.festival.infra.entity.FestivalStatus
import com.team007.room_escape.domain.festival.infra.entity.FestivalSubmission
import io.swagger.v3.oas.annotations.media.Schema
import java.time.LocalDateTime
import java.util.UUID

class FestivalSubmissionResponse private constructor() {
    @Schema(name = "FestivalSubmissionCreate", description = "행사 등록 결과")
    @JvmRecord
    data class Create(
        @field:Schema(description = "생성된 행사 번호")
        val festivalId: Long?,

        @field:Schema(description = "생성된 행사 제보 번호")
        val festivalSubmissionId: UUID?,

        @field:Schema(description = "행사 상태", example = "OPEN")
        val status: FestivalStatus?
    ) {
        companion object {
            @JvmStatic
            fun builder(): CreateBuilder = CreateBuilder()

            @JvmStatic
            fun from(festival: Festival, festivalSubmission: FestivalSubmission): Create {
                return Create.builder()
                    .festivalId(festival.id)
                    .festivalSubmissionId(festivalSubmission.id)
                    .status(FestivalStatus.from(festival.endDe))
                    .build()
            }
        }

        class CreateBuilder {
            private var festivalId: Long? = null
            private var festivalSubmissionId: UUID? = null
            private var status: FestivalStatus? = null

            fun festivalId(festivalId: Long?): CreateBuilder = apply { this.festivalId = festivalId }

            fun festivalSubmissionId(festivalSubmissionId: UUID?): CreateBuilder = apply { this.festivalSubmissionId = festivalSubmissionId }

            fun status(status: FestivalStatus?): CreateBuilder = apply { this.status = status }

            fun build(): Create = Create(festivalId, festivalSubmissionId, status)
        }
    }

    @Schema(name = "FestivalSubmissionListItem", description = "[ME] 내 행사 목록 항목")
    @JvmRecord
    data class ListItem(
        @field:Schema(description = "행사 제보 번호")
        val festivalSubmissionId: UUID?,

        @field:Schema(description = "행사 번호")
        val festivalId: Long?,

        @field:Schema(description = "행사 제목")
        val title: String?,

        @field:Schema(description = "행사 지역")
        val region: FestivalRegion?,

        @field:Schema(description = "행사 상세 주소")
        val regionDetail: String?,

        @field:Schema(description = "행사 시작 일시")
        val beginDe: LocalDateTime?,

        @field:Schema(description = "행사 종료 일시")
        val endDe: LocalDateTime?,

        @field:Schema(description = "행사 제보 일시")
        val createdAt: LocalDateTime?,

        @field:Schema(description = "삭제 정보. 삭제되지 않았으면 null")
        val deletion: FestivalResponse.DeletionInfo?,

        @field:Schema(description = "행사 상태", example = "OPEN")
        val status: FestivalStatus?
    ) {
        companion object {
            @JvmStatic
            fun builder(): ListItemBuilder = ListItemBuilder()

            @JvmStatic
            fun from(festivalSubmission: FestivalSubmission, latest: DeletionHistory?): ListItem {
                val festival = festivalSubmission.festival!!

                return ListItem.builder()
                    .festivalSubmissionId(festivalSubmission.id)
                    .festivalId(festival.id)
                    .title(festival.title)
                    .region(festival.region)
                    .regionDetail(festival.regionDetail)
                    .beginDe(festival.beginDe)
                    .endDe(festival.endDe)
                    .createdAt(festivalSubmission.createdAt)
                    .deletion(FestivalResponse.DeletionInfo.from(festival, latest))
                    .status(FestivalStatus.from(festival.endDe))
                    .build()
            }
        }

        class ListItemBuilder {
            private var festivalSubmissionId: UUID? = null
            private var festivalId: Long? = null
            private var title: String? = null
            private var region: FestivalRegion? = null
            private var regionDetail: String? = null
            private var beginDe: LocalDateTime? = null
            private var endDe: LocalDateTime? = null
            private var createdAt: LocalDateTime? = null
            private var deletion: FestivalResponse.DeletionInfo? = null
            private var status: FestivalStatus? = null

            fun festivalSubmissionId(festivalSubmissionId: UUID?): ListItemBuilder = apply { this.festivalSubmissionId = festivalSubmissionId }

            fun festivalId(festivalId: Long?): ListItemBuilder = apply { this.festivalId = festivalId }

            fun title(title: String?): ListItemBuilder = apply { this.title = title }

            fun region(region: FestivalRegion?): ListItemBuilder = apply { this.region = region }

            fun regionDetail(regionDetail: String?): ListItemBuilder = apply { this.regionDetail = regionDetail }

            fun beginDe(beginDe: LocalDateTime?): ListItemBuilder = apply { this.beginDe = beginDe }

            fun endDe(endDe: LocalDateTime?): ListItemBuilder = apply { this.endDe = endDe }

            fun createdAt(createdAt: LocalDateTime?): ListItemBuilder = apply { this.createdAt = createdAt }

            fun deletion(deletion: FestivalResponse.DeletionInfo?): ListItemBuilder = apply { this.deletion = deletion }

            fun status(status: FestivalStatus?): ListItemBuilder = apply { this.status = status }

            fun build(): ListItem = ListItem(festivalSubmissionId, festivalId, title, region, regionDetail, beginDe, endDe, createdAt, deletion, status)
        }
    }

    @Schema(name = "FestivalSubmissionDetail", description = "[ME] 내 행사 상세")
    @JvmRecord
    data class Detail(
        @field:Schema(description = "행사 제보 정보")
        val submission: SubmissionInfo?
    ) {
        companion object {
            @JvmStatic
            fun builder(): DetailBuilder = DetailBuilder()

            @JvmStatic
            fun from(festivalSubmission: FestivalSubmission, latest: DeletionHistory?): Detail {
                return Detail.builder()
                    .submission(SubmissionInfo.from(festivalSubmission, latest))
                    .build()
            }
        }

        class DetailBuilder {
            private var submission: SubmissionInfo? = null

            fun submission(submission: SubmissionInfo?): DetailBuilder = apply { this.submission = submission }

            fun build(): Detail = Detail(submission)
        }
    }

    @Schema(name = "FestivalSubmissionInfo", description = "행사 제보 정보")
    @JvmRecord
    data class SubmissionInfo(
        @field:Schema(description = "행사 제보 번호")
        val festivalSubmissionId: UUID?,

        @field:Schema(description = "행사 제보 일시")
        val createdAt: LocalDateTime?,

        @field:Schema(description = "마지막 수정 일시")
        val updatedAt: LocalDateTime?,

        @field:Schema(description = "행사 정보")
        val festival: FestivalInfo?
    ) {
        companion object {
            @JvmStatic
            fun builder(): SubmissionInfoBuilder = SubmissionInfoBuilder()

            @JvmStatic
            fun from(festivalSubmission: FestivalSubmission, latest: DeletionHistory?): SubmissionInfo {
                return SubmissionInfo.builder()
                    .festivalSubmissionId(festivalSubmission.id)
                    .createdAt(festivalSubmission.createdAt)
                    .updatedAt(festivalSubmission.updatedAt)
                    .festival(FestivalInfo.from(festivalSubmission.festival!!, latest))
                    .build()
            }
        }

        class SubmissionInfoBuilder {
            private var festivalSubmissionId: UUID? = null
            private var createdAt: LocalDateTime? = null
            private var updatedAt: LocalDateTime? = null
            private var festival: FestivalInfo? = null

            fun festivalSubmissionId(festivalSubmissionId: UUID?): SubmissionInfoBuilder = apply { this.festivalSubmissionId = festivalSubmissionId }

            fun createdAt(createdAt: LocalDateTime?): SubmissionInfoBuilder = apply { this.createdAt = createdAt }

            fun updatedAt(updatedAt: LocalDateTime?): SubmissionInfoBuilder = apply { this.updatedAt = updatedAt }

            fun festival(festival: FestivalInfo?): SubmissionInfoBuilder = apply { this.festival = festival }

            fun build(): SubmissionInfo = SubmissionInfo(festivalSubmissionId, createdAt, updatedAt, festival)
        }
    }

    @Schema(name = "FestivalSubmissionFestivalInfo", description = "제보한 행사 정보")
    @JvmRecord
    data class FestivalInfo(
        @field:Schema(description = "행사 번호")
        val festivalId: Long?,

        @field:Schema(description = "행사 제목")
        val title: String?,

        @field:Schema(description = "행사 종류")
        val category: String?,

        @field:Schema(description = "행사 상세 내용")
        val festivalContent: String?,

        @field:Schema(description = "행사 정보를 확인할 수 있는 참고 링크")
        val referenceUrl: String?,

        @field:Schema(description = "행사 지역")
        val region: FestivalRegion?,

        @field:Schema(description = "행사 상세 주소")
        val regionDetail: String?,

        @field:Schema(description = "행사 이미지 URL")
        val imgUrl: String?,

        @field:Schema(description = "행사 시작 일시")
        val beginDe: LocalDateTime?,

        @field:Schema(description = "행사 종료 일시")
        val endDe: LocalDateTime?,

        @field:Schema(description = "참가 비용 정보")
        val partcptExpnInfo: String?,

        @field:Schema(description = "전화번호")
        val telnoInfo: String?,

        @field:Schema(description = "삭제 정보. 삭제되지 않았으면 null")
        val deletion: FestivalResponse.DeletionInfo?,

        @field:Schema(description = "행사 상태", example = "OPEN")
        val status: FestivalStatus?
    ) {
        companion object {
            @JvmStatic
            fun builder(): FestivalInfoBuilder = FestivalInfoBuilder()

            @JvmStatic
            fun from(festival: Festival, latest: DeletionHistory?): FestivalInfo {
                return FestivalInfo.builder()
                    .festivalId(festival.id)
                    .category(festival.category)
                    .title(festival.title)
                    .festivalContent(festival.content)
                    .referenceUrl(festival.url)
                    .region(festival.region)
                    .regionDetail(festival.regionDetail)
                    .imgUrl(festival.imgUrl)
                    .beginDe(festival.beginDe)
                    .endDe(festival.endDe)
                    .partcptExpnInfo(festival.partcptExpnInfo)
                    .telnoInfo(festival.telnoInfo)
                    .deletion(FestivalResponse.DeletionInfo.from(festival, latest))
                    .status(FestivalStatus.from(festival.endDe))
                    .build()
            }
        }

        class FestivalInfoBuilder {
            private var festivalId: Long? = null
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
            private var deletion: FestivalResponse.DeletionInfo? = null
            private var status: FestivalStatus? = null

            fun festivalId(festivalId: Long?): FestivalInfoBuilder = apply { this.festivalId = festivalId }

            fun title(title: String?): FestivalInfoBuilder = apply { this.title = title }

            fun category(category: String?): FestivalInfoBuilder = apply { this.category = category }

            fun festivalContent(festivalContent: String?): FestivalInfoBuilder = apply { this.festivalContent = festivalContent }

            fun referenceUrl(referenceUrl: String?): FestivalInfoBuilder = apply { this.referenceUrl = referenceUrl }

            fun region(region: FestivalRegion?): FestivalInfoBuilder = apply { this.region = region }

            fun regionDetail(regionDetail: String?): FestivalInfoBuilder = apply { this.regionDetail = regionDetail }

            fun imgUrl(imgUrl: String?): FestivalInfoBuilder = apply { this.imgUrl = imgUrl }

            fun beginDe(beginDe: LocalDateTime?): FestivalInfoBuilder = apply { this.beginDe = beginDe }

            fun endDe(endDe: LocalDateTime?): FestivalInfoBuilder = apply { this.endDe = endDe }

            fun partcptExpnInfo(partcptExpnInfo: String?): FestivalInfoBuilder = apply { this.partcptExpnInfo = partcptExpnInfo }

            fun telnoInfo(telnoInfo: String?): FestivalInfoBuilder = apply { this.telnoInfo = telnoInfo }

            fun deletion(deletion: FestivalResponse.DeletionInfo?): FestivalInfoBuilder = apply { this.deletion = deletion }

            fun status(status: FestivalStatus?): FestivalInfoBuilder = apply { this.status = status }

            fun build(): FestivalInfo = FestivalInfo(festivalId, title, category, festivalContent, referenceUrl, region, regionDetail, imgUrl, beginDe, endDe, partcptExpnInfo, telnoInfo, deletion, status)
        }
    }
}
