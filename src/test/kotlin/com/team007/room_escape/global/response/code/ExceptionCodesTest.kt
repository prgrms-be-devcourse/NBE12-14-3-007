package com.team007.room_escape.global.response.code

import com.team007.room_escape.global.exception.ExceptionCode
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test

/** 도메인별 에러 코드 enum 전체에 대한 공통 규칙. 응답의 code로 에러를 구분하므로 겹치면 안 된다. */
class ExceptionCodesTest {

    private val all: List<ExceptionCode> = listOf(
        AuthExceptionCode.entries,
        CommentExceptionCode.entries,
        CommonExceptionCode.entries,
        CommunityExceptionCode.entries,
        DeletionExceptionCode.entries,
        FestivalExceptionCode.entries,
        InquiryExceptionCode.entries,
        LikeExceptionCode.entries,
        MemberExceptionCode.entries,
        PostExceptionCode.entries,
        StorageExceptionCode.entries,
    ).flatten()

    @Test
    fun `에러 코드 문자열은 전체에서 겹치지 않는다`() {
        val duplicated = all.groupBy { it.code }.filterValues { it.size > 1 }

        assertThat(duplicated).isEmpty()
    }

    @Test
    fun `모든 에러 코드는 코드와 메시지가 비어 있지 않다`() {
        assertThat(all).allSatisfy {
            assertThat(it.code).isNotBlank()
            assertThat(it.message).isNotBlank()
        }
    }

    @Test
    fun `모든 에러 코드는 4xx 또는 5xx 상태를 가진다`() {
        assertThat(all).allSatisfy { assertThat(it.status.isError).isTrue() }
    }

    @Test
    fun `에러 코드 enum 11개가 모두 검사 대상이다`() {
        assertThat(all.map { it.javaClass }.distinct()).hasSize(11)
    }
}
