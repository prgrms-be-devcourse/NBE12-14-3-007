package com.team007.room_escape.global.exception

import com.team007.room_escape.global.response.code.MemberExceptionCode
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test

class BusinessExceptionTest {

    @Test
    fun `에러 코드만 주면 코드의 기본 메시지를 쓴다`() {
        val e = BusinessException(MemberExceptionCode.MEMBER_NOT_FOUND)

        assertThat(e.exceptionCode).isEqualTo(MemberExceptionCode.MEMBER_NOT_FOUND)
        assertThat(e.message).isEqualTo("회원을 찾을 수 없습니다.")
    }

    @Test
    fun `메시지를 따로 주면 그 메시지를 쓰고 에러 코드는 유지한다`() {
        val e = BusinessException(MemberExceptionCode.MEMBER_NOT_FOUND, "닉네임이 없는 회원입니다.")

        assertThat(e.exceptionCode).isEqualTo(MemberExceptionCode.MEMBER_NOT_FOUND)
        assertThat(e.message).isEqualTo("닉네임이 없는 회원입니다.")
    }

    @Test
    fun `메시지로 null을 주면 메시지가 없는 예외가 된다`() {
        val e = BusinessException(MemberExceptionCode.MEMBER_NOT_FOUND, null)

        assertThat(e.exceptionCode).isEqualTo(MemberExceptionCode.MEMBER_NOT_FOUND)
        assertThat(e.message).isNull()
    }

    @Test
    fun `런타임 예외라서 선언 없이 던질 수 있다`() {
        assertThat(BusinessException(MemberExceptionCode.EMAIL_DUPLICATED)).isInstanceOf(RuntimeException::class.java)
    }
}
