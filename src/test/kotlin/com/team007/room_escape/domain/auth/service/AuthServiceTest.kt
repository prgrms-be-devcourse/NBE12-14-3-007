package com.team007.room_escape.domain.auth.service

import com.team007.room_escape.domain.auth.dto.AuthRequest
import com.team007.room_escape.domain.member.infra.entity.Member
import com.team007.room_escape.domain.member.infra.entity.MemberRole
import com.team007.room_escape.domain.member.infra.repository.MemberRepository
import com.team007.room_escape.global.exception.BusinessException
import com.team007.room_escape.global.jwt.JwtProperties
import com.team007.room_escape.global.jwt.JwtProvider
import com.team007.room_escape.global.response.code.AuthExceptionCode
import com.team007.room_escape.global.response.code.MemberExceptionCode
import io.jsonwebtoken.JwtException
import org.assertj.core.api.Assertions.assertThat
import org.assertj.core.api.Assertions.assertThatCode
import org.assertj.core.api.Assertions.assertThatThrownBy
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test
import org.mockito.ArgumentCaptor
import org.mockito.ArgumentMatchers.any
import org.mockito.ArgumentMatchers.anyString
import org.mockito.ArgumentMatchers.eq
import org.mockito.Mockito.doThrow
import org.mockito.Mockito.mock
import org.mockito.Mockito.never
import org.mockito.Mockito.verify
import org.mockito.Mockito.`when`
import org.springframework.security.crypto.password.PasswordEncoder
import org.springframework.test.util.ReflectionTestUtils
import java.time.LocalDateTime
import java.util.Optional
import java.util.UUID

class AuthServiceTest {

    private val memberRepository = mock(MemberRepository::class.java)
    private val passwordEncoder = mock(PasswordEncoder::class.java)
    private val refreshTokenService = mock(RefreshTokenService::class.java)
    private val jwtProperties = JwtProperties(
        "access-secret-access-secret-access-secret", "roomescape", 3_600,
        "refresh-secret-refresh-secret-refresh-secret", 7_200,
    )
    private val jwtProvider = JwtProvider(jwtProperties)
    private val service = AuthService(memberRepository, passwordEncoder, jwtProvider, jwtProperties, refreshTokenService)

    private val memberId = UUID.randomUUID()

    // Kotlin 서비스의 non-null 파라미터에는 Mockito 매처가 돌려주는 null을 넣을 수 없어서, 자리표시 값을 대신 넘긴다.
    private fun anyMember(): Member = any(Member::class.java) ?: member()
    private fun anyUuid(): UUID = any(UUID::class.java) ?: UUID(0, 0)
    private fun anyTime(): LocalDateTime = any(LocalDateTime::class.java) ?: LocalDateTime.MIN
    private fun anyText(): String = anyString() ?: ""

    private fun member(role: MemberRole = MemberRole.ROLE_UNVERIFIED, nickname: String = "닉네임"): Member =
        Member.builder().email("user@example.com").password("ENCODED").nickname(nickname).role(role).build()
            .also { ReflectionTestUtils.setField(it, "id", memberId) }

    private fun signup(email: String = "user@example.com", phone: String? = null) =
        AuthRequest.Signup(email, "Password1!", "닉네임", phone)

    private fun org.assertj.core.api.AbstractThrowableAssert<*, *>.isBusiness(code: Enum<*>) {
        isInstanceOfSatisfying(BusinessException::class.java) {
            assertThat(it.exceptionCode).isEqualTo(code)
        }
    }

    @Nested
    inner class `회원가입` {

        private fun savedMember(): Member {
            val captor = ArgumentCaptor.forClass(Member::class.java)
            verify(memberRepository).save(captor.capture())
            return captor.value
        }

        private fun stubSave() {
            `when`(memberRepository.save(any(Member::class.java))).thenAnswer { it.arguments[0] }
            `when`(passwordEncoder.encode("Password1!")).thenReturn("ENCODED")
        }

        @Test
        fun `비밀번호를 인코딩해서 미인증 등급으로 저장한다`() {
            stubSave()

            service.signup(signup(phone = "01012345678"))

            val saved = savedMember()
            assertThat(saved.email).isEqualTo("user@example.com")
            assertThat(saved.password).isEqualTo("ENCODED")
            assertThat(saved.nickname).isEqualTo("닉네임")
            assertThat(saved.phone).isEqualTo("01012345678")
            assertThat(saved.role).isEqualTo(MemberRole.ROLE_UNVERIFIED)
        }

        @Test
        fun `전화번호가 비었거나 공백이면 null로 저장한다`() {
            stubSave()

            service.signup(signup(phone = ""))

            assertThat(savedMember().phone).isNull()
        }

        @Test
        fun `쓰는 중인 이메일이면 이메일 중복으로 거절하고 저장하지 않는다`() {
            `when`(memberRepository.existsByEmail("user@example.com")).thenReturn(true)
            `when`(memberRepository.existsByEmailAndDeletedAtIsNull("user@example.com")).thenReturn(true)

            assertThatThrownBy { service.signup(signup()) }.isBusiness(MemberExceptionCode.EMAIL_DUPLICATED)
            verify(memberRepository, never()).save(any(Member::class.java))
        }

        @Test
        fun `탈퇴한 회원의 이메일이면 탈퇴 안내로 거절한다`() {
            `when`(memberRepository.existsByEmail("user@example.com")).thenReturn(true)
            `when`(memberRepository.existsByEmailAndDeletedAtIsNull("user@example.com")).thenReturn(false)

            assertThatThrownBy { service.signup(signup()) }.isBusiness(MemberExceptionCode.EMAIL_WITHDRAWN)
            verify(memberRepository, never()).save(any(Member::class.java))
        }

        @Test
        fun `닉네임이 겹치면 거절한다`() {
            `when`(memberRepository.existsByNicknameAndDeletedAtIsNull("닉네임")).thenReturn(true)

            assertThatThrownBy { service.signup(signup()) }.isBusiness(MemberExceptionCode.NICKNAME_DUPLICATED)
            verify(memberRepository, never()).save(any(Member::class.java))
        }
    }

    @Nested
    inner class `로그인` {

        @Test
        fun `맞는 비밀번호면 액세스와 리프레시 토큰을 만들고 리프레시를 저장한다`() {
            val member = member(MemberRole.ROLE_TRUSTED)
            `when`(memberRepository.findByEmailAndDeletedAtIsNull("user@example.com")).thenReturn(Optional.of(member))
            `when`(passwordEncoder.matches("Password1!", "ENCODED")).thenReturn(true)
            val before = LocalDateTime.now()

            val pair = service.login("user@example.com", "Password1!")

            val access = jwtProvider.parse(pair.accessToken)
            assertThat(access.subject).isEqualTo(memberId.toString())
            assertThat(access.get("role", String::class.java)).isEqualTo("ROLE_TRUSTED")
            assertThat(jwtProvider.parseRefresh(pair.refreshToken).subject).isEqualTo(memberId.toString())

            val expiry = ArgumentCaptor.forClass(LocalDateTime::class.java)
            verify(refreshTokenService).save(
                eq(member) ?: member, eq(pair.refreshToken) ?: "", expiry.capture() ?: LocalDateTime.MIN,
            )
            assertThat(expiry.value).isBetween(before.plusSeconds(7_200), LocalDateTime.now().plusSeconds(7_200))
        }

        @Test
        fun `비밀번호가 틀리면 아이디 또는 비밀번호 오류다`() {
            `when`(memberRepository.findByEmailAndDeletedAtIsNull("user@example.com")).thenReturn(Optional.of(member()))
            `when`(passwordEncoder.matches("wrong", "ENCODED")).thenReturn(false)

            assertThatThrownBy { service.login("user@example.com", "wrong") }
                .isBusiness(AuthExceptionCode.INVALID_CREDENTIALS)
            verify(refreshTokenService, never()).save(anyMember(), anyText(), anyTime())
        }

        @Test
        fun `없는 이메일도 같은 오류로 알려서 존재 여부를 드러내지 않는다`() {
            `when`(memberRepository.findByEmailAndDeletedAtIsNull("none@example.com")).thenReturn(Optional.empty())

            assertThatThrownBy { service.login("none@example.com", "Password1!") }
                .isBusiness(AuthExceptionCode.INVALID_CREDENTIALS)
        }
    }

    @Nested
    inner class `토큰 재발급` {

        private val refreshToken = jwtProvider.createRefreshToken(memberId, "옛닉네임", "ROLE_TRUSTED", null)

        @Test
        fun `리프레시 토큰이 없거나 공백이면 토큰 없음이다`() {
            assertThatThrownBy { service.refresh(null) }.isBusiness(AuthExceptionCode.TOKEN_MISSING)
            assertThatThrownBy { service.refresh("") }.isBusiness(AuthExceptionCode.TOKEN_MISSING)
            assertThatThrownBy { service.refresh("   ") }.isBusiness(AuthExceptionCode.TOKEN_MISSING)
        }

        @Test
        fun `토큰 형식이 틀리면 JWT 예외가 그대로 올라간다`() {
            assertThatThrownBy { service.refresh("not-a-token") }.isInstanceOf(JwtException::class.java)
        }

        @Test
        fun `저장된 토큰과 맞으면 현재 DB의 등급과 닉네임으로 새 액세스 토큰을 만든다`() {
            // 토큰에는 TRUSTED로 들어 있지만 DB는 WARNING으로 강등된 상태
            `when`(memberRepository.findByIdAndDeletedAtIsNull(memberId))
                .thenReturn(Optional.of(member(MemberRole.ROLE_WARNING, "새닉네임")))

            val access = jwtProvider.parse(service.refresh(refreshToken))

            verify(refreshTokenService).verify(memberId, refreshToken)
            assertThat(access.get("role", String::class.java)).isEqualTo("ROLE_WARNING")
            assertThat(access.get("nickname", String::class.java)).isEqualTo("새닉네임")
        }

        @Test
        fun `저장된 토큰 검증에 실패하면 그 예외를 그대로 올린다`() {
            doThrow(BusinessException(AuthExceptionCode.TOKEN_EXPIRED)).`when`(refreshTokenService).verify(memberId, refreshToken)

            assertThatThrownBy { service.refresh(refreshToken) }.isBusiness(AuthExceptionCode.TOKEN_EXPIRED)
        }

        @Test
        fun `탈퇴했거나 없는 회원이면 유효하지 않은 토큰이다`() {
            `when`(memberRepository.findByIdAndDeletedAtIsNull(memberId)).thenReturn(Optional.empty())

            assertThatThrownBy { service.refresh(refreshToken) }.isBusiness(AuthExceptionCode.TOKEN_INVALID)
        }
    }

    @Nested
    inner class `로그아웃` {

        private val refreshToken = jwtProvider.createRefreshToken(memberId, "닉네임", "ROLE_UNVERIFIED", null)

        @Test
        fun `리프레시 토큰의 회원 토큰을 지운다`() {
            service.logout(refreshToken)

            verify(refreshTokenService).deleteByMemberId(memberId)
        }

        @Test
        fun `쿠키가 없거나 공백이면 아무것도 하지 않는다`() {
            service.logout(null)
            service.logout("")
            service.logout("  ")

            verify(refreshTokenService, never()).deleteByMemberId(anyUuid())
        }

        @Test
        fun `위조되거나 만료된 쿠키는 오류 없이 넘어가고 지우지 않는다`() {
            assertThatCode { service.logout("not-a-token") }.doesNotThrowAnyException()

            verify(refreshTokenService, never()).deleteByMemberId(anyUuid())
        }

        @Test
        fun `삭제 중 런타임 오류가 나도 로그아웃은 실패하지 않는다`() {
            doThrow(IllegalStateException("DB 오류")).`when`(refreshTokenService).deleteByMemberId(memberId)

            assertThatCode { service.logout(refreshToken) }.doesNotThrowAnyException()
        }
    }
}
