package com.team007.room_escape.domain.weather.service

import com.team007.room_escape.domain.festival.infra.entity.FestivalRegion
import com.team007.room_escape.domain.weather.dto.WeatherCondition
import com.team007.room_escape.domain.weather.dto.WeatherResponse
import com.team007.room_escape.domain.weather.infra.client.KmaWeatherApiClient
import com.team007.room_escape.domain.weather.infra.client.WeatherRegionMapping
import com.team007.room_escape.domain.weather.infra.dto.ShortTermForecastItem
import com.team007.room_escape.global.util.trimLikeJava
import org.slf4j.LoggerFactory
import org.springframework.stereotype.Service
import java.time.Duration
import java.time.LocalDate
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter
import kotlin.math.abs

/**
 * 기상청 단기예보 기반 날씨 조회.
 * 미래 날짜의 제공 범위는 고정 일수로 정하지 않고, KMA 응답에 해당 날짜 데이터가 있는지로 자연히 정해진다.
 * 외부 API 실패도 화면이 깨지면 안 되는 부가 기능이라, 예외를 던지지 않고 UNKNOWN으로 감싸서 돌려준다.
 */
@Service
class WeatherService(
    private val client: KmaWeatherApiClient
) {

    private val log = LoggerFactory.getLogger(javaClass)

    fun getWeather(region: FestivalRegion, date: LocalDate): WeatherResponse {
        // 과거 날짜만 막는다. 미래 상한은 KMA 응답에 그 날짜 데이터가 있는지로 shortTerm() 안에서 자연히 정해진다.
        if (date.isBefore(LocalDate.now())) {
            return WeatherResponse.unknown(date)
        }
        try {
            return shortTerm(region, date)
        } catch (e: Exception) {
            // API 호출·파싱 실패 격리. 날씨는 부가 기능이라 실패해도 UNKNOWN으로 조용히 처리
            log.warn("날씨 조회 실패 (region={}, date={})", region, date, e)
            return WeatherResponse.unknown(date)
        }
    }

    private fun shortTerm(region: FestivalRegion, date: LocalDate): WeatherResponse {
        // 지역 → 격자 좌표 변환
        val point = WeatherRegionMapping.resolve(region)
        // 현재 시각 기준 가장 최근 발표 회차 산출
        val base = resolveBase(LocalDateTime.now())

        val items = client.fetchShortTerm(
            point.nx, point.ny,
            base.format(DATE_FORMAT), "%02d00".format(base.hour)
        )

        val targetDate = date.format(DATE_FORMAT)
        // 하늘상태·강수형태·강수확률 추출
        val sky = pickValue(items, targetDate, "SKY")
        val pty = pickValue(items, targetDate, "PTY")
        if (sky == null && pty == null) {
            return WeatherResponse.unknown(date)
        }
        return WeatherResponse(toCondition(sky, pty), parseInt(pickValue(items, targetDate, "POP")), date)
    }

    /** 해당 날짜의 하루 대표값 선정. 정오(12시)와 가장 가까운 발표시각의 값 채택 */
    private fun pickValue(items: List<ShortTermForecastItem>, targetDate: String, category: String): String? {
        return items
            .filter { item -> item.fcstDate == targetDate && item.category == category }
            .minByOrNull { item -> abs(item.fcstTime.substring(0, 2).toInt() - 12) }
            ?.fcstValue
    }

    /** SKY/PTY 코드 → WeatherCondition 매핑. 강수형태(PTY)가 하늘상태(SKY)보다 우선 판단 */
    private fun toCondition(sky: String?, pty: String?): WeatherCondition {
        if (pty != null) {
            when (pty) {
                "1", "4", "5" -> return WeatherCondition.RAIN // 비, 소나기, 빗방울
                "2", "6" -> return WeatherCondition.RAIN_SNOW // 비/눈, 빗방울눈날림
                "3", "7" -> return WeatherCondition.SNOW // 눈, 눈날림
                else -> {
                    // "0"(강수 없음)이면 SKY로 판단 계속
                }
            }
        }
        if (sky != null) {
            return when (sky) {
                "1" -> WeatherCondition.SUNNY
                "3", "4" -> WeatherCondition.CLOUDY
                else -> WeatherCondition.UNKNOWN
            }
        }
        return WeatherCondition.UNKNOWN
    }

    /** 문자열 → 정수 안전 변환. 형식 오류 시 null 반환 */
    private fun parseInt(value: String?): Int? {
        if (value == null) {
            return null
        }
        try {
            // Java String.trim()과 같은 기준(U+0020 이하)으로 자른다.
            return value.trimLikeJava().toInt()
        } catch (e: NumberFormatException) {
            return null
        }
    }

    /** 발표 후 10분 지연 반영, 이미 발표 완료된 가장 최근 회차 계산 */
    private fun resolveBase(now: LocalDateTime): LocalDateTime {
        val cutoff = now.minus(PUBLISH_DELAY)
        return BASE_HOURS
            .map { hour -> cutoff.toLocalDate().atTime(hour, 0) }
            .filter { candidate -> !candidate.isAfter(cutoff) }
            .maxOrNull()
            // 오늘 02시 발표(-10분 여유)보다 이른 새벽이면 전날 23시 발표로 대체
            ?: cutoff.toLocalDate().minusDays(1).atTime(23, 0)
    }

    companion object {

        private val DATE_FORMAT: DateTimeFormatter = DateTimeFormatter.ofPattern("yyyyMMdd")

        /** 단기예보 발표 시간 (하루 8회 -> 3시간 주기) */
        private val BASE_HOURS = intArrayOf(2, 5, 8, 11, 14, 17, 20, 23)

        /** 발표 후 실제 조회 가능해지기까지의 지연 */
        private val PUBLISH_DELAY: Duration = Duration.ofMinutes(10)
    }
}
