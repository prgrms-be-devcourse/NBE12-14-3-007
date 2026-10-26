package com.team007.room_escape.domain.auth.service

import com.team007.room_escape.domain.auth.service.EmailVerificationService.Purpose
import com.team007.room_escape.global.config.AuthMailProperties
import com.team007.room_escape.global.exception.BusinessException
import com.team007.room_escape.global.response.code.AuthExceptionCode
import org.assertj.core.api.Assertions.assertThat
import org.assertj.core.api.Assertions.assertThatCode
import org.assertj.core.api.Assertions.assertThatThrownBy
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test
import java.util.UUID

class EmailVerificationServiceTest {

    // 시간을 주입할 수 없어서, 만료는 음수 분으로 "이미 지난 시각"을 만들어 확인한다.
    private fun serviceOf(
        expireMinutes: Long = 5,
        resendCooldownSeconds: Long = 60,
        verifiedValidMinutes: Long = 30,
    ) = EmailVerificationService(AuthMailProperties(expireMinutes, resendCooldownSeconds, verifiedValidMinutes))

    private val member = UUID.randomUUID()
    private val purpose = Purpose.PASSWORD_CHANGE

    private fun org.assertj.core.api.AbstractThrowableAssert<*, *>.isBusiness(code: AuthExceptionCode) {
        isInstanceOfSatisfying(BusinessException::class.java) {
            assertThat(it.exceptionCode).isEqualTo(code)
        }
    }

    @Nested
    inner class `코드 발급` {

        @Test
        fun `숫자 여섯 자리 코드를 돌려준다`() {
            val code = serviceOf().issueCode(member, purpose)

            assertThat(code).matches("\\d{6}")
        }

        @Test
        fun `재발송 제한 시간 안에 다시 요청하면 거절한다`() {
            val service = serviceOf(resendCooldownSeconds = 60)
            service.issueCode(member, purpose)

            assertThatThrownBy { service.issueCode(member, purpose) }.isBusiness(AuthExceptionCode.VERIFICATION_RESEND_TOO_SOON)
        }

        @Test
        fun `제한 시간이 지나면 새 코드를 발급하고 이전 코드는 쓸 수 없다`() {
            val service = serviceOf(resendCooldownSeconds = 0)
            val first = service.issueCode(member, purpose)
            var second = service.issueCode(member, purpose)
            while (second == first) second = service.issueCode(member, purpose) // 우연히 같은 번호가 나온 경우

            assertThatThrownBy { service.verifyCode(member, purpose, first) }
                .isBusiness(AuthExceptionCode.VERIFICATION_CODE_MISMATCH)
            assertThatCode { service.verifyCode(member, purpose, second) }.doesNotThrowAnyException()
        }

        @Test
        fun `회원마다 따로 발급한다`() {
            val service = serviceOf(resendCooldownSeconds = 60)
            val other = UUID.randomUUID()
            service.issueCode(member, purpose)

            assertThatCode { service.issueCode(other, purpose) }.doesNotThrowAnyException()
        }
    }

    @Nested
    inner class `코드 확인` {

        @Test
        fun `발급받지 않았으면 먼저 요청하라고 알린다`() {
            assertThatThrownBy { serviceOf().verifyCode(member, purpose, "123456") }
                .isBusiness(AuthExceptionCode.VERIFICATION_NOT_FOUND)
        }

        @Test
        fun `코드가 다르면 거절하고 올바른 코드로 다시 시도할 수 있다`() {
            val service = serviceOf()
            val code = service.issueCode(member, purpose)
            val wrong = if (code == "000000") "000001" else "000000"

            assertThatThrownBy { service.verifyCode(member, purpose, wrong) }
                .isBusiness(AuthExceptionCode.VERIFICATION_CODE_MISMATCH)
            assertThatCode { service.verifyCode(member, purpose, code) }.doesNotThrowAnyException()
        }

        @Test
        fun `코드 유효 시간이 지나면 만료로 거절하고 기록을 지운다`() {
            val service = serviceOf(expireMinutes = -1)
            val code = service.issueCode(member, purpose)

            assertThatThrownBy { service.verifyCode(member, purpose, code) }
                .isBusiness(AuthExceptionCode.VERIFICATION_CODE_EXPIRED)
            assertThatThrownBy { service.verifyCode(member, purpose, code) }
                .isBusiness(AuthExceptionCode.VERIFICATION_NOT_FOUND)
        }
    }

    @Nested
    inner class `인증 소모` {

        @Test
        fun `발급받지 않았으면 먼저 요청하라고 알린다`() {
            assertThatThrownBy { serviceOf().consumeVerified(member, purpose) }
                .isBusiness(AuthExceptionCode.VERIFICATION_NOT_FOUND)
        }

        @Test
        fun `코드 확인을 건너뛰면 인증을 먼저 완료하라고 알린다`() {
            val service = serviceOf()
            service.issueCode(member, purpose)

            assertThatThrownBy { service.consumeVerified(member, purpose) }
                .isBusiness(AuthExceptionCode.VERIFICATION_REQUIRED)
        }

        @Test
        fun `확인을 마친 뒤에는 한 번만 소모할 수 있다`() {
            val service = serviceOf()
            service.verifyCode(member, purpose, service.issueCode(member, purpose))

            assertThatCode { service.consumeVerified(member, purpose) }.doesNotThrowAnyException()
            assertThatThrownBy { service.consumeVerified(member, purpose) }
                .isBusiness(AuthExceptionCode.VERIFICATION_NOT_FOUND)
        }

        @Test
        fun `인증 후 작업 제한 시간이 지나면 만료로 거절한다`() {
            val service = serviceOf(verifiedValidMinutes = -1)
            service.verifyCode(member, purpose, service.issueCode(member, purpose))

            assertThatThrownBy { service.consumeVerified(member, purpose) }
                .isBusiness(AuthExceptionCode.VERIFICATION_CODE_EXPIRED)
        }

        @Test
        fun `다른 회원의 인증은 소모할 수 없다`() {
            val service = serviceOf()
            service.verifyCode(member, purpose, service.issueCode(member, purpose))

            assertThatThrownBy { service.consumeVerified(UUID.randomUUID(), purpose) }
                .isBusiness(AuthExceptionCode.VERIFICATION_NOT_FOUND)
        }
    }
}
