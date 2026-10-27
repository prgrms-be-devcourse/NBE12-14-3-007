package com.team007.room_escape.global.exception

import com.team007.room_escape.global.ratelimit.AuthRateLimiter
import com.team007.room_escape.global.response.ApiResponse
import com.team007.room_escape.global.response.code.AuthExceptionCode
import com.team007.room_escape.global.response.code.CommonExceptionCode
import io.jsonwebtoken.ExpiredJwtException
import io.jsonwebtoken.JwtException
import org.hibernate.query.sqm.UnknownPathException
import org.slf4j.LoggerFactory
import org.springframework.dao.InvalidDataAccessApiUsageException
import org.springframework.data.core.PropertyReferenceException
import org.springframework.http.HttpHeaders
import org.springframework.http.ResponseEntity
import org.springframework.http.converter.HttpMessageNotReadableException
import org.springframework.security.access.AccessDeniedException
import org.springframework.security.core.AuthenticationException
import org.springframework.web.HttpRequestMethodNotSupportedException
import org.springframework.web.bind.MethodArgumentNotValidException
import org.springframework.web.bind.MissingServletRequestParameterException
import org.springframework.web.bind.annotation.ExceptionHandler
import org.springframework.web.bind.annotation.RestControllerAdvice
import org.springframework.web.method.annotation.MethodArgumentTypeMismatchException
import org.springframework.web.multipart.MaxUploadSizeExceededException
import org.springframework.web.servlet.resource.NoResourceFoundException

private typealias FailureResponse = ResponseEntity<ApiResponse<Void?>>

/** 컨트롤러·필터 예외를 ApiResponse 형식으로 통일해 응답한다. 필터 예외도 HandlerExceptionResolver로 들어온다. */
@RestControllerAdvice
class GlobalExceptionHandler {

    private val log = LoggerFactory.getLogger(javaClass)

    /** 서비스에서 의도적으로 던진 비즈니스 예외 (AUTH/MEMBER 등 ExceptionCode 전부) */
    @ExceptionHandler(BusinessException::class)
    fun handleBusiness(e: BusinessException): ResponseEntity<out ApiResponse<*>> {
        val ec = e.exceptionCode
        // 5xx는 스택트레이스까지, 4xx는 메시지만 남긴다
        if (ec.status.is5xxServerError) log.error("[{}] {}", ec.code, e.message, e) else log.warn("[{}] {}", ec.code, e.message)
        val details = e.details
        return if (details == null) respond(ec, e.message)
        else ResponseEntity.status(ec.status).headers(retryAfterHeaders(details))
            .body(ApiResponse.failWithDetails(ec, e.message, details))
    }

    /** 요청을 제한한 응답에는 몇 초 뒤에 다시 시도할 수 있는지 Retry-After 헤더로도 알려 준다. */
    private fun retryAfterHeaders(details: Map<String, Any>): HttpHeaders = HttpHeaders().apply {
        (details[AuthRateLimiter.RETRY_AFTER_SECONDS] as? Long)?.let { set(HttpHeaders.RETRY_AFTER, it.toString()) }
    }

    /** @Valid 요청 본문 검증 실패 (필드 제약 위반) */
    @ExceptionHandler(MethodArgumentNotValidException::class)
    fun handleValidation(e: MethodArgumentNotValidException): FailureResponse {
        val message = e.bindingResult.fieldErrors.joinToString(", ") { "${it.field}: ${it.defaultMessage}" }
        return reject(CommonExceptionCode.INVALID_INPUT, logDetail = message, message = message)
    }

    /** Refresh 등에서 JWT 만료. 필터의 만료 토큰은 BusinessException으로 먼저 처리된다 */
    @ExceptionHandler(ExpiredJwtException::class)
    fun handleExpiredJwt(e: ExpiredJwtException): FailureResponse =
        reject(AuthExceptionCode.TOKEN_EXPIRED, logDetail = e.message)

    /** JWT 서명 불일치·형식 오류 등 만료 이외의 토큰 문제 */
    @ExceptionHandler(JwtException::class)
    fun handleJwt(e: JwtException): FailureResponse =
        reject(AuthExceptionCode.TOKEN_INVALID, logDetail = e.message)

    /** 시큐리티 인증 실패. 주로 @PreAuthorize 등 컨트롤러 구간. 필터 401은 EntryPoint가 처리 */
    @ExceptionHandler(AuthenticationException::class)
    fun handleAuthentication(e: AuthenticationException): FailureResponse =
        reject(AuthExceptionCode.AUTHENTICATION_FAILED, logDetail = "AuthenticationException: ${e.message}")

    /** 인증은 됐으나 권한 부족. 주로 @PreAuthorize(hasRole) 실패. 필터 403은 AccessDeniedHandler */
    @ExceptionHandler(AccessDeniedException::class)
    fun handleAccessDenied(e: AccessDeniedException): FailureResponse =
        reject(AuthExceptionCode.ACCESS_DENIED, logDetail = "AccessDeniedException: ${e.message}")

    /** 업로드 파일이 max-file-size를 넘은 경우. 안 잡으면 500이 나간다. */
    @ExceptionHandler(MaxUploadSizeExceededException::class)
    fun handleFileTooLarge(e: MaxUploadSizeExceededException): FailureResponse =
        reject(CommonExceptionCode.FILE_TOO_LARGE, logDetail = "업로드 크기 초과: ${e.message}")

    /** 요청 본문을 읽지 못한 경우(깨진 JSON, 잘못된 enum 등). 원문 메시지는 노출하지 않는다. */
    @ExceptionHandler(HttpMessageNotReadableException::class)
    fun handleUnreadableBody(e: HttpMessageNotReadableException): FailureResponse =
        reject(
            CommonExceptionCode.INVALID_INPUT,
            logDetail = "본문을 읽지 못함: ${e.message}",
            message = "요청 형식이 올바르지 않습니다.",
        )

    /** 경로 변수·쿼리 파라미터 타입이 맞지 않는 경우. (예: UUID 자리에 문자열) */
    @ExceptionHandler(MethodArgumentTypeMismatchException::class)
    fun handleTypeMismatch(e: MethodArgumentTypeMismatchException): FailureResponse =
        reject(
            CommonExceptionCode.INVALID_INPUT,
            logDetail = "파라미터 타입 불일치: ${e.name}=${e.value}",
            message = "'${e.name}' 값이 올바르지 않습니다.",
        )

    /** 필수 쿼리 파라미터가 빠진 경우 */
    @ExceptionHandler(MissingServletRequestParameterException::class)
    fun handleMissingParam(e: MissingServletRequestParameterException): FailureResponse =
        reject(
            CommonExceptionCode.INVALID_INPUT,
            logDetail = "필수 파라미터 누락: ${e.parameterName}",
            message = "'${e.parameterName}' 값이 필요합니다.",
        )

    /** sort에 엔티티에 없는 필드가 들어온 경우. 안 잡으면 500이라 여기서 400으로 바꾼다. */
    @ExceptionHandler(PropertyReferenceException::class)
    fun handleBadSort(e: PropertyReferenceException): FailureResponse =
        reject(
            CommonExceptionCode.INVALID_INPUT,
            logDetail = "잘못된 정렬 필드: ${e.propertyName}",
            message = "'${e.propertyName}' 으로는 정렬할 수 없습니다.",
        )

    /** 경로는 맞지만 메서드가 틀린 경우. 안 잡으면 500이라 여기서 405로 바꾼다. */
    @ExceptionHandler(HttpRequestMethodNotSupportedException::class)
    fun handleMethodNotAllowed(e: HttpRequestMethodNotSupportedException): FailureResponse =
        reject(CommonExceptionCode.METHOD_NOT_ALLOWED, logDetail = "지원하지 않는 메서드: ${e.method}")

    /** 매핑되지 않은 경로. 안 잡으면 500이라 여기서 404로 바꾼다. */
    @ExceptionHandler(NoResourceFoundException::class)
    fun handleNoResource(e: NoResourceFoundException): FailureResponse =
        reject(CommonExceptionCode.ENDPOINT_NOT_FOUND, logDetail = "없는 경로: ${e.resourcePath}")

    /**
     * @Query 로 직접 쓴 쿼리에 없는 정렬 필드가 들어온 경우.
     * Spring Data 는 이때 정렬 필드를 검증하지 않고 JPQL 에 그대로 붙이므로
     * PropertyReferenceException 이 아니라 Hibernate 예외가 래핑되어 올라온다.
     * 공개 목록에서도 ?sort= 만으로 500이 나던 것을 400으로 바꾼다.
     *
     * 같은 예외 타입이 진짜 서버 버그일 수도 있어, 원인이 경로 해석 실패일 때만 400으로 본다.
     */
    @ExceptionHandler(InvalidDataAccessApiUsageException::class)
    fun handleInvalidDataAccess(e: InvalidDataAccessApiUsageException): FailureResponse =
        if (hasUnknownPathCause(e)) {
            reject(
                CommonExceptionCode.INVALID_INPUT,
                logDetail = "잘못된 정렬 필드: ${e.message}",
                message = "정렬할 수 없는 필드입니다.",
            )
        } else {
            handleUnknown(e)
        }

    /** 원인 사슬에 경로 해석 실패가 있는지 본다. 원인이 자기 자신을 가리키면 거기서 멈춘다. */
    private fun hasUnknownPathCause(e: Throwable): Boolean =
        generateSequence(e) { it.cause?.takeIf { cause -> cause !== it } }.any { it is UnknownPathException }

    /** 위에서 못 잡은 모든 예외. 원문 메시지는 노출하지 않는다 */
    @ExceptionHandler(Exception::class)
    fun handleUnknown(e: Exception): FailureResponse {
        log.error("[UNHANDLED] 처리되지 않은 예외", e)
        return respond(CommonExceptionCode.INTERNAL_ERROR)
    }

    /** 경고 로그를 남기고 응답한다. 응답 메시지를 따로 안 주면 에러 코드의 기본 메시지를 쓴다. */
    private fun reject(ec: ExceptionCode, logDetail: Any?, message: String? = ec.message): FailureResponse {
        log.warn("[{}] {}", ec.code, logDetail)
        return respond(ec, message)
    }

    private fun respond(ec: ExceptionCode, message: String? = ec.message): FailureResponse =
        ResponseEntity.status(ec.status).body(ApiResponse.fail(ec, message))
}
