package com.team007.room_escape.global.storage

import com.team007.room_escape.global.config.R2Properties
import com.team007.room_escape.global.util.isBlankLikeJava
import org.springframework.stereotype.Component

/** 저장 key를 공개 URL로 바꾼다. R2에 접근하지 않아서 URL만 필요한 서비스는 이것만 주입받으면 된다. */
@Component
class ImageUrlResolver(
    private val properties: R2Properties,
) {

    /** 비어 있으면 null, 이미 URL로 저장된 옛 값이나 외부 URL은 그대로 돌려준다. */
    fun resolve(key: String?): String? = when {
        key == null || key.isBlankLikeJava() -> null
        key.startsWith("http://") || key.startsWith("https://") -> key
        else -> "${prefix()}/$key"
    }

    /** 요청으로 들어온 이미지 값을 key로 되돌린다. 화면이 받은 URL을 그대로 보내기도 해서 앞부분을 뗀다. */
    fun toKey(value: String?): String? =
        if (value == null || value.isBlankLikeJava()) value else value.removePrefix("${prefix()}/")

    private fun prefix(): String = properties.publicUrl.removeSuffix("/")
}
