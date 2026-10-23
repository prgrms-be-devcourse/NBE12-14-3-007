package com.team007.room_escape.domain.deletion.infra.repository

import com.team007.room_escape.domain.deletion.infra.entity.DeletionHistory
import com.team007.room_escape.domain.deletion.infra.entity.DeletionTargetType
import org.springframework.data.jpa.repository.Query
import org.springframework.data.repository.Repository
import org.springframework.data.repository.query.Param
import java.util.*

/** 이력은 추가와 조회만 제공한다. 현재 상태 확인과 대상 잠금은 호출 측의 책임이다.  */
interface DeletionHistoryRepository : Repository<DeletionHistory, Long> {
    /** 목록 한 페이지의 대상별 최신 조치를 한 번에 조회한다.  */
    @Query(
        """
		select h from DeletionHistory h where h.id in (
			select max(latest.id) from DeletionHistory latest
			where latest.targetType = :type and latest.targetId in :ids
			group by latest.targetId
		)
		
		"""
    )
    fun findLatestForTargets(
        @Param("type") type: DeletionTargetType,
        @Param("ids") ids: List<String>
    ): List<DeletionHistory>

    fun save(history: DeletionHistory): DeletionHistory

    fun findFirstByTargetTypeAndTargetIdOrderByIdDesc(
        targetType: DeletionTargetType, targetId: String
    ): Optional<DeletionHistory>

    fun findAllByTargetTypeAndTargetIdOrderByIdDesc(
        targetType: DeletionTargetType, targetId: String
    ): List<DeletionHistory>
}