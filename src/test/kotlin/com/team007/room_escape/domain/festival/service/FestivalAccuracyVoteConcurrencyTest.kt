package com.team007.room_escape.domain.festival.service

import com.team007.room_escape.domain.festival.dto.FestivalAccuracyVoteRequest
import com.team007.room_escape.domain.festival.infra.entity.Festival
import com.team007.room_escape.domain.festival.infra.entity.FestivalAccuracyVoteType
import com.team007.room_escape.domain.festival.infra.entity.ProviderType
import com.team007.room_escape.domain.festival.infra.repository.FestivalAccuracyVoteRepository
import com.team007.room_escape.domain.festival.infra.repository.FestivalRepository
import com.team007.room_escape.domain.member.infra.entity.Member
import com.team007.room_escape.domain.member.infra.entity.MemberRole
import com.team007.room_escape.domain.member.infra.repository.MemberRepository
import com.team007.room_escape.domain.member.service.MemberReader
import com.team007.room_escape.domain.member.service.MemberTrustGradeService
import com.team007.room_escape.support.TestDatabase
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.data.jpa.test.autoconfigure.DataJpaTest
import org.springframework.boot.jdbc.test.autoconfigure.AutoConfigureTestDatabase
import org.springframework.context.annotation.Import
import org.springframework.test.context.DynamicPropertyRegistry
import org.springframework.test.context.DynamicPropertySource
import org.springframework.transaction.PlatformTransactionManager
import org.springframework.transaction.annotation.Propagation
import org.springframework.transaction.annotation.Transactional
import org.springframework.transaction.support.TransactionTemplate
import java.util.UUID
import java.util.concurrent.CountDownLatch
import java.util.concurrent.Executors
import java.util.concurrent.TimeUnit

@DataJpaTest(properties = [
    "spring.datasource.username=roomescape",
    "spring.datasource.password=roomescape",
    "spring.flyway.locations=classpath:db/migration,classpath:db/migration_v2"
])
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.NONE)
@Import(FestivalAccuracyVoteService::class, MemberReader::class, MemberTrustGradeService::class)
@Transactional(propagation = Propagation.NOT_SUPPORTED)
class FestivalAccuracyVoteConcurrencyTest @Autowired constructor(
    private val service: FestivalAccuracyVoteService,
    private val members: MemberRepository,
    private val festivals: FestivalRepository,
    private val votes: FestivalAccuracyVoteRepository,
    private val transactionManager: PlatformTransactionManager
) {
    companion object {
        private val schema = "accuracy_vote_${UUID.randomUUID().toString().replace("-", "")}"

        @JvmStatic
        @DynamicPropertySource
        fun database(properties: DynamicPropertyRegistry) {
            TestDatabase.configure(properties, schema)
        }
    }

    @Test
    fun concurrentFirstVotesBothSucceedAndLeaveOneVote() {
        val transactions = TransactionTemplate(transactionManager)
        val ids = checkNotNull(transactions.execute {
            fun member() = members.save(Member.builder()
                .email("${UUID.randomUUID()}@example.com")
                .password("test").nickname("투표 검증")
                .role(MemberRole.ROLE_UNVERIFIED).build())
            val author = member()
            val voter = member()
            val festival = festivals.save(Festival.create(
                member = author, providerType = ProviderType.MEMBER, title = "동시 투표 검증"
            ))
            checkNotNull(festival.id) to voter.id
        })
        val ready = CountDownLatch(2)
        val start = CountDownLatch(1)
        val executor = Executors.newFixedThreadPool(2)
        try {
            val requests = List(2) {
                executor.submit {
                    ready.countDown()
                    check(start.await(10, TimeUnit.SECONDS))
                    service.vote(ids.second, ids.first,
                        FestivalAccuracyVoteRequest.Upsert(FestivalAccuracyVoteType.ACCURATE))
                }
            }
            check(ready.await(10, TimeUnit.SECONDS))
            start.countDown()
            requests.forEach { it.get(20, TimeUnit.SECONDS) }
            transactions.executeWithoutResult {
                val festival = festivals.findById(ids.first).orElseThrow()
                assertThat(votes.countByFestivalAndVoteType(festival, FestivalAccuracyVoteType.ACCURATE))
                    .isEqualTo(1L)
                assertThat(votes.findByFestivalIdAndMemberId(ids.first, ids.second)).isPresent()
            }
        } finally {
            start.countDown()
            executor.shutdownNow()
            check(executor.awaitTermination(10, TimeUnit.SECONDS))
        }
    }
}
