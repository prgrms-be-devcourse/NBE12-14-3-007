package com.team007.room_escape.domain.deletion.service

import com.team007.room_escape.domain.deletion.infra.entity.DeletionTargetType
import com.team007.room_escape.domain.inquiry.service.InquiryDeletionProcessor
import com.team007.room_escape.domain.member.service.MemberReader
import org.assertj.core.api.Assertions.assertThatCode
import org.assertj.core.api.Assertions.assertThatThrownBy
import org.junit.jupiter.api.Test
import org.mockito.Mockito.mock
import org.mockito.Mockito.`when`

/** 삭제 핸들러는 대상 종류마다 하나씩 등록되어야 한다. */
class AdminDeletionFacadeHandlerTest {

    private fun handlerFor(type: DeletionTargetType): DeletionHandler =
        mock(DeletionHandler::class.java).also { `when`(it.supports()).thenReturn(type) }

    private fun facadeOf(vararg handlers: DeletionHandler) = AdminDeletionFacade(
        handlers.toList(),
        mock(DeletionHistoryService::class.java),
        mock(MemberReader::class.java),
        mock(InquiryDeletionProcessor::class.java),
    )

    @Test
    fun `대상 종류마다 핸들러가 하나씩이면 만들어진다`() {
        assertThatCode {
            facadeOf(handlerFor(DeletionTargetType.POST), handlerFor(DeletionTargetType.COMMENT))
        }.doesNotThrowAnyException()
    }

    @Test
    fun `같은 대상 종류를 두 핸들러가 맡으면 시작할 때 거절한다`() {
        assertThatThrownBy {
            facadeOf(handlerFor(DeletionTargetType.POST), handlerFor(DeletionTargetType.POST))
        }.isInstanceOf(IllegalStateException::class.java)
    }
}
