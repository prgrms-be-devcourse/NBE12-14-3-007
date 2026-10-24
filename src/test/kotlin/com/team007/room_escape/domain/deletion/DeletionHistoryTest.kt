package com.team007.room_escape.domain.deletion

import com.team007.room_escape.domain.deletion.infra.entity.DeletionAction
import com.team007.room_escape.domain.deletion.infra.entity.DeletionActorType
import com.team007.room_escape.domain.deletion.infra.entity.DeletionHistory
import com.team007.room_escape.domain.deletion.infra.entity.DeletionReason
import com.team007.room_escape.domain.deletion.infra.entity.DeletionTargetType
import com.team007.room_escape.global.exception.BusinessException
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.assertThrows
import java.util.UUID

class DeletionHistoryTest {
    @Test
    fun authorDeletionUsesFixedReasonAndNormalizesTargetId() {
        val history = DeletionHistory.record(
            DeletionTargetType.FESTIVAL, "00012", DeletionAction.DELETE,
            UUID.randomUUID(), DeletionActorType.AUTHOR, DeletionReason.AUTHOR_REQUEST, null,
        )

        assertThat(history.targetId).isEqualTo("12")
        assertThat(history.reason).isEqualTo(DeletionReason.AUTHOR_REQUEST)
        assertThat(history.createdAt).isNotNull()
    }

    @Test
    fun otherRequiresExplanationAndRestorationRequiresAdministrator() {
        val actor = UUID.randomUUID()

        assertThrows<BusinessException> {
            DeletionHistory.record(
                DeletionTargetType.POST, UUID.randomUUID().toString(), DeletionAction.DELETE,
                actor, DeletionActorType.ADMIN, DeletionReason.OTHER, " ",
            )
        }
        assertThrows<BusinessException> {
            DeletionHistory.record(
                DeletionTargetType.FESTIVAL, "12", DeletionAction.RESTORE,
                actor, DeletionActorType.AUTHOR, DeletionReason.ADMIN_RESTORE, null,
            )
        }
    }

    @Test
    fun restoreRecordDoesNotErasePreviousDeleteRecord() {
        val actor = UUID.randomUUID()
        val deletion = DeletionHistory.record(
            DeletionTargetType.FESTIVAL, "12", DeletionAction.DELETE,
            actor, DeletionActorType.ADMIN, DeletionReason.SPAM, "광고 도배",
        )
        val restore = DeletionHistory.record(
            DeletionTargetType.FESTIVAL, "12", DeletionAction.RESTORE,
            actor, DeletionActorType.ADMIN, DeletionReason.ADMIN_RESTORE, null,
        )

        assertThat(deletion.action).isEqualTo(DeletionAction.DELETE)
        assertThat(deletion.reasonDetail).isEqualTo("광고 도배")
        assertThat(restore.action).isEqualTo(DeletionAction.RESTORE)
    }
}
