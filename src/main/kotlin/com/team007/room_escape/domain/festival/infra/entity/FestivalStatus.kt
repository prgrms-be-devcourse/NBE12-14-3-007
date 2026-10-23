package com.team007.room_escape.domain.festival.infra.entity

import java.time.LocalDateTime

enum class FestivalStatus {
    OPEN,
    CLOSED;

    companion object {
        @JvmStatic
        fun from(endDe: LocalDateTime?): FestivalStatus {
            if (endDe == null) {
                return OPEN
            }

            return if (endDe.isBefore(LocalDateTime.now())) CLOSED else OPEN
        }
    }
}
