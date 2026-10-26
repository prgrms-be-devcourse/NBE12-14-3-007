package com.team007.room_escape.domain.festival.infra.client

import com.team007.room_escape.domain.festival.infra.dto.CultureInfoDetailRow
import com.team007.room_escape.domain.festival.infra.dto.CultureInfoPeriodRow
import com.team007.room_escape.global.exception.BusinessException
import com.team007.room_escape.global.response.code.FestivalExceptionCode
import java.net.URI
import java.nio.charset.StandardCharsets
import java.time.Duration
import org.slf4j.LoggerFactory
import org.springframework.boot.context.properties.EnableConfigurationProperties
import org.springframework.http.client.SimpleClientHttpRequestFactory
import org.springframework.stereotype.Component
import org.springframework.web.client.RestClient
import org.springframework.web.util.UriComponentsBuilder
import tools.jackson.dataformat.xml.XmlMapper

/** 전국 문화정보 API(period2/detail2) 호출·파싱. */
@Component
@EnableConfigurationProperties(FestivalPublicApiPropertiesV2::class)
class FestivalPublicApiClientV2(
    /** application.yaml에서 읽어온 url/serviceKey. */
    private val properties: FestivalPublicApiPropertiesV2
) {
    private val log = LoggerFactory.getLogger(javaClass)

    /** 실제로 HTTP 요청을 날리는 스프링 도구. 한 번 만들어두고 모든 요청에 재사용해 (요청마다 새로 안 만듦) */
    private val restClient: RestClient = RestClient.builder()
        .requestFactory(timeoutRequestFactory())
        .build()

    /** XML 텍스트를 자바 객체로 바꿔주는 도구 */
    private val xmlMapper = XmlMapper()

    private fun timeoutRequestFactory(): SimpleClientHttpRequestFactory {
        val requestFactory = SimpleClientHttpRequestFactory()
        // 연결 타임아웃(connectTimeout): 서버에 연결 자체가 안 될 때 얼마나 기다릴지
        requestFactory.setConnectTimeout(REQUEST_TIMEOUT.toMillis().toInt())
        // 읽기 타임아웃(readTimeout): 연결은 됐는데 응답이 안 올 때 얼마나 기다릴지
        requestFactory.setReadTimeout(REQUEST_TIMEOUT.toMillis().toInt())
        return requestFactory
    }

    /** 기간 내 행사 목록을 받아온다 (전체 타입: 공연/전시, 행사/축제, 교육/체험). 상세 정보는 없고 seq/title만 들어있다. */
    fun fetchPeriod(pageNo: Int, numOfRows: Int, from: String, to: String): List<CultureInfoPeriodRow> {
        val xml = callApi(buildPeriodUri(pageNo, numOfRows, from, to))
        return parseItems(xml, CultureInfoPeriodRow::class.java)
    }

    /** 신규로 판별된 행사 하나의 상세 정보를 받아온다. 없으면 null. */
    fun fetchDetail(seq: String): CultureInfoDetailRow? {
        val xml = callApi(buildDetailUri(seq))
        val items = parseItems(xml, CultureInfoDetailRow::class.java)
        return if (items.isEmpty()) null else items[0]
    }

    private fun callApi(uri: URI): String? {
        return try {
            // Content-Type에 charset이 없어서 문자열로 바로 받으면 한글이 깨진다. 바이트로 받아 UTF-8로 직접 디코딩한다.
            val body = restClient.get().uri(uri).retrieve().body(ByteArray::class.java)
            if (body == null) null else String(body, StandardCharsets.UTF_8)
        } catch (e: Exception) {
            log.error("[{}] 전국 문화정보 API 호출 실패", FestivalExceptionCode.PUBLIC_API_CALL_FAILED.code, e)
            throw BusinessException(FestivalExceptionCode.PUBLIC_API_CALL_FAILED)
        }
    }

    /** item이 1건뿐이면 배열이 아니라 단일 객체로 오기도 해서, 배열/단일 둘 다 받아들이게 처리한다. */
    private fun <T> parseItems(xml: String?, rowType: Class<T>): List<T> =
        try {
            val root = xmlMapper.readTree(xml)
            val itemNode = root.findPath("item")
            if (itemNode.isMissingNode) {
                return emptyList()
            }
            if (itemNode.isArray) {
                val rows = mutableListOf<T>()
                itemNode.forEach { node -> rows.add(xmlMapper.convertValue(node, rowType)) }
                rows
            } else {
                listOf(xmlMapper.convertValue(itemNode, rowType))
            }
        } catch (e: Exception) {
            log.error("[{}] 전국 문화정보 API 응답 파싱 실패", FestivalExceptionCode.PUBLIC_API_PARSE_FAILED.code, e)
            throw BusinessException(FestivalExceptionCode.PUBLIC_API_PARSE_FAILED)
        }

    private fun buildPeriodUri(pageNo: Int, numOfRows: Int, from: String, to: String): URI =
        UriComponentsBuilder.fromUriString(properties.url)
            .path("/period2")
            .queryParam("serviceKey", properties.serviceKey)
            .queryParam("PageNo", pageNo)
            .queryParam("numOfrows", numOfRows)
            .queryParam("from", from)
            .queryParam("to", to)
            .build()
            .toUri()

    private fun buildDetailUri(seq: String): URI =
        UriComponentsBuilder.fromUriString(properties.url)
            .path("/detail2")
            .queryParam("serviceKey", properties.serviceKey)
            .queryParam("seq", seq)
            .build()
            .toUri()

    companion object {
        /** 요청 응답 시간이 30초 이상일 경우 포기 */
        private val REQUEST_TIMEOUT: Duration = Duration.ofSeconds(30)
    }
}
