package com.team007.room_escape.domain.deletion.infra.entity

import com.team007.room_escape.global.exception.BusinessException
import com.team007.room_escape.global.response.code.DeletionExceptionCode
import com.team007.room_escape.global.util.isNullOrBlankLikeJava
import java.util.UUID

/** 신고 대상과 달리 회원·문의는 콘텐츠 삭제 대상에 포함하지 않는다.  */
enum class DeletionTargetType {
    FESTIVAL, POST, COMMENT, COMMUNITY_POST, COMMUNITY_COMMENT;

    fun normalizeId(id: String?): String {
        if (id.isNullOrBlankLikeJava()) {
            throw BusinessException(DeletionExceptionCode.INVALID_TARGET_ID)
        }
        try {
            if (this == DeletionTargetType.POST || this == DeletionTargetType.COMMUNITY_POST) {
                val normalized = UUID.fromString(id.trim { it <= ' ' }).toString()
                require(normalized.equals(id.trim { it <= ' ' }, ignoreCase = true))
                return normalized
            }
            val number = id.trim { it <= ' ' }.toLong()
            require(number > 0)
            return number.toString()
        } catch (exception: IllegalArgumentException) {
            throw BusinessException(DeletionExceptionCode.INVALID_TARGET_ID)
        }
    }
}
