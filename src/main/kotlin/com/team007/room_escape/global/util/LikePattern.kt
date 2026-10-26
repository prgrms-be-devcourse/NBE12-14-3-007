package com.team007.room_escape.global.util

/** LIKE 쿼리에 함께 쓰는 escape 문자. 백슬래시는 HQL 문자열에서 다시 해석돼 헷갈려서 '!'를 쓴다. */
const val LIKE_ESCAPE = '!'

/**
 * LIKE 검색어 안의 와일드카드(%, _)와 escape 문자(!)를 글자 그대로 찾도록 바꾼다.
 * 쿼리의 LIKE에는 ESCAPE '!'를 함께 써야 한다. 그대로 넣으면 "%"는 모든 행을, "_"는 아무 글자 하나를 찾는다.
 */
fun String.escapeLikePattern(): String = buildString(length) {
    for (c in this@escapeLikePattern) {
        if (c == LIKE_ESCAPE || c == '%' || c == '_') append(LIKE_ESCAPE)
        append(c)
    }
}
