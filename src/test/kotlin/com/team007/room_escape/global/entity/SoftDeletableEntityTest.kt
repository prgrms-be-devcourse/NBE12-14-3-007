package com.team007.room_escape.global.entity

import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test
import java.time.LocalDateTime

class SoftDeletableEntityTest {

    private class Sample : SoftDeletableEntity()

    @Test
    fun `처음에는 삭제되지 않은 상태다`() {
        val entity = Sample()

        assertThat(entity.isDeleted()).isFalse()
        assertThat(entity.deletedAt).isNull()
    }

    @Test
    fun `삭제하면 행을 지우지 않고 삭제 시각만 기록한다`() {
        val entity = Sample()
        val before = LocalDateTime.now()

        entity.delete()

        assertThat(entity.isDeleted()).isTrue()
        assertThat(entity.deletedAt).isBetween(before, LocalDateTime.now())
    }

    @Test
    fun `복구하면 삭제 시각이 사라지고 삭제되지 않은 상태로 돌아간다`() {
        val entity = Sample().apply { delete() }

        entity.restore()

        assertThat(entity.isDeleted()).isFalse()
        assertThat(entity.deletedAt).isNull()
    }

    @Test
    fun `저장 전에는 생성·수정 시각이 비어 있다`() {
        val entity = Sample()

        assertThat(entity.createdAt).isNull()
        assertThat(entity.updatedAt).isNull()
    }
}
