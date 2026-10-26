package com.team007.room_escape.domain.festival

import com.team007.room_escape.domain.festival.infra.entity.Festival
import com.team007.room_escape.domain.festival.infra.entity.FestivalRegion
import com.team007.room_escape.domain.festival.infra.entity.ProviderType
import com.team007.room_escape.domain.festival.infra.repository.FestivalRepository
import jakarta.persistence.EntityManager
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.data.jpa.test.autoconfigure.DataJpaTest
import org.springframework.boot.jdbc.test.autoconfigure.AutoConfigureTestDatabase
import java.time.LocalDateTime
import java.util.UUID

@DataJpaTest
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.NONE)
class SubmissionDuplicateRepositoryTest @Autowired constructor(
    private val em: EntityManager,
    private val festivals: FestivalRepository,
) {
    @Test
    fun comparesNameDistrictDatesRegardlessOfUrlAndExcludesDeletedAndSelf() {
        val start = LocalDateTime.of(2026, 10, 2, 0, 0)
        val end = start.plusDays(1)
        val url = "https://example.com/${UUID.randomUUID()}"
        val festival = Festival.builder().providerType(ProviderType.MEMBER)
            .title(url).district("수원시").url("https://different.example.com").region(FestivalRegion.GYEONGGI)
            .beginDe(start.plusHours(10)).endDe(end.plusHours(18)).build()
        em.persist(festival)
        em.flush()
        assertThat(festivals.lockSubmissionDuplicateKey(123456789L)).isEqualTo(1)
        assertThat(duplicate(null, start, end, url)).isTrue()
        assertThat(duplicate(festival.id, start, end, url)).isFalse()
        assertThat(duplicate(null, start.plusDays(1), end, url)).isFalse()
        assertThat(duplicate(null, start, end.plusDays(1), url)).isFalse()
        assertThat(duplicate(null, start, end, url + "different")).isFalse()
        assertThat(festivals.findSubmissionDuplicateId(null, start, start.plusDays(1),
            end, end.plusDays(1), FestivalRegion.GYEONGGI.name, url, "성남시")).isNull()
        assertThat(festivals.findSubmissionDuplicateId(null, start, start.plusDays(1),
            end, end.plusDays(1), FestivalRegion.SEOUL.name, url, "수원시")).isNull()
        festival.delete()
        em.flush()
        assertThat(duplicate(null, start, end, url)).isFalse()
    }

    @Test
    fun databaseRejectsSameNameDistrictDatesEvenWithDifferentUrlsAndTimes() {
        val start = LocalDateTime.of(2026, 10, 2, 10, 0)
        val title = UUID.randomUUID().toString()
        fun event(url: String, hour: Long) = Festival.create(
            providerType = ProviderType.MEMBER, title = title,
            region = FestivalRegion.SEOUL, district = "강남구", url = url,
            beginDe = start.plusHours(hour), endDe = start.plusDays(1).plusHours(hour)
        )
        festivals.saveAndFlush(event("https://first.example.com", 0))
        org.junit.jupiter.api.assertThrows<org.springframework.dao.DataIntegrityViolationException> {
            festivals.saveAndFlush(event("https://second.example.com", 1))
        }
    }

    private fun duplicate(id: Long?, start: LocalDateTime, end: LocalDateTime, url: String): Boolean =
        festivals.findSubmissionDuplicateId(id, start, start.plusDays(1),
            end, end.plusDays(1), FestivalRegion.GYEONGGI.name, url, "수원시") != null
}
