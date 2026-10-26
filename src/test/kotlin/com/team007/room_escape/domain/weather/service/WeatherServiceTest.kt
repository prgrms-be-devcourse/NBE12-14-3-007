package com.team007.room_escape.domain.weather.service

import com.team007.room_escape.domain.festival.infra.entity.FestivalRegion
import com.team007.room_escape.domain.weather.dto.WeatherCondition
import com.team007.room_escape.domain.weather.infra.client.KmaWeatherApiClient
import com.team007.room_escape.domain.weather.infra.dto.ShortTermForecastItem
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test
import org.mockito.Mockito.mock
import java.time.LocalDate
import java.time.format.DateTimeFormatter

class WeatherServiceTest {

    private val today = LocalDate.now()
    private val todayText = today.format(DateTimeFormatter.ofPattern("yyyyMMdd"))

    /** 기상청 호출을 가짜로 바꾼다. 받은 인자를 [calls]에 남기고, [items]나 [failure]를 돌려준다. */
    private class FakeClient(
        var items: List<ShortTermForecastItem> = emptyList(),
        var failure: RuntimeException? = null,
    ) {
        val calls = mutableListOf<List<Any?>>()

        val mock: KmaWeatherApiClient = mock(KmaWeatherApiClient::class.java) { invocation ->
            calls += invocation.arguments.toList()
            failure?.let { throw it }
            items
        }
    }

    private fun item(category: String, time: String, value: String, date: String = todayText) =
        ShortTermForecastItem(category, date, time, value)

    private fun weather(client: FakeClient, date: LocalDate = today) =
        WeatherService(client.mock).getWeather(FestivalRegion.SEOUL, date)

    @Test
    fun `발표 회차는 정각 HH00 형식으로 기상청에 요청한다`() {
        val client = FakeClient()

        weather(client)

        val (_, _, baseDate, baseTime) = client.calls.single()
        assertThat(baseDate.toString()).matches("\\d{8}")
        // 발표 시각은 02 05 08 11 14 17 20 23시 중 하나이고, 분은 항상 00이다.
        assertThat(baseTime.toString()).matches("(02|05|08|11|14|17|20|23)00")
    }

    @Test
    fun `하늘 상태와 강수 형태 중 강수 형태를 먼저 본다`() {
        val client = FakeClient(listOf(item("SKY", "1200", "1"), item("PTY", "1200", "1"), item("POP", "1200", "70")))

        val result = weather(client)

        assertThat(result.condition).isEqualTo(WeatherCondition.RAIN)
        assertThat(result.precipitationProbability).isEqualTo(70)
        assertThat(result.date).isEqualTo(today)
    }

    @Test
    fun `강수가 없으면 하늘 상태로 맑음 또는 흐림을 정한다`() {
        assertThat(weather(FakeClient(listOf(item("SKY", "1200", "1"), item("PTY", "1200", "0")))).condition)
            .isEqualTo(WeatherCondition.SUNNY)
        assertThat(weather(FakeClient(listOf(item("SKY", "1200", "4"), item("PTY", "1200", "0")))).condition)
            .isEqualTo(WeatherCondition.CLOUDY)
    }

    @Test
    fun `비눈과 눈은 강수 형태 코드로 구분한다`() {
        assertThat(weather(FakeClient(listOf(item("PTY", "1200", "2")))).condition).isEqualTo(WeatherCondition.RAIN_SNOW)
        assertThat(weather(FakeClient(listOf(item("PTY", "1200", "3")))).condition).isEqualTo(WeatherCondition.SNOW)
    }

    @Test
    fun `하루 대표값은 정오에 가장 가까운 예보 시각의 값이다`() {
        val client = FakeClient(
            listOf(item("SKY", "0600", "4"), item("SKY", "1300", "1"), item("SKY", "2100", "4"), item("PTY", "1300", "0")),
        )

        assertThat(weather(client).condition).isEqualTo(WeatherCondition.SUNNY)
    }

    @Test
    fun `다른 날짜의 예보는 무시하고 해당 날짜 데이터가 없으면 알 수 없음이다`() {
        val client = FakeClient(listOf(item("SKY", "1200", "1", date = "19990101")))

        assertThat(weather(client).condition).isEqualTo(WeatherCondition.UNKNOWN)
    }

    @Test
    fun `강수확률이 숫자가 아니면 null이다`() {
        val client = FakeClient(listOf(item("SKY", "1200", "1"), item("POP", "1200", "없음")))

        assertThat(weather(client).precipitationProbability).isNull()
    }

    @Test
    fun `지난 날짜는 기상청을 부르지 않고 알 수 없음이다`() {
        val client = FakeClient()

        val result = weather(client, today.minusDays(1))

        assertThat(result.condition).isEqualTo(WeatherCondition.UNKNOWN)
        assertThat(client.calls).isEmpty()
    }

    @Test
    fun `기상청 호출이 실패해도 예외 없이 알 수 없음이다`() {
        val client = FakeClient(failure = IllegalStateException("연결 실패"))

        val result = weather(client)

        assertThat(result.condition).isEqualTo(WeatherCondition.UNKNOWN)
        assertThat(result.date).isEqualTo(today)
    }
}
