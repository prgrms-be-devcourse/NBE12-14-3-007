package com.team007.room_escape.domain.festival

import com.team007.room_escape.domain.festival.infra.entity.Festival
import com.team007.room_escape.domain.festival.infra.entity.FestivalRegion
import com.team007.room_escape.domain.festival.infra.entity.FestivalStatus
import com.team007.room_escape.domain.festival.infra.entity.ProviderType
import com.team007.room_escape.domain.festival.infra.repository.FestivalRepository
import jakarta.persistence.EntityManager
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.data.jpa.test.autoconfigure.DataJpaTest
import org.springframework.boot.jdbc.test.autoconfigure.AutoConfigureTestDatabase
import org.springframework.data.domain.PageRequest
import java.time.LocalDateTime
import java.util.UUID

/**
 * FestivalRepository의 쿼리를 실제 PostgreSQL에서 확인한다.
 * 로컬 DB에 다른 데이터가 있어도 섞이지 않게 제목과 external_id에 테스트마다 고유 토큰을 넣고, 그 토큰으로만 비교한다.
 */
@DataJpaTest
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.NONE)
class FestivalRepositoryQueryTest @Autowired constructor(
    private val em: EntityManager,
    private val festivals: FestivalRepository,
) {
    private lateinit var token: String
    private val now = LocalDateTime.now()

    @BeforeEach
    fun setUp() {
        token = "repo" + UUID.randomUUID().toString().substring(0, 8)
    }

    private fun festival(
        name: String,
        providerType: ProviderType = ProviderType.PUBLIC,
        status: FestivalStatus = FestivalStatus.OPEN,
        endDe: LocalDateTime = now.plusDays(10),
        imgUrl: String? = null,
        externalId: String? = null,
    ): Festival {
        val festival = Festival.builder()
            .providerType(providerType)
            .title("$token-$name")
            .beginDe(endDe.minusDays(3))
            .endDe(endDe)
            .status(status)
            .imgUrl(imgUrl)
            .externalId(externalId)
            .region(FestivalRegion.values()[0])
            .build()
        em.persist(festival)
        return festival
    }

    private fun flushAndClear() {
        em.flush()
        em.clear()
    }

    private fun reload(festival: Festival): Festival = em.find(Festival::class.java, festival.id)

    @Test
    fun `종료일이 지난 OPEN 행사만 CLOSED로 바꾸고 바꾼 건수를 돌려준다`() {
        val expired = festival("expired", endDe = now.minusDays(1))
        val upcoming = festival("upcoming", endDe = now.plusDays(1))
        val alreadyClosed = festival("closed", status = FestivalStatus.CLOSED, endDe = now.minusDays(5))
        em.flush()

        val updated = festivals.closeExpiredFestivals(now)

        assertThat(updated).isGreaterThanOrEqualTo(1)
        assertThat(reload(expired).status).isEqualTo(FestivalStatus.CLOSED)
        assertThat(reload(upcoming).status).isEqualTo(FestivalStatus.OPEN)
        assertThat(reload(alreadyClosed).status).isEqualTo(FestivalStatus.CLOSED)
    }

    @Test
    fun `종료일이 지났는데 OPEN인 행사를 찾는다`() {
        val expired = festival("expired", endDe = now.minusDays(1))
        val upcoming = festival("upcoming", endDe = now.plusDays(1))
        val closed = festival("closed", status = FestivalStatus.CLOSED, endDe = now.minusDays(1))
        em.flush()

        val ids = festivals.findByStatusAndEndDeBefore(FestivalStatus.OPEN, now).map { it.id }

        assertThat(ids).contains(expired.id).doesNotContain(upcoming.id, closed.id)
    }

    @Test
    fun `R2 주소가 아닌 이미지를 쓰는 행사만 이관 대상으로 찾는다`() {
        val r2Url = "https://img.example.com/$token"
        val legacy = festival("legacy", imgUrl = "https://other.example.com/$token.png")
        val migrated = festival("migrated", imgUrl = "$r2Url/a.png")
        val noImage = festival("none", imgUrl = null)
        em.flush()

        val found = festivals.findLegacyImages(r2Url, PageRequest.of(0, 1000)).content.map { it.id }

        assertThat(found).contains(legacy.id).doesNotContain(migrated.id, noImage.id)
    }

    @Test
    fun `이미 저장된 external_id만 돌려준다`() {
        festival("saved", externalId = "ext-$token-1")
        em.flush()

        val existing = festivals.findExistingExternalIds(
            ProviderType.PUBLIC,
            listOf("ext-$token-1", "ext-$token-2"),
        )

        assertThat(existing).containsExactly("ext-$token-1")
        assertThat(festivals.findExistingExternalIds(ProviderType.MEMBER, listOf("ext-$token-1"))).isEmpty()
    }

    @Test
    fun `삭제된 행사는 목록 검색에서 빠진다`() {
        festival("visible")
        festival("removed").delete()
        em.flush()

        val page = festivals.searchFestivals(
            true, token,
            false, null,
            false, null,
            false, null,
            false, null,
            false, null, null,
            false,
            PageRequest.of(0, 10),
        )

        assertThat(page.content.map { it.title }).containsExactly("$token-visible")
        assertThat(page.totalElements).isEqualTo(1)
    }

    @Test
    fun `삭제된 행사는 존재하지 않는 것으로 본다`() {
        val visible = festival("visible")
        val removed = festival("removed").also { it.delete() }
        em.flush()

        assertThat(festivals.existsByIdAndDeletedAtIsNull(visible.requiredId)).isTrue()
        assertThat(festivals.existsByIdAndDeletedAtIsNull(removed.requiredId)).isFalse()
        assertThat(festivals.findByIdAndDeletedAtIsNull(removed.requiredId)).isEmpty()
    }

    @Test
    fun `관리자 검색은 옵션에 따라 삭제된 행사를 포함한다`() {
        festival("visible")
        festival("removed").delete()
        em.flush()
        val pageable = PageRequest.of(0, 10)

        val withoutDeleted = festivals.searchForAdmin(token, null, false, false, pageable)
        val withDeleted = festivals.searchForAdmin(token, null, true, false, pageable)

        assertThat(withoutDeleted.content.map { it.title }).containsExactly("$token-visible")
        assertThat(withDeleted.content.map { it.title }).containsExactlyInAnyOrder("$token-visible", "$token-removed")
    }

    @Test
    fun `행사 종류별 저장 건수를 센다`() {
        val before = festivals.countByProviderType(ProviderType.MEMBER)
        festival("member-1", providerType = ProviderType.MEMBER)
        festival("member-2", providerType = ProviderType.MEMBER)
        festival("public-1", providerType = ProviderType.PUBLIC)
        flushAndClear()

        assertThat(festivals.countByProviderType(ProviderType.MEMBER)).isEqualTo(before + 2)
    }
}
