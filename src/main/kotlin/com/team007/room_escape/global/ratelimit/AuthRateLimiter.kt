package com.team007.room_escape.global.ratelimit

import com.team007.room_escape.global.exception.BusinessException
import com.team007.room_escape.global.exception.ExceptionCode
import com.team007.room_escape.global.response.code.AuthExceptionCode
import jakarta.servlet.http.HttpServletRequest
import org.springframework.boot.context.properties.ConfigurationProperties
import org.springframework.stereotype.Component
import java.time.Duration
import java.util.Locale

/** auth-rate-limit.* 설정. 로그인 실패와 가입 시도 횟수 제한. */
@ConfigurationProperties(prefix = "auth-rate-limit")
data class AuthRateLimitProperties(
    /** 로그인 실패를 [loginWindow] 안에 이만큼 하면 구간이 끝날 때까지 막는다. */
    val loginMaxFailures: Int = 5,
    val loginWindow: Duration = Duration.ofMinutes(5),
    /** 같은 IP의 가입 시도를 [signupWindow] 안에 이만큼까지만 받는다. */
    val signupMaxAttempts: Int = 5,
    val signupWindow: Duration = Duration.ofHours(1),
)

/**
 * 로그인과 가입의 시도 횟수를 제한한다.
 *
 * - 로그인: 이메일(+IP)별로 틀린 횟수를 센다. 맞게 로그인하면 지운다.
 *   IP를 믿을 수 있으면 "이메일+IP"로, 아니면 이메일만으로 센다.
 * - 가입: IP별로 센다. IP를 믿을 수 없으면 제한하지 않는다. (전체 사용자가 한꺼번에 막히는 것을 피한다)
 */
@Component
class AuthRateLimiter(
    properties: AuthRateLimitProperties,
    private val clientIps: ClientIpResolver,
) {

    private val loginMaxFailures = properties.loginMaxFailures
    private val loginFailures = FixedWindowLimiter(properties.loginMaxFailures, properties.loginWindow)
    private val signups = FixedWindowLimiter(properties.signupMaxAttempts, properties.signupWindow)

    /**
     * 막혀 있으면 로그인을 시도하지 않고 거절한다. 비밀번호가 틀려서 실패하면 세고,
     * 그 응답에 몇 번 더 틀릴 수 있는지(remainingAttempts)를 담는다. 마지막 기회까지 틀리면 풀릴 때까지의 초도 함께 담는다.
     */
    fun <T> guardLogin(email: String?, request: HttpServletRequest, login: () -> T): T {
        val key = loginKey(email, clientIps.resolve(request))
        loginFailures.retryAfter(key)?.let { throw tooMany(AuthExceptionCode.TOO_MANY_LOGIN_ATTEMPTS, it) }

        val result = try {
            login()
        } catch (e: BusinessException) {
            // 가입하지 않은 이메일도 같은 코드로 실패하므로, 이메일이 있는지 없는지와 상관없이 똑같이 센다.
            if (e.exceptionCode == AuthExceptionCode.INVALID_CREDENTIALS) throw withRemaining(e, loginFailures.record(key), key)
            throw e
        }
        loginFailures.reset(key)
        return result
    }

    /** 가입 시도 한 번을 센다. 한도를 넘으면 거절한다. */
    fun requireSignupAllowed(request: HttpServletRequest) {
        val ip = clientIps.resolve(request) ?: return
        signups.tryAcquire(ip)?.let { throw tooMany(AuthExceptionCode.TOO_MANY_SIGNUPS, it) }
    }

    private fun withRemaining(e: BusinessException, failures: Int, key: String): BusinessException {
        val remaining = maxOf(0, loginMaxFailures - failures)
        val details = buildMap<String, Any> {
            put(REMAINING_ATTEMPTS, remaining)
            if (remaining == 0) loginFailures.retryAfter(key)?.let { put(RETRY_AFTER_SECONDS, secondsOf(it)) }
        }
        return BusinessException(e.exceptionCode, e.message, details)
    }

    private fun loginKey(email: String?, ip: String?): String {
        val normalized = email.orEmpty().trim().lowercase(Locale.ROOT)
        return if (ip == null) normalized else "$normalized|$ip"
    }

    private fun tooMany(code: ExceptionCode, retryAfter: Duration) = BusinessException(
        code,
        details = mapOf(RETRY_AFTER_SECONDS to secondsOf(retryAfter)),
    )

    /** 남은 시간은 올림해서, 알려 준 시간이 지난 뒤에는 반드시 풀려 있게 한다. */
    private fun secondsOf(duration: Duration): Long = maxOf(1L, (duration.toMillis() + 999) / 1000)

    companion object {
        /** 막힌 응답의 details 에 담는 다시 시도할 수 있을 때까지의 초. */
        const val RETRY_AFTER_SECONDS = "retryAfterSeconds"

        /** 비밀번호가 틀린 응답의 details 에 담는, 막히기 전까지 더 틀릴 수 있는 횟수. */
        const val REMAINING_ATTEMPTS = "remainingAttempts"
    }
}
