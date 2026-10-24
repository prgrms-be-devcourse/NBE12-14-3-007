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

        fun <T> ok(data: T, message: String = ""): ApiResponse<T> =
            ApiResponse(true, SUCCESS_CODE, message, data)

        fun noContent(message: String = ""): ApiResponse<Void?> =
            ApiResponse(true, SUCCESS_CODE, message, null)

        fun fail(code: ExceptionCode, message: String? = code.message): ApiResponse<Void?> =
            ApiResponse(false, code.code, message, null)

        // ---- 아직 Java 코드가 부르는 옛 모양. Kotlin 코드는 위의 새 모양만 쓴다. ----

        @Deprecated("ok()를 쓰세요", ReplaceWith("ok(data)"), DeprecationLevel.WARNING)
        @JvmStatic
        fun <T> success(data: T): ApiResponse<T> = ok(data)

        @Deprecated("ok()를 쓰세요", ReplaceWith("ok(data, message)"), DeprecationLevel.WARNING)
        @JvmStatic
        fun <T> success(data: T, message: String?): ApiResponse<T> = ApiResponse(true, SUCCESS_CODE, message, data)

        @Deprecated("noContent()를 쓰세요", ReplaceWith("noContent()"), DeprecationLevel.WARNING)
        @JvmStatic
        fun noContentSuccess(): ApiResponse<Void?> = noContent()

        @Deprecated("noContent()를 쓰세요", ReplaceWith("noContent(message)"), DeprecationLevel.WARNING)
        @JvmStatic
        fun noContentSuccess(message: String?): ApiResponse<Void?> = ApiResponse(true, SUCCESS_CODE, message, null)

        @Deprecated("fail()을 쓰세요", level = DeprecationLevel.WARNING)
        @JvmStatic
        fun <T> error(message: String?, code: String?, data: T): ApiResponse<T> = ApiResponse(false, code, message, data)

        @Deprecated("fail()을 쓰세요", level = DeprecationLevel.WARNING)
        @JvmStatic
        fun error(message: String?, code: String?): ApiResponse<Void?> = ApiResponse(false, code, message, null)
    }
}
