package com.team007.room_escape.v2.global.exception

import com.team007.room_escape.global.exception.BusinessException
import com.team007.room_escape.global.exception.ExceptionCode
import com.team007.room_escape.global.exception.GlobalExceptionHandler
import com.team007.room_escape.global.response.ApiResponse
import com.team007.room_escape.global.response.code.AuthExceptionCode
import com.team007.room_escape.global.response.code.CommonExceptionCode
import com.team007.room_escape.global.response.code.MemberExceptionCode
import com.team007.room_escape.global.response.code.StorageExceptionCode
import io.jsonwebtoken.ExpiredJwtException
import io.jsonwebtoken.JwtException
import org.assertj.core.api.Assertions.assertThat
import org.hibernate.query.sqm.UnknownPathException
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.DynamicTest
import org.junit.jupiter.api.DynamicTest.dynamicTest
import org.junit.jupiter.api.TestFactory
import org.mockito.Mockito.mock
import org.springframework.core.MethodParameter
import org.springframework.dao.InvalidDataAccessApiUsageException
import org.springframework.http.HttpInputMessage
import org.springframework.http.HttpMethod
import org.springframework.http.ResponseEntity
import org.springframework.http.converter.HttpMessageNotReadableException
import org.springframework.security.access.AccessDeniedException
import org.springframework.security.authentication.BadCredentialsException
import org.springframework.validation.BeanPropertyBindingResult
import org.springframework.validation.FieldError
import org.springframework.web.HttpRequestMethodNotSupportedException
import org.springframework.web.bind.MethodArgumentNotValidException
import org.springframework.web.bind.MissingServletRequestParameterException
import org.springframework.web.method.annotation.MethodArgumentTypeMismatchException
import org.springframework.web.multipart.MaxUploadSizeExceededException
import org.springframework.web.servlet.resource.NoResourceFoundException
import java.util.UUID

/**
 * 예외 종류별로 어떤 상태 코드·에러 코드·메시지가 나가는지 확인한다.
 * 핸들러를 직접 불러서 스프링 컨텍스트 없이 빠르게 돈다.
 */
class GlobalExceptionHandlerTest {

    private val handler = GlobalExceptionHandler()

    /** 어떤 예외를 어느 핸들러에 넣으면 어떤 응답이 나와야 하는지 한 줄로 적는 표 */
    private class Case(
        val name: String,
        val expected: ExceptionCode,
        val message: String = expected.message,
        val call: (GlobalExceptionHandler) -> ResponseEntity<ApiResponse<Void?>>
    )

    private fun cases(): List<Case> = listOf(
        Case("JWT 만료", AuthExceptionCode.TOKEN_EXPIRED) {
            it.handleExpiredJwt(ExpiredJwtException(null, null, "expired"))
        },
        Case("JWT 서명·형식 오류", AuthExceptionCode.TOKEN_INVALID) {
            it.handleJwt(JwtException("bad signature"))
        },
        Case("시큐리티 인증 실패", AuthExceptionCode.AUTHENTICATION_FAILED) {
            it.handleAuthentication(BadCredentialsException("bad"))
        },
        Case("권한 부족", AuthExceptionCode.ACCESS_DENIED) {
            it.handleAccessDenied(AccessDeniedException("denied"))
        },
        Case("업로드 용량 초과", CommonExceptionCode.FILE_TOO_LARGE) {
            it.handleFileTooLarge(MaxUploadSizeExceededException(5_000_000))
        },
        Case("요청 본문을 읽을 수 없음", CommonExceptionCode.INVALID_INPUT, "요청 형식이 올바르지 않습니다.") {
            it.handleUnreadableBody(HttpMessageNotReadableException("깨진 JSON", mock(HttpInputMessage::class.java)))
        },
        Case("파라미터 타입 불일치", CommonExceptionCode.INVALID_INPUT, "'id' 값이 올바르지 않습니다.") {
            it.handleTypeMismatch(MethodArgumentTypeMismatchException("abc", UUID::class.java, "id", parameter(), null))
        },
        Case("필수 파라미터 누락", CommonExceptionCode.INVALID_INPUT, "'region' 값이 필요합니다.") {
            it.handleMissingParam(MissingServletRequestParameterException("region", "String"))
        },
        Case("허용하지 않는 HTTP 메서드", CommonExceptionCode.METHOD_NOT_ALLOWED) {
            it.handleMethodNotAllowed(HttpRequestMethodNotSupportedException("DELETE"))
        },
        Case("없는 경로", CommonExceptionCode.ENDPOINT_NOT_FOUND) {
            it.handleNoResource(NoResourceFoundException(HttpMethod.GET, "/api/v1/nothing", "api/v1/nothing"))
        },
        Case("처리하지 못한 예외", CommonExceptionCode.INTERNAL_ERROR) {
            it.handleUnknown(IllegalStateException("내부 사정"))
        }
    )

    @TestFactory
    fun `예외 종류별로 정해진 상태 코드와 에러 코드와 메시지로 응답한다`(): List<DynamicTest> =
        cases().map { case ->
            dynamicTest(case.name) {
                case.call(handler).shouldBe(case.expected, case.message)
            }
        }

    @Test
    fun `비즈니스 예외는 던진 에러 코드의 상태와 코드로 응답한다`() {
        val response = handler.handleBusiness(BusinessException(MemberExceptionCode.MEMBER_NOT_FOUND))

        response.shouldBe(MemberExceptionCode.MEMBER_NOT_FOUND)
        assertThat(response.statusCode.value()).isEqualTo(404)
    }

    @Test
    fun `비즈니스 예외에 메시지를 따로 줬다면 그 메시지를 내려준다`() {
        val response = handler.handleBusiness(BusinessException(MemberExceptionCode.EMAIL_DUPLICATED, "이미 가입한 메일입니다."))

        response.shouldBe(MemberExceptionCode.EMAIL_DUPLICATED, "이미 가입한 메일입니다.")
    }

    @Test
    fun `5xx 비즈니스 예외도 같은 형식으로 응답한다`() {
        val response = handler.handleBusiness(BusinessException(StorageExceptionCode.UPLOAD_FAILED))

        response.shouldBe(StorageExceptionCode.UPLOAD_FAILED)
        assertThat(response.statusCode.value()).isEqualTo(500)
    }

    @Test
    fun `요청 본문 검증에 실패하면 필드별 메시지를 쉼표로 이어서 내려준다`() {
        val bindingResult = BeanPropertyBindingResult(Any(), "request").apply {
            addError(FieldError("request", "title", "제목은 필수입니다."))
            addError(FieldError("request", "content", "내용은 필수입니다."))
        }

        val response = handler.handleValidation(MethodArgumentNotValidException(parameter(), bindingResult))

        response.shouldBe(CommonExceptionCode.INVALID_INPUT, "title: 제목은 필수입니다., content: 내용은 필수입니다.")
    }

    @Test
    fun `정렬 필드가 엔티티에 없으면 400으로 바꿔 내려준다`() {
        val response = handler.handleInvalidDataAccess(
            InvalidDataAccessApiUsageException("bad sort", mock(UnknownPathException::class.java))
        )

        response.shouldBe(CommonExceptionCode.INVALID_INPUT, "정렬할 수 없는 필드입니다.")
    }

    @Test
    fun `정렬 필드 오류가 원인 사슬 깊은 곳에 있어도 찾아낸다`() {
        val response = handler.handleInvalidDataAccess(
            InvalidDataAccessApiUsageException("wrapped", RuntimeException(mock(UnknownPathException::class.java)))
        )

        response.shouldBe(CommonExceptionCode.INVALID_INPUT, "정렬할 수 없는 필드입니다.")
    }

    @Test
    fun `같은 예외 타입이어도 원인이 정렬 오류가 아니면 서버 오류로 응답한다`() {
        val response = handler.handleInvalidDataAccess(InvalidDataAccessApiUsageException("진짜 서버 버그"))

        response.shouldBe(CommonExceptionCode.INTERNAL_ERROR)
    }

    @Test
    fun `원인이 자기 자신을 가리키는 예외도 무한히 따라가지 않고 서버 오류로 응답한다`() {
        val selfCaused = object : InvalidDataAccessApiUsageException("순환") {
            override val cause: Throwable get() = this
        }

        handler.handleInvalidDataAccess(selfCaused).shouldBe(CommonExceptionCode.INTERNAL_ERROR)
    }

    @Test
    fun `서버 오류 응답에는 예외의 원문 메시지를 담지 않는다`() {
        val response = handler.handleUnknown(IllegalStateException("DB 비밀번호가 틀렸습니다"))

        assertThat(response.body?.message).doesNotContain("DB 비밀번호")
    }

    /** 응답이 특정 에러 코드(상태, 코드, 메시지)와 같은지 확인한다 */
    private fun ResponseEntity<ApiResponse<Void?>>.shouldBe(expected: ExceptionCode, message: String = expected.message) {
        assertThat(statusCode).isEqualTo(expected.status)
        val body = requireNotNull(body)
        assertThat(body.success).isFalse()
        assertThat(body.code).isEqualTo(expected.code)
        assertThat(body.message).isEqualTo(message)
        assertThat(body.data).isNull()
    }

    /** 예외 생성자가 요구하는 MethodParameter. 어떤 메서드든 상관없다 */
    private fun parameter() = MethodParameter(this::class.java.getDeclaredMethod("anyMethod", String::class.java), 0)

    @Suppress("unused", "UNUSED_PARAMETER")
    private fun anyMethod(value: String) = Unit
}
