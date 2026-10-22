package com.team007.room_escape.global.exception

import com.team007.room_escape.global.response.ApiResponse
import com.team007.room_escape.global.response.code.AuthExceptionCode
import com.team007.room_escape.global.response.code.CommonExceptionCode
import io.jsonwebtoken.ExpiredJwtException
import io.jsonwebtoken.JwtException
import org.hibernate.query.sqm.UnknownPathException
import org.slf4j.LoggerFactory
import org.springframework.dao.InvalidDataAccessApiUsageException
import org.springframework.data.core.PropertyReferenceException
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

/** 컨트롤러·필터 예외를 ApiResponse 형식으로 통일해 응답한다. 필터 예외도 HandlerExceptionResolver로 들어온다. */
@RestControllerAdvice
class GlobalExceptionHandler {

    private val log = LoggerFactory.getLogger(javaClass)

    /** 서비스에서 의도적으로 던진 비즈니스 예외 (AUTH/MEMBER 등 ExceptionCode 전부) */
    @ExceptionHandler(BusinessException::class)
    fun handleBusiness(e: BusinessException): ResponseEntity<ApiResponse<Void?>> {
        val ec = e.exceptionCode
        logByStatus(ec, e)
        return ResponseEntity.status(ec.status)
            .body(ApiResponse.error(e.message, ec.code))
    }

    /** @Valid 요청 본문 검증 실패 (필드 제약 위반) */
    @ExceptionHandler(MethodArgumentNotValidException::class)
    fun handleValidation(e: MethodArgumentNotValidException): ResponseEntity<ApiResponse<Void?>> {
        val message = e.bindingResult.fieldErrors
            .joinToString(", ") { fe -> fe.field + ": " + fe.defaultMessage }
        val ec = CommonExceptionCode.INVALID_INPUT
        log.warn("[{}] {}", ec.code, message)
        return ResponseEntity.status(ec.status)
            .body(ApiResponse.error(message, ec.code))
    }

    /** Refresh 등에서 JWT 만료. 필터의 만료 토큰은 BusinessException으로 먼저 처리된다 */
    @ExceptionHandler(ExpiredJwtException::class)
    fun handleExpiredJwt(e: ExpiredJwtException): ResponseEntity<ApiResponse<Void?>> {
        val ec = AuthExceptionCode.TOKEN_EXPIRED
        log.warn("[{}] {}", ec.code, e.message)
        return ResponseEntity.status(ec.status)
            .body(ApiResponse.error(ec.message, ec.code))
    }

    /** JWT 서명 불일치·형식 오류 등 만료 이외의 토큰 문제 */
    @ExceptionHandler(JwtException::class)
    fun handleJwt(e: JwtException): ResponseEntity<ApiResponse<Void?>> {
        val ec = AuthExceptionCode.TOKEN_INVALID
        log.warn("[{}] {}", ec.code, e.message)
        return ResponseEntity.status(ec.status)
            .body(ApiResponse.error(ec.message, ec.code))
    }

    /** 시큐리티 인증 실패. 주로 @PreAuthorize 등 컨트롤러 구간. 필터 401은 EntryPoint가 처리 */
    @ExceptionHandler(AuthenticationException::class)
    fun handleAuthentication(e: AuthenticationException): ResponseEntity<ApiResponse<Void?>> {
        val ec = AuthExceptionCode.AUTHENTICATION_FAILED
        log.warn("[{}] AuthenticationException: {}", ec.code, e.message)
        return ResponseEntity.status(ec.status)
            .body(ApiResponse.error(ec.message, ec.code))
    }

    /** 인증은 됐으나 권한 부족. 주로 @PreAuthorize(hasRole) 실패. 필터 403은 AccessDeniedHandler */
    @ExceptionHandler(AccessDeniedException::class)
    fun handleAccessDenied(e: AccessDeniedException): ResponseEntity<ApiResponse<Void?>> {
        val ec = AuthExceptionCode.ACCESS_DENIED
        log.warn("[{}] AccessDeniedException: {}", ec.code, e.message)
        return ResponseEntity.status(ec.status)
            .body(ApiResponse.error(ec.message, ec.code))
    }

    /** 업로드 파일이 max-file-size를 넘은 경우. 안 잡으면 500이 나간다. */
    @ExceptionHandler(MaxUploadSizeExceededException::class)
    fun handleFileTooLarge(e: MaxUploadSizeExceededException): ResponseEntity<ApiResponse<Void?>> {
        val ec = CommonExceptionCode.FILE_TOO_LARGE
        log.warn("[{}] 업로드 크기 초과: {}", ec.code, e.message)
        return ResponseEntity.status(ec.status)
            .body(ApiResponse.error(ec.message, ec.code))
    }

    /** 요청 본문을 읽지 못한 경우(깨진 JSON, 잘못된 enum 등). 원문 메시지는 노출하지 않는다. */
    @ExceptionHandler(HttpMessageNotReadableException::class)
    fun handleUnreadableBody(e: HttpMessageNotReadableException): ResponseEntity<ApiResponse<Void?>> {
        val ec = CommonExceptionCode.INVALID_INPUT
        log.warn("[{}] 본문을 읽지 못함: {}", ec.code, e.message)
        return ResponseEntity.status(ec.status)
            .body(ApiResponse.error("요청 형식이 올바르지 않습니다.", ec.code))
    }

    /** 경로 변수·쿼리 파라미터 타입이 맞지 않는 경우. (예: UUID 자리에 문자열) */
    @ExceptionHandler(MethodArgumentTypeMismatchException::class)
    fun handleTypeMismatch(e: MethodArgumentTypeMismatchException): ResponseEntity<ApiResponse<Void?>> {
        val ec = CommonExceptionCode.INVALID_INPUT
        log.warn("[{}] 파라미터 타입 불일치: {}={}", ec.code, e.name, e.value)
        return ResponseEntity.status(ec.status)
            .body(
                ApiResponse.error(
                    "'" + e.name + "' 값이 올바르지 않습니다.", ec.code
                )
            )
    }

    /** 필수 쿼리 파라미터가 빠진 경우 */
    @ExceptionHandler(MissingServletRequestParameterException::class)
    fun handleMissingParam(e: MissingServletRequestParameterException): ResponseEntity<ApiResponse<Void?>> {
        val ec = CommonExceptionCode.INVALID_INPUT
        log.warn("[{}] 필수 파라미터 누락: {}", ec.code, e.parameterName)
        return ResponseEntity.status(ec.status)
            .body(
                ApiResponse.error(
                    "'" + e.parameterName + "' 값이 필요합니다.", ec.code
                )
            )
    }

    /** sort에 엔티티에 없는 필드가 들어온 경우. 안 잡으면 500이라 여기서 400으로 바꾼다. */
    @ExceptionHandler(PropertyReferenceException::class)
    fun handleBadSort(e: PropertyReferenceException): ResponseEntity<ApiResponse<Void?>> {
        val ec = CommonExceptionCode.INVALID_INPUT
        log.warn("[{}] 잘못된 정렬 필드: {}", ec.code, e.propertyName)
        return ResponseEntity.status(ec.status)
            .body(
                ApiResponse.error(
                    "'" + e.propertyName + "' 으로는 정렬할 수 없습니다.", ec.code
                )
            )
    }

    /** 경로는 맞지만 메서드가 틀린 경우. 안 잡으면 500이라 여기서 405로 바꾼다. */
    @ExceptionHandler(HttpRequestMethodNotSupportedException::class)
    fun handleMethodNotAllowed(e: HttpRequestMethodNotSupportedException): ResponseEntity<ApiResponse<Void?>> {
        val ec = CommonExceptionCode.METHOD_NOT_ALLOWED
        log.warn("[{}] 지원하지 않는 메서드: {}", ec.code, e.method)
        return ResponseEntity.status(ec.status).body(ApiResponse.error(ec.message, ec.code))
    }

    /** 매핑되지 않은 경로. 안 잡으면 500이라 여기서 404로 바꾼다. */
    @ExceptionHandler(NoResourceFoundException::class)
    fun handleNoResource(e: NoResourceFoundException): ResponseEntity<ApiResponse<Void?>> {
        val ec = CommonExceptionCode.ENDPOINT_NOT_FOUND
        log.warn("[{}] 없는 경로: {}", ec.code, e.resourcePath)
        return ResponseEntity.status(ec.status).body(ApiResponse.error(ec.message, ec.code))
    }

    /**
     * @Query 로 직접 쓴 쿼리에 없는 정렬 필드가 들어온 경우.
     * Spring Data 는 이때 정렬 필드를 검증하지 않고 JPQL 에 그대로 붙이므로
     * PropertyReferenceException 이 아니라 Hibernate 예외가 래핑되어 올라온다.
     * 공개 목록에서도 ?sort= 만으로 500이 나던 것을 400으로 바꾼다.
     *
     * 같은 예외 타입이 진짜 서버 버그일 수도 있어, 원인이 경로 해석 실패일 때만 400으로 본다.
     */
    @ExceptionHandler(InvalidDataAccessApiUsageException::class)
    fun handleInvalidDataAccess(e: InvalidDataAccessApiUsageException): ResponseEntity<ApiResponse<Void?>> {
        if (!hasUnknownPathCause(e)) {
            return handleUnknown(e)
        }
        val ec = CommonExceptionCode.INVALID_INPUT
        log.warn("[{}] 잘못된 정렬 필드: {}", ec.code, e.message)
        return ResponseEntity.status(ec.status)
            .body(ApiResponse.error("정렬할 수 없는 필드입니다.", ec.code))
    }

    private fun hasUnknownPathCause(e: Throwable): Boolean {
        var cause: Throwable? = e
        while (cause != null) {
            if (cause is UnknownPathException) {
                return true
            }
            if (cause.cause === cause) {
                break
            }
            cause = cause.cause
        }
        return false
    }

    /** 위에서 못 잡은 모든 예외. 원문 메시지는 노출하지 않는다 */
    @ExceptionHandler(Exception::class)
    fun handleUnknown(e: Exception): ResponseEntity<ApiResponse<Void?>> {
        val ec = CommonExceptionCode.INTERNAL_ERROR
        log.error("[UNHANDLED] 처리되지 않은 예외", e)
        return ResponseEntity.status(ec.status)
            .body(ApiResponse.error(ec.message, ec.code))
    }

    /** 5xx는 스택트레이스까지, 4xx는 메시지만 남긴다 */
    private fun logByStatus(ec: ExceptionCode, e: Exception) {
        if (ec.status.is5xxServerError) {
            log.error("[{}] {}", ec.code, e.message, e)
        } else {
            log.warn("[{}] {}", ec.code, e.message)
        }
    }
}
