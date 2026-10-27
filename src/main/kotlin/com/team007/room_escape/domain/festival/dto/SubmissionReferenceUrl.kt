package com.team007.room_escape.domain.festival.dto

import java.net.URI
import com.team007.room_escape.global.util.trimLikeJava

/** URL 형식만 검사한다. 외부 서버에 접속하거나 콘텐츠의 정확성을 보장하지 않는다. */
object SubmissionReferenceUrl {
    const val INVALID_MESSAGE = "행사 참고 링크는 호스트가 있는 http:// 또는 https:// 주소로 입력해 주세요."

    fun isValid(value: String): Boolean {
        val normalized = value.trimLikeJava().replaceFirst(Regex("/+$"), "")
        return runCatching {
            val uri = URI(normalized)
            uri.scheme?.lowercase() in setOf("http", "https") &&
                !uri.host.isNullOrBlank() && uri.rawUserInfo == null &&
                (uri.port == -1 || uri.port in 0..65535)
        }.getOrDefault(false)
    }
}
