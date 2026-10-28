package com.team007.room_escape.api

import com.team007.room_escape.domain.festival.infra.client.FestivalPublicApiClientV2
import com.team007.room_escape.domain.festival.infra.dto.CultureInfoPeriodRow
import com.team007.room_escape.domain.festival.service.FestivalSyncExecutor
import com.team007.room_escape.domain.member.infra.entity.MemberRole
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.mockito.ArgumentMatchers.anyInt
import org.mockito.ArgumentMatchers.anyString
import org.mockito.Mockito.`when`
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.test.context.bean.override.mockito.MockitoBean
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.status

/**
 * 공공 행사 동기화 시작(POST /sync)·상태 조회(GET /sync/status)의 권한과 응답 모양을 확인한다.
 * 실제 공공 API는 FestivalPublicApiClientV2를 가짜로 바꿔서 호출하지 않는다 — 빈 목록을 주면
 * 신규 행사가 없는 걸로 판별되어 동기화가 금방 끝난다.
 *
 * FestivalSyncExecutor는 싱글톤이라 테스트끼리 진행 상태를 공유한다. 각 테스트 시작 전에
 * 이전 테스트가 시작한 동기화가 끝났는지 확인하고, 동기화를 시작하는 테스트는 끝나기 전에
 * 자기가 시작한 동기화가 끝날 때까지 기다려서 테스트 간 레이스를 막는다.
 */
class FestivalSyncApiContractTest : ApiContractSupport() {

    @field:MockitoBean
    private lateinit var festivalPublicApiClientV2: FestivalPublicApiClientV2

    @Autowired
    private lateinit var festivalSyncExecutor: FestivalSyncExecutor

    @BeforeEach
    fun ensureSyncIdle() {
        awaitSyncIdle()
    }

    @Test
    fun 비로그인은_동기화_상태를_조회할_수_없다() {
        // GET /festivals/** 는 SecurityConfig에서 permitAll이라 필터는 통과하고,
        // 컨트롤러의 @PreAuthorize에서 걸려 403(인증 안 된 익명 사용자는 권한 없음)이 된다.
        mvc.perform(get("/api/v1/festivals/sync/status"))
            .andExpect(status().isForbidden)
    }

    @Test
    fun 관리자가_아니면_동기화_상태를_조회할_수_없다() {
        mvc.perform(`as`(get("/api/v1/festivals/sync/status"), tokenOf(MemberRole.ROLE_UNVERIFIED)))
            .andExpect(status().isForbidden)
    }

    @Test
    fun 비로그인은_동기화를_시작할_수_없다() {
        // POST는 permitAll 대상이 아니라서 필터 단계에서 바로 401이 된다.
        mvc.perform(post("/api/v1/festivals/sync"))
            .andExpect(status().isUnauthorized)
    }

    @Test
    fun 관리자가_동기화를_시작하면_즉시_202와_진행중_상태를_받는다() {
        `when`(festivalPublicApiClientV2.fetchPeriod(anyInt(), anyInt(), anyString(), anyString()))
            .thenReturn(emptyList())

        mvc.perform(`as`(post("/api/v1/festivals/sync"), tokenOf(MemberRole.ROLE_ADMIN)))
            .andExpect(status().isAccepted)
            .andExpect(jsonPath("$.data.running").value(true))

        awaitSyncIdle()
    }

    @Test
    fun 이미_진행_중이면_다시_시작할_수_없다() {
        // 바로 끝나버리면 두 번째 요청이 들어가기 전에 첫 동기화가 끝날 수 있어, 응답을 일부러 늦춘다.
        `when`(festivalPublicApiClientV2.fetchPeriod(anyInt(), anyInt(), anyString(), anyString()))
            .thenAnswer { Thread.sleep(300); emptyList<CultureInfoPeriodRow>() }
        val admin = tokenOf(MemberRole.ROLE_ADMIN)

        mvc.perform(`as`(post("/api/v1/festivals/sync"), admin))
            .andExpect(status().isAccepted)
        mvc.perform(`as`(post("/api/v1/festivals/sync"), admin))
            .andExpect(status().isConflict)

        awaitSyncIdle()
    }

    @Test
    fun 동기화_상태를_조회하면_실행_여부와_결과_모양을_받는다() {
        mvc.perform(`as`(get("/api/v1/festivals/sync/status"), tokenOf(MemberRole.ROLE_ADMIN)))
            .andExpect(status().isOk)
            .andExpect(jsonPath("$.data.running").isBoolean())
    }

    /** 이전/이번 테스트가 시작한 백그라운드 동기화가 끝날 때까지 기다린다. */
    private fun awaitSyncIdle() {
        val deadline = System.currentTimeMillis() + 5_000
        while (festivalSyncExecutor.status().running && System.currentTimeMillis() < deadline) {
            Thread.sleep(20)
        }
    }
}
