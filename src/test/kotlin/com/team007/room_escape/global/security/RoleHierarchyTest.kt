package com.team007.room_escape.global.security

import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.params.ParameterizedTest
import org.junit.jupiter.params.provider.CsvSource
import org.springframework.security.core.authority.SimpleGrantedAuthority

class RoleHierarchyTest {

    private val hierarchy = SecurityConfig.roleHierarchy()

    private fun reachableFrom(role: String): List<String> =
        hierarchy.getReachableGrantedAuthorities(listOf(SimpleGrantedAuthority(role))).mapNotNull { it.authority }

    @ParameterizedTest(name = "{0}은 {1}의 권한을 포함한다")
    @CsvSource(
        "ROLE_ADMIN,ROLE_TRUSTED", "ROLE_ADMIN,ROLE_RECOGNIZED", "ROLE_ADMIN,ROLE_UNVERIFIED", "ROLE_ADMIN,ROLE_WARNING",
        "ROLE_TRUSTED,ROLE_RECOGNIZED", "ROLE_TRUSTED,ROLE_UNVERIFIED", "ROLE_TRUSTED,ROLE_WARNING",
        "ROLE_RECOGNIZED,ROLE_UNVERIFIED", "ROLE_RECOGNIZED,ROLE_WARNING",
        "ROLE_UNVERIFIED,ROLE_WARNING",
    )
    fun `상위 등급은 하위 등급의 권한을 포함한다`(upper: String, lower: String) {
        assertThat(reachableFrom(upper)).contains(lower)
    }

    @ParameterizedTest(name = "{0}은 {1}의 권한이 없다")
    @CsvSource(
        "ROLE_WARNING,ROLE_UNVERIFIED", "ROLE_UNVERIFIED,ROLE_RECOGNIZED",
        "ROLE_RECOGNIZED,ROLE_TRUSTED", "ROLE_TRUSTED,ROLE_ADMIN",
    )
    fun `하위 등급은 상위 등급의 권한이 없다`(lower: String, upper: String) {
        assertThat(reachableFrom(lower)).doesNotContain(upper)
    }
}
