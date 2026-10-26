package com.team007.room_escape.domain.inquiry.dto

import com.team007.room_escape.domain.inquiry.infra.entity.Inquiry
import com.team007.room_escape.domain.inquiry.infra.entity.InquiryCategory
import com.team007.room_escape.domain.inquiry.infra.entity.InquiryStatus
import com.team007.room_escape.domain.inquiry.infra.entity.InquiryTargetType
import com.team007.room_escape.domain.member.dto.MemberResponse
import io.swagger.v3.oas.annotations.media.Schema
import java.time.LocalDateTime
import java.util.UUID

class AdminInquiryResponse private constructor() {

    /** 관리자 문의 목록 항목. 본문과 답변은 상세에서만 내려준다. */
    @Schema(name = "AdminInquiryListItem", description = "관리자 문의 목록 항목")
    data class ListItem(

        @field:Schema(description = "문의 번호")
        val id: UUID?,

        @field:Schema(description = "접수 종류", example = "REPORT")
        val category: InquiryCategory,

        @field:Schema(description = "신고·제보 대상 종류. 일반 문의면 null", example = "FESTIVAL")
        val targetType: InquiryTargetType?,

        @field:Schema(description = "신고·제보 대상 ID. 일반 문의면 null", example = "123")
        val targetId: String?,

        @field:Schema(description = "제목")
        val title: String,

        @field:Schema(description = "작성자. 회원 정보가 없으면 null")
        val writer: MemberResponse.AdminInfo?,

        @field:Schema(description = "답변 상태", example = "PENDING")
        val status: InquiryStatus?,

        @field:Schema(description = "등록 시각")
        val createdAt: LocalDateTime?,

        @field:Schema(description = "삭제 시각. 삭제되지 않았으면 null")
        val deletedAt: LocalDateTime?
    ) {

        companion object {

            @JvmStatic
            fun from(inquiry: Inquiry, writerProfileImgUrl: String?): ListItem {
                return ListItem(
                    id = inquiry.id,
                    category = inquiry.category,
                    targetType = inquiry.targetType,
                    targetId = inquiry.targetId,
                    title = inquiry.title,
                    writer = inquiry.member?.let { MemberResponse.AdminInfo.from(it, writerProfileImgUrl) },
                    status = inquiry.status,
                    createdAt = inquiry.createdAt,
                    deletedAt = inquiry.deletedAt
                )
            }
        }
    }

    /** 관리자 문의 상세. 본문·첨부·답변까지 내려준다. */
    @Schema(name = "AdminInquiryDetail", description = "관리자 문의 상세")
    data class Detail(

        @field:Schema(description = "문의 번호")
        val id: UUID?,

        @field:Schema(description = "접수 종류", example = "REPORT")
        val category: InquiryCategory,

        @field:Schema(description = "신고·제보 대상 종류. 일반 문의면 null", example = "FESTIVAL")
        val targetType: InquiryTargetType?,

        @field:Schema(description = "신고·제보 대상 ID. 일반 문의면 null", example = "123")
        val targetId: String?,

        @field:Schema(description = "댓글 신고일 때 그 댓글이 달린 글 ID. 그 외에는 null")
        val targetPostId: UUID?,

        @field:Schema(description = "제목")
        val title: String,

        @field:Schema(description = "본문")
        val content: String,

        @field:Schema(description = "첨부 이미지 공개 URL. 첨부가 없으면 null")
        val img: String?,

        @field:Schema(description = "작성자. 회원 정보가 없으면 null")
        val writer: MemberResponse.AdminInfo?,

        @field:Schema(description = "답변 상태", example = "PENDING")
        val status: InquiryStatus?,

        @field:Schema(description = "관리자 답변. 아직 답변 전이면 null")
        val answer: String?,

        @field:Schema(description = "등록 시각")
        val createdAt: LocalDateTime?,

        @field:Schema(description = "최종 수정 시각")
        val updatedAt: LocalDateTime?,

        @field:Schema(description = "삭제 시각. 삭제되지 않았으면 null")
        val deletedAt: LocalDateTime?
    ) {

        companion object {

            @JvmStatic
            fun from(
                inquiry: Inquiry,
                imgUrl: String?,
                writerProfileImgUrl: String?,
                targetPostId: UUID?
            ): Detail {
                return Detail(
                    id = inquiry.id,
                    category = inquiry.category,
                    targetType = inquiry.targetType,
                    targetId = inquiry.targetId,
                    targetPostId = targetPostId,
                    title = inquiry.title,
                    content = inquiry.content,
                    img = imgUrl,
                    writer = inquiry.member?.let { MemberResponse.AdminInfo.from(it, writerProfileImgUrl) },
                    status = inquiry.status,
                    answer = inquiry.answer,
                    createdAt = inquiry.createdAt,
                    updatedAt = inquiry.updatedAt,
                    deletedAt = inquiry.deletedAt
                )
            }
        }
    }
}
