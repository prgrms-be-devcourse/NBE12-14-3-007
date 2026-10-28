package com.team007.room_escape.domain.member.service

import com.team007.room_escape.domain.festival.infra.entity.Festival
import com.team007.room_escape.domain.festival.infra.entity.FestivalAccuracyVote
import com.team007.room_escape.domain.festival.infra.entity.FestivalAccuracyVoteType
import com.team007.room_escape.domain.festival.infra.entity.ProviderType
import com.team007.room_escape.domain.festival.infra.repository.FestivalAccuracyVoteRepository
import com.team007.room_escape.domain.festival.infra.repository.FestivalRepository
import com.team007.room_escape.domain.like.infra.entity.Like
import com.team007.room_escape.domain.like.infra.repository.LikeRepository
import com.team007.room_escape.domain.member.infra.entity.Member
import com.team007.room_escape.domain.member.infra.entity.MemberRole
import com.team007.room_escape.domain.member.infra.repository.MemberRepository
import com.team007.room_escape.domain.member.infra.repository.MemberTrustGradeRepository
import com.team007.room_escape.support.TestDatabase
import jakarta.persistence.EntityManager
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Nested
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
import java.time.LocalDateTime
import java.util.UUID
import java.util.concurrent.CountDownLatch
import java.util.concurrent.Executors
import java.util.concurrent.TimeUnit

/** 신뢰 등급 자정 집계를 실제 PostgreSQL에서 확인한다. 한 번의 SQL로 전체 작성자를 계산하므로 조건이 핵심이다. */
@DataJpaTest(
    properties = [
        "spring.datasource.username=roomescape",
        "spring.datasource.password=roomescape",
        "spring.flyway.locations=classpath:db/migration,classpath:db/migration_v2",
    ],
)
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.NONE)
@Import(MemberTrustGradeService::class, MemberTrustGradeRepository::class)
@Transactional(propagation = Propagation.NOT_SUPPORTED)
class MemberTrustGradeNightlyTest @Autowired constructor(
    private val grades: MemberTrustGradeService,
    private val trustGrades: MemberTrustGradeRepository,
    private val members: MemberRepository,
    private val festivals: FestivalRepository,
    private val likes: LikeRepository,
    private val votes: FestivalAccuracyVoteRepository,
    private val em: EntityManager,
    transactionManager: PlatformTransactionManager,
) {

    private val transactions = TransactionTemplate(transactionManager)

    companion object {
        private val SCHEMA = "trust_nightly_${UUID.randomUUID().toString().replace("-", "")}"

        @JvmStatic
        @DynamicPropertySource
        fun database(properties: DynamicPropertyRegistry) = TestDatabase.configure(properties, SCHEMA)
    }

    // ---- 준비 ----

    private fun <T> inTransaction(block: () -> T): T = checkNotNull(transactions.execute { block() })

    private fun member(role: MemberRole = MemberRole.ROLE_UNVERIFIED): Member = inTransaction {
        members.save(Member(email = "${UUID.randomUUID()}@example.com", password = "pw", role = role, nickname = "회원", id = null))
    }

    private fun festival(author: Member, provider: ProviderType = ProviderType.MEMBER): Festival = inTransaction {
        festivals.save(Festival(member = author, providerType = provider, title = "행사 ${UUID.randomUUID()}"))
    }

    /** 서로 다른 회원 [count]명이 이 행사에 좋아요를 누른다. */
    private fun likesOn(festival: Festival, count: Int) = inTransaction {
        repeat(count) { likes.save(Like.of(festival, members.save(Member(email = "${UUID.randomUUID()}@example.com", password = "pw", role = MemberRole.ROLE_UNVERIFIED, nickname = "좋아요")))) }
    }

    private fun votesOn(festival: Festival, count: Int, type: FestivalAccuracyVoteType = FestivalAccuracyVoteType.ACCURATE) = inTransaction {
        repeat(count) {
            val voter = members.save(Member(email = "${UUID.randomUUID()}@example.com", password = "pw", role = MemberRole.ROLE_UNVERIFIED, nickname = "평가"))
            votes.save(FestivalAccuracyVote(member = voter, festival = festival, voteType = type))
        }
    }

    private fun roleOf(member: Member): MemberRole {
        em.clear()
        return members.findById(member.id).orElseThrow().role
    }

    private fun recalculate() = checkNotNull(grades.recalculateAll())

    /** 이 테스트가 만든 회원만 확인하도록, 한 명을 기준 작성자로 만들고 반응을 채운다. */
    private fun authorWith(likeCount: Int, voteCount: Int, role: MemberRole = MemberRole.ROLE_UNVERIFIED): Member {
        val author = member(role)
        val festival = festival(author)
        likesOn(festival, likeCount)
        votesOn(festival, voteCount)
        return author
    }

    @Nested
    inner class `등급 계산` {

        @Test
        fun `좋아요와 정확해요가 모두 10개 이상이면 탈출 마스터가 된다`() {
            val author = authorWith(likeCount = 10, voteCount = 10)

            recalculate()

            assertThat(roleOf(author)).isEqualTo(MemberRole.ROLE_TRUSTED)
        }

        @Test
        fun `하나만 10개 이상이면 탈출 메이커가 된다`() {
            val byLikes = authorWith(likeCount = 10, voteCount = 9)
            val byVotes = authorWith(likeCount = 9, voteCount = 10)

            recalculate()

            assertThat(roleOf(byLikes)).isEqualTo(MemberRole.ROLE_RECOGNIZED)
            assertThat(roleOf(byVotes)).isEqualTo(MemberRole.ROLE_RECOGNIZED)
        }

        @Test
        fun `둘 다 10개 미만이면 기본 등급이다`() {
            val author = authorWith(likeCount = 9, voteCount = 9)

            recalculate()

            assertThat(roleOf(author)).isEqualTo(MemberRole.ROLE_UNVERIFIED)
        }

        @Test
        fun `반응이 줄면 등급이 내려간다`() {
            val author = authorWith(likeCount = 10, voteCount = 10)
            recalculate()
            assertThat(roleOf(author)).isEqualTo(MemberRole.ROLE_TRUSTED)

            inTransaction { likes.deleteAll(likes.findAll().filter { it.festival?.member?.id == author.id }.take(1)) }
            recalculate()

            assertThat(roleOf(author)).isEqualTo(MemberRole.ROLE_RECOGNIZED)
        }

        @Test
        fun `부정확해요는 세지 않는다`() {
            val author = member()
            val festival = festival(author)
            votesOn(festival, 10, FestivalAccuracyVoteType.INACCURATE)

            recalculate()

            assertThat(roleOf(author)).isEqualTo(MemberRole.ROLE_UNVERIFIED)
        }

        @Test
        fun `작성자 본인이 누른 반응은 세지 않는다`() {
            val author = member()
            val festival = festival(author)
            inTransaction { likes.save(Like.of(festival, author)) }
            inTransaction { votes.save(FestivalAccuracyVote(member = author, festival = festival, voteType = FestivalAccuracyVoteType.ACCURATE)) }
            likesOn(festival, 9)
            votesOn(festival, 9)

            recalculate()

            assertThat(roleOf(author)).isEqualTo(MemberRole.ROLE_UNVERIFIED)
        }

        @Test
        fun `삭제된 행사의 반응은 세지 않고 복구하면 다시 센다`() {
            val author = authorWith(likeCount = 10, voteCount = 10)
            val festival = inTransaction { festivals.findAll().first { it.member?.id == author.id } }
            recalculate()
            assertThat(roleOf(author)).isEqualTo(MemberRole.ROLE_TRUSTED)

            inTransaction { festivals.findById(festival.requiredId).orElseThrow().delete() }
            recalculate()
            assertThat(roleOf(author)).isEqualTo(MemberRole.ROLE_UNVERIFIED)

            inTransaction { festivals.findById(festival.requiredId).orElseThrow().restore() }
            recalculate()
            assertThat(roleOf(author)).isEqualTo(MemberRole.ROLE_TRUSTED)
        }

        @Test
        fun `여러 행사가 받은 반응은 작성자 기준으로 합친다`() {
            val author = member()
            likesOn(festival(author), 6)
            likesOn(festival(author), 4)
            votesOn(festival(author), 10)

            recalculate()

            assertThat(roleOf(author)).isEqualTo(MemberRole.ROLE_TRUSTED)
        }

        @Test
        fun `공공 행사가 받은 반응은 작성자 등급에 쓰지 않는다`() {
            val author = member()
            val publicFestival = festival(author, ProviderType.PUBLIC)
            likesOn(publicFestival, 10)
            votesOn(publicFestival, 10)

            recalculate()

            assertThat(roleOf(author)).isEqualTo(MemberRole.ROLE_UNVERIFIED)
        }
    }

    @Nested
    inner class `건드리지 않는 회원` {

        @Test
        fun `제재 회원과 관리자는 반응이 많아도 등급이 그대로다`() {
            val warning = authorWith(likeCount = 10, voteCount = 10, role = MemberRole.ROLE_WARNING)
            val admin = authorWith(likeCount = 10, voteCount = 10, role = MemberRole.ROLE_ADMIN)

            recalculate()

            assertThat(roleOf(warning)).isEqualTo(MemberRole.ROLE_WARNING)
            assertThat(roleOf(admin)).isEqualTo(MemberRole.ROLE_ADMIN)
        }

        @Test
        fun `탈퇴한 회원은 바꾸지 않는다`() {
            val author = authorWith(likeCount = 10, voteCount = 10)
            inTransaction { members.findById(author.id).orElseThrow().delete() }

            recalculate()

            assertThat(roleOf(author)).isEqualTo(MemberRole.ROLE_UNVERIFIED)
        }

        @Test
        fun `관리자가 직접 바꿔 고정한 등급은 반응과 상관없이 유지한다`() {
            val promoted = authorWith(likeCount = 0, voteCount = 0)
            val demoted = authorWith(likeCount = 10, voteCount = 10)
            inTransaction {
                members.findById(promoted.id).orElseThrow().changeRole(MemberRole.ROLE_TRUSTED)
                members.findById(demoted.id).orElseThrow().changeRole(MemberRole.ROLE_UNVERIFIED)
            }

            recalculate()

            assertThat(roleOf(promoted)).isEqualTo(MemberRole.ROLE_TRUSTED)
            assertThat(roleOf(demoted)).isEqualTo(MemberRole.ROLE_UNVERIFIED)
        }

        @Test
        fun `행사를 올리지 않은 회원은 바꾸지 않는다`() {
            val reader = member(MemberRole.ROLE_RECOGNIZED)

            recalculate()

            assertThat(roleOf(reader)).isEqualTo(MemberRole.ROLE_RECOGNIZED)
        }

        @Test
        fun `이미 같은 등급이면 수정 시각을 건드리지 않는다`() {
            val author = authorWith(likeCount = 10, voteCount = 10)
            recalculate()
            em.clear()
            val before: LocalDateTime? = members.findById(author.id).orElseThrow().updatedAt

            val changed = recalculate()
            em.clear()

            assertThat(members.findById(author.id).orElseThrow().updatedAt).isEqualTo(before)
            assertThat(changed).isGreaterThanOrEqualTo(0)
        }
    }

    @Nested
    inner class `한 번만 실행` {

        @Test
        fun `한 서버가 집계하는 동안 다른 서버는 건너뛴다`() {
            val holding = CountDownLatch(1)
            val release = CountDownLatch(1)
            val executor = Executors.newFixedThreadPool(2)
            try {
                val first = executor.submit<Int?> {
                    transactions.execute {
                        assertThat(trustGrades.tryAcquireNightlyLock()).isTrue()
                        holding.countDown()
                        check(release.await(10, TimeUnit.SECONDS))
                    }
                    0
                }
                check(holding.await(10, TimeUnit.SECONDS))

                val second = grades.recalculateAll()

                assertThat(second).isNull()
                release.countDown()
                first.get(15, TimeUnit.SECONDS)
            } finally {
                release.countDown()
                executor.shutdownNow()
                executor.awaitTermination(10, TimeUnit.SECONDS)
            }
        }

        @Test
        fun `집계가 끝나면 잠금이 풀려서 다음 집계는 다시 실행된다`() {
            assertThat(grades.recalculateAll()).isNotNull()
            assertThat(grades.recalculateAll()).isNotNull()
        }
    }
}
