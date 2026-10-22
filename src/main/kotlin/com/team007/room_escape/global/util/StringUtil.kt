package com.team007.room_escape.global.util

/** 빈 문자열과 null을 null 하나로 모은다. Spring의 StringUtils와 헷갈리지 않게 StringUtil로 지었다. */
object StringUtil {

    /** null이거나 공백뿐이면 null, 아니면 그대로 돌려준다. */
    @JvmStatic
    fun emptyToNull(value: String?): String? {
        // Kotlin의 isBlank()는 NBSP 같은 공백도 공백으로 봐서, Java String.isBlank()와 같은 기준으로 맞춘다.
        return if (value == null || value.all { Character.isWhitespace(it) }) null else value
    }
}
