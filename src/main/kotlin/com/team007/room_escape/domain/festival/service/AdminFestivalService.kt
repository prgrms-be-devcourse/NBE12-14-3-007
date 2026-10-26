package com.team007.room_escape.domain.festival.service

import com.team007.room_escape.domain.deletion.infra.entity.DeletionTargetType
import com.team007.room_escape.domain.deletion.service.DeletionHistoryService
import com.team007.room_escape.domain.festival.dto.AdminFestivalRequest
import com.team007.room_escape.domain.festival.dto.AdminFestivalResponse
import com.team007.room_escape.domain.festival.dto.FestivalResponse
import com.team007.room_escape.domain.festival.infra.entity.Festival
import com.team007.room_escape.domain.festival.infra.repository.FestivalRepository
import com.team007.room_escape.global.exception.BusinessException
import com.team007.room_escape.global.response.code.CommonExceptionCode
import com.team007.room_escape.global.response.code.FestivalExceptionCode
import com.team007.room_escape.global.util.RichTextSanitizer
import org.springframework.data.domain.Page
import org.springframework.data.domain.Pageable
import org.springframework.data.domain.Sort
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@Service
class AdminFestivalService(
    private val festivalRepository: FestivalRepository,
    private val richTextSanitizer: RichTextSanitizer,
    private val deletionHistories: DeletionHistoryService
) {

    /** 관리자 행사 검색. 복구 대상을 찾도록 삭제된 행사도 볼 수 있다. */
    @Transactional(readOnly = true)
    fun search(
        request: AdminFestivalRequest.Search,
        pageable: Pageable
    ): Page<AdminFestivalResponse.ListItem> {
        validateSort(pageable.sort)

        val festivals = festivalRepository.searchForAdmin(
            request.keywordOrEmpty(),
            request.providerType,
            request.includeDeletedOrFalse(),
            request.excludeClosedOrFalse(),
            pageable
        )
        val histories = deletionHistories.findLatestForTargets(
            DeletionTargetType.FESTIVAL,
            festivals.content.filter { it.isDeleted() }.map { it.id.toString() }
        )
        return festivals.map { festival -> AdminFestivalResponse.ListItem.from(festival, histories[festival.id.toString()]) }
    }

    private fun validateSort(sort: Sort) {
        val hasUnknownField = sort.any { it.property !in SORTABLE }

        if (hasUnknownField) {
            throw BusinessException(CommonExceptionCode.INVALID_INPUT)
        }
    }

    /** 행사 수정. 동기화는 신규만 insert 해서 여기서 고친 값이 덮이지 않는다. */
    // TODO 동기화가 upsert로 바뀌면 관리자가 고친 행사는 건너뛰도록 표시가 필요하다.
    @Transactional
    fun update(
        festivalId: Long,
        request: AdminFestivalRequest.Update
    ): FestivalResponse.Detail {
        if (!request.hasValidPeriod()) {
            throw BusinessException(CommonExceptionCode.INVALID_INPUT)
        }

        // 삭제된 행사는 복구 후에 고칠 수 있다.
        val festival: Festival = festivalRepository.findByIdAndDeletedAtIsNull(festivalId)
            .orElseThrow { BusinessException(FestivalExceptionCode.FESTIVAL_NOT_FOUND) }

        // 진행 상태(status)는 종료일에서 다시 계산된다.
        festival.updateDetails(
            request.title,
            request.category,
            richTextSanitizer.sanitize(request.festivalContent),
            request.referenceUrl,
            request.region,
            request.regionDetail,
            request.imgUrl,
            request.beginDe,
            request.endDe,
            request.partcptExpnInfo,
            request.telnoInfo
        )

        return FestivalResponse.Detail.from(festival, 0, 0, null, 0, false, null)
    }

    companion object {
        /** 정렬 허용 필드. 엔티티에 없는 필드가 오면 500이 나서 먼저 거른다. */
        private val SORTABLE = setOf("beginDe", "endDe", "title", "createdAt")
    }
}
