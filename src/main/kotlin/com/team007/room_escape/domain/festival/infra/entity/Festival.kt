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
class Festival(
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
    district: String? = null,
    regionDetail: String? = null,
    place: String? = null,
    placeAddress: String? = null,
) : SoftDeletableEntity() {
    @field:jakarta.persistence.Version
    @field:Column(nullable = false)
    var version: Long = 0
        protected set

    @field:Id
    @field:GeneratedValue(strategy = GenerationType.IDENTITY)
    var id: Long? = id
        protected set

    /** 저장된 행사의 ID. 저장 전이면 어떤 행사인지 알려주는 예외를 던진다. */
    val requiredId: Long
        get() = checkNotNull(id) { "저장되지 않은 행사입니다: $title" }

    @field:ManyToOne(fetch = FetchType.LAZY)
    @field:JoinColumn(name = "member_id")
    var member: Member? = member
        protected set

    @field:Enumerated(EnumType.STRING)
    @field:Column(name = "provider_type", nullable = false, length = 32)
    var providerType: ProviderType? = providerType
        protected set

    @field:Column(name = "external_id", length = 64)
    var externalId: String? = externalId
        protected set

    var title: String? = title
        protected set

    var category: String? = category
        protected set

    var manager: String? = manager
        protected set

    @field:Column(columnDefinition = "text")
    var content: String? = content
        protected set

    @field:Column(length = 2048)
    var url: String? = url
        protected set

    @field:Column(name = "img_url", length = 2048)
    var imgUrl: String? = imgUrl
        protected set

    @field:Column(name = "begin_de")
    var beginDe: LocalDateTime? = beginDe
        protected set

    @field:Column(name = "end_de")
    var endDe: LocalDateTime? = endDe
        protected set

    @field:Column(name = "partcpt_expn_info", columnDefinition = "text")
    var partcptExpnInfo: String? = partcptExpnInfo
        protected set

    @field:Column(name = "telno_info", columnDefinition = "text")
    var telnoInfo: String? = telnoInfo
        protected set

    @field:Enumerated(EnumType.STRING)
    @field:Column(length = 32)
    var status: FestivalStatus? = status
        protected set

    @field:Enumerated(EnumType.STRING)
    @field:Column(name = "region", length = 32)
    var region: FestivalRegion? = region
        protected set

    @field:Column(length = 80)
    var district: String? = district
        protected set

    @field:Column(name = "region_detail", columnDefinition = "text")
    var regionDetail: String? = regionDetail
        protected set

    @field:Column(columnDefinition = "text")
    var place: String? = place
        protected set

    @field:Column(name = "place_address", columnDefinition = "text")
    var placeAddress: String? = placeAddress
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
        beginDe: LocalDateTime?, endDe: LocalDateTime?, partcptExpnInfo: String?, telnoInfo: String?,
        district: String? = if (region == this.region) this.district else null
    ) {
        this.district = district
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
}
