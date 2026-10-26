package com.team007.room_escape.domain.member.service

import com.team007.room_escape.domain.auth.service.EmailVerificationService
import com.team007.room_escape.domain.auth.service.EmailVerificationService.Purpose
import com.team007.room_escape.domain.auth.service.RefreshTokenService
import com.team007.room_escape.domain.member.dto.MemberRequest
import com.team007.room_escape.domain.member.dto.MemberResponse
import com.team007.room_escape.domain.member.infra.entity.Member
import com.team007.room_escape.domain.member.infra.repository.MemberRepository
import com.team007.room_escape.global.exception.BusinessException
import com.team007.room_escape.global.mail.MailSendService
import com.team007.room_escape.global.response.code.AuthExceptionCode
import com.team007.room_escape.global.response.code.MemberExceptionCode
import com.team007.room_escape.global.storage.ImageUrlResolver
import com.team007.room_escape.global.storage.R2StorageService
import org.springframework.security.crypto.password.PasswordEncoder
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.util.UUID

@Service
class MemberService(
    private val memberRepository: MemberRepository,
    private val memberReader: MemberReader,
    private val imageUrlResolver: ImageUrlResolver,
    private val r2StorageService: R2StorageService,
    private val emailVerificationService: EmailVerificationService,
    private val mailSendService: MailSendService,
    private val refreshTokenService: RefreshTokenService,
    private val passwordEncoder: PasswordEncoder,
) {

    /** 마이페이지 조회. 토큰 값은 발급 시점 기준이라 DB에서 최신 값을 다시 읽는다. */
    @Transactional(readOnly = true)
    fun getMyPage(memberId: UUID): MemberResponse.MyPageInfo = toMyPageInfo(memberReader.getActiveMember(memberId))

    /** 마이페이지 수정. 제재 회원은 신고 회피를 막으려고 수정할 수 없다. */
    @Transactional
    fun updateMyPage(memberId: UUID, request: MemberRequest.UpdateMyPage): MemberResponse.MyPageInfo {
        val member = memberReader.getUnrestrictedMember(memberId)

        validateNickname(member, request.nickname)
        r2StorageService.requireOwnedBy(request.profileImg, member.profileImg, memberId)
        r2StorageService.confirmImages(memberId, attachments = arrayOf(request.profileImg))

        val previousProfileImg = member.profileImg
        member.updateProfile(request.nickname, request.phone, request.profileImg)

        deleteReplacedProfileImage(previousProfileImg, member.profileImg, memberId)

        return toMyPageInfo(member)
    }

    /** 인증 코드를 가입 이메일로 보낸다. 메일 발송 중 커넥션을 잡지 않으려고 트랜잭션을 걸지 않는다. */
    fun sendPasswordChangeCode(memberId: UUID) {
        val member = memberReader.getUnrestrictedMember(memberId)

        val code = emailVerificationService.issueCode(memberId, Purpose.PASSWORD_CHANGE)

        mailSendService.sendPasswordChangeCode(member.email, code)
    }

    /** 비밀번호 변경 1단계. 인증 코드가 맞는지 확인한다. */
    @Transactional(readOnly = true)
    fun verifyPasswordChangeCode(memberId: UUID, request: MemberRequest.VerifyPassword) {
        memberReader.getUnrestrictedMember(memberId)

        emailVerificationService.verifyCode(memberId, Purpose.PASSWORD_CHANGE, request.code)
    }

    /** 비밀번호 변경 2단계. 변경 후 Refresh Token을 지워 다른 기기의 세션을 끊는다. */
    @Transactional
    fun changePassword(memberId: UUID, request: MemberRequest.ChangePassword) {
        val member = memberReader.getUnrestrictedMember(memberId)
        // 요청 검증(@NotBlank)을 통과하면 새 비밀번호는 항상 있다.
        val newPassword = requireNotNull(request.newPassword) { "검증을 통과한 요청에는 새 비밀번호가 있다." }

        // 인증 상태는 롤백되지 않으므로 소모하기 전에 확인한다.
        if (passwordEncoder.matches(newPassword, member.password)) {
            throw BusinessException(AuthExceptionCode.SAME_AS_OLD_PASSWORD)
        }

        emailVerificationService.consumeVerified(memberId, Purpose.PASSWORD_CHANGE)

        member.changePassword(requireNotNull(passwordEncoder.encode(newPassword)))

        refreshTokenService.deleteByMemberId(memberId)
    }

    /** 회원 탈퇴. 작성한 글이 참조를 잃지 않게 행은 지우지 않고 탈퇴 시각만 남긴다. */
    @Transactional
    fun withdraw(memberId: UUID, request: MemberRequest.Withdraw) {
        val member = memberReader.getActiveMember(memberId)

        // 관리자는 운영 업무 인계가 안 되므로 탈퇴 불가.
        if (member.role.isAdmin) throw BusinessException(MemberExceptionCode.MEMBER_ADMIN_WITHDRAW_DENIED)

        // 자리를 비운 사이 남이 탈퇴시키지 못하게 비밀번호를 다시 확인한다.
        val password = requireNotNull(request.password) { "검증을 통과한 요청에는 비밀번호가 있다." }
        if (!passwordEncoder.matches(password, member.password)) {
            throw BusinessException(MemberExceptionCode.MEMBER_PASSWORD_MISMATCH)
        }

        member.delete()

        // 리프레시 토큰이 남으면 탈퇴 후에도 재발급이 된다.
        refreshTokenService.deleteByMemberId(memberId)
    }

    /** 지금 쓰던 닉네임 그대로면 중복 검사를 건너뛴다. */
    private fun validateNickname(member: Member, nickname: String?) {
        if (nickname == null || nickname == member.nickname) return
        if (memberRepository.existsByNicknameAndDeletedAtIsNull(nickname)) {
            throw BusinessException(MemberExceptionCode.NICKNAME_DUPLICATED)
        }
    }

    /** 프로필 이미지 key를 공개 URL로 바꿔 내려준다. */
    private fun toMyPageInfo(member: Member) =
        MemberResponse.MyPageInfo.from(member, imageUrlResolver.resolve(member.profileImg))

    /** 교체된 옛 이미지를 R2에서 지운다. */
    private fun deleteReplacedProfileImage(previousKey: String?, currentKey: String?, memberId: UUID) {
        if (previousKey == null || previousKey == currentKey) return
        r2StorageService.deleteOwnedBy(previousKey, memberId)
    }
}
