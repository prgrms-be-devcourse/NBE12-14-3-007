package com.team007.room_escape.domain.support.infra.entity

/** 고객센터 글 종류. */
enum class SupportArticleType {

    /** 공지사항. 최신순으로 보인다. */
    NOTICE,

    /** 자주 묻는 질문. 관리자가 정한 순서로 보인다. */
    FAQ,
}
