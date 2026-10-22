package com.team007.room_escape.global.exception

import org.springframework.http.HttpStatus

/**
 * 도메인별 에러 코드 enum이 구현하는 계약.
 * 식별 코드, HTTP 상태, 기본 메시지를 한곳에서 꺼내 BusinessException/핸들러가 공통 처리한다.
 */
interface ExceptionCode {

    val code: String

    val status: HttpStatus

    val message: String
}
