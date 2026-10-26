package com.team007.room_escape.global.response

import com.team007.room_escape.global.exception.ExceptionCode

/**
 * API 공통 응답 래퍼.
 * 성공/실패 모두 success, code, message, data 형태로 내려 프론트 계약을 맞춘다.
 */
class ApiResponse<T> private constructor(
    val success: Boolean,
    val code: String?,
    val message: String?,
    val data: T?,
) {

    companion object {

        private const val SUCCESS_CODE = "0000"

        @JvmStatic
        @JvmOverloads
        fun <T> ok(data: T, message: String = ""): ApiResponse<T> =
            ApiResponse(true, SUCCESS_CODE, message, data)

        @JvmStatic
        @JvmOverloads
        fun noContent(message: String = ""): ApiResponse<Void?> =
            ApiResponse(true, SUCCESS_CODE, message, null)

        @JvmStatic
        @JvmOverloads
        fun fail(code: ExceptionCode, message: String? = code.message): ApiResponse<Void?> =
            ApiResponse(false, code.code, message, null)

        fun failWithDetails(code: ExceptionCode, message: String?, details: Map<String, Any>): ApiResponse<Map<String, Any>> =
            ApiResponse(false, code.code, message, details)
    }
}
