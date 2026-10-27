package com.team007.room_escape.domain.festival.controller

import com.team007.room_escape.domain.festival.dto.FestivalResponse
import com.team007.room_escape.domain.festival.dto.FestivalSearchRequest
import com.team007.room_escape.domain.festival.service.FestivalService
import com.team007.room_escape.domain.festival.service.FestivalSyncExecutor
import com.team007.room_escape.global.exception.BusinessException
import com.team007.room_escape.global.response.ApiResponse
import com.team007.room_escape.global.response.code.FestivalExceptionCode
import com.team007.room_escape.global.security.CustomUserDetails
import io.swagger.v3.oas.annotations.Operation
import org.springdoc.core.annotations.ParameterObject
import org.springframework.data.domain.Page
import org.springframework.data.domain.Pageable
import org.springframework.data.web.PageableDefault
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.security.core.annotation.AuthenticationPrincipal
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.ModelAttribute
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping("/api/v1/festivals")
class FestivalController(
    private val festivalService: FestivalService,
    private val festivalSyncExecutor: FestivalSyncExecutor
) {

    @Operation(summary = "행사 통합 검색", description = "공공행사와 사용자 등록 행사를 통합 검색한다. 모든 조건은 선택이다.")
    @GetMapping
    fun searchFestivals(
        @ParameterObject @ModelAttribute request: FestivalSearchRequest,
        @ParameterObject @PageableDefault(size = 9) pageable: Pageable
    ): ResponseEntity<ApiResponse<Page<FestivalResponse.ListItem>>> {
        val response: Page<FestivalResponse.ListItem> =
            festivalService.searchFestivals(request, pageable)

        return ResponseEntity.ok(ApiResponse.ok(response))
    }

    @Operation(summary = "행사 상세 조회", description = "공공행사 또는 회원 제보 행사 1건의 상세 정보를 조회합니다.")
    @GetMapping("/{festivalId}")
    fun getFestival(
        @AuthenticationPrincipal principal: CustomUserDetails?,
        @PathVariable festivalId: Long
    ): ResponseEntity<ApiResponse<FestivalResponse.Detail>> {
        val response: FestivalResponse.Detail = festivalService.getFestival(
            festivalId,
            principal?.id
        )

        return ResponseEntity.ok(ApiResponse.ok(response))
    }

    @Operation(
        summary = "공공 행사 수동 동기화 시작",
        description = "관리자가 공공 API 데이터 동기화를 백그라운드로 시작합니다. 결과를 기다리지 않고 바로 응답하며, " +
            "진행 상태와 결과는 GET /sync/status로 조회합니다. 이미 진행 중이면 409를 반환합니다."
    )
    @PreAuthorize("hasRole('ADMIN')")
    @PostMapping("/sync")
    fun startSyncPublicFestivals(): ResponseEntity<ApiResponse<FestivalResponse.SyncStatusResponse>> {
        if (!festivalSyncExecutor.tryStart()) {
            throw BusinessException(FestivalExceptionCode.SYNC_ALREADY_RUNNING)
        }
        return ResponseEntity.status(HttpStatus.ACCEPTED).body(ApiResponse.ok(festivalSyncExecutor.status()))
    }

    @Operation(
        summary = "공공 행사 동기화 상태 조회",
        description = "지금 동기화가 진행 중인지, 혹은 마지막으로 끝난 결과(성공·건너뜀 건수 포함)를 반환합니다."
    )
    @PreAuthorize("hasRole('ADMIN')")
    @GetMapping("/sync/status")
    fun syncStatus(): ResponseEntity<ApiResponse<FestivalResponse.SyncStatusResponse>> {
        return ResponseEntity.ok(ApiResponse.ok(festivalSyncExecutor.status()))
    }
}
