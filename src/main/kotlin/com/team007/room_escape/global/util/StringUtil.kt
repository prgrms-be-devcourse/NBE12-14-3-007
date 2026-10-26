package com.team007.room_escape.global.util

import kotlin.contracts.ExperimentalContracts
import kotlin.contracts.contract

/** Kotlin의 isBlank()는 NBSP 같은 공백도 공백으로 봐서, Java String.isBlank()와 같은 기준으로 맞춘다. */
fun String.isBlankLikeJava(): Boolean = all { Character.isWhitespace(it) }

/** Java String.trim()과 같은 기준(U+0020 이하)으로 앞뒤를 자른다. Kotlin trim()은 NBSP 같은 공백도 자른다. */
fun String.trimLikeJava(): String = trim { it <= ' ' }

/** null이거나 [isBlankLikeJava]면 true. false를 돌려주면 null이 아니라고 컴파일러가 알 수 있다. */
@OptIn(ExperimentalContracts::class)
fun String?.isNullOrBlankLikeJava(): Boolean {
    contract { returns(false) implies (this@isNullOrBlankLikeJava != null) }
    return this == null || isBlankLikeJava()
}

/** 빈 문자열과 null을 null 하나로 모은다. Spring의 StringUtils와 헷갈리지 않게 StringUtil로 지었다. */
object StringUtil {

    /** null이거나 공백뿐이면 null, 아니면 그대로 돌려준다. */
    @JvmStatic
    fun emptyToNull(value: String?): String? = value?.takeUnless { it.isBlankLikeJava() }
}
