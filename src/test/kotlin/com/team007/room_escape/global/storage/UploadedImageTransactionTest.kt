package com.team007.room_escape.global.storage

import com.team007.room_escape.global.exception.BusinessException
import com.team007.room_escape.support.TestDatabase
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.assertThrows
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
import java.time.Duration
import java.time.Instant
import java.util.UUID
import java.util.concurrent.CountDownLatch
import java.util.concurrent.Executors
import java.util.concurrent.TimeUnit

@DataJpaTest(properties = ["spring.flyway.locations=classpath:db/migration,classpath:db/migration_v2"])
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.NONE)
@Import(UploadedImageService::class)
@Transactional(propagation = Propagation.NOT_SUPPORTED)
class UploadedImageTransactionTest @Autowired constructor(
    private val images: UploadedImageService,
    private val repository: UploadedImageRepository,
    transactionManager: PlatformTransactionManager
) {
    private val transactions = TransactionTemplate(transactionManager)
    private val owner = UUID.randomUUID()
    private val cutoff = Instant.now().minus(Duration.ofHours(24))

    companion object {
        private val schema = "uploads_${UUID.randomUUID().toString().replace("-", "")}"

        @JvmStatic
        @DynamicPropertySource
        fun database(properties: DynamicPropertyRegistry) = TestDatabase.configure(properties, schema)
    }

    private fun expired(): String {
        val key = "posts/$owner/${UUID.randomUUID()}.png"
        transactions.executeWithoutResult { repository.save(UploadedImage(key, owner, cutoff.minusSeconds(1))) }
        return key
    }

    @Test
    fun uploadFailureLeavesPersistentPendingRecord() {
        val key = "posts/$owner/${UUID.randomUUID()}.png"
        images.register(key, owner)
        assertThrows<IllegalStateException> {
            images.upload(key) { error("업로드 실패") }
        }
        assertThat(repository.findById(key).orElseThrow().state).isEqualTo(UploadState.PENDING)
    }

    @Test
    fun usedImageIsExcludedFromCleanupEvenAfterTwentyFourHours() {
        val key = expired()
        transactions.executeWithoutResult { images.confirm(listOf(key), owner) }
        assertThat(images.cleanupKeys(cutoff)).doesNotContain(key)
        assertThat(images.beginDeletion(key, cutoff)).isFalse()
    }

    @Test
    fun failedBusinessTransactionRollsBackConfirmation() {
        val key = expired()
        assertThrows<IllegalStateException> {
            transactions.executeWithoutResult {
                images.confirm(listOf(key), owner)
                error("글 저장 실패")
            }
        }
        assertThat(repository.findById(key).orElseThrow().state).isEqualTo(UploadState.PENDING)
        assertThat(images.beginDeletion(key, cutoff)).isTrue()
    }

    @Test
    fun committedConfirmationWinsAgainstConcurrentCleanup() {
        val key = expired()
        val confirmed = CountDownLatch(1)
        val release = CountDownLatch(1)
        val cleanupStarted = CountDownLatch(1)
        val executor = Executors.newFixedThreadPool(2)
        try {
            val saving = executor.submit {
                transactions.executeWithoutResult {
                    images.confirm(listOf(key), owner)
                    confirmed.countDown()
                    check(release.await(10, TimeUnit.SECONDS))
                }
            }
            check(confirmed.await(10, TimeUnit.SECONDS))
            val cleaning = executor.submit<Boolean> {
                cleanupStarted.countDown()
                images.beginDeletion(key, cutoff)
            }
            check(cleanupStarted.await(10, TimeUnit.SECONDS))
            release.countDown()
            saving.get(15, TimeUnit.SECONDS)
            assertThat(cleaning.get(15, TimeUnit.SECONDS)).isFalse()
            assertThat(repository.findById(key).orElseThrow().state).isEqualTo(UploadState.ACTIVE)
        } finally {
            release.countDown()
            executor.shutdownNow()
            executor.awaitTermination(10, TimeUnit.SECONDS)
        }
    }

    @Test
    fun cleanupWinningFirstRejectsLateRegistration() {
        val key = expired()
        assertThat(images.beginDeletion(key, cutoff)).isTrue()
        assertThrows<BusinessException> {
            transactions.executeWithoutResult { images.confirm(listOf(key), owner) }
        }
        assertThat(repository.findById(key).orElseThrow().state).isEqualTo(UploadState.DELETING)
    }

    @Test

    fun discardedImageIsPickedUpByCleanupEvenWhenRecentlyUploaded() {
        val key = "profiles/$owner/${UUID.randomUUID()}.png"
        transactions.executeWithoutResult {
            repository.save(UploadedImage(key, owner).also { it.activate() }) // 방금 올려 쓰고 있는 이미지
        }
        assertThat(images.cleanupKeys(cutoff)).doesNotContain(key)

        transactions.executeWithoutResult { assertThat(images.markForDeletion(key)).isTrue() }

        assertThat(images.cleanupKeys(cutoff)).contains(key)
        assertThat(images.beginDeletion(key, cutoff)).isTrue()
    }

    @Test
    fun discardIsRolledBackTogetherWithTheTransaction() {
        val key = "profiles/$owner/${UUID.randomUUID()}.png"
        transactions.executeWithoutResult { repository.save(UploadedImage(key, owner).also { it.activate() }) }

        assertThrows<IllegalStateException> {
            transactions.executeWithoutResult {
                images.markForDeletion(key)
                error("파기 실패")
            }
        }

        assertThat(repository.findById(key).orElseThrow().state).isEqualTo(UploadState.ACTIVE)

        fun recentUploadCountIncludesOnlyThisOwnersUploadsAfterTheCutoff() {
            val since = Instant.now().minus(Duration.ofHours(24))
            val someone = UUID.randomUUID()
            transactions.executeWithoutResult {
                repository.save(
                    UploadedImage(
                        "posts/$someone/${UUID.randomUUID()}.png",
                        someone,
                        since.plusSeconds(60)
                    )
                )
                repository.save(
                    UploadedImage(
                        "posts/$someone/${UUID.randomUUID()}.png",
                        someone,
                        since.plusSeconds(120)
                    )
                )
                repository.save(
                    UploadedImage(
                        "posts/$someone/${UUID.randomUUID()}.png",
                        someone,
                        since.minusSeconds(60)
                    )
                ) // 24시간 전
                repository.save(
                    UploadedImage(
                        "posts/$owner/${UUID.randomUUID()}.png",
                        owner,
                        since.plusSeconds(60)
                    )
                ) // 다른 회원
            }

            assertThat(repository.countByOwnerIdAndUploadedAtAfter(someone, since)).isEqualTo(2)

        }
    }
}
