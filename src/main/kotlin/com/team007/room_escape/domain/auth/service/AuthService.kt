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
import com.team007.room_escape.global.util.StringUtil.emptyToNull
import com.team007.room_escape.global.util.isBlankLikeJava
import org.slf4j.LoggerFactory
import org.springframework.security.crypto.password.PasswordEncoder
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.time.LocalDateTime
import java.util.UUID

@Service
class AuthService(
    private val memberRepository: MemberRepository,
    private val passwordEncoder: PasswordEncoder,
    private val jwtProvider: JwtProvider,
    private val jwtProperties: JwtProperties,
    private val refreshTokenService: RefreshTokenService,
) {

    private val log = LoggerFactory.getLogger(javaClass)

    /** 서비스 → 컨트롤러 내부 전달용. Refresh Token은 쿠키로 나가서 응답 본문에는 쓰지 않는다. */
    data class TokenPair(val accessToken: String, val refreshToken: String)

    /** 비회원은 이미지를 올릴 수 없어서 프로필 사진은 가입 후 마이페이지에서 등록한다. */
    @Transactional
    fun signup(request: AuthRequest.Signup) {
        log.info("[가입] 요청 email={} nickname={} phone={}", request.email, request.nickname, request.phone)

        // 탈퇴 회원까지 본다. 탈퇴 직후 같은 이메일로 다시 가입하는 것을 막기 위함이다.
        if (memberRepository.existsByEmail(request.email)) {
            // 쓰는 중인지 탈퇴한 것인지 구분해서 알려준다. 둘 다 "이 이메일이 존재한다"는
            // 사실은 같으므로 노출되는 정보의 양은 다르지 않고, 안내만 정확해진다.
            val inUse = memberRepository.existsByEmailAndDeletedAtIsNull(request.email)
            log.warn("[가입] 이메일 중복 email={} inUse={}", request.email, inUse)
            throw BusinessException(
                if (inUse) MemberExceptionCode.EMAIL_DUPLICATED else MemberExceptionCode.EMAIL_WITHDRAWN
            )
        }
        if (memberRepository.existsByNicknameAndDeletedAtIsNull(request.nickname)) {
            log.warn("[가입] 닉네임 중복 nickname={}", request.nickname)
            throw BusinessException(MemberExceptionCode.NICKNAME_DUPLICATED)
        }

        val saved = memberRepository.save(
            Member(
                email = requireNotNull(request.email) { "검증을 통과한 요청에는 이메일이 있다." },
                password = requireNotNull(passwordEncoder.encode(request.password)),
                role = MemberRole.ROLE_UNVERIFIED,
                nickname = requireNotNull(request.nickname) { "검증을 통과한 요청에는 닉네임이 있다." },
                // 빈 문자열이 그대로 저장되면 "번호 없음"과 구분이 안 되고 DB 제약에도 걸린다.
                phone = emptyToNull(request.phone),
            )
        )

        log.info("[가입] 완료 id={} email={}", saved.id, saved.email)
    }

    // TODO(login-rate-limit): 로그인 시도 횟수 제한이 없다. 이메일+IP별 실패 횟수를 Caffeine 캐시로 세어
    //  일정 횟수를 넘으면 429(TOO_MANY_REQUESTS)로 막을 것. (대입 공격과 BCrypt CPU 소모 대응,
    //  EmailVerificationService가 같은 방식으로 Caffeine을 쓴다.)
    @Transactional
    fun login(email: String?, password: String?): TokenPair {
        // 이메일이나 비밀번호가 없으면(검증을 통과했다면 생기지 않는다) 일치하는 회원이 없는 것과 같게 처리한다.
        val member = memberRepository.findByEmailAndDeletedAtIsNull(email)
            ?.takeIf { password != null && passwordEncoder.matches(password, it.password) }
            ?: throw BusinessException(AuthExceptionCode.INVALID_CREDENTIALS)
        return issueTokens(member)
    }

    /**
     * 등급·닉네임·프로필은 리프레시 토큰 claim이 아니라 DB에서 다시 읽는다.
     * claim을 그대로 쓰면 제재(WARNING)나 등급 변경이 리프레시 토큰 만료 전까지 반영되지 않는다.
     */
    @Transactional(readOnly = true)
    fun refresh(refreshToken: String?): String {
        if (refreshToken == null || refreshToken.isBlankLikeJava()) {
            throw BusinessException(AuthExceptionCode.TOKEN_MISSING)
        }

        val memberId = UUID.fromString(jwtProvider.parseRefresh(refreshToken).subject)
        refreshTokenService.verify(memberId, refreshToken)

        val member = memberRepository.findByIdAndDeletedAtIsNull(memberId)
            ?: throw BusinessException(AuthExceptionCode.TOKEN_INVALID)

        return jwtProvider.createAccessToken(member.id, member.nickname, member.authority(), member.profileImg)
    }

    @Transactional
    fun logout(refreshToken: String?) {
        if (refreshToken == null || refreshToken.isBlankLikeJava()) return

        try {
            val memberId = UUID.fromString(jwtProvider.parseRefresh(refreshToken).subject)
            refreshTokenService.deleteByMemberId(memberId)
        } catch (e: RuntimeException) {
            // 만료·위조된 쿠키면 DB에 지울 행이 없을 수 있다
        }
    }

    private fun issueTokens(member: Member): TokenPair {
        val accessToken = jwtProvider.createAccessToken(member.id, member.nickname, member.authority(), member.profileImg)
        val refreshToken = jwtProvider.createRefreshToken(member.id, member.nickname, member.authority(), member.profileImg)

        refreshTokenService.save(
            member,
            refreshToken,
            LocalDateTime.now().plusSeconds(jwtProperties.refreshTokenValiditySeconds),
        )
        return TokenPair(accessToken, refreshToken)
    }
}
