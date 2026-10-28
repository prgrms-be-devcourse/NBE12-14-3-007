package com.team007.room_escape.domain.festival.service

import com.team007.room_escape.domain.festival.dto.FestivalResponse
import org.assertj.core.api.Assertions.assertThat
import org.assertj.core.api.Assertions.fail
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.extension.ExtendWith
import org.mockito.InjectMocks
import org.mockito.Mock
import org.mockito.Mockito.`when`
import org.mockito.junit.jupiter.MockitoExtension

/**
 * FestivalSyncRunner가 실제로 성공/실패를 어느 콜백으로 알리는지 검증한다.
 * 여기서는 스프링 컨텍스트가 없어 @Async가 그냥 평범한 동기 호출로 처리된다 —
 * 진짜 비동기로 도는지는 FestivalSyncApiContractTest가 따로 확인한다.
 */
@ExtendWith(MockitoExtension::class)
class FestivalSyncRunnerTest {

    @field:Mock
    private lateinit var festivalService: FestivalService

    @field:InjectMocks
    private lateinit var runner: FestivalSyncRunner

    @Test
    fun runSync은_결과를_그대로_돌려준다() {
        `when`(festivalService.syncPublicFestivals()).thenReturn(RESULT)

        assertThat(runner.runSync()).isEqualTo(RESULT)
    }

    @Test
    fun runAsync은_성공하면_onFinished와_onDone만_부른다() {
        `when`(festivalService.syncPublicFestivals()).thenReturn(RESULT)
        var finished: FestivalResponse.SyncResponse? = null
        var done = false

        runner.runAsync(
            onFinished = { finished = it },
            onFailed = { fail<Unit>("실패 콜백이 불리면 안 됨") },
            onDone = { done = true }
        )

        assertThat(finished).isEqualTo(RESULT)
        assertThat(done).isTrue()
    }

    @Test
    fun runAsync은_예외가_나면_onFailed와_onDone만_부른다() {
        `when`(festivalService.syncPublicFestivals()).thenThrow(RuntimeException("boom"))
        var failed: Throwable? = null
        var done = false

        runner.runAsync(
            onFinished = { fail<Unit>("성공 콜백이 불리면 안 됨") },
            onFailed = { failed = it },
            onDone = { done = true }
        )

        assertThat(failed).isInstanceOf(RuntimeException::class.java)
        assertThat(done).isTrue()
    }

    @Test
    fun runAsync은_Error가_나도_onFailed와_onDone을_부른다() {
        `when`(festivalService.syncPublicFestivals()).thenThrow(OutOfMemoryError("heap"))
        var failed: Throwable? = null
        var done = false

        runner.runAsync(
            onFinished = { fail<Unit>("성공 콜백이 불리면 안 됨") },
            onFailed = { failed = it },
            onDone = { done = true }
        )

        assertThat(failed).isInstanceOf(OutOfMemoryError::class.java)
        assertThat(done).isTrue()
    }

    companion object {
        private val RESULT = FestivalResponse.SyncResponse(
            closedFestivals = listOf(FestivalResponse.SyncedFestival(1L, "종료된 행사")),
            savedFestivals = listOf(FestivalResponse.SyncedFestival(2L, "새 행사")),
            updatedFestivals = emptyList(),
            detailLookupCount = 1,
            skippedCount = 0,
            interrupted = false
        )
    }
}
