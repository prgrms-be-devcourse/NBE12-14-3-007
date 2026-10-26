package com.team007.room_escape.domain.inquiry.dto

import com.fasterxml.jackson.annotation.JsonIgnore
import com.team007.room_escape.domain.inquiry.infra.entity.Inquiry
import com.team007.room_escape.domain.inquiry.infra.entity.InquiryCategory
import com.team007.room_escape.domain.inquiry.infra.entity.InquiryStatus
import com.team007.room_escape.domain.inquiry.infra.entity.InquiryTargetType
import com.team007.room_escape.domain.member.infra.entity.Member
import com.team007.room_escape.global.util.StringUtil.emptyToNull
import com.team007.room_escape.global.util.isNullOrBlankLikeJava
import io.swagger.v3.oas.annotations.media.Schema
import jakarta.validation.constraints.AssertTrue
import jakarta.validation.constraints.NotBlank
import jakarta.validation.constraints.NotNull
import jakarta.validation.constraints.Size

class InquiryRequest private constructor() {

    @Schema(name = "InquiryCreateRequest", description = "문의 등록 요청")
    data class Create(

        @field:NotNull
        @field:Schema(description = "접수 종류. QUESTION(일반 문의), REPORT(신고), TIP(제보)", example = "QUESTION")
        val category: InquiryCategory?,

        @field:Schema(description = "신고·제보 대상 종류. FESTIVAL, POST, COMMENT, MEMBER, COMMUNITY_POST, COMMUNITY_COMMENT. 일반 문의는 생략", example = "FESTIVAL")
        val targetType: InquiryTargetType?,

        @field:Size(max = 255)
        @field:Schema(description = "신고·제보 대상 ID. 일반 문의는 생략", example = "123")
        val targetId: String?,

        @field:NotBlank
        @field:Size(max = 255)
        @field:Schema(description = "제목", example = "행사 신청이 취소되지 않습니다")
        val title: String?,

        @field:NotBlank
        @field:Schema(description = "내용", example = "신청 취소 버튼을 눌러도 목록에 그대로 남아 있습니다.")
        val content: String?,

        @field:Size(max = 2048)
        @field:Schema(description = "첨부 이미지 key. 업로드 API가 돌려준 key", example = "inquiries/0befc150-badb-4674-a99d-ded96f03814a.png")
        val img: String?
    ) {
        @JsonIgnore
        @AssertTrue(message = "신고·제보 대상 종류와 대상 ID는 함께 입력해야 합니다.")
        fun isTargetValid(): Boolean {
            val noTargetId = targetId.isNullOrBlankLikeJava()
            val noTarget = targetType == null && noTargetId
            val completeTarget = targetType != null && !noTargetId

            return if (category == InquiryCategory.QUESTION) noTarget else noTarget || completeTarget
        }

        /** 검증을 통과한 요청으로 새 문의를 만든다. 비어 있는 대상 ID와 첨부는 null로 맞춘다. */
        fun toEntity(member: Member): Inquiry = Inquiry(
            member = member,
            category = requireNotNull(category),
            title = requireNotNull(title),
            content = requireNotNull(content),
            targetType = targetType,
            targetId = emptyToNull(targetId),
            img = emptyToNull(img),
            status = InquiryStatus.PENDING,
        )
    }

    /** 문의 수정 요청. 보낸 필드만 반영한다. */
    @Schema(name = "InquiryUpdateRequest", description = "문의 수정 요청")
    data class Update(

        @field:Schema(description = "접수 종류. 생략하면 변경하지 않는다", example = "REPORT")
        val category: InquiryCategory?,

        @field:Size(max = 255)
        @field:Schema(description = "제목. 생략하면 변경하지 않는다", example = "제목을 수정합니다")
        val title: String?,

        @field:Schema(description = "내용. 생략하면 변경하지 않는다", example = "내용을 수정합니다")
        val content: String?,

        @field:Size(max = 2048)
        @field:Schema(description = "첨부 이미지 key. 빈 문자열이면 첨부를 지운다", example = "inquiries/0befc150-badb-4674-a99d-ded96f03814a.png")
        val img: String?
    )
}
