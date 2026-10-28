package com.team007.room_escape.domain.festival.service

import com.team007.room_escape.domain.festival.dto.FestivalResponse
import java.time.Instant

/**
 * 수동 동기화(관리자 버튼)의 진행 상태. running/lastResult/lastError를 따로따로 들고 있으면
 * "실행 중인데 에러도 있다" 같은 말이 안 되는 조합도 컴파일이 돼버린다. 대기·실행중·성공·실패
 * 넷 중 하나만 될 수 있다는 걸 타입으로 못 박아서, 그런 조합 자체를 만들 수 없게 한다.
 */
sealed class SyncState {
    data object Idle : SyncState()
    data object Running : SyncState()
    data class Succeeded(val result: FestivalResponse.SyncResponse, val finishedAt: Instant) : SyncState()
    data class Failed(val error: String, val finishedAt: Instant) : SyncState()
}

/** 자동(스케줄러) 동기화의 상태. 사람이 버튼을 누른 게 아니라 "진행 중" 개념이 따로 없다. */
sealed class ScheduledSyncState {
    data object Idle : ScheduledSyncState()
    data class Succeeded(val result: FestivalResponse.SyncResponse, val finishedAt: Instant) : ScheduledSyncState()
    data class Failed(val error: String, val finishedAt: Instant) : ScheduledSyncState()
}
