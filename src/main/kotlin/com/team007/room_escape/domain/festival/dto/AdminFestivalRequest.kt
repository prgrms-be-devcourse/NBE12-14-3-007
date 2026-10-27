package com.team007.room_escape.domain.festival.dto

import java.time.LocalDateTime
import java.util.Locale
import com.team007.room_escape.domain.festival.infra.entity.FestivalRegion
import com.team007.room_escape.domain.festival.infra.entity.ProviderType
import io.swagger.v3.oas.annotations.media.Schema
import jakarta.validation.constraints.NotBlank
import jakarta.validation.constraints.NotNull
import jakarta.validation.constraints.Size
import com.team007.room_escape.global.util.isBlankLikeJava
import com.team007.room_escape.global.util.trimLikeJava

class AdminFestivalRequest private constructor() {
    /** 관리자 행사 검색 조건. 모든 항목이 선택이며, 비우면 전체를 조회한다. */
    @Schema(name = "AdminFestivalSearchRequest", description = "관리자 행사 검색 조건")
    @JvmRecord
    data class Search(
        @field:Schema(description = "행사명·기관명·상세주소 검색어. 부분 일치, 대소문자 무시", example = "수원")
        val keyword: String?,

        @field:Schema(description = "데이터 출처. PUBLIC(공공) 또는 MEMBER(회원 제보)", example = "PUBLIC")
        val providerType: ProviderType?,

        @field:Schema(description = "종료된 행사 제외 여부. 기본값 false", defaultValue = "false")
        val excludeClosed: Boolean?,

        @field:Schema(description = "삭제된 행사 포함 여부. 기본값 false", defaultValue = "false")
        val includeDeleted: Boolean?,

        @field:Schema(description = "삭제된 행사만 조회 여부. 기본값 false", defaultValue = "false")
        val deletedOnly: Boolean?
    ) {
        /** 검색어가 없으면 null 대신 빈 문자열을 돌려준다. */
        fun keywordOrEmpty(): String {
            if (keyword == null || keyword.isBlankLikeJava()) return ""
            return keyword.trimLikeJava().lowercase(Locale.ROOT)
        }

        fun excludeClosedOrFalse(): Boolean = excludeClosed == true

        fun includeDeletedOrFalse(): Boolean = includeDeleted == true

        fun deletedOnlyOrFalse(): Boolean = deletedOnly == true
    }

    /** 관리자 행사 수정 요청. 보낸 값으로 전부 덮어쓰며, 출처와 작성자는 바꿀 수 없다. */
    @Schema(name = "AdminFestivalUpdateRequest", description = "관리자 행사 수정 요청")
    @JvmRecord
    data class Update(
        @field:NotBlank(message = "행사 이름은 필수입니다.")
        @field:Size(max = 255, message = "행사 이름은 255자 이하여야 합니다.")
        @field:Schema(description = "행사 이름", example = "수원 화성 문화제")
        val title: String?,

        @field:NotBlank(message = "행사 카테고리는 필수입니다.")
        @field:Size(max = 50, message = "행사 카테고리는 50자 이하여야 합니다.")
        @field:Schema(description = "행사 카테고리", example = "축제")
        val category: String?,

        @field:Schema(description = "행사 소개", example = "화성행궁 일대에서 열리는 가을 축제입니다.")
        val festivalContent: String?,

        @field:Size(max = 2048, message = "행사 참고 링크는 2,048자 이하여야 합니다.")
        @field:Schema(description = "행사 참고 링크", example = "https://example.com/festival")
        val referenceUrl: String?,

        @field:NotNull(message = "행사 지역은 필수입니다.")
        @field:Schema(description = "행사 지역", example = "GYEONGGI_SUWON")
        val region: FestivalRegion?,

        @field:Size(max = 255, message = "행사 상세 주소는 255자 이하여야 합니다.")
        @field:Schema(description = "행사 상세 주소", example = "수원시 팔달구 정조로 825")
        val regionDetail: String?,

        @field:Size(max = 2048, message = "이미지 URL은 2,048자 이하여야 합니다.")
        @field:Schema(description = "행사 이미지 URL")
        val imgUrl: String?,

        @field:NotNull(message = "행사 시작 일시는 필수입니다.")
        @field:Schema(description = "행사 시작 일시", example = "2026-10-01T10:00:00")
        val beginDe: LocalDateTime?,

        @field:NotNull(message = "행사 종료 일시는 필수입니다.")
        @field:Schema(description = "행사 종료 일시", example = "2026-10-05T18:00:00")
        val endDe: LocalDateTime?,

        @field:Size(max = 255)
        @field:Schema(description = "참가 비용 정보", example = "무료")
        val partcptExpnInfo: String?,

        @field:Size(max = 255)
        @field:Schema(description = "전화번호", example = "031-123-4567")
        val telnoInfo: String?
    ) {
        /** 종료일이 시작일보다 앞서면 진행 상태 계산이 틀어진다. */
        fun hasValidPeriod(): Boolean {
            val begin = beginDe
            val end = endDe
            // 비어 있는 값은 각 필드의 @NotNull이 따로 알린다.
            return begin == null || end == null || !end.isBefore(begin)
        }
    }
}
