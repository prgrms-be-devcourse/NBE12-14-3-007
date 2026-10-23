package com.team007.room_escape.domain.deletion.infra.entity

enum class DeletionReason(val description: String) {
    AUTHOR_REQUEST("작성자 직접 삭제"),
    DUPLICATE("중복 등록"),
    INCORRECT_INFORMATION("잘못된 정보"),
    SPAM("도배·스팸"),
    ABUSIVE_CONTENT("욕설·비방"),
    PRIVACY_EXPOSURE("개인정보 노출"),
    OTHER("기타"),
    ADMIN_RESTORE("관리자 복구");
}
