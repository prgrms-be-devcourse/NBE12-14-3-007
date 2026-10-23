package com.team007.room_escape.domain.inquiry.dto

import com.team007.room_escape.domain.inquiry.infra.entity.Inquiry
import com.team007.room_escape.domain.inquiry.infra.entity.InquiryCategory
import com.team007.room_escape.domain.inquiry.infra.entity.InquiryStatus
import com.team007.room_escape.domain.inquiry.infra.entity.InquiryTargetType
import io.swagger.v3.oas.annotations.media.Schema
import java.time.LocalDateTime
import java.util.UUID

class InquiryResponse private constructor() {

    /** 내 문의 목록 항목. 본문과 답변은 상세에서만 내려준다. */
    @Schema(name = "InquiryListItem", description = "내 문의 목록 항목")
    data class ListItem(
        val id: UUID?,
        val category: InquiryCategory,
        val targetType: InquiryTargetType?,
        val targetId: String?,
        val title: String,
        val status: InquiryStatus?,
        val createdAt: LocalDateTime?
    ) {

        companion object {

            @JvmStatic
            fun from(inquiry: Inquiry): ListItem {
                return ListItem(
                    id = inquiry.id,
                    category = inquiry.category,
                    targetType = inquiry.targetType,
                    targetId = inquiry.targetId,
                    title = inquiry.title,
                    status = inquiry.status,
                    createdAt = inquiry.createdAt
                )
            }
        }
    }

    /** 문의 상세. 등록·수정 응답도 같은 모양이다. */
    @Schema(name = "InquiryDetail", description = "문의 상세")
    data class Detail(
        val id: UUID?,
        val category: InquiryCategory,
        val targetType: InquiryTargetType?,
        val targetId: String?,
        val title: String,
        val content: String,
        /** 공개 URL. 첨부가 없으면 null */
        val img: String?,
        val status: InquiryStatus?,
        /** 관리자 답변. 아직 답변 전이면 null */
        val answer: String?,
        val createdAt: LocalDateTime?
    ) {

        companion object {

            @JvmStatic
            fun from(inquiry: Inquiry, imgUrl: String?): Detail {
                return Detail(
                    id = inquiry.id,
                    category = inquiry.category,
                    targetType = inquiry.targetType,
                    targetId = inquiry.targetId,
                    title = inquiry.title,
                    content = inquiry.content,
                    img = imgUrl,
                    status = inquiry.status,
                    answer = inquiry.answer,
                    createdAt = inquiry.createdAt
                )
            }
        }
    }
}
