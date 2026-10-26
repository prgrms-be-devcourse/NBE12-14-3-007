package com.team007.room_escape.api

import com.team007.room_escape.domain.festival.infra.entity.Festival
import com.team007.room_escape.domain.festival.infra.entity.FestivalRegion
import com.team007.room_escape.domain.festival.infra.entity.ProviderType
import com.team007.room_escape.domain.festival.infra.repository.FestivalRepository
import com.team007.room_escape.domain.member.infra.entity.Member
import com.team007.room_escape.domain.member.infra.entity.MemberRole
import com.team007.room_escape.domain.member.infra.repository.MemberRepository
import com.team007.room_escape.global.jwt.JwtProvider
import jakarta.persistence.EntityManager
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.http.HttpHeaders
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.request.MockHttpServletRequestBuilder
import org.springframework.transaction.annotation.Transactional
import tools.jackson.databind.json.JsonMapper
import java.time.LocalDateTime
import java.util.UUID

/**
 * API 계약 테스트 공통 설정.
 *
 * 상태 코드와 응답 JSON만 확인한다. 내부 구현을 바꿔도 이 테스트는 수정할 필요가 없어야 한다.
 *
 * 실제 JwtProvider 로 토큰을 발급해 보안 필터와 @PreAuthorize 를 그대로 태운다.
 * 목으로 SecurityContext 를 주입하면 정작 검증하려는 인가 설정을 건너뛰게 된다.
 *
 * test 프로필의 임시 PostgreSQL(Testcontainers)에 붙고 테스트마다 트랜잭션이 롤백된다.
 */
@SpringBootTest
@AutoConfigureMockMvc
@Transactional
abstract class ApiContractSupport {

    @Autowired
    protected lateinit var mvc: MockMvc

    @Autowired
    protected lateinit var jwtProvider: JwtProvider

    @Autowired
    protected lateinit var memberRepository: MemberRepository

    @Autowired
    protected lateinit var entityManager: EntityManager

    @Autowired
    protected lateinit var objectMapper: JsonMapper

    @Autowired
    protected lateinit var festivalRepository: FestivalRepository

    private var savedFestivalId: Long? = null

    /** 회원을 만들고 그 회원의 액세스 토큰을 돌려준다. */
    protected fun tokenOf(role: MemberRole): String = bearer(saveMember(role))

    protected fun saveMember(role: MemberRole): Member {
        val token = UUID.randomUUID().toString().substring(0, 8)
        return memberRepository.saveAndFlush(
            Member(
                email = "${UUID.randomUUID()}@example.com",
                password = "test",
                role = role,
                nickname = "계약테스트 $token",
            ),
        )
    }

    protected fun bearer(member: Member): String = bearerWithRole(member, member.role)

    /** 등급만 바꿔 토큰을 만든다. 등급별 인가 차이를 볼 때 쓴다. */
    protected fun bearerWithRole(member: Member, role: MemberRole): String =
        "Bearer " + jwtProvider.createAccessToken(member.id, member.nickname, role.name, member.profileImg)

    protected fun `as`(request: MockHttpServletRequestBuilder, bearerToken: String): MockHttpServletRequestBuilder =
        request.header(HttpHeaders.AUTHORIZATION, bearerToken)

    /** 후기·댓글이 매달릴 행사 하나. 테스트마다 새로 만들어 서로 간섭하지 않는다. */
    protected fun festivalId(): Long = savedFestivalId ?: festivalRepository.saveAndFlush(
        Festival.builder()
            .providerType(ProviderType.PUBLIC)
            .title("계약테스트 행사 " + UUID.randomUUID().toString().substring(0, 8))
            .region(FestivalRegion.SEOUL)
            .beginDe(LocalDateTime.of(2026, 10, 1, 10, 0))
            .endDe(LocalDateTime.of(2026, 10, 5, 18, 0))
            .build(),
    ).requiredId().also { savedFestivalId = it }

    private fun Festival.requiredId(): Long = checkNotNull(id) { "저장되지 않은 행사입니다." }
}
