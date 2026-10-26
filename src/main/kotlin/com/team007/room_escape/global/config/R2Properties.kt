package com.team007.room_escape.global.config

import org.springframework.boot.context.properties.ConfigurationProperties

/** r2.* 설정. R2 접속 정보와 공개 URL 앞부분 */
@ConfigurationProperties(prefix = "r2")
data class R2Properties(
    val accountId: String,
    val accessKey: String,
    val secretKey: String,
    val bucket: String,
    val publicUrl: String,
) {

    /** R2의 S3 호환 엔드포인트. 계정마다 주소가 다르다. */
    val endpoint: String get() = "https://$accountId.r2.cloudflarestorage.com"

    // TODO(java-compat): Java FestivalService가 쓰는 동안만 둔다. Kotlin으로 옮기면 지운다.
    @Deprecated("프로퍼티 publicUrl을 쓰세요", ReplaceWith("publicUrl"))
    fun publicUrl(): String = publicUrl
}
