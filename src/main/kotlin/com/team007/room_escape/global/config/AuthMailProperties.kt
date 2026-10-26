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
}
