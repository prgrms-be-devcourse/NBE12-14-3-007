package com.team007.room_escape.global.security

import com.team007.room_escape.global.jwt.JwtAuthenticationFilter
import com.team007.room_escape.global.jwt.JwtProperties
import org.springframework.beans.factory.annotation.Value
import org.springframework.boot.context.properties.EnableConfigurationProperties
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.http.HttpMethod
import org.springframework.security.access.hierarchicalroles.RoleHierarchy
import org.springframework.security.access.hierarchicalroles.RoleHierarchyImpl
import org.springframework.security.config.Customizer
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity
import org.springframework.security.config.annotation.web.builders.HttpSecurity
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity
import org.springframework.security.config.http.SessionCreationPolicy
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder
import org.springframework.security.crypto.password.PasswordEncoder
import org.springframework.security.web.SecurityFilterChain
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter
import org.springframework.web.cors.CorsConfiguration
import org.springframework.web.cors.CorsConfigurationSource
import org.springframework.web.cors.UrlBasedCorsConfigurationSource

/**
 * Spring Security 설정.
 * JWT 무상태 세션, /api/v1/auth와 스웨거만 공개, 나머지는 인증 필요.
 * @PreAuthorize 메서드 보안과 BCrypt, CORS도 여기서 연다.
 */
@Configuration
@EnableWebSecurity
@EnableMethodSecurity
@EnableConfigurationProperties(JwtProperties::class, AuthCookieProperties::class)
class SecurityConfig(
    private val jwtAuthenticationFilter: JwtAuthenticationFilter,
    private val authenticationEntryPoint: JwtAuthenticationEntryPoint,
    private val accessDeniedHandler: JwtAccessDeniedHandler,
) {

    @Bean
    fun filterChain(http: HttpSecurity): SecurityFilterChain = http
            .csrf { it.disable() }
            .cors(Customizer.withDefaults())
            .sessionManagement { it.sessionCreationPolicy(SessionCreationPolicy.STATELESS) }
            .authorizeHttpRequests { auth ->
                auth
                    .requestMatchers("/api/v1/auth/**").permitAll()
                    // TODO url 한꺼번에 정리하기 (지금은 공개 API가 늘어날 때마다 규칙을 한 줄씩 추가하고 있음)
                    .requestMatchers(HttpMethod.GET, "/api/v1/festivals/**").permitAll()
                    .requestMatchers(HttpMethod.GET, "/api/v1/posts/**").permitAll()
                    .requestMatchers(HttpMethod.GET, "/api/v1/community/**").permitAll()
                    .requestMatchers(HttpMethod.GET, "/api/v1/weather").permitAll()
                    .requestMatchers("/api/v1/admin/**").hasRole("ADMIN")
                    // 비회원의 R2 용량 남용을 막고, 제재(ROLE_WARNING) 회원은 글쓰기와 같은 기준으로 막는다.
                    .requestMatchers(HttpMethod.POST, "/api/v1/images").hasRole("UNVERIFIED")
                    .requestMatchers("/v3/api-docs/**", "/swagger-ui/**", "/swagger-ui.html").permitAll()
                    // Prometheus가 토큰 없이 긁어갈 수 있어야 한다.
                    // TODO 운영 배포 시에는 관리 포트 분리나 IP 제한으로 외부 노출을 막을 것.
                    .requestMatchers("/actuator/health", "/actuator/prometheus").permitAll()
                    .anyRequest().authenticated()
            }
            .exceptionHandling {
                it.authenticationEntryPoint(authenticationEntryPoint)
                    .accessDeniedHandler(accessDeniedHandler)
            }
            .addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter::class.java)
            .build()

    @Bean
    fun passwordEncoder(): PasswordEncoder = BCryptPasswordEncoder()

    /**
     * 허용 출처는 app.cors.allowed-origins 로 받는다. 값은 프로필 파일에 있다.
     * 로컬은 localhost 프론트, 운영은 CORS_ALLOWED_ORIGINS 환경 변수(쉼표 구분).
     */
    @Bean
    fun corsConfigurationSource(
        @Value("\${app.cors.allowed-origins}") allowedOrigins: List<String>,
    ): CorsConfigurationSource {
        val config = CorsConfiguration().apply {
            this.allowedOrigins = allowedOrigins
            allowedMethods = listOf("GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS")
            allowedHeaders = listOf("*")
            exposedHeaders = listOf("Authorization")
            allowCredentials = true
        }
        return UrlBasedCorsConfigurationSource().apply { registerCorsConfiguration("/**", config) }
    }

    companion object {

        /**
         * 권한 계층. MemberRole enum의 선언 순서와 항상 동일하게 유지할 것.
         * 상위 등급은 하위 등급의 권한을 모두 포함한다.
         */
        @Bean
        @JvmStatic
        fun roleHierarchy(): RoleHierarchy = RoleHierarchyImpl.withDefaultRolePrefix()
            .role("ADMIN").implies("TRUSTED")
            .role("TRUSTED").implies("RECOGNIZED")
            .role("RECOGNIZED").implies("UNVERIFIED")
            .role("UNVERIFIED").implies("WARNING")
            .build()
    }
}
