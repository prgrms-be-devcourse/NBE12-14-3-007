package com.team007.room_escape.global.security

import org.springframework.security.core.GrantedAuthority
import org.springframework.security.core.authority.SimpleGrantedAuthority
import org.springframework.security.core.userdetails.UserDetails
import java.util.UUID

/**
 * SecurityContext에 들어가는 로그인 사용자.
 * JWT 필터가 클레임으로 만들며 password는 로그인 시에만 채우고, 토큰 복원 시에는 null이다.
 * 컨트롤러에서는 @AuthenticationPrincipal 로 id, nickname, role, profileImg를 꺼낸다.
 */
class CustomUserDetails(
    val id: UUID,
    val nickname: String,
    val role: String,
    val profileImg: String?,
    private val password: String?
) : UserDetails {

    fun isAdmin(): Boolean {
        return "ROLE_ADMIN" == role
    }

    override fun getAuthorities(): Collection<GrantedAuthority> {
        return listOf(SimpleGrantedAuthority(role))
    }

    override fun getPassword(): String? {
        return password
    }

    override fun getUsername(): String {
        return nickname
    }

    override fun isAccountNonExpired(): Boolean {
        return true
    }

    override fun isAccountNonLocked(): Boolean {
        return true
    }

    override fun isCredentialsNonExpired(): Boolean {
        return true
    }

    override fun isEnabled(): Boolean {
        return true
    }
}
