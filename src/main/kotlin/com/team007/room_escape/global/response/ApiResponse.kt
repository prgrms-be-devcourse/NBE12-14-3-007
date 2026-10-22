package com.team007.room_escape.global.response

/**
 * API 공통 응답 래퍼.
 * 성공/실패 모두 success, code, message, data 형태로 내려 프론트 계약을 맞춘다.
 */
class ApiResponse<T> private constructor(
    val success: Boolean,
    val code: String?,
    val message: String?,
    val data: T?
) {

    class ApiResponseBuilder<T> internal constructor() {
        private var success: Boolean = false
        private var code: String? = null
        private var message: String? = null
        private var data: T? = null

        fun success(success: Boolean): ApiResponseBuilder<T> = apply { this.success = success }

        fun code(code: String?): ApiResponseBuilder<T> = apply { this.code = code }

        fun message(message: String?): ApiResponseBuilder<T> = apply { this.message = message }

        fun data(data: T?): ApiResponseBuilder<T> = apply { this.data = data }

        fun build(): ApiResponse<T> = ApiResponse(success, code, message, data)
    }

    companion object {

        private const val DEFAULT_CODE = "0000"

        @JvmStatic
        fun <T> builder(): ApiResponseBuilder<T> = ApiResponseBuilder()

        @JvmStatic
        fun <T> success(data: T): ApiResponse<T> {
            return builder<T>().success(true).code(DEFAULT_CODE).message("").data(data).build()
        }

        @JvmStatic
        fun <T> success(data: T, message: String?): ApiResponse<T> {
            return builder<T>().success(true).code(DEFAULT_CODE).message(message).data(data).build()
        }

        @JvmStatic
        fun noContentSuccess(): ApiResponse<Void?> {
            return builder<Void?>().success(true).code(DEFAULT_CODE).message("").data(null).build()
        }

        @JvmStatic
        fun noContentSuccess(message: String?): ApiResponse<Void?> {
            return builder<Void?>().success(true).code(DEFAULT_CODE).message(message).data(null).build()
        }

        @JvmStatic
        fun <T> error(message: String?, code: String?, data: T): ApiResponse<T> {
            return builder<T>().success(false).code(code).message(message).data(data).build()
        }

        @JvmStatic
        fun error(message: String?, code: String?): ApiResponse<Void?> {
            return builder<Void?>().success(false).code(code).message(message).data(null).build()
        }
    }
}
