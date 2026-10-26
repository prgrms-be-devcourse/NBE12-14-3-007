package com.team007.room_escape.support

import com.team007.room_escape.domain.festival.infra.entity.Festival

/** 저장된 행사의 ID. 저장 전이면 !! 대신 이유가 보이는 예외를 던진다. */
val Festival.requiredId: Long
    get() = checkNotNull(id) { "저장되지 않은 행사입니다: $title" }
