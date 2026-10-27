package com.team007.room_escape.global.storage

import com.team007.room_escape.global.exception.BusinessException
import com.team007.room_escape.global.response.code.StorageExceptionCode
import com.team007.room_escape.support.anyOf
import org.assertj.core.api.Assertions.assertThat
import org.assertj.core.api.Assertions.assertThatCode
import org.assertj.core.api.Assertions.assertThatThrownBy
import org.junit.jupiter.api.Test
import org.mockito.ArgumentCaptor
import org.mockito.Mockito.mock
import org.mockito.Mockito.verify
import org.mockito.Mockito.`when`
import java.time.Duration
import java.time.Instant
import java.util.UUID

class UploadQuotaTest {

    private val repository = mock(UploadedImageRepository::class.java)
    private val quota = UploadQuota(repository, dailyLimit = 3)
    private val me = UUID.randomUUID()

    private fun givenUploadedToday(count: Long) {
        `when`(repository.countByOwnerIdAndUploadedAtAfter(anyOf(UUID::class.java, me), anyOf(Instant::class.java, Instant.EPOCH)))
            .thenReturn(count)
    }

    @Test
    fun `한도보다 적게 올렸으면 통과한다`() {
        givenUploadedToday(2)

        assertThatCode { quota.requireAvailable(me) }.doesNotThrowAnyException()
    }

    @Test
    fun `한도만큼 올렸으면 더 올릴 수 없다`() {
        givenUploadedToday(3)

        assertThatThrownBy { quota.requireAvailable(me) }
            .isInstanceOfSatisfying(BusinessException::class.java) {
                assertThat(it.exceptionCode).isEqualTo(StorageExceptionCode.UPLOAD_LIMIT_EXCEEDED)
            }
    }

    @Test
    fun `최근 24시간을 기준으로 센다`() {
        givenUploadedToday(0)
        val before = Instant.now()

        quota.requireAvailable(me)

        val captor = ArgumentCaptor.forClass(Instant::class.java)
        verify(repository).countByOwnerIdAndUploadedAtAfter(anyOf(UUID::class.java, me), captor.capture() ?: Instant.EPOCH)
        val window = Duration.between(captor.value, before)
        assertThat(window).isBetween(Duration.ofHours(24).minusSeconds(5), Duration.ofHours(24).plusSeconds(5))
    }
}
