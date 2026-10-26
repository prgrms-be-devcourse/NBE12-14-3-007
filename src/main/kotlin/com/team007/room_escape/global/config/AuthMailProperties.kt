package com.team007.room_escape.global.config

import org.springframework.boot.context.properties.ConfigurationProperties

/** auth-mail.* 설정. 인증 메일의 만료·재발송·인증 유지 시간 */
@ConfigurationProperties(prefix = "auth-mail")
data class AuthMailProperties(
    val expireMinutes: Long,
    val resendCooldownSeconds: Long,
    val verifiedValidMinutes: Long,
) {

    /** 캐시 보관 시간. 두 단계 중 긴 쪽보다 넉넉해야 "만료"와 "없음"을 구분할 수 있다. */
    val cacheRetentionMinutes: Long get() = maxOf(expireMinutes, verifiedValidMinutes) + 1

    // TODO(java-compat): Java EmailVerificationService가 쓰는 동안만 둔다. Kotlin으로 옮기면 지운다.
    @Deprecated("프로퍼티 expireMinutes를 쓰세요", ReplaceWith("expireMinutes"))
    fun expireMinutes(): Long = expireMinutes

    @Deprecated("프로퍼티 resendCooldownSeconds를 쓰세요", ReplaceWith("resendCooldownSeconds"))
    fun resendCooldownSeconds(): Long = resendCooldownSeconds

    @Deprecated("프로퍼티 verifiedValidMinutes를 쓰세요", ReplaceWith("verifiedValidMinutes"))
    fun verifiedValidMinutes(): Long = verifiedValidMinutes

    @Deprecated("프로퍼티 cacheRetentionMinutes를 쓰세요", ReplaceWith("cacheRetentionMinutes"))
    fun cacheRetentionMinutes(): Long = cacheRetentionMinutes
}
