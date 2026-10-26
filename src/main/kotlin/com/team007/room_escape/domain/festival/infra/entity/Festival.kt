package com.team007.room_escape.domain.festival.infra.entity

import com.team007.room_escape.domain.member.infra.entity.Member
import com.team007.room_escape.global.entity.SoftDeletableEntity
import jakarta.persistence.Column
import jakarta.persistence.Entity
import jakarta.persistence.EnumType
import jakarta.persistence.Enumerated
import jakarta.persistence.FetchType
import jakarta.persistence.GeneratedValue
import jakarta.persistence.GenerationType
import jakarta.persistence.Id
import jakarta.persistence.JoinColumn
import jakarta.persistence.ManyToOne
import jakarta.persistence.Table
import java.time.LocalDateTime
import com.team007.room_escape.global.exception.BusinessException
import com.team007.room_escape.global.response.code.FestivalExceptionCode

// 삭제된 행사를 참조하는 후기·제보 조회가 깨지지 않게 @SQLRestriction을 걸지 않는다. 목록·상세는 deletedAtIsNull로 거른다.
@Entity
@Table(name = "festival")
class Festival protected constructor() : SoftDeletableEntity() {
    @field:Id
    @field:GeneratedValue(strategy = GenerationType.IDENTITY)
    var id: Long? = null
        protected set

    @field:ManyToOne(fetch = FetchType.LAZY)
    @field:JoinColumn(name = "member_id")
    var member: Member? = null
        protected set

    @field:Enumerated(EnumType.STRING)
    @field:Column(name = "provider_type", nullable = false, length = 32)
    var providerType: ProviderType? = null
        protected set

    @field:Column(name = "external_id", length = 64)
    var externalId: String? = null
        protected set

    var title: String? = null
        protected set

    var category: String? = null
        protected set

    var manager: String? = null
        protected set

    @field:Column(columnDefinition = "text")
    var content: String? = null
        protected set

    @field:Column(length = 2048)
    var url: String? = null
        protected set

    @field:Column(name = "img_url", length = 2048)
    var imgUrl: String? = null
        protected set

    @field:Column(name = "begin_de")
    var beginDe: LocalDateTime? = null
        protected set

    @field:Column(name = "end_de")
    var endDe: LocalDateTime? = null
        protected set

    @field:Column(name = "partcpt_expn_info", columnDefinition = "text")
    var partcptExpnInfo: String? = null
        protected set

    @field:Column(name = "telno_info", columnDefinition = "text")
    var telnoInfo: String? = null
        protected set

    @field:Enumerated(EnumType.STRING)
    @field:Column(length = 32)
    var status: FestivalStatus? = null
        protected set

    @field:Enumerated(EnumType.STRING)
    @field:Column(name = "region", length = 32)
    var region: FestivalRegion? = null
        protected set

    @field:Column(name = "region_detail", columnDefinition = "text")
    var regionDetail: String? = null
        protected set

    @field:Column(columnDefinition = "text")
    var place: String? = null
        protected set

    @field:Column(name = "place_address", columnDefinition = "text")
    var placeAddress: String? = null
        protected set

    /** 삭제 주체·사유는 공통 이력에 기록하며 행사는 현재 삭제 상태만 관리한다. */
    override fun delete() {
        if (isDeleted()) throw BusinessException(FestivalExceptionCode.FESTIVAL_NOT_FOUND)
        super.delete()
    }

    override fun restore() {
        if (!isDeleted()) throw BusinessException(FestivalExceptionCode.FESTIVAL_NOT_DELETED)
        super.restore()
    }

    // TODO 인자가 많아서 정리 필요
    fun updateDetails(
        title: String?, category: String?, content: String?, referenceUrl: String?,
        region: FestivalRegion?, regionDetail: String?, imgUrl: String?,
        beginDe: LocalDateTime?, endDe: LocalDateTime?, partcptExpnInfo: String?, telnoInfo: String?
    ) {
        this.title = title
        this.category = category
        this.content = content
        this.url = referenceUrl
        this.region = region
        this.regionDetail = regionDetail
        this.imgUrl = imgUrl
        this.beginDe = beginDe
        this.endDe = endDe
        this.status = FestivalStatus.from(endDe)
        this.partcptExpnInfo = partcptExpnInfo
        this.telnoInfo = telnoInfo
    }

    /** 이관 배치에서 원본 URL을 R2 URL로 교체할 때 쓴다. 다른 필드는 건드리지 않는다. */
    fun updateImgUrl(imgUrl: String?) {
        this.imgUrl = imgUrl
    }

    companion object {
        @Deprecated("Kotlin에서는 create()를 사용하세요. Java 호출 호환용입니다.")
        @JvmStatic
        fun builder(): FestivalBuilder = FestivalBuilder()

        fun create(
            id: Long? = null,
            member: Member? = null,
            providerType: ProviderType? = null,
            externalId: String? = null,
            title: String? = null,
            category: String? = null,
            manager: String? = null,
            content: String? = null,
            url: String? = null,
            imgUrl: String? = null,
            beginDe: LocalDateTime? = null,
            endDe: LocalDateTime? = null,
            partcptExpnInfo: String? = null,
            telnoInfo: String? = null,
            status: FestivalStatus? = null,
            region: FestivalRegion? = null,
            regionDetail: String? = null,
            place: String? = null,
            placeAddress: String? = null
        ): Festival = Festival().also {
            it.id = id
            it.member = member
            it.providerType = providerType
            it.externalId = externalId
            it.title = title
            it.category = category
            it.manager = manager
            it.content = content
            it.url = url
            it.imgUrl = imgUrl
            it.beginDe = beginDe
            it.endDe = endDe
            it.partcptExpnInfo = partcptExpnInfo
            it.telnoInfo = telnoInfo
            it.status = status
            it.region = region
            it.regionDetail = regionDetail
            it.place = place
            it.placeAddress = placeAddress
        }
    }

    class FestivalBuilder {
        private var id: Long? = null
        private var member: Member? = null
        private var providerType: ProviderType? = null
        private var externalId: String? = null
        private var title: String? = null
        private var category: String? = null
        private var manager: String? = null
        private var content: String? = null
        private var url: String? = null
        private var imgUrl: String? = null
        private var beginDe: LocalDateTime? = null
        private var endDe: LocalDateTime? = null
        private var partcptExpnInfo: String? = null
        private var telnoInfo: String? = null
        private var status: FestivalStatus? = null
        private var region: FestivalRegion? = null
        private var regionDetail: String? = null
        private var place: String? = null
        private var placeAddress: String? = null

        fun id(id: Long?): FestivalBuilder = apply { this.id = id }
        fun member(member: Member?): FestivalBuilder = apply { this.member = member }
        fun providerType(providerType: ProviderType?): FestivalBuilder = apply { this.providerType = providerType }
        fun externalId(externalId: String?): FestivalBuilder = apply { this.externalId = externalId }
        fun title(title: String?): FestivalBuilder = apply { this.title = title }
        fun category(category: String?): FestivalBuilder = apply { this.category = category }
        fun manager(manager: String?): FestivalBuilder = apply { this.manager = manager }
        fun content(content: String?): FestivalBuilder = apply { this.content = content }
        fun url(url: String?): FestivalBuilder = apply { this.url = url }
        fun imgUrl(imgUrl: String?): FestivalBuilder = apply { this.imgUrl = imgUrl }
        fun beginDe(beginDe: LocalDateTime?): FestivalBuilder = apply { this.beginDe = beginDe }
        fun endDe(endDe: LocalDateTime?): FestivalBuilder = apply { this.endDe = endDe }
        fun partcptExpnInfo(partcptExpnInfo: String?): FestivalBuilder = apply { this.partcptExpnInfo = partcptExpnInfo }
        fun telnoInfo(telnoInfo: String?): FestivalBuilder = apply { this.telnoInfo = telnoInfo }
        fun status(status: FestivalStatus?): FestivalBuilder = apply { this.status = status }
        fun region(region: FestivalRegion?): FestivalBuilder = apply { this.region = region }
        fun regionDetail(regionDetail: String?): FestivalBuilder = apply { this.regionDetail = regionDetail }
        fun place(place: String?): FestivalBuilder = apply { this.place = place }
        fun placeAddress(placeAddress: String?): FestivalBuilder = apply { this.placeAddress = placeAddress }

        fun build(): Festival = Festival().also {
            it.id = id
            it.member = member
            it.providerType = providerType
            it.externalId = externalId
            it.title = title
            it.category = category
            it.manager = manager
            it.content = content
            it.url = url
            it.imgUrl = imgUrl
            it.beginDe = beginDe
            it.endDe = endDe
            it.partcptExpnInfo = partcptExpnInfo
            it.telnoInfo = telnoInfo
            it.status = status
            it.region = region
            it.regionDetail = regionDetail
            it.place = place
            it.placeAddress = placeAddress
        }
    }
}
