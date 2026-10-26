package com.team007.room_escape.domain.auth.service

import com.team007.room_escape.domain.auth.infra.repository.RefreshTokenRepository
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test
import org.mockito.ArgumentCaptor
import org.mockito.Mockito.mock
import org.mockito.Mockito.verify
import java.time.LocalDateTime

class RefreshTokenCleanupSchedulerTest {

    private val repository = mock(RefreshTokenRepository::class.java)

    @Test
    fun `지금보다 이전에 만료된 토큰을 지운다`() {
        val before = LocalDateTime.now()

        RefreshTokenCleanupScheduler(repository).purgeExpired()

        val captor = ArgumentCaptor.forClass(LocalDateTime::class.java)
        verify(repository).deleteByExpiresAtBefore(captor.capture())
        assertThat(captor.value).isBetween(before, LocalDateTime.now())
    }
}
