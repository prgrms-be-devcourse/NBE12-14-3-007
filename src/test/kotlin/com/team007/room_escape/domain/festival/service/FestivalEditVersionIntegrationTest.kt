package com.team007.room_escape.domain.festival.service

import com.team007.room_escape.domain.festival.infra.entity.Festival
import com.team007.room_escape.domain.festival.infra.entity.ProviderType
import com.team007.room_escape.domain.festival.infra.repository.FestivalRepository
import com.team007.room_escape.support.TestDatabase
import jakarta.persistence.EntityManager
import jakarta.persistence.OptimisticLockException
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.assertThrows
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.data.jpa.test.autoconfigure.DataJpaTest
import org.springframework.boot.jdbc.test.autoconfigure.AutoConfigureTestDatabase
import org.springframework.test.context.DynamicPropertyRegistry
import org.springframework.test.context.DynamicPropertySource
import java.util.UUID

@DataJpaTest(properties = [
    "spring.datasource.username=roomescape",
    "spring.datasource.password=roomescape",
    "spring.flyway.locations=classpath:db/migration,classpath:db/migration_v2"
])
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.NONE)
class FestivalEditVersionIntegrationTest @Autowired constructor(
    private val festivals: FestivalRepository,
    private val em: EntityManager
) {
    companion object {
        private val schema = "festival_version_${UUID.randomUUID().toString().replace("-", "")}"
        @JvmStatic
        @DynamicPropertySource
        fun database(properties: DynamicPropertyRegistry) = TestDatabase.configure(properties, schema)
    }

    @Test
    fun changingFestivalIncrementsVersionAndRejectsStaleEntity() {
        val original = festivals.saveAndFlush(Festival.create(
            providerType = ProviderType.MEMBER, title = "원본"
        ))
        val id = checkNotNull(original.id)
        val originalVersion = original.version
        em.clear()
        val latest = festivals.findById(id).orElseThrow()
        latest.updateDetails("최신 제목", null, null, null, null, null, null, null, null, null, null)
        festivals.flush()
        assertThat(latest.version).isEqualTo(originalVersion + 1)
        assertThat(latest.updatedAt).isNotNull()
        em.clear()

        original.updateDetails("오래된 화면", null, null, null, null, null, null, null, null, null, null)
        assertThrows<OptimisticLockException> {
            em.merge(original)
            em.flush()
        }
    }
}
