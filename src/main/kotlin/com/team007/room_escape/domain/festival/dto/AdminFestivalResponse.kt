package com.team007.room_escape.domain.festival.dto

import java.time.LocalDateTime
import com.team007.room_escape.domain.deletion.infra.entity.DeletionHistory
import com.team007.room_escape.domain.deletion.infra.entity.DeletionAction
import com.team007.room_escape.domain.festival.infra.entity.Festival
import com.team007.room_escape.domain.festival.infra.entity.FestivalRegion
import com.team007.room_escape.domain.festival.infra.entity.FestivalStatus
import com.team007.room_escape.domain.festival.infra.entity.ProviderType
import io.swagger.v3.oas.annotations.media.Schema

class AdminFestivalResponse private constructor() {
    /** 관리자 행사 목록 항목. 삭제 정보로 안내 사유와 복구 가능 여부를 판단한다. */
    @Schema(name = "AdminFestivalListItem", description = "관리자 행사 목록 항목")
    @JvmRecord
    data class ListItem(
        @field:Schema(description = "행사 번호")
        val festivalId: Long?,

        @field:Schema(description = "데이터 출처", example = "PUBLIC")
        val providerType: ProviderType?,

        @field:Schema(description = "행사 제목")
        val title: String?,

        @field:Schema(description = "행사 종류")
        val category: String?,

        @field:Schema(description = "행사 이미지 URL")
        val imgUrl: String?,

        @field:Schema(description = "행사 시작 일시")
        val beginDe: LocalDateTime?,

        @field:Schema(description = "행사 종료 일시")
        val endDe: LocalDateTime?,

        @field:Schema(description = "행사 등록 일시")
        val createdAt: LocalDateTime?,

        @field:Schema(description = "행사 지역")
        val region: FestivalRegion?,

        @field:Schema(description = "진행 상태. 종료일에서 계산된다", example = "OPEN")
        val status: FestivalStatus?,

        @field:Schema(description = "삭제 시각. 삭제되지 않았으면 null")
        val deletedAt: LocalDateTime?,

        @field:Schema(description = "삭제 주체 구분 및 안내 사유")
        val deletion: FestivalResponse.DeletionInfo?
    ) {
        companion object {
            @JvmStatic
            fun builder(): ListItemBuilder = ListItemBuilder()

            @JvmStatic
            fun from(festival: Festival, latest: DeletionHistory?): ListItem {
                return ListItem.builder()
                    .festivalId(festival.id)
                    .providerType(festival.providerType)
                    .title(festival.title)
                    .category(festival.category)
                    .imgUrl(festival.imgUrl)
                    .beginDe(festival.beginDe)
                    .endDe(festival.endDe)
                    .createdAt(festival.createdAt)
                    .region(festival.region)
                    .status(festival.status)
                    .deletedAt(festival.deletedAt)
                    .deletion(deletionFromHistory(festival, latest))
                    .build()
            }

            private fun deletionFromHistory(festival: Festival, latest: DeletionHistory?): FestivalResponse.DeletionInfo? {
                if (!festival.isDeleted() || latest == null || latest.action != DeletionAction.DELETE) return null
                return FestivalResponse.DeletionInfo.from(festival, latest)
            }
        }

        class ListItemBuilder {
            private var festivalId: Long? = null
            private var providerType: ProviderType? = null
            private var title: String? = null
            private var category: String? = null
            private var imgUrl: String? = null
            private var beginDe: LocalDateTime? = null
            private var endDe: LocalDateTime? = null
            private var createdAt: LocalDateTime? = null
            private var region: FestivalRegion? = null
            private var status: FestivalStatus? = null
            private var deletedAt: LocalDateTime? = null
            private var deletion: FestivalResponse.DeletionInfo? = null

            fun festivalId(festivalId: Long?): ListItemBuilder = apply { this.festivalId = festivalId }

            fun providerType(providerType: ProviderType?): ListItemBuilder = apply { this.providerType = providerType }

            fun title(title: String?): ListItemBuilder = apply { this.title = title }

            fun category(category: String?): ListItemBuilder = apply { this.category = category }

            fun imgUrl(imgUrl: String?): ListItemBuilder = apply { this.imgUrl = imgUrl }

            fun beginDe(beginDe: LocalDateTime?): ListItemBuilder = apply { this.beginDe = beginDe }

            fun endDe(endDe: LocalDateTime?): ListItemBuilder = apply { this.endDe = endDe }

            fun createdAt(createdAt: LocalDateTime?): ListItemBuilder = apply { this.createdAt = createdAt }

            fun region(region: FestivalRegion?): ListItemBuilder = apply { this.region = region }

            fun status(status: FestivalStatus?): ListItemBuilder = apply { this.status = status }

            fun deletedAt(deletedAt: LocalDateTime?): ListItemBuilder = apply { this.deletedAt = deletedAt }

            fun deletion(deletion: FestivalResponse.DeletionInfo?): ListItemBuilder = apply { this.deletion = deletion }

            fun build(): ListItem = ListItem(festivalId, providerType, title, category, imgUrl, beginDe, endDe, createdAt, region, status, deletedAt, deletion)
        }
    }
}
