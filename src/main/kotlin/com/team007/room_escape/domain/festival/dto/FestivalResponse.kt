package com.team007.room_escape.domain.festival.dto

import com.team007.room_escape.domain.festival.infra.entity.Festival
import com.team007.room_escape.domain.deletion.infra.entity.DeletionHistory
import com.team007.room_escape.domain.deletion.infra.entity.DeletionAction
import com.team007.room_escape.domain.deletion.infra.entity.DeletionActorType
import com.team007.room_escape.domain.festival.infra.entity.FestivalAccuracyVoteType
import com.team007.room_escape.domain.festival.infra.entity.FestivalRegion
import com.team007.room_escape.domain.festival.infra.entity.FestivalStatus
import com.team007.room_escape.domain.festival.infra.entity.ProviderType
import com.team007.room_escape.domain.member.dto.MemberResponse
import com.team007.room_escape.global.storage.ImageUrlResolver
import io.swagger.v3.oas.annotations.media.Schema
import java.time.LocalDateTime

class FestivalResponse private constructor() {
    @Schema(name = "FestivalDeletionInfo", description = "현재 삭제 상태. 삭제되지 않았으면 null")
    @JvmRecord
    data class DeletionInfo(
        @field:Schema(description = "행사 삭제 시각")
        val deletedAt: LocalDateTime?,

        @field:Schema(description = "이력에 기록된 삭제 주체. AUTHOR, ADMIN. 이력이 없으면 null")
        val type: DeletionActorType?,

        @field:Schema(description = "작성자에게 안내하는 삭제 사유")
        val reason: String?
    ) {
        companion object {
            fun builder(): DeletionInfoBuilder = DeletionInfoBuilder()

            fun from(festival: Festival, latest: DeletionHistory?): DeletionInfo? {
                if (!festival.isDeleted()) return null
                if (latest == null || latest.action != DeletionAction.DELETE) {
                    return DeletionInfo(festival.deletedAt, null, "삭제 사유를 확인할 수 없습니다.")
                }
                val detail = latest.reasonDetail?.let { " — $it" }.orEmpty()
                return DeletionInfo(festival.deletedAt, latest.actorType, latest.reason.description + detail)
            }
        }

        class DeletionInfoBuilder {
            private var deletedAt: LocalDateTime? = null
            private var type: DeletionActorType? = null
            private var reason: String? = null

            fun deletedAt(deletedAt: LocalDateTime?): DeletionInfoBuilder = apply { this.deletedAt = deletedAt }

            fun type(type: DeletionActorType?): DeletionInfoBuilder = apply { this.type = type }

            fun reason(reason: String?): DeletionInfoBuilder = apply { this.reason = reason }

            fun build(): DeletionInfo = DeletionInfo(deletedAt, type, reason)
        }
    }

    @Schema(name = "FestivalListItem", description = "행사 목록 항목")
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

        @field:Schema(description = "행사 지역")
        val region: FestivalRegion?,

        @field:Schema(description = "행사 지역 상세(시·군·구)", nullable = true)
        val regionDetail: String?,

        @field:Schema(description = "행사 상태", example = "OPEN")
        val status: FestivalStatus?,

        @field:Schema(description = "좋아요 수")
        val likeCount: Long,

        @field:Schema(description = "정확해요 개수. 공공데이터 행사는 0", example = "3")
        val accurateCount: Long,

        @field:Schema(description = "부정확해요 개수. 공공데이터 행사는 0", example = "1")
        val inaccurateCount: Long,

        @field:Schema(description = "회원 제보 행사 작성자 정보. 공공데이터 행사는 null", nullable = true)
        val member: MemberResponse.MemberInfo?,

        val district: String? = null
    ) {
        companion object {
            fun builder(): ListItemBuilder = ListItemBuilder()

            fun from(festival: Festival, likeCount: Long, accurateCount: Long, inaccurateCount: Long, imageUrlResolver: ImageUrlResolver?): ListItem =
                ListItem.builder()
                    .festivalId(festival.id)
                    .providerType(festival.providerType)
                    .title(festival.title)
                    .category(festival.category)
                    .imgUrl(image(festival.imgUrl, imageUrlResolver))
                    .beginDe(festival.beginDe)
                    .endDe(festival.endDe)
                    .region(festival.region)
                    .district(festival.district)
                    .regionDetail(festival.regionDetail)
                    .status(FestivalStatus.from(festival.endDe))
                    .likeCount(likeCount)
                    .accurateCount(accurateCount)
                    .inaccurateCount(inaccurateCount)
                    .member(toMember(festival, imageUrlResolver))
                    .build()
        }

        class ListItemBuilder {
            private var district: String? = null
            fun district(district: String?): ListItemBuilder = apply { this.district = district }
            private var festivalId: Long? = null
            private var providerType: ProviderType? = null
            private var title: String? = null
            private var category: String? = null
            private var imgUrl: String? = null
            private var beginDe: LocalDateTime? = null
            private var endDe: LocalDateTime? = null
            private var region: FestivalRegion? = null
            private var regionDetail: String? = null
            private var status: FestivalStatus? = null
            private var likeCount: Long = 0
            private var accurateCount: Long = 0
            private var inaccurateCount: Long = 0
            private var member: MemberResponse.MemberInfo? = null

            fun festivalId(festivalId: Long?): ListItemBuilder = apply { this.festivalId = festivalId }

            fun providerType(providerType: ProviderType?): ListItemBuilder = apply { this.providerType = providerType }

            fun title(title: String?): ListItemBuilder = apply { this.title = title }

            fun category(category: String?): ListItemBuilder = apply { this.category = category }

            fun imgUrl(imgUrl: String?): ListItemBuilder = apply { this.imgUrl = imgUrl }

            fun beginDe(beginDe: LocalDateTime?): ListItemBuilder = apply { this.beginDe = beginDe }

            fun endDe(endDe: LocalDateTime?): ListItemBuilder = apply { this.endDe = endDe }

            fun region(region: FestivalRegion?): ListItemBuilder = apply { this.region = region }

            fun regionDetail(regionDetail: String?): ListItemBuilder = apply { this.regionDetail = regionDetail }

            fun status(status: FestivalStatus?): ListItemBuilder = apply { this.status = status }

            fun likeCount(likeCount: Long): ListItemBuilder = apply { this.likeCount = likeCount }

            fun accurateCount(accurateCount: Long): ListItemBuilder = apply { this.accurateCount = accurateCount }

            fun inaccurateCount(inaccurateCount: Long): ListItemBuilder = apply { this.inaccurateCount = inaccurateCount }

            fun member(member: MemberResponse.MemberInfo?): ListItemBuilder = apply { this.member = member }

            fun build(): ListItem = ListItem(festivalId, providerType, title, category, imgUrl, beginDe, endDe, region, regionDetail, status, likeCount, accurateCount, inaccurateCount, member, district)
        }
    }

    @Schema(name = "FestivalDetail", description = "행사 상세")
    @JvmRecord
    data class Detail(
        @field:Schema(description = "행사 번호")
        val festivalId: Long?,

        @field:Schema(description = "데이터 출처", example = "MEMBER")
        val providerType: ProviderType?,

        @field:Schema(description = "행사 제목")
        val title: String?,

        @field:Schema(description = "행사 종류")
        val category: String?,

        @field:Schema(description = "행사 소개")
        val festivalContent: String?,

        @field:Schema(description = "행사 이미지 URL")
        val imgUrl: String?,

        @field:Schema(description = "행사 원문 주소")
        val url: String?,

        @field:Schema(description = "사용자에게 안내할 행사 참고 링크")
        val referenceUrl: String?,

        @field:Schema(description = "행사 시작 일시")
        val beginDe: LocalDateTime?,

        @field:Schema(description = "행사 종료 일시")
        val endDe: LocalDateTime?,

        @field:Schema(description = "참가 비용 정보")
        val partcptExpnInfo: String?,

        @field:Schema(description = "전화번호")
        val telnoInfo: String?,

        @field:Schema(description = "행사 지역")
        val region: FestivalRegion?,

        @field:Schema(description = "행사 상세 주소")
        val regionDetail: String?,

        @field:Schema(description = "행사 상태", example = "OPEN")
        val status: FestivalStatus?,

        @field:Schema(description = "정확해요 개수", example = "18")
        val accurateCount: Long,

        @field:Schema(description = "부정확해요 개수", example = "2")
        val inaccurateCount: Long,

        @field:Schema(description = "현재 사용자의 평가, 평가하지 않았다면 null", example = "ACCURATE", nullable = true)
        val myVote: FestivalAccuracyVoteType?,

        @field:Schema(description = "좋아요 개수", example = "7")
        val likeCount: Long,

        @field:Schema(description = "현재 사용자의 좋아요 여부", example = "true")
        val likedByMe: Boolean,

        @field:Schema(description = "회원 제보 행사 작성자 정보. 공공데이터 행사는 null", nullable = true)
        val member: MemberResponse.MemberInfo?,

        val district: String? = null
    ) {
        companion object {
            fun builder(): DetailBuilder = DetailBuilder()

            fun from(festival: Festival, accurateCount: Long, inaccurateCount: Long, myVote: FestivalAccuracyVoteType?, likeCount: Long, likedByMe: Boolean, imageUrlResolver: ImageUrlResolver?): Detail =
                Detail.builder()
                    .festivalId(festival.id)
                    .providerType(festival.providerType)
                    .title(festival.title)
                    .category(festival.category)
                    .festivalContent(festival.content)
                    .imgUrl(image(festival.imgUrl, imageUrlResolver))
                    .url(festival.url)
                    .referenceUrl(festival.url)
                    .beginDe(festival.beginDe)
                    .endDe(festival.endDe)
                    .partcptExpnInfo(festival.partcptExpnInfo)
                    .telnoInfo(festival.telnoInfo)
                    .region(festival.region)
                    .district(festival.district)
                    .regionDetail(festival.regionDetail)
                    .status(FestivalStatus.from(festival.endDe))
                    .accurateCount(accurateCount)
                    .inaccurateCount(inaccurateCount)
                    .myVote(myVote)
                    .likeCount(likeCount)
                    .likedByMe(likedByMe)
                    .member(toMember(festival, imageUrlResolver))
                    .build()
        }

        class DetailBuilder {
            private var district: String? = null
            fun district(district: String?): DetailBuilder = apply { this.district = district }
            private var festivalId: Long? = null
            private var providerType: ProviderType? = null
            private var title: String? = null
            private var category: String? = null
            private var festivalContent: String? = null
            private var imgUrl: String? = null
            private var url: String? = null
            private var referenceUrl: String? = null
            private var beginDe: LocalDateTime? = null
            private var endDe: LocalDateTime? = null
            private var partcptExpnInfo: String? = null
            private var telnoInfo: String? = null
            private var region: FestivalRegion? = null
            private var regionDetail: String? = null
            private var status: FestivalStatus? = null
            private var accurateCount: Long = 0
            private var inaccurateCount: Long = 0
            private var myVote: FestivalAccuracyVoteType? = null
            private var likeCount: Long = 0
            private var likedByMe: Boolean = false
            private var member: MemberResponse.MemberInfo? = null

            fun festivalId(festivalId: Long?): DetailBuilder = apply { this.festivalId = festivalId }

            fun providerType(providerType: ProviderType?): DetailBuilder = apply { this.providerType = providerType }

            fun title(title: String?): DetailBuilder = apply { this.title = title }

            fun category(category: String?): DetailBuilder = apply { this.category = category }

            fun festivalContent(festivalContent: String?): DetailBuilder = apply { this.festivalContent = festivalContent }

            fun imgUrl(imgUrl: String?): DetailBuilder = apply { this.imgUrl = imgUrl }

            fun url(url: String?): DetailBuilder = apply { this.url = url }

            fun referenceUrl(referenceUrl: String?): DetailBuilder = apply { this.referenceUrl = referenceUrl }

            fun beginDe(beginDe: LocalDateTime?): DetailBuilder = apply { this.beginDe = beginDe }

            fun endDe(endDe: LocalDateTime?): DetailBuilder = apply { this.endDe = endDe }

            fun partcptExpnInfo(partcptExpnInfo: String?): DetailBuilder = apply { this.partcptExpnInfo = partcptExpnInfo }

            fun telnoInfo(telnoInfo: String?): DetailBuilder = apply { this.telnoInfo = telnoInfo }

            fun region(region: FestivalRegion?): DetailBuilder = apply { this.region = region }

            fun regionDetail(regionDetail: String?): DetailBuilder = apply { this.regionDetail = regionDetail }

            fun status(status: FestivalStatus?): DetailBuilder = apply { this.status = status }

            fun accurateCount(accurateCount: Long): DetailBuilder = apply { this.accurateCount = accurateCount }

            fun inaccurateCount(inaccurateCount: Long): DetailBuilder = apply { this.inaccurateCount = inaccurateCount }

            fun myVote(myVote: FestivalAccuracyVoteType?): DetailBuilder = apply { this.myVote = myVote }

            fun likeCount(likeCount: Long): DetailBuilder = apply { this.likeCount = likeCount }

            fun likedByMe(likedByMe: Boolean): DetailBuilder = apply { this.likedByMe = likedByMe }

            fun member(member: MemberResponse.MemberInfo?): DetailBuilder = apply { this.member = member }

            fun build(): Detail = Detail(festivalId, providerType, title, category, festivalContent, imgUrl, url, referenceUrl, beginDe, endDe, partcptExpnInfo, telnoInfo, region, regionDetail, status, accurateCount, inaccurateCount, myVote, likeCount, likedByMe, member, district)
        }
    }

    @Schema(description = "공공 행사 동기화 결과")
    @JvmRecord
    data class SyncResponse(
        @field:Schema(description = "종료 처리(CLOSED)된 행사 목록")
        val closedFestivals: List<SyncedFestival>?,

        @field:Schema(description = "새로 저장된 행사 목록")
        val savedFestivals: List<SyncedFestival>?
    )

    @Schema(description = "동기화된 행사 요약")
    @JvmRecord
    data class SyncedFestival(
        @field:Schema(description = "행사 번호")
        val festivalId: Long?,

        @field:Schema(description = "행사 제목")
        val title: String?
    ) {
        companion object {
            fun from(festival: Festival): SyncedFestival =
                SyncedFestival(festival.id, festival.title)
        }
    }

    companion object {
        /** 회원 제보 행사의 제보자. 공공데이터 행사는 제보자가 없어 null이다. */
        private fun toMember(festival: Festival, imageUrlResolver: ImageUrlResolver?): MemberResponse.MemberInfo? {
            val member = festival.member
            if (member == null || imageUrlResolver == null) return null
            return MemberResponse.MemberInfo.from(member, imageUrlResolver)
        }

        private fun image(value: String?, imageUrlResolver: ImageUrlResolver?): String? =
            if (imageUrlResolver == null) value else imageUrlResolver.resolve(value)
    }
}
