package com.team007.room_escape.global.config

import io.swagger.v3.oas.models.Components
import io.swagger.v3.oas.models.OpenAPI
import io.swagger.v3.oas.models.info.Info
import io.swagger.v3.oas.models.security.SecurityRequirement
import io.swagger.v3.oas.models.security.SecurityScheme
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration

/**
 * Swagger(OpenAPI) 문서 설정.
 * UI 우측 상단 Authorize에 JWT를 넣으면 이후 요청에 Authorization: Bearer 가 붙는다.
 */
@Configuration
class OpenApiConfig {

    @Bean
    fun openAPI(): OpenAPI {
        val bearer = SecurityScheme()
            .type(SecurityScheme.Type.HTTP)
            .scheme("bearer")
            .bearerFormat("JWT")
            .`in`(SecurityScheme.In.HEADER)
            .name("Authorization")
        val info = Info()
            .title("roomescape API")
            .version("v1")
            .description("Access Token을 Authorize에 넣으면 됩니다. Bearer 접두사는 자동으로 붙습니다.")

        return OpenAPI()
            .info(info)
            .components(Components().addSecuritySchemes(BEARER_SCHEME, bearer))
            .addSecurityItem(SecurityRequirement().addList(BEARER_SCHEME))
    }

    companion object {
        const val BEARER_SCHEME = "bearerAuth"
    }
}
