package com.team007.room_escape.domain.festival.service

import com.team007.room_escape.domain.deletion.infra.entity.DeletionAction
import com.team007.room_escape.domain.deletion.infra.entity.DeletionActorType
import com.team007.room_escape.domain.deletion.infra.entity.DeletionHistory
import com.team007.room_escape.domain.deletion.infra.entity.DeletionReason
import com.team007.room_escape.domain.deletion.infra.entity.DeletionTargetType
import com.team007.room_escape.domain.festival.infra.entity.Festival
import com.team007.room_escape.global.exception.BusinessException
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.assertThrows
import java.util.UUID

class FestivalDeletionTest {
    @Test
    fun festivalTracksOnlyCurrentDeletionState() {
        val festival = Festival.builder().build()

        festival.delete()
        assertThat(festival.isDeleted()).isTrue()
        festival.restore()
        assertThat(festival.isDeleted()).isFalse()
    }

    @Test
    fun repeatedDeletionCannotOverwriteDeletionTime() {
        val festival = Festival.builder().build()
        festival.delete()
        val deletedAt = festival.deletedAt

        assertThrows<BusinessException> { festival.delete() }
        assertThat(festival.deletedAt).isEqualTo(deletedAt)
        assertThat(festival.isDeleted()).isTrue()
    }

    @Test
    fun adminDeletionRequiresNonBlankReasonAndValidActor() {
        assertThrows<BusinessException> {
            DeletionHistory.record(
                DeletionTargetType.FESTIVAL, "1", DeletionAction.DELETE,
                UUID.randomUUID(), DeletionActorType.ADMIN, DeletionReason.OTHER, " ",
            )
        }
        assertThrows<BusinessException> {
            DeletionHistory.record(
                DeletionTargetType.FESTIVAL, "1", DeletionAction.DELETE,
                null, DeletionActorType.ADMIN, DeletionReason.OTHER, "사유",
            )
        }
        assertThrows<BusinessException> {
            DeletionHistory.record(
                DeletionTargetType.FESTIVAL, "1", DeletionAction.DELETE,
                UUID.randomUUID(), DeletionActorType.ADMIN, DeletionReason.OTHER, "가".repeat(501),
            )
        }
    }

    @Test
    fun activeEventCannotBeRestored() {
        assertThrows<BusinessException> { Festival.builder().build().restore() }
    }
}
