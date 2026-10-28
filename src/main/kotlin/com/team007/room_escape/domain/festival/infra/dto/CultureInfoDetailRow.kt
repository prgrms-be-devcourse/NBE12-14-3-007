package com.team007.room_escape.domain.festival.infra.dto

import com.team007.room_escape.domain.festival.infra.entity.Festival
import com.team007.room_escape.domain.festival.infra.entity.FestivalRegion
import com.team007.room_escape.domain.festival.infra.entity.FestivalStatus
import com.team007.room_escape.domain.festival.infra.entity.ProviderType
import java.time.LocalDate
import java.time.LocalDateTime
import java.time.LocalTime
import java.time.format.DateTimeFormatter
import org.springframework.web.util.HtmlUtils
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
            title = unescapeHtml(title),
            category = realmName,
            content = unescapeHtml(contents1),
            url = url,
            telnoInfo = phone,
            partcptExpnInfo = price,
            imgUrl = processedImgUrl,
            beginDe = begin,
            endDe = end,
            status = FestivalStatus.from(end),
            region = FestivalRegion.fromDisplayName(area),
            regionDetail = sigungu,
            place = unescapeHtml(place),
            placeAddress = placeAddr,
        )
    }

    /** 이미 저장돼 있던 같은 external_id의 행사에, 이번 조회로 받은 최신 내용을 덮어쓴다. */
    fun applyTo(festival: Festival, processedImgUrl: String?) {
        festival.updateFromPublicSource(
            title = unescapeHtml(title),
            category = realmName,
            content = unescapeHtml(contents1),
            url = url,
            telnoInfo = phone,
            partcptExpnInfo = price,
            imgUrl = processedImgUrl,
            beginDe = parseDate(startDate),
            endDe = parseEndDate(endDate),
            region = FestivalRegion.fromDisplayName(area),
            regionDetail = sigungu,
            place = unescapeHtml(place),
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

        /**
         * 공공 API가 title/contents1/place에 &lt;, &amp;, &#39; 같은 HTML 엔티티를 이스케이프해서 보낸다.
         * 간혹 &amp;lsquo; 처럼 이중 이스케이프된 값도 있어 더 이상 안 바뀔 때까지 반복 디코딩한다.
         */
        private fun unescapeHtml(value: String?): String? {
            var result: String = value ?: return null
            while (true) {
                val decoded = HtmlUtils.htmlUnescape(result)
                if (decoded == result) {
                    return result
                }
                result = decoded
            }
        }
    }
}
