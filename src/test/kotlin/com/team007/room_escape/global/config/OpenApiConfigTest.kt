package com.team007.room_escape.global.config

import io.swagger.v3.oas.models.security.SecurityScheme
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test

class OpenApiConfigTest {

    private val openApi = OpenApiConfig().openAPI()

    @Test
    fun `문서 제목과 버전과 인증 안내를 담는다`() {
        assertThat(openApi.info.title).isEqualTo("roomescape API")
        assertThat(openApi.info.version).isEqualTo("v1")
        assertThat(openApi.info.description).contains("Access Token")
    }

    @Test
    fun `JWT Bearer 인증 방식을 Authorization 헤더로 등록한다`() {
        val scheme = requireNotNull(openApi.components.securitySchemes[OpenApiConfig.BEARER_SCHEME])

        assertThat(scheme.type).isEqualTo(SecurityScheme.Type.HTTP)
        assertThat(scheme.scheme).isEqualTo("bearer")
        assertThat(scheme.bearerFormat).isEqualTo("JWT")
        assertThat(scheme.`in`).isEqualTo(SecurityScheme.In.HEADER)
        assertThat(scheme.name).isEqualTo("Authorization")
    }

    @Test
    fun `모든 API에 Bearer 인증을 기본으로 요구한다`() {
        assertThat(openApi.security.map { it.keys }).containsExactly(mutableSetOf(OpenApiConfig.BEARER_SCHEME))
    }
}
