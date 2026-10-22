package com.team007.room_escape.global.storage

import com.team007.room_escape.global.config.R2Properties
import org.springframework.stereotype.Component

/** 저장 key를 공개 URL로 바꾼다. R2에 접근하지 않아서 URL만 필요한 서비스는 이것만 주입받으면 된다. */
@Component
class ImageUrlResolver(
    private val properties: R2Properties
) {

    /** 비어 있으면 null, 이미 URL로 저장된 옛 값이나 외부 URL은 그대로 돌려준다. */
    fun resolve(key: String?): String? {
        if (key == null || isBlank(key)) {
            return null
        }
        if (isUrl(key)) {
            return key
        }
        return "${prefix()}/$key"
    }

    /** 요청으로 들어온 이미지 값을 key로 되돌린다. 화면이 받은 URL을 그대로 보내기도 해서 앞부분을 뗀다. */
    fun toKey(value: String?): String? {
        if (value == null || isBlank(value)) {
            return value
        }
        val prefix = prefix() + "/"
        return if (value.startsWith(prefix)) value.substring(prefix.length) else value
    }

    private fun isUrl(value: String): Boolean {
        return value.startsWith("http://") || value.startsWith("https://")
    }

    private fun prefix(): String {
        val publicUrl = properties.publicUrl()
        return if (publicUrl.endsWith("/")) publicUrl.substring(0, publicUrl.length - 1) else publicUrl
    }

    // Kotlin의 isBlank()는 NBSP도 공백으로 봐서, Java String.isBlank()와 같은 기준으로 맞춘다.
    private fun isBlank(value: String): Boolean {
        return value.all { Character.isWhitespace(it) }
    }
}
