package com.team007.room_escape.global.jwt

import org.springframework.boot.context.properties.ConfigurationProperties

/**
 * application.yaml의 jwt.* 설정 바인딩.
 * Access/Refresh 서명 키와 만료 시간을 담는다.
 */
@ConfigurationProperties(prefix = "jwt")
data class JwtProperties(
    val secret: String,
    val issuer: String,
    val accessTokenValiditySeconds: Long,
    val refreshSecret: String,
    val refreshTokenValiditySeconds: Long,
)
