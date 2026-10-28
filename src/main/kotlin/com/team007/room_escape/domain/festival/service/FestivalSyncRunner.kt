package com.team007.room_escape.domain.festival.service

import com.team007.room_escape.domain.festival.dto.FestivalResponse
import org.slf4j.LoggerFactory
import org.springframework.scheduling.annotation.Async
import org.springframework.stereotype.Component

/**
 * 공공 행사 동기화를 실제로 실행한다. 동시 실행 방지·상태 관리는 [FestivalSyncExecutor]가 맡고,
 * 여기서는 "어떻게 실행할지"만 책임진다 — 스케줄러는 결과를 바로 받아야 해서 동기로,
 * 관리자 버튼은 오래 걸려도 요청을 바로 끝내야 해서 비동기([runAsync])로 돈다.
 */
@Component
class FestivalSyncRunner(
    private val festivalService: FestivalService
) {
    private val log = LoggerFactory.getLogger(javaClass)

    /** 스케줄러용: 그대로 동기 실행해서 결과를 바로 돌려준다. */
    fun runSync(): FestivalResponse.SyncResponse = festivalService.syncPublicFestivals()

    /**
     * 관리자 버튼용: 이 프로젝트가 이미 메일 발송에 쓰는 @Async 방식을 그대로 따른다
     * (스레드를 직접 만들지 않고, 스프링이 관리하는 비동기 실행에 맡긴다).
     *
     * OutOfMemoryError 같은 Error까지 잡아야 한다. void 메서드라 여기서 안 잡으면 호출자에게
     * 전달할 곳이 없어 스프링 기본 핸들러가 로그만 남기고 삼켜버리고, [onDone]도 못 불려서
     * 잠금(gate)이 영원히 안 풀린다.
     */
    @Async
    fun runAsync(
        onFinished: (FestivalResponse.SyncResponse) -> Unit,
        onFailed: (Throwable) -> Unit,
        onDone: () -> Unit
    ) {
        try {
            val result = festivalService.syncPublicFestivals()
            onFinished(result)
        } catch (e: Throwable) {
            log.error("공공 행사 동기화 실패", e)
            onFailed(e)
        } finally {
            onDone()
        }
    }
}
