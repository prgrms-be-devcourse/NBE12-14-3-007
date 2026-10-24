package com.team007.room_escape.domain.like.infra.dto

/** 행사별 좋아요 수 (목록 조회 시 한 번에 세기 위한 결과) */
data class FestivalLikeCount(
    val festivalId: Long,
    val likeCount: Long,
)
