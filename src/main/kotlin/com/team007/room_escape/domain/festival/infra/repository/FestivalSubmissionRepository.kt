package com.team007.room_escape.domain.festival.infra.repository

import com.team007.room_escape.domain.festival.infra.entity.FestivalSubmission
import com.team007.room_escape.domain.festival.infra.entity.ProviderType
import org.springframework.data.jpa.repository.EntityGraph
import org.springframework.data.jpa.repository.JpaRepository
import java.util.*

interface FestivalSubmissionRepository : JpaRepository<FestivalSubmission, UUID> {
    @EntityGraph(attributePaths = ["festival"])
    fun findAllByFestival_Member_IdAndFestival_ProviderTypeOrderByCreatedAtDesc(
        memberId: UUID,
        providerType: ProviderType
    ): List<FestivalSubmission>

    @EntityGraph(attributePaths = ["festival"])
    fun findByIdAndFestival_Member_Id(
        submissionId: UUID,
        memberId: UUID
    ): Optional<FestivalSubmission>
}
