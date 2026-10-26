package com.team007.room_escape.domain.member.service

import com.team007.room_escape.domain.deletion.infra.entity.DeletionActorType
import com.team007.room_escape.domain.deletion.infra.entity.DeletionAction
import com.team007.room_escape.domain.deletion.infra.entity.DeletionHistory
import com.team007.room_escape.domain.deletion.infra.entity.DeletionReason
import com.team007.room_escape.domain.deletion.infra.entity.DeletionTargetType
import com.team007.room_escape.domain.deletion.service.DeletionHistoryService
import com.team007.room_escape.domain.member.infra.repository.MyContentRepository
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test
import org.mockito.Mockito.mock
import org.mockito.Mockito.verify
import org.mockito.Mockito.`when`
import org.springframework.data.domain.PageImpl
import org.springframework.data.domain.PageRequest
import java.time.LocalDateTime
import java.util.UUID

class MyContentServiceTest {

    private val contents = mock(MyContentRepository::class.java)
    private val members = mock(MemberReader::class.java)
    private val histories = mock(DeletionHistoryService::class.java)
    private val service = MyContentService(contents, members, histories)

    private val memberId = UUID.randomUUID()
    private val pageable = PageRequest.of(0, 20)
    private val now = LocalDateTime.of(2026, 10, 20, 12, 0)
    // 후기와 커뮤니티 글의 ID는 UUID여야 조치 이력을 만들 수 있다.
    private val postId = UUID.randomUUID().toString()
    private val otherPostId = UUID.randomUUID().toString()
    private val communityPostId = UUID.randomUUID().toString()

    private fun row(
        type: DeletionTargetType,
        targetId: String,
        deleted: Boolean = false,
        parentDeleted: Boolean = false,
    ) = MyContentRepository.Row(
        type, targetId, "제목 $targetId", now, if (deleted) now.plusDays(1) else null, parentDeleted, "/원본/$targetId",
    )

    private fun history(type: DeletionTargetType, targetId: String) = DeletionHistory.record(
        type, targetId, DeletionAction.DELETE, UUID.randomUUID(), DeletionActorType.ADMIN, DeletionReason.SPAM, "도배",
    )

    private fun givenRows(vararg rows: MyContentRepository.Row, comments: Boolean = false) =
        `when`(contents.findMine(memberId, comments, pageable)).thenReturn(PageImpl(rows.toList(), pageable, rows.size.toLong()))

    @Test
    fun `먼저 활동 중인 회원인지 확인한다`() {
        givenRows()

        service.findMine(memberId, false, pageable)

        verify(members).getActiveMember(memberId)
    }

    @Test
    fun `삭제되지 않은 글은 원본 경로를 담고 조치 이력은 없다`() {
        givenRows(row(DeletionTargetType.POST, postId))

        val item = service.findMine(memberId, false, pageable).content.single()

        assertThat(item.originalPath).isEqualTo("/원본/$postId")
        assertThat(item.deletion).isNull()
    }

    @Test
    fun `삭제된 글은 원본 경로를 가리고 최근 조치 이력을 붙인다`() {
        givenRows(row(DeletionTargetType.POST, postId, deleted = true))
        `when`(histories.findLatestForTargets(DeletionTargetType.POST, listOf(postId)))
            .thenReturn(mapOf(postId to history(DeletionTargetType.POST, postId)))

        val item = service.findMine(memberId, false, pageable).content.single()

        assertThat(item.originalPath).isNull()
        assertThat(item.deletedAt).isNotNull()
        assertThat(item.deletion?.reasonDetail).isEqualTo("도배")
    }

    @Test
    fun `글이 지워진 댓글은 댓글이 살아 있어도 원본 경로를 가린다`() {
        givenRows(row(DeletionTargetType.COMMENT, "7", parentDeleted = true), comments = true)

        val item = service.findMine(memberId, true, pageable).content.single()

        assertThat(item.parentDeleted).isTrue()
        assertThat(item.originalPath).isNull()
    }

    @Test
    fun `조치 이력은 종류별로 삭제된 항목만 조회한다`() {
        givenRows(
            row(DeletionTargetType.POST, postId, deleted = true),
            row(DeletionTargetType.POST, otherPostId),
            row(DeletionTargetType.COMMUNITY_POST, communityPostId, deleted = true),
        )

        service.findMine(memberId, false, pageable)

        verify(histories).findLatestForTargets(DeletionTargetType.POST, listOf(postId))
        verify(histories).findLatestForTargets(DeletionTargetType.COMMUNITY_POST, listOf(communityPostId))
        verify(histories).findLatestForTargets(DeletionTargetType.FESTIVAL, emptyList())
    }

    @Test
    fun `제목이 없는 항목도 그대로 돌려준다`() {
        givenRows(row(DeletionTargetType.FESTIVAL, "3").copy(title = null))

        assertThat(service.findMine(memberId, false, pageable).content.single().title).isNull()
    }
}
