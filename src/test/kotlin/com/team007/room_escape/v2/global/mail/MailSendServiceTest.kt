package com.team007.room_escape.v2.global.mail

import com.team007.room_escape.global.config.AuthMailProperties
import com.team007.room_escape.global.mail.MailSendService
import org.assertj.core.api.Assertions.assertThat
import org.assertj.core.api.Assertions.assertThatCode
import org.junit.jupiter.api.Test
import org.mockito.ArgumentCaptor
import org.mockito.ArgumentMatchers.any
import org.mockito.Mockito.doThrow
import org.mockito.Mockito.mock
import org.mockito.Mockito.verify
import org.springframework.mail.MailSendException
import org.springframework.mail.SimpleMailMessage
import org.springframework.mail.javamail.JavaMailSender
import org.springframework.test.util.ReflectionTestUtils

class MailSendServiceTest {

    private val mailSender = mock(JavaMailSender::class.java)

    private val service = MailSendService(mailSender, AuthMailProperties(5, 60, 30)).also {
        // 발신 주소는 @Value 로 채워지는 필드라서 직접 넣는다
        ReflectionTestUtils.setField(it, "from", "no-reply@room.test")
    }

    private fun sentMessage(): SimpleMailMessage {
        val captor = ArgumentCaptor.forClass(SimpleMailMessage::class.java)
        verify(mailSender).send(captor.capture())
        return captor.value
    }

    @Test
    fun `인증 코드 메일을 받는 사람과 제목과 본문 형식대로 보낸다`() {
        service.sendPasswordChangeCode("user@example.com", "123456")

        val message = sentMessage()
        assertThat(message.from).isEqualTo("no-reply@room.test")
        assertThat(message.to).containsExactly("user@example.com")
        assertThat(message.subject).isEqualTo("[roomescape] 비밀번호 변경 인증 코드")
        assertThat(message.text).isEqualTo(
            "비밀번호 변경을 위한 인증 코드입니다.\n" +
                "\n" +
                "    123456\n" +
                "\n" +
                "유효시간은 5분입니다.\n" +
                "본인이 요청하지 않았다면 이 메일을 무시하고 비밀번호를 바꾸지 마세요.\n"
        )
    }

    @Test
    fun `유효시간은 설정한 분 단위 값을 쓴다`() {
        val service = MailSendService(mailSender, AuthMailProperties(10, 60, 30))
        ReflectionTestUtils.setField(service, "from", "no-reply@room.test")

        service.sendPasswordChangeCode("user@example.com", "000000")

        assertThat(sentMessage().text).contains("유효시간은 10분입니다.")
    }

    @Test
    fun `메일 발송이 실패해도 예외를 던지지 않는다`() {
        doThrow(MailSendException("SMTP 오류")).`when`(mailSender).send(any(SimpleMailMessage::class.java))

        assertThatCode { service.sendPasswordChangeCode("user@example.com", "123456") }
            .doesNotThrowAnyException()
    }
}
