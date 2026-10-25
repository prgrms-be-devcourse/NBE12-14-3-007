package com.team007.room_escape.domain.post.dto

import io.swagger.v3.oas.annotations.media.Schema
import jakarta.validation.constraints.NotBlank
import jakarta.validation.constraints.Size

/** 필드가 빠진 요청도 검증 메시지로 400을 돌려주도록 nullable로 받는다. */
@Schema(name = "PostRequest", description = "후기 작성 및 수정 요청")
data class PostRequest(

    @field:Size(min = 2, max = 30, message = "제목은 2글자 이상 30글자 이하로 작성해주세요.")
    @field:NotBlank
    @field:Schema(description = "후기 제목", example = "서울 불꽃축제 다녀왔어요")
    val title: String?,

    @field:NotBlank
    @field:Schema(description = "후기 내용", example = "불꽃축제가 정말 재미있었습니다.")
    val content: String?,

    @field:Size(max = 2048)
    @field:Schema(description = "썸네일 이미지 key (이미지 업로드 API가 돌려준 key)", example = "posts/{회원ID}/{파일명}.png")
    val thumbnail: String?,
)
