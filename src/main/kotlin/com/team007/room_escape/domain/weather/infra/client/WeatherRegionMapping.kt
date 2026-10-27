package com.team007.room_escape.domain.weather.infra.client

import com.team007.room_escape.domain.festival.infra.entity.FestivalRegion
import java.util.EnumMap

/**
 * 17개 시·도를 대표 도시의 기상청 단기예보 격자 좌표로 매핑한다. 격자값은 각 시·도 도청 소재지급
 * 대표 도시 좌표를 기상청 격자 변환 공식으로 계산해, 공개적으로 알려진 값과 대조 검증했다.
 * 날씨는 시·도 단위로만 제공하며, 경기도 시·군(GYEONGGI_* )은 지원하지 않는다.
 */
object WeatherRegionMapping {

    /** EnumMap을 쓴 이유 => key가 FestivalRegion이라는 고정된 enum이기 때문 일반 HashMap보다 내부적으로 배열 기반이라 더 빠름**/
    private val POINTS: MutableMap<FestivalRegion, WeatherRegionPoint> = EnumMap(FestivalRegion::class.java)

    init {
        POINTS[FestivalRegion.SEOUL] = WeatherRegionPoint(60, 127)
        POINTS[FestivalRegion.INCHEON] = WeatherRegionPoint(55, 124)
        POINTS[FestivalRegion.GYEONGGI] = WeatherRegionPoint(61, 120)
        POINTS[FestivalRegion.GANGWON] = WeatherRegionPoint(73, 134)
        POINTS[FestivalRegion.CHUNGBUK] = WeatherRegionPoint(69, 107)
        POINTS[FestivalRegion.CHUNGNAM] = WeatherRegionPoint(62, 110)
        POINTS[FestivalRegion.DAEJEON] = WeatherRegionPoint(67, 100)
        POINTS[FestivalRegion.SEJONG] = WeatherRegionPoint(66, 103)
        POINTS[FestivalRegion.JEONBUK] = WeatherRegionPoint(63, 89)
        POINTS[FestivalRegion.JEONNAM] = WeatherRegionPoint(50, 67)
        // 통합 지역의 날씨는 기존 전남 대표 지점으로 제공한다.
        POINTS[FestivalRegion.JEONNAM_GWANGJU] = WeatherRegionPoint(50, 67)
        POINTS[FestivalRegion.GWANGJU] = WeatherRegionPoint(58, 74)
        POINTS[FestivalRegion.GYEONGBUK] = WeatherRegionPoint(102, 94)
        POINTS[FestivalRegion.DAEGU] = WeatherRegionPoint(89, 91)
        POINTS[FestivalRegion.GYEONGNAM] = WeatherRegionPoint(91, 77)
        POINTS[FestivalRegion.BUSAN] = WeatherRegionPoint(98, 76)
        POINTS[FestivalRegion.ULSAN] = WeatherRegionPoint(102, 84)
        POINTS[FestivalRegion.JEJU] = WeatherRegionPoint(53, 38)
    }

    fun resolve(region: FestivalRegion): WeatherRegionPoint =
        POINTS[region] ?: throw IllegalArgumentException("날씨를 지원하지 않는 지역입니다: $region")
}
