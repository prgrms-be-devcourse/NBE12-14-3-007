package com.team007.room_escape.domain.festival.infra.dto

import com.team007.room_escape.domain.festival.infra.entity.Festival
import com.team007.room_escape.domain.festival.infra.entity.FestivalRegion
import com.team007.room_escape.domain.festival.infra.entity.FestivalStatus
import com.team007.room_escape.domain.festival.infra.entity.ProviderType
import java.time.LocalDate
import java.time.LocalDateTime
import java.time.LocalTime
import java.time.format.DateTimeFormatter
import tools.jackson.dataformat.xml.annotation.JacksonXmlProperty

/** /detail2 응답의 item 1건. */
@JvmRecord
data class CultureInfoDetailRow(
    @JacksonXmlProperty(localName = "seq") val seq: String?,
    @JacksonXmlProperty(localName = "title") val title: String?,
    @JacksonXmlProperty(localName = "startDate") val startDate: String?,
    @JacksonXmlProperty(localName = "endDate") val endDate: String?,
    @JacksonXmlProperty(localName = "place") val place: String?,
    @JacksonXmlProperty(localName = "realmName") val realmName: String?,
    @JacksonXmlProperty(localName = "area") val area: String?,
    @JacksonXmlProperty(localName = "sigungu") val sigungu: String?,
    @JacksonXmlProperty(localName = "price") val price: String?,
    @JacksonXmlProperty(localName = "contents1") val contents1: String?,
    @JacksonXmlProperty(localName = "url") val url: String?,
    @JacksonXmlProperty(localName = "phone") val phone: String?,
    @JacksonXmlProperty(localName = "imgUrl") val imgUrl: String?,
    @JacksonXmlProperty(localName = "placeAddr") val placeAddr: String?
) {

    /** 전국 문화정보 API 행 1건을 공공 행사 엔티티로 바꾼다. 이미지는 서비스가 R2에 올린 뒤 URL만 넘겨준다. */
    fun toFestival(processedImgUrl: String?): Festival {
        val begin = parseDate(startDate)
        val end = parseEndDate(endDate)

        return Festival(
            providerType = ProviderType.PUBLIC,
            externalId = seq,
            title = title,
            category = realmName,
            content = contents1,
            url = url,
            telnoInfo = phone,
            partcptExpnInfo = price,
            imgUrl = processedImgUrl,
            beginDe = begin,
            endDe = end,
            status = FestivalStatus.from(end),
            region = FestivalRegion.fromDisplayName(area),
            regionDetail = sigungu,
            place = place,
            placeAddress = placeAddr,
        )
    }

    companion object {
        private val API_DATE_FORMAT: DateTimeFormatter = DateTimeFormatter.ofPattern("yyyyMMdd")

        /** yyyyMMdd 문자열을 날짜로 바꾼다. 비어 있으면 null. */
        private fun parseDate(yyyyMMdd: String?): LocalDateTime? {
            if (yyyyMMdd.isNullOrBlank()) {
                return null
            }
            return LocalDate.parse(yyyyMMdd, API_DATE_FORMAT).atStartOfDay()
        }

        /** 종료일은 그날 23:59:59까지로 해석한다. 마지막 날 자정에 종료 처리되는 걸 막는다. */
        private fun parseEndDate(yyyyMMdd: String?): LocalDateTime? {
            if (yyyyMMdd.isNullOrBlank()) {
                return null
            }
            return LocalDate.parse(yyyyMMdd, API_DATE_FORMAT).atTime(LocalTime.MAX)
        }
    }
}
