package com.team007.room_escape.domain.weather.infra.client

import org.springframework.boot.context.properties.ConfigurationProperties

@ConfigurationProperties(prefix = "public-api.weather")
data class KmaWeatherProperties(
    val url: String,
    val serviceKey: String
)
