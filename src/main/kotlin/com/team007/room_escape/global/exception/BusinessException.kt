package com.team007.room_escape.global.exception

/**
 * 비즈니스 규칙 위반 시 던지는 예외.
 * ExceptionCode만 넘기면 핸들러가 HTTP 상태/응답 코드/메시지를 맞춰 ApiResponse로 내려준다.
 */
class BusinessException constructor(
    val exceptionCode: ExceptionCode,
    message: String? = exceptionCode.message,
) : RuntimeException(message)
