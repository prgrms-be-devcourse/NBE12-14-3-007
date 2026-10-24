package com.team007.room_escape.domain.deletion

import com.team007.room_escape.domain.festival.controller.AdminFestivalController
import com.team007.room_escape.domain.festival.service.AdminFestivalService
import org.junit.jupiter.api.Test
import org.mockito.Mockito.mock
import org.mockito.Mockito.verifyNoInteractions
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.patch
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.status
import org.springframework.test.web.servlet.setup.MockMvcBuilders

/** 경로 제거 검증이다. 보안 필터를 포함한 인증·인가 통합 테스트는 아니다. */
class LegacyAdminDeletionRouteTest {
    @Test
    fun legacyFestivalDeletionAndRestorationRoutesAreNotAvailable() {
        val service = mock(AdminFestivalService::class.java)
        val mvc = MockMvcBuilders.standaloneSetup(AdminFestivalController(service)).build()

        mvc.perform(delete("/api/v1/admin/festivals/42"))
            .andExpect(status().isMethodNotAllowed)
        mvc.perform(patch("/api/v1/admin/festivals/42/restore"))
            .andExpect(status().isNotFound)
        verifyNoInteractions(service)
    }
}
