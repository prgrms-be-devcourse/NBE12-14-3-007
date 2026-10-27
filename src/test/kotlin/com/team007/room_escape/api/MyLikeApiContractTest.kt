package com.team007.room_escape.api

import com.team007.room_escape.domain.member.infra.entity.Member
import com.team007.room_escape.domain.member.infra.entity.MemberRole
import org.hamcrest.Matchers.hasSize
import org.junit.jupiter.api.Test
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.status
import java.util.UUID

/**
 * 마이페이지의 "내가 좋아요한 행사·후기" 목록.
 * 항목은 공개 목록과 같은 모양(FestivalListItem, PostListItem)이라 같은 카드로 그릴 수 있다.
 */
class MyLikeApiContractTest : ApiContractSupport() {

    @Test
    fun 좋아요한_행사를_행사_목록과_같은_모양으로_돌려준다() {
        val me = saveMember(MemberRole.ROLE_UNVERIFIED)
        like("/api/v1/festivals/${festivalId()}", me)

        mvc.perform(`as`(get("/api/v1/members/me/likes/festivals"), bearer(me)))
            .andExpect(status().isOk)
            .andExpect(jsonPath("$.data.content", hasSize<Any>(1)))
            .andExpect(jsonPath("$.data.content[0].festivalId").value(festivalId()))
            .andExpect(jsonPath("$.data.content[0].title").isString)
            .andExpect(jsonPath("$.data.content[0].likeCount").value(1))
            .andExpect(jsonPath("$.data.content[0].status").isString)
            .andExpect(jsonPath("$.data.totalElements").value(1))
    }

    @Test
    fun 좋아요한_후기를_후기_목록과_같은_모양으로_돌려준다() {
        val me = saveMember(MemberRole.ROLE_UNVERIFIED)
        val postId = createPost()
        like("/api/v1/posts/$postId", me)

        mvc.perform(`as`(get("/api/v1/members/me/likes/posts"), bearer(me)))
            .andExpect(status().isOk)
            .andExpect(jsonPath("$.data.content", hasSize<Any>(1)))
            .andExpect(jsonPath("$.data.content[0].id").value(postId.toString()))
            .andExpect(jsonPath("$.data.content[0].festivalId").value(festivalId()))
            .andExpect(jsonPath("$.data.content[0].festivalTitle").isString)
            .andExpect(jsonPath("$.data.content[0].member.nickname").isString)
            .andExpect(jsonPath("$.data.content[0].likeCount").value(1))
            .andExpect(jsonPath("$.data.totalElements").value(1))
    }

    @Test
    fun 좋아요를_취소하면_목록에서_빠진다() {
        val me = saveMember(MemberRole.ROLE_UNVERIFIED)
        val postId = createPost()
        like("/api/v1/posts/$postId", me)
        like("/api/v1/festivals/${festivalId()}", me)
        mvc.perform(`as`(delete("/api/v1/posts/$postId/likes/me"), bearer(me))).andExpect(status().isOk)
        mvc.perform(`as`(delete("/api/v1/festivals/${festivalId()}/likes/me"), bearer(me))).andExpect(status().isOk)

        mvc.perform(`as`(get("/api/v1/members/me/likes/posts"), bearer(me)))
            .andExpect(status().isOk)
            .andExpect(jsonPath("$.data.content", hasSize<Any>(0)))
        mvc.perform(`as`(get("/api/v1/members/me/likes/festivals"), bearer(me)))
            .andExpect(status().isOk)
            .andExpect(jsonPath("$.data.content", hasSize<Any>(0)))
    }

    @Test
    fun 다른_회원의_좋아요는_보이지_않는다() {
        like("/api/v1/festivals/${festivalId()}", saveMember(MemberRole.ROLE_UNVERIFIED))

        mvc.perform(`as`(get("/api/v1/members/me/likes/festivals"), tokenOf(MemberRole.ROLE_UNVERIFIED)))
            .andExpect(status().isOk)
            .andExpect(jsonPath("$.data.totalElements").value(0))
    }

    /** 순서는 좋아요를 누른 시각으로 고정한다. 정렬 파라미터를 보내도 오류 없이 무시한다. */
    @Test
    fun 정렬_파라미터는_무시한다() {
        val me = saveMember(MemberRole.ROLE_UNVERIFIED)
        like("/api/v1/festivals/${festivalId()}", me)

        mvc.perform(`as`(get("/api/v1/members/me/likes/festivals?sort=title,asc"), bearer(me)))
            .andExpect(status().isOk)
            .andExpect(jsonPath("$.data.totalElements").value(1))
        mvc.perform(`as`(get("/api/v1/members/me/likes/posts?sort=nopeField,desc"), bearer(me)))
            .andExpect(status().isOk)
    }

    @Test
    fun 로그인하지_않으면_조회할_수_없다() {
        mvc.perform(get("/api/v1/members/me/likes/festivals")).andExpect(status().isUnauthorized)
        mvc.perform(get("/api/v1/members/me/likes/posts")).andExpect(status().isUnauthorized)
    }

    /** 좋아요는 활동 제한 회원이 누를 수 없지만, 이미 누른 목록은 볼 수 있다. */
    @Test
    fun 활동_제한_회원도_조회할_수_있다() {
        mvc.perform(`as`(get("/api/v1/members/me/likes/festivals"), tokenOf(MemberRole.ROLE_WARNING)))
            .andExpect(status().isOk)
    }

    /**
     * 좋아요를 누른다. 후기 좋아요 수는 UPDATE 쿼리로 올라서, 테스트 전체가 한 트랜잭션인 동안에는
     * 캐시된 후기가 옛 값을 들고 있다. 실제 요청처럼 새로 읽도록 비운다.
     */
    private fun like(target: String, member: Member) {
        mvc.perform(`as`(post("$target/likes/me"), bearer(member))).andExpect(status().isOk)
        entityManager.flush()
        entityManager.clear()
    }

    private fun createPost(): UUID {
        val result = mvc.perform(
            `as`(post("/api/v1/festivals/${festivalId()}/posts"), tokenOf(MemberRole.ROLE_UNVERIFIED))
                .contentType("application/json")
                .content("""{"title":"좋아요 목록 후기 ${UUID.randomUUID().toString().take(8)}","content":"내용"}"""),
        )
            .andExpect(status().isOk)
            .andReturn()
        return UUID.fromString(
            objectMapper.readTree(result.response.contentAsString).path("data").path("id").asString(),
        )
    }
}
