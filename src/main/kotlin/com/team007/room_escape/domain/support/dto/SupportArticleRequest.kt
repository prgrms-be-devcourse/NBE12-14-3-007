package com.team007.room_escape.domain.support.dto

import com.team007.room_escape.domain.support.infra.entity.SupportArticleType
import com.team007.room_escape.global.util.trimLikeJava
import io.swagger.v3.oas.annotations.media.Schema
import jakarta.validation.constraints.NotBlank
import jakarta.validation.constraints.NotNull
import jakarta.validation.constraints.PositiveOrZero
import jakarta.validation.constraints.Size

class SupportArticleRequest private constructor() {

    @Schema(name = "SupportArticleCreateRequest", description = "고객센터 글 쓰기 요청")
    data class Create(

        @field:NotNull
        @field:Schema(description = "글 종류. NOTICE(공지사항) 또는 FAQ(자주 묻는 질문)", example = "NOTICE")
        val type: SupportArticleType?,

        @field:NotBlank
        @field:Size(max = TITLE_MAX)
        @field:Schema(description = "제목", example = "추석 연휴 고객센터 운영 안내")
        val title: String?,

        @field:NotBlank
        @field:Size(max = CONTENT_MAX)
        @field:Schema(description = "본문. 줄바꿈으로 문단을 나눈다", example = "연휴 동안 문의 답변이 늦어질 수 있어요.")
        val content: String?,

        @field:PositiveOrZero
        @field:Schema(description = "자주 묻는 질문의 표시 순서. 작을수록 위. 비우면 맨 아래. 공지사항은 무시한다", example = "1")
        val displayOrder: Int?,
    ) {
        fun cleanTitle(): String = requireNotNull(title).trimLikeJava()

        fun cleanContent(): String = normalizeContent(requireNotNull(content))
    }

    @Schema(name = "SupportArticleUpdateRequest", description = "고객센터 글 수정 요청. 종류는 바꿀 수 없다")
    data class Update(

        @field:NotBlank
        @field:Size(max = TITLE_MAX)
        @field:Schema(description = "제목", example = "추석 연휴 고객센터 운영 안내")
        val title: String?,

        @field:NotBlank
        @field:Size(max = CONTENT_MAX)
        @field:Schema(description = "본문. 줄바꿈으로 문단을 나눈다")
        val content: String?,

        @field:PositiveOrZero
        @field:Schema(description = "자주 묻는 질문의 표시 순서. 비우면 지금 순서를 유지한다. 공지사항은 무시한다", example = "1")
        val displayOrder: Int?,
    ) {
        fun cleanTitle(): String = requireNotNull(title).trimLikeJava()

        fun cleanContent(): String = normalizeContent(requireNotNull(content))
    }

    companion object {
        const val TITLE_MAX = 100
        const val CONTENT_MAX = 5000

        /** 앞뒤 공백을 지우고, 운영체제마다 다른 줄바꿈(\r\n, \r)을 \n 하나로 맞춘다. */
        private fun normalizeContent(content: String): String =
            content.replace("\r\n", "\n").replace('\r', '\n').trimLikeJava()
    }
}
