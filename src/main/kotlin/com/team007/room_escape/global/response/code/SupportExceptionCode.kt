package com.team007.room_escape.global.response.code

import com.team007.room_escape.global.exception.ExceptionCode
import org.springframework.http.HttpStatus

enum class SupportExceptionCode(
    override val code: String,
    override val status: HttpStatus,
    override val message: String,
) : ExceptionCode {

    /** 지운 글도 없는 글로 본다. 고객센터 글은 복구 기능이 없다 */
    SUPPORT_ARTICLE_NOT_FOUND("SUPPORT000", HttpStatus.NOT_FOUND, "존재하지 않는 공지사항 또는 질문입니다."),
}
