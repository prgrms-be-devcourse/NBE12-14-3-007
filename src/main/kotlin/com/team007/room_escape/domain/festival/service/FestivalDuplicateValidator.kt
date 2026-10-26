package com.team007.room_escape.domain.festival.service

import com.team007.room_escape.domain.festival.infra.entity.FestivalRegion
import com.team007.room_escape.domain.festival.infra.repository.FestivalRepository
import com.team007.room_escape.global.exception.BusinessException
import com.team007.room_escape.global.response.code.FestivalExceptionCode
import org.springframework.stereotype.Component
import java.time.LocalDateTime
import java.util.*

/** 등록·수정·복구에서 같은 중복 기준과 잠금 키를 사용한다. 호출자는 트랜잭션을 유지한다. */
@Component
class FestivalDuplicateValidator(
    private val repository: FestivalRepository
) {
    fun normalizeReferenceUrl(url: String): String {
        // Java String.trim()과 같은 문자 범위만 제거한다.
        return url.trim { it <= ' ' }.replaceFirst(Regex("/+$"), "")
    }

    fun validate(
        currentId: Long?,
        beginDe: LocalDateTime,
        endDe: LocalDateTime,
        region: FestivalRegion,
        referenceUrl: String
    ) {
        val begin = beginDe.toLocalDate()
        val end = endDe.toLocalDate()
        val url = normalizeReferenceUrl(referenceUrl)
        repository.lockSubmissionDuplicateKey(Objects.hash(begin, end, region.name, url).toLong())
        if (repository.existsSubmissionDuplicate(
                currentId, begin.atStartOfDay(),
                begin.plusDays(1).atStartOfDay(),
                end.atStartOfDay(), end.plusDays(1).atStartOfDay(),
                region.name, url
            )) {
            throw BusinessException(FestivalExceptionCode.DUPLICATE_FESTIVAL)
        }
    }
}
