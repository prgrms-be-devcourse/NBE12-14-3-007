package com.team007.room_escape.domain.inquiry.dto

import com.team007.room_escape.domain.inquiry.infra.entity.InquiryCategory
import com.team007.room_escape.domain.inquiry.infra.entity.InquiryStatus
import com.team007.room_escape.global.util.isBlankLikeJava
import io.swagger.v3.oas.annotations.media.Schema
import jakarta.validation.constraints.NotBlank
import jakarta.validation.constraints.Size
import java.util.Locale

class AdminInquiryRequest private constructor() {

    /** 관리자 문의 검색 조건. 모든 항목이 선택이며, 비우면 전체를 조회한다. */
    @Schema(name = "AdminInquirySearchRequest", description = "관리자 문의 검색 조건")
    data class Search(

        @field:Schema(description = "제목 검색어. 부분 일치, 대소문자 무시", example = "취소")
        val title: String?,

        @field:Schema(description = "답변 상태. PENDING(답변 대기) 또는 ANSWERED(답변 완료)", example = "PENDING")
        val status: InquiryStatus?,

        @field:Schema(description = "접수 종류. QUESTION(일반 문의), REPORT(신고), TIP(제보)", example = "REPORT")
        val category: InquiryCategory?,

        @field:Schema(description = "삭제된 문의 포함 여부. 기본값 false", example = "false", defaultValue = "false")
        val includeDeleted: Boolean?
    ) {

        /**
         * 앞뒤 공백을 지우고 소문자로 맞춘다.
         * 검색어가 없으면 빈 문자열을 돌려준다. LIKE '%%' 가 되어 전체가 조회된다.
         */
        fun titleOrEmpty(): String =
            // Java String.trim()과 같은 기준(U+0020 이하)으로 자른다.
            title?.takeUnless { it.isBlankLikeJava() }?.trim { it <= ' ' }?.lowercase(Locale.ROOT).orEmpty()

        fun includeDeletedOrFalse(): Boolean = includeDeleted == true
    }

    /**
     * 관리자 답변 등록·수정 요청.
     * 이미 답변이 있으면 덮어쓴다. 오타를 고칠 방법이 없으면 곤란하기 때문이다.
     */
    @Schema(name = "AdminInquiryAnswerRequest", description = "관리자 문의 답변 요청")
    data class Answer(

        @field:NotBlank
        @field:Size(max = 2000)
        @field:Schema(
            description = "답변 내용",
            example = "확인 결과 중복 등록이 맞아 해당 제보를 숨김 처리했습니다."
        )
        val answer: String?
    ) {

        /** 앞뒤 공백은 저장하지 않는다. (Java String.trim()과 같은 기준: U+0020 이하) */
        fun trimmed(): String = requireNotNull(answer).trim { it <= ' ' }
    }
}
