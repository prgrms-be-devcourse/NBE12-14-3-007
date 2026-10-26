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
import com.team007.room_escape.global.exception.BusinessException
import com.team007.room_escape.global.response.code.MemberExceptionCode
import com.team007.room_escape.support.TestDatabase
import org.assertj.core.api.Assertions.assertThat
import org.assertj.core.api.Assertions.assertThatThrownBy
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.junit.jupiter.params.ParameterizedTest
import org.junit.jupiter.params.provider.CsvSource
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
import kotlin.properties.Delegates

@DataJpaTest(properties = [
    "spring.datasource.username=roomescape",
    "spring.datasource.password=roomescape",
    "spring.flyway.locations=classpath:db/migration,classpath:db/migration_v2"
])
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.NONE)
@Import(MemberTrustGradeService::class, MemberReader::class)
@Transactional(propagation = Propagation.NOT_SUPPORTED)
class MemberTrustGradeConcurrencyTest @Autowired constructor(
    private val members: MemberRepository,
    private val festivals: FestivalRepository,
    private val grades: MemberTrustGradeService,
    private val reader: MemberReader,
    private val transactionManager: PlatformTransactionManager,
    private val likes: LikeRepository,
    private val votes: FestivalAccuracyVoteRepository
) {

    companion object {
        private val SCHEMA = "trust_grade_${UUID.randomUUID().toString().replace("-", "")}"

        @JvmStatic
        @DynamicPropertySource
        fun database(properties: DynamicPropertyRegistry) {
            TestDatabase.configure(properties, SCHEMA)
        }
    }

    private lateinit var transactions: TransactionTemplate
    private lateinit var authorId: UUID
    private var festivalId by Delegates.notNull<Long>()

    @BeforeEach
    fun setUp() {
        transactions = TransactionTemplate(transactionManager)
        transactions.executeWithoutResult {
            val author = members.save(Member(
                email = "${UUID.randomUUID()}@example.com",
                password = "test",
                role = MemberRole.ROLE_TRUSTED,
                nickname = "작성자",
            ))
            authorId = author.id
            festivalId = festivals.save(Festival(
                member = author,
                providerType = ProviderType.MEMBER,
                title = "등급 검증 행사",
            )).requiredId
        }
    }

    @Test
    fun 재계산이_먼저_조회해도_다른_요청에서_완료한_탈퇴를_취소하지_않는다() {
        recalculateAfter(Member::delete)

        assertThatThrownBy { transactions.execute { reader.getActiveMember(authorId) } }
            .isInstanceOfSatisfying(BusinessException::class.java) { exception ->
                assertThat(exception.exceptionCode).isEqualTo(MemberExceptionCode.MEMBER_NOT_FOUND)
            }
    }

    @Test
    fun 재계산이_먼저_조회해도_다른_요청에서_완료한_제재를_해제하지_않는다() {
        recalculateAfter { author -> author.changeRole(MemberRole.ROLE_WARNING) }

        val role = transactions.execute { reader.getActiveMember(authorId).role }
        assertThat(role).isEqualTo(MemberRole.ROLE_WARNING)
    }

    @Test
    fun 프로필_수정이_나중에_저장되어도_재계산된_등급을_덮어쓰지_않는다() {
        inOrder(
            { author -> author.updateProfile("변경한 닉네임", null, null) },
            { grades.refreshForFestival(festivals.findById(festivalId).orElseThrow()) }
        )

        transactions.executeWithoutResult {
            val author = reader.getActiveMember(authorId)
            assertThat(author.nickname).isEqualTo("변경한 닉네임")
            assertThat(author.role).isEqualTo(MemberRole.ROLE_UNVERIFIED)
        }
    }

    @Test
    fun 재계산이_먼저_조회해도_다른_요청의_관리자_역할을_변경하지_않는다() {
        recalculateAfter { author -> author.changeRole(MemberRole.ROLE_ADMIN) }

        val role = transactions.execute { reader.getActiveMember(authorId).role }
        assertThat(role).isEqualTo(MemberRole.ROLE_ADMIN)
    }

    @Test
    fun 재계산이_먼저_완료되어도_오래된_회원_정보로_탈퇴할_수_있다() {
        inOrder(
            Member::delete,
            { grades.refreshForFestival(festivals.findById(festivalId).orElseThrow()) }
        )

        assertThatThrownBy { transactions.execute { reader.getActiveMember(authorId) } }
            .isInstanceOfSatisfying(BusinessException::class.java) { exception ->
                assertThat(exception.exceptionCode).isEqualTo(MemberExceptionCode.MEMBER_NOT_FOUND)
            }
    }

    @Test
    fun 재계산이_먼저_완료되어도_관리자의_제재가_유지된다() {
        inOrder(
            { author -> author.changeRole(MemberRole.ROLE_WARNING) },
            { grades.refreshForFestival(festivals.findById(festivalId).orElseThrow()) }
        )

        val role = transactions.execute { reader.getActiveMember(authorId).role }
        assertThat(role).isEqualTo(MemberRole.ROLE_WARNING)
    }

    @ParameterizedTest
    @CsvSource(value = [
        "0, 0, ROLE_UNVERIFIED",
        "9, 9, ROLE_UNVERIFIED",
        "10, 9, ROLE_RECOGNIZED",
        "9, 10, ROLE_RECOGNIZED",
        "10, 10, ROLE_TRUSTED"
    ])
    fun 기존_등급_기준을_유지하고_같은_요청에서도_최신_등급을_읽는다(
        likeCount: Int,
        accurateCount: Int,
        expected: MemberRole
    ) {
        transactions.executeWithoutResult {
            val festival = festivals.findById(festivalId).orElseThrow()
            repeat(maxOf(likeCount, accurateCount)) { index ->
                val voter = members.save(Member(
                    email = "${UUID.randomUUID()}@example.com",
                    password = "test",
                    role = MemberRole.ROLE_UNVERIFIED,
                    nickname = "평가자",
                ))
                if (index < likeCount) {
                    likes.save(Like.of(festival, voter))
                }
                if (index < accurateCount) {
                    votes.save(FestivalAccuracyVote(
                        festival = festival,
                        member = voter,
                        voteType = FestivalAccuracyVoteType.ACCURATE,
                    ))
                }
            }
            grades.refreshForFestival(festival)
            assertThat(reader.getActiveMember(authorId).role).isEqualTo(expected)
        }
        val storedRole = transactions.execute { reader.getActiveMember(authorId).role }
        assertThat(storedRole).isEqualTo(expected)
    }

    @Test
    fun 등급_갱신이_같은_요청의_행사_변경을_분리하거나_누락시키지_않는다() {
        transactions.executeWithoutResult {
            val festival = festivals.findById(festivalId).orElseThrow()
            festival.delete()
            grades.refreshForFestival(festival)
            festival.updateImgUrl("https://images.example.com/after-refresh.png")
        }
        transactions.executeWithoutResult {
            val festival = festivals.findById(festivalId).orElseThrow()
            assertThat(festival.isDeleted()).isTrue()
            assertThat(festival.imgUrl).isEqualTo("https://images.example.com/after-refresh.png")
        }
    }

    @Test
    fun 요청이_롤백되면_등급_갱신도_함께_롤백된다() {
        assertThatThrownBy {
            transactions.executeWithoutResult {
                grades.refreshForFestival(festivals.findById(festivalId).orElseThrow())
                throw IllegalStateException("후속 처리 실패")
            }
        }.isInstanceOf(IllegalStateException::class.java)

        val role = transactions.execute { reader.getActiveMember(authorId).role }
        assertThat(role).isEqualTo(MemberRole.ROLE_TRUSTED)
    }

    private fun recalculateAfter(competingChange: (Member) -> Unit) {
        inOrder(
            { grades.refreshForFestival(festivals.findById(festivalId).orElseThrow()) },
            competingChange
        )
    }

    private fun inOrder(delayedChange: (Member) -> Unit, competingChange: (Member) -> Unit) {
        val loaded = CountDownLatch(1)
        val changed = CountDownLatch(1)
        Executors.newSingleThreadExecutor().use { executor ->
            val calculation = executor.submit(Runnable {
                transactions.executeWithoutResult {
                    val author = reader.getActiveMember(authorId) // 다른 요청 전의 회원 상태를 먼저 읽는다.
                    loaded.countDown()
                    await(changed)
                    delayedChange(author)
                }
            })
            try {
                await(loaded)
                transactions.executeWithoutResult { competingChange(reader.getActiveMember(authorId)) }
            } finally {
                changed.countDown()
            }
            calculation.get(15, TimeUnit.SECONDS)
        }
    }

    private fun await(latch: CountDownLatch) {
        try {
            if (!latch.await(10, TimeUnit.SECONDS)) {
                throw AssertionError("동시 요청의 진행 신호를 받지 못했습니다.")
            }
        } catch (exception: InterruptedException) {
            Thread.currentThread().interrupt()
            throw AssertionError(exception)
        }
    }
}
