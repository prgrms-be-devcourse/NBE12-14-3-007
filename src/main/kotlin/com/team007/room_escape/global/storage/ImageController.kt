package com.team007.room_escape.global.storage

import com.team007.room_escape.domain.member.service.MemberReader
import com.team007.room_escape.global.response.ApiResponse
import com.team007.room_escape.global.security.CustomUserDetails
import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.tags.Tag
import org.springframework.http.MediaType
import org.springframework.http.ResponseEntity
import org.springframework.security.core.annotation.AuthenticationPrincipal
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RequestParam
import org.springframework.web.bind.annotation.RequestPart
import org.springframework.web.bind.annotation.RestController
import org.springframework.web.multipart.MultipartFile

/** 이미지 업로드 공통 API. 프론트는 key를 먼저 받아두고 등록·수정 요청에 담아 보낸다. */
@Tag(name = "Image", description = "이미지 업로드 API")
@RestController
@RequestMapping("/api/v1/images")
class ImageController(
    private val r2StorageService: R2StorageService,
    private val imageUrlResolver: ImageUrlResolver,
    private val memberReader: MemberReader,
) {

    /** 업로드 폴더 구분. 임의 경로를 못 넘기게 enum으로 고정한다. */
    enum class ImageType(val directory: String) {

        POST("posts"),
        PROFILE("profiles"),
        INQUIRY("inquiries"),
        FESTIVAL("festivals"),
    }

    /** 업로드 결과. key는 DB에 저장할 값, url은 화면에서 바로 쓸 공개 URL이다. */
    data class UploadInfo(val key: String, val url: String?)

    @Operation(
        summary = "이미지 업로드",
        description = "이미지를 업로드하고 저장 key와 공개 URL을 돌려준다. " +
            "DB에는 URL이 아니라 key를 저장한다. jpeg/png/webp만 허용하며 최대 5MB.",
    )
    @PostMapping(consumes = [MediaType.MULTIPART_FORM_DATA_VALUE])
    fun upload(
        @AuthenticationPrincipal principal: CustomUserDetails,
        // 이름을 명시해 -parameters 컴파일 옵션에 의존하지 않는다.
        @RequestParam("type") type: ImageType,
        @RequestPart("file") file: MultipartFile,
    ): ResponseEntity<ApiResponse<UploadInfo>> {
        // 토큰 발급 이후 탈퇴·제재됐을 수 있으므로 업로드 전에 DB의 현재 상태를 확인한다.
        memberReader.getUnrestrictedMember(principal.id)
        val key = r2StorageService.upload(file, type.directory, principal.id)
        return ResponseEntity.ok(ApiResponse.ok(UploadInfo(key, imageUrlResolver.resolve(key))))
    }
}
