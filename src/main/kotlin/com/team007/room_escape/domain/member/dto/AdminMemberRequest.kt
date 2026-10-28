package com.team007.room_escape.domain.member.dto

import com.team007.room_escape.domain.member.infra.entity.MemberRole
import com.team007.room_escape.global.util.isBlankLikeJava
import com.team007.room_escape.global.util.trimLikeJava
import io.swagger.v3.oas.annotations.media.Schema
import jakarta.validation.constraints.NotNull
import jakarta.validation.constraints.Size
import java.util.Locale

class AdminMemberRequest private constructor() {

    /** 관리자 회원 검색 조건. 모든 항목이 선택이며, 비우면 전체를 조회한다. */
    @Schema(name = "AdminMemberSearchRequest", description = "관리자 회원 검색 조건")
    data class Search(

        @field:Schema(description = "닉네임 또는 이메일 검색어. 부분 일치, 대소문자 무시", example = "autumn")
        val keyword: String?,

        @field:Schema(description = "회원 등급. 비우면 전체 등급을 조회한다", example = "ROLE_WARNING")
        val role: MemberRole?,

        @field:Schema(description = "탈퇴 회원 포함 여부. 기본값 false", example = "false", defaultValue = "false")
        val includeDeleted: Boolean?,
    ) {

        /** 검색어가 없으면 null 대신 빈 문자열을 돌려준다. null이면 Postgres LIKE가 실패한다. */
        fun keywordOrEmpty(): String =
            keyword?.takeUnless { it.isBlankLikeJava() }?.trimLikeJava()?.lowercase(Locale.ROOT).orEmpty()

        fun includeDeletedOrFalse(): Boolean = includeDeleted == true
    }

    /** 회원 등급 변경 요청. ROLE_ADMIN은 서비스에서 막는다. */
    @Schema(name = "AdminMemberRoleChangeRequest", description = "회원 등급 변경 요청")
    data class ChangeRole(

        @field:NotNull
        @field:Schema(description = "변경할 등급. ROLE_ADMIN은 부여할 수 없다", example = "ROLE_TRUSTED")
        val role: MemberRole?,

        @field:Size(max = 500)
        @field:Schema(description = "변경 사유. 제재(ROLE_WARNING)로 바꿀 때만 필수, 그 밖에는 선택. 500자 이하", example = "허위 행사 제보 반복", nullable = true)
        val reason: String? = null,
    )
}
