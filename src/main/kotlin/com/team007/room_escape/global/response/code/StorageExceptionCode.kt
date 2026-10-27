package com.team007.room_escape.global.response.code

import com.team007.room_escape.global.exception.ExceptionCode
import org.springframework.http.HttpStatus

enum class StorageExceptionCode(
    override val code: String,
    override val status: HttpStatus,
    override val message: String
) : ExceptionCode {
    IMAGE_EXPIRED("STOR004", HttpStatus.CONFLICT, "이미지 보관 기간이 만료되어 정리 중이거나 삭제되었습니다. 이미지를 다시 업로드해 주세요."),

    EMPTY_FILE("STOR000", HttpStatus.BAD_REQUEST, "업로드할 파일이 비어 있습니다."),
    UNSUPPORTED_FILE_TYPE("STOR001", HttpStatus.BAD_REQUEST, "지원하지 않는 파일 형식입니다."),
    UPLOAD_FAILED("STOR002", HttpStatus.INTERNAL_SERVER_ERROR, "파일 업로드에 실패했습니다."),
    /** 남이 올린 이미지 key를 자기 데이터에 넣으면, 나중에 교체할 때 남의 파일이 지워진다 */
    IMAGE_NOT_OWNED("STOR003", HttpStatus.FORBIDDEN, "본인이 업로드한 이미지만 사용할 수 있습니다."),
    INVALID_IMAGE("STOR005", HttpStatus.BAD_REQUEST, "올바른 이미지 파일이 아닙니다. JPG, PNG, WEBP 이미지만 올릴 수 있습니다."),
    IMAGE_TOO_LARGE("STOR006", HttpStatus.BAD_REQUEST, "이미지 해상도가 너무 큽니다. 더 작은 이미지를 올려 주세요."),
    UPLOAD_LIMIT_EXCEEDED("STOR007", HttpStatus.TOO_MANY_REQUESTS, "하루에 올릴 수 있는 이미지 수를 넘었습니다. 내일 다시 시도해 주세요.")
}
