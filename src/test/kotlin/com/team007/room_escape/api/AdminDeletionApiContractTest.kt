package com.team007.room_escape.api

import com.team007.room_escape.domain.festival.infra.entity.Festival
import com.team007.room_escape.domain.festival.infra.entity.FestivalRegion
import com.team007.room_escape.domain.festival.infra.entity.ProviderType
import com.team007.room_escape.domain.member.infra.entity.MemberRole
import org.junit.jupiter.api.Test
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.status
import java.time.LocalDateTime
import java.util.UUID

/** GET /admin/deletions/latest, POST /admin/deletions, POST /admin/deletions/restore */
class AdminDeletionApiContractTest : ApiContractSupport() {
    @Test
    fun 관리자는_행사를_삭제하고_이력을_남긴다() {
        val festival = saveFestival()
        val admin = tokenOf(MemberRole.ROLE_ADMIN)

        mvc.perform(`as`(post("/api/v1/admin/deletions"), admin)
            .contentType("application/json")
            .content(deleteBody(festival.id, "DUPLICATE", null)))
            .andExpect(status().isOk)

        mvc.perform(`as`(get("/api/v1/admin/deletions/latest?targetType=FESTIVAL&targetId=${festival.id}"), admin))
            .andExpect(status().isOk)
            .andExpect(jsonPath("$.data.action").value("DELETE"))
            .andExpect(jsonPath("$.data.actorType").value("ADMIN"))
            .andExpect(jsonPath("$.data.reasonCode").value("DUPLICATE"))
    }

    @Test
    fun 삭제_이력이_없으면_data가_null이다() {
        val festival = saveFestival()

        mvc.perform(`as`(get("/api/v1/admin/deletions/latest?targetType=FESTIVAL&targetId=${festival.id}"),
            tokenOf(MemberRole.ROLE_ADMIN)))
            .andExpect(status().isOk)
            .andExpect(jsonPath("$.data").doesNotExist())
    }

    /** 사유를 '기타'로 고르면 상세를 받아야 이력만 보고 판단할 수 있다. */
    @Test
    fun 기타_사유는_상세_없이_삭제할_수_없다() {
        val festival = saveFestival()

        mvc.perform(`as`(post("/api/v1/admin/deletions"), tokenOf(MemberRole.ROLE_ADMIN))
            .contentType("application/json")
            .content(deleteBody(festival.id, "OTHER", null)))
            .andExpect(status().isBadRequest)
            .andExpect(jsonPath("$.code").value("DELETION004"))
    }

    @Test
    fun 작성자_요청_사유는_관리자_삭제에_쓸_수_없다() {
        val festival = saveFestival()

        mvc.perform(`as`(post("/api/v1/admin/deletions"), tokenOf(MemberRole.ROLE_ADMIN))
            .contentType("application/json")
            .content(deleteBody(festival.id, "AUTHOR_REQUEST", null)))
            .andExpect(status().isBadRequest)
            .andExpect(jsonPath("$.code").value("DELETION005"))
    }

    @Test
    fun 관리자가_삭제한_행사는_복구된다() {
        val festival = saveFestival()
        val admin = tokenOf(MemberRole.ROLE_ADMIN)

        mvc.perform(`as`(post("/api/v1/admin/deletions"), admin)
            .contentType("application/json")
            .content(deleteBody(festival.id, "SPAM", null)))
            .andExpect(status().isOk)

        mvc.perform(`as`(post("/api/v1/admin/deletions/restore"), admin)
            .contentType("application/json")
            .content(restoreBody(festival.id)))
            .andExpect(status().isOk)

        mvc.perform(`as`(get("/api/v1/admin/deletions/latest?targetType=FESTIVAL&targetId=${festival.id}"), admin))
            .andExpect(jsonPath("$.data.action").value("RESTORE"))
    }

    @Test
    fun 삭제되지_않은_행사는_복구_요청이_거부된다() {
        val festival = saveFestival()

        mvc.perform(`as`(post("/api/v1/admin/deletions/restore"), tokenOf(MemberRole.ROLE_ADMIN))
            .contentType("application/json")
            .content(restoreBody(festival.id)))
            .andExpect(status().isConflict)
            .andExpect(jsonPath("$.code").value("FESTIVAL007"))
    }

    /** 삭제 이력이 없으면 관리자 삭제였는지 알 수 없어 복구하지 않는다. */
    @Test
    fun 이력_없이_삭제된_행사는_복구할_수_없다() {
        val festival = saveFestival()
        markDeletedWithoutHistory(festival)

        mvc.perform(`as`(post("/api/v1/admin/deletions/restore"), tokenOf(MemberRole.ROLE_ADMIN))
            .contentType("application/json")
            .content(restoreBody(festival.id)))
            .andExpect(status().isConflict)
            .andExpect(jsonPath("$.code").value("DELETION006"))
    }

    @Test
    fun 대상_ID_형식이_맞지_않으면_거부한다() {
        mvc.perform(`as`(post("/api/v1/admin/deletions"), tokenOf(MemberRole.ROLE_ADMIN))
            .contentType("application/json")
            .content("""{"targetType":"FESTIVAL","targetId":"not-a-number","reasonCode":"SPAM"}"""))
            .andExpect(status().isBadRequest)
            .andExpect(jsonPath("$.code").value("DELETION000"))
    }

    @Test
    fun 일반_회원은_삭제할_수_없다() {
        val festival = saveFestival()

        mvc.perform(`as`(post("/api/v1/admin/deletions"), tokenOf(MemberRole.ROLE_UNVERIFIED))
            .contentType("application/json")
            .content(deleteBody(festival.id, "SPAM", null)))
            .andExpect(status().isForbidden)
    }

    @Test
    fun 일반_회원은_복구할_수_없다() {
        val festival = saveFestival()

        mvc.perform(`as`(post("/api/v1/admin/deletions/restore"), tokenOf(MemberRole.ROLE_UNVERIFIED))
            .contentType("application/json")
            .content(restoreBody(festival.id)))
            .andExpect(status().isForbidden)
    }

    @Test
    fun 일반_회원은_조치_이력을_조회할_수_없다() {
        mvc.perform(`as`(get("/api/v1/admin/deletions/latest?targetType=FESTIVAL&targetId=1"),
            tokenOf(MemberRole.ROLE_UNVERIFIED)))
            .andExpect(status().isForbidden)
    }

    @Test
    fun 미인증_사용자는_삭제할_수_없다() {
        mvc.perform(post("/api/v1/admin/deletions")
            .contentType("application/json")
            .content("""{"targetType":"FESTIVAL","targetId":"1","reasonCode":"SPAM"}"""))
            .andExpect(status().isUnauthorized)
    }

    private fun restoreBody(festivalId: Long): String =
        """{"targetType":"FESTIVAL","targetId":"$festivalId"}"""

    /** 이력 테이블을 거치지 않고 삭제 상태만 만든다. 이력이 없던 과거 삭제를 재현한다. */
    private fun markDeletedWithoutHistory(festival: Festival) {
        entityManager.createQuery("update Festival f set f.deletedAt = :at where f.id = :id")
            .setParameter("at", LocalDateTime.now().minusDays(1))
            .setParameter("id", festival.id)
            .executeUpdate()
        entityManager.clear()
    }

    private fun saveFestival(): Festival = festivalRepository.saveAndFlush(
        Festival.builder()
            .providerType(ProviderType.PUBLIC)
            .title("계약테스트 행사 ${UUID.randomUUID().toString().substring(0, 8)}")
            .region(FestivalRegion.SEOUL)
            .beginDe(LocalDateTime.of(2026, 10, 1, 10, 0))
            .endDe(LocalDateTime.of(2026, 10, 5, 18, 0))
            .build(),
    )

    private fun deleteBody(festivalId: Long, reasonCode: String, reasonDetail: String?): String {
        val detail = reasonDetail?.let { "\"$it\"" } ?: "null"
        return """{"targetType":"FESTIVAL","targetId":"$festivalId","reasonCode":"$reasonCode","reasonDetail":$detail}"""
    }
}
