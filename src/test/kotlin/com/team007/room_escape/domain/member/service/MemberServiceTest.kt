package com.team007.room_escape.domain.member.service

import com.team007.room_escape.domain.auth.service.EmailVerificationService
import com.team007.room_escape.domain.auth.service.EmailVerificationService.Purpose
import com.team007.room_escape.domain.auth.service.RefreshTokenService
import com.team007.room_escape.domain.member.dto.MemberRequest
import com.team007.room_escape.domain.member.infra.entity.Member
import com.team007.room_escape.domain.member.infra.entity.MemberRole
import com.team007.room_escape.domain.member.infra.repository.MemberRepository
import com.team007.room_escape.global.config.R2Properties
import com.team007.room_escape.global.exception.BusinessException
import com.team007.room_escape.global.mail.MailSendService
import com.team007.room_escape.global.response.code.AuthExceptionCode
import com.team007.room_escape.global.response.code.MemberExceptionCode
import com.team007.room_escape.global.storage.ImageUrlResolver
import com.team007.room_escape.global.storage.R2StorageService
import org.assertj.core.api.Assertions.assertThat
import org.assertj.core.api.Assertions.assertThatThrownBy
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test
import org.mockito.Mockito.inOrder
import org.mockito.Mockito.mock
import org.mockito.Mockito.never
import org.mockito.Mockito.verify
import org.mockito.Mockito.`when`
import org.springframework.security.crypto.password.PasswordEncoder
import java.util.UUID

class MemberServiceTest {

    private val memberRepository = mock(MemberRepository::class.java)
    private val memberReader = mock(MemberReader::class.java)
    private val r2StorageService = mock(R2StorageService::class.java)
    private val emailVerificationService = mock(EmailVerificationService::class.java)
    private val mailSendService = mock(MailSendService::class.java)
    private val refreshTokenService = mock(RefreshTokenService::class.java)
    private val passwordEncoder = mock(PasswordEncoder::class.java)
    private val imageUrlResolver =
        ImageUrlResolver(R2Properties("account", "access", "secret", "bucket", "https://img.example.com"))
    private val service = MemberService(
        memberRepository, memberReader, imageUrlResolver, r2StorageService,
        emailVerificationService, mailSendService, refreshTokenService, passwordEncoder,
    )

    private val memberId = UUID.randomUUID()

    private fun member(role: MemberRole = MemberRole.ROLE_UNVERIFIED, profileImg: String? = null) = Member(
        email = "user@example.com", password = "ENCODED", role = role, nickname = "기존닉네임",
        profileImg = profileImg, phone = "01012345678", id = memberId,
    )

    private fun givenUnrestricted(member: Member) = `when`(memberReader.getUnrestrictedMember(memberId)).thenReturn(member)

    private fun org.assertj.core.api.AbstractThrowableAssert<*, *>.isBusiness(code: Enum<*>) {
        isInstanceOfSatisfying(BusinessException::class.java) {
            assertThat(it.exceptionCode).isEqualTo(code)
        }
    }

    @Nested
    inner class `마이페이지` {

        @Test
        fun `조회하면 프로필 이미지를 공개 URL로 바꿔 돌려준다`() {
            `when`(memberReader.getActiveMember(memberId)).thenReturn(member(profileImg = "profiles/$memberId/a.png"))

            val info = service.getMyPage(memberId)

            assertThat(info.id).isEqualTo(memberId)
            assertThat(info.email).isEqualTo("user@example.com")
            assertThat(info.profileImg).isEqualTo("https://img.example.com/profiles/$memberId/a.png")
        }

        @Test
        fun `수정하면 보낸 값만 바꿔서 돌려준다`() {
            val member = member()
            givenUnrestricted(member)

            val info = service.updateMyPage(memberId, MemberRequest.UpdateMyPage("새닉네임", null, null))

            assertThat(info.nickname).isEqualTo("새닉네임")
            assertThat(info.phone).isEqualTo("01012345678")
        }

        @Test
        fun `남이 쓰는 닉네임으로는 바꿀 수 없다`() {
            givenUnrestricted(member())
            `when`(memberRepository.existsByNicknameAndDeletedAtIsNull("남의닉네임")).thenReturn(true)

            assertThatThrownBy { service.updateMyPage(memberId, MemberRequest.UpdateMyPage("남의닉네임", null, null)) }
                .isBusiness(MemberExceptionCode.NICKNAME_DUPLICATED)
        }

        @Test
        fun `지금 쓰는 닉네임 그대로면 중복 검사를 하지 않는다`() {
            givenUnrestricted(member())

            service.updateMyPage(memberId, MemberRequest.UpdateMyPage("기존닉네임", null, null))

            verify(memberRepository, never()).existsByNicknameAndDeletedAtIsNull("기존닉네임")
        }

        @Test
        fun `프로필 이미지를 바꾸면 새 이미지의 주인을 확인하고 옛 이미지를 지운다`() {
            givenUnrestricted(member(profileImg = "profiles/$memberId/old.png"))

            service.updateMyPage(memberId, MemberRequest.UpdateMyPage(null, null, "profiles/$memberId/new.png"))

            verify(r2StorageService).requireOwnedBy("profiles/$memberId/new.png", "profiles/$memberId/old.png", memberId)
            verify(r2StorageService).deleteOwnedBy("profiles/$memberId/old.png", memberId)
        }

        @Test
        fun `프로필 이미지를 비우면 옛 이미지를 지운다`() {
            givenUnrestricted(member(profileImg = "profiles/$memberId/old.png"))

            val info = service.updateMyPage(memberId, MemberRequest.UpdateMyPage(null, null, ""))

            assertThat(info.profileImg).isNull()
            verify(r2StorageService).deleteOwnedBy("profiles/$memberId/old.png", memberId)
        }

        @Test
        fun `프로필 이미지를 건드리지 않으면 지우지 않는다`() {
            givenUnrestricted(member(profileImg = "profiles/$memberId/old.png"))

            service.updateMyPage(memberId, MemberRequest.UpdateMyPage("새닉네임", null, null))

            verify(r2StorageService, never()).deleteOwnedBy("profiles/$memberId/old.png", memberId)
        }
    }

    @Nested
    inner class `비밀번호 변경` {

        @Test
        fun `인증 코드를 가입 이메일로 보낸다`() {
            givenUnrestricted(member())
            `when`(emailVerificationService.issueCode(memberId, Purpose.PASSWORD_CHANGE)).thenReturn("123456")

            service.sendPasswordChangeCode(memberId)

            verify(mailSendService).sendPasswordChangeCode("user@example.com", "123456")
        }

        @Test
        fun `1단계는 입력한 코드로 인증 상태를 확인한다`() {
            givenUnrestricted(member())

            service.verifyPasswordChangeCode(memberId, MemberRequest.VerifyPassword("123456"))

            verify(emailVerificationService).verifyCode(memberId, Purpose.PASSWORD_CHANGE, "123456")
        }

        @Test
        fun `2단계는 새 비밀번호를 인코딩해 저장하고 인증을 소모하고 리프레시 토큰을 지운다`() {
            val member = member()
            givenUnrestricted(member)
            `when`(passwordEncoder.matches("NewPass1!", "ENCODED")).thenReturn(false)
            `when`(passwordEncoder.encode("NewPass1!")).thenReturn("NEW-ENCODED")

            service.changePassword(memberId, MemberRequest.ChangePassword("NewPass1!"))

            assertThat(member.password).isEqualTo("NEW-ENCODED")
            val order = inOrder(emailVerificationService, refreshTokenService)
            order.verify(emailVerificationService).consumeVerified(memberId, Purpose.PASSWORD_CHANGE)
            order.verify(refreshTokenService).deleteByMemberId(memberId)
        }

        @Test
        fun `지금과 같은 비밀번호면 인증을 소모하기 전에 거절한다`() {
            val member = member()
            givenUnrestricted(member)
            `when`(passwordEncoder.matches("SamePass1!", "ENCODED")).thenReturn(true)

            assertThatThrownBy { service.changePassword(memberId, MemberRequest.ChangePassword("SamePass1!")) }
                .isBusiness(AuthExceptionCode.SAME_AS_OLD_PASSWORD)

            verify(emailVerificationService, never()).consumeVerified(memberId, Purpose.PASSWORD_CHANGE)
            assertThat(member.password).isEqualTo("ENCODED")
        }
    }

    @Nested
    inner class `탈퇴` {

        private fun givenActive(member: Member) = `when`(memberReader.getActiveMember(memberId)).thenReturn(member)

        @Test
        fun `비밀번호가 맞으면 탈퇴 처리하고 리프레시 토큰을 지운다`() {
            val member = member()
            givenActive(member)
            `when`(passwordEncoder.matches("Password1!", "ENCODED")).thenReturn(true)

            service.withdraw(memberId, MemberRequest.Withdraw("Password1!"))

            assertThat(member.isDeleted()).isTrue()
            verify(refreshTokenService).deleteByMemberId(memberId)
        }

        @Test
        fun `비밀번호가 틀리면 탈퇴시키지 않는다`() {
            val member = member()
            givenActive(member)
            `when`(passwordEncoder.matches("Wrong1!", "ENCODED")).thenReturn(false)

            assertThatThrownBy { service.withdraw(memberId, MemberRequest.Withdraw("Wrong1!")) }
                .isBusiness(MemberExceptionCode.MEMBER_PASSWORD_MISMATCH)

            assertThat(member.isDeleted()).isFalse()
            verify(refreshTokenService, never()).deleteByMemberId(memberId)
        }

        @Test
        fun `관리자는 탈퇴할 수 없다`() {
            val admin = member(MemberRole.ROLE_ADMIN)
            givenActive(admin)

            assertThatThrownBy { service.withdraw(memberId, MemberRequest.Withdraw("Password1!")) }
                .isBusiness(MemberExceptionCode.MEMBER_ADMIN_WITHDRAW_DENIED)

            assertThat(admin.isDeleted()).isFalse()
        }
    }
}
