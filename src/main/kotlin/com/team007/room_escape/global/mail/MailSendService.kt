package com.team007.room_escape.global.mail

import com.team007.room_escape.global.config.AuthMailProperties
import org.slf4j.LoggerFactory
import org.springframework.beans.factory.annotation.Value
import org.springframework.mail.MailException
import org.springframework.mail.SimpleMailMessage
import org.springframework.mail.javamail.JavaMailSender
import org.springframework.scheduling.annotation.Async
import org.springframework.stereotype.Service

/** 메일 발송. SMTP가 느려서 @Async로 보내고, 실패는 로그만 남긴다(재발송으로 복구 가능). */
@Service
class MailSendService(
    private val mailSender: JavaMailSender,
    private val properties: AuthMailProperties
) {

    private val log = LoggerFactory.getLogger(javaClass)

    @Value("\${spring.mail.username}")
    private lateinit var from: String

    @Async
    fun sendPasswordChangeCode(to: String, code: String) {
        val message = SimpleMailMessage()
        message.from = from
        message.setTo(to)
        message.subject = "[roomescape] 비밀번호 변경 인증 코드"
        message.text = """
            비밀번호 변경을 위한 인증 코드입니다.

                $code

            유효시간은 ${properties.expireMinutes()}분입니다.
            본인이 요청하지 않았다면 이 메일을 무시하고 비밀번호를 바꾸지 마세요.
            """.trimIndent() + "\n"

        try {
            mailSender.send(message)
            log.info("비밀번호 변경 인증 메일 발송 완료 to={}", mask(to))
        } catch (e: MailException) {
            log.error("비밀번호 변경 인증 메일 발송 실패 to={}", mask(to), e)
        }
    }

    /** 로그에 이메일 전체를 남기지 않는다. */
    private fun mask(email: String): String {
        val at = email.indexOf('@')
        if (at <= 1) {
            return "***"
        }
        return email[0] + "***" + email.substring(at)
    }
}
