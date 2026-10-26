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
            fun from(festival: Festival, festivalSubmission: FestivalSubmission): Create =
                Create(
                    festivalId = festival.id,
                    festivalSubmissionId = festivalSubmission.id,
                    status = FestivalStatus.from(festival.endDe),
                )
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
        val status: FestivalStatus?,

        val district: String? = null
    ) {
        companion object {
            fun from(festivalSubmission: FestivalSubmission, latest: DeletionHistory?): ListItem {
                val festival = festivalSubmission.festival

                return ListItem(
                    festivalSubmissionId = festivalSubmission.id,
                    festivalId = festival.id,
                    title = festival.title,
                    region = festival.region,
                    district = festival.district,
                    regionDetail = festival.regionDetail,
                    beginDe = festival.beginDe,
                    endDe = festival.endDe,
                    createdAt = festivalSubmission.createdAt,
                    deletion = FestivalResponse.DeletionInfo.from(festival, latest),
                    status = FestivalStatus.from(festival.endDe),
                )
            }
        }
    }

    @Schema(name = "FestivalSubmissionDetail", description = "[ME] 내 행사 상세")
    @JvmRecord
    data class Detail(
        @field:Schema(description = "행사 제보 정보")
        val submission: SubmissionInfo?
    ) {
        companion object {
            fun from(festivalSubmission: FestivalSubmission, latest: DeletionHistory?): Detail =
                Detail(
                    submission = SubmissionInfo.from(festivalSubmission, latest),
                )
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
        val festival: FestivalInfo?,

        @field:Schema(description = "수정 요청에 전달할 행사 버전")
        val version: Long = 0
    ) {
        companion object {
            fun from(festivalSubmission: FestivalSubmission, latest: DeletionHistory?): SubmissionInfo {
                val festival = checkNotNull(festivalSubmission.festival)
                return SubmissionInfo(
                    festivalSubmissionId = festivalSubmission.id,
                    createdAt = festivalSubmission.createdAt,
                    updatedAt = festival.updatedAt,
                    festival = FestivalInfo.from(festival, latest),
                    version = festival.version
                )
            }
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
        val status: FestivalStatus?,

        val district: String? = null
    ) {
        companion object {
            fun from(festival: Festival, latest: DeletionHistory?): FestivalInfo =
                FestivalInfo(
                    festivalId = festival.id,
                    district = festival.district,
                    category = festival.category,
                    title = festival.title,
                    festivalContent = festival.content,
                    referenceUrl = festival.url,
                    region = festival.region,
                    regionDetail = festival.regionDetail,
                    imgUrl = festival.imgUrl,
                    beginDe = festival.beginDe,
                    endDe = festival.endDe,
                    partcptExpnInfo = festival.partcptExpnInfo,
                    telnoInfo = festival.telnoInfo,
                    deletion = FestivalResponse.DeletionInfo.from(festival, latest),
                    status = FestivalStatus.from(festival.endDe),
                )
        }
    }
}
