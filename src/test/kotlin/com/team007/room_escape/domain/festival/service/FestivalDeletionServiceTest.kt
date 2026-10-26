package com.team007.room_escape.domain.festival.service

import com.team007.room_escape.domain.deletion.service.DeletionHistoryService
import com.team007.room_escape.domain.festival.infra.entity.Festival
import com.team007.room_escape.domain.festival.infra.entity.FestivalRegion
import com.team007.room_escape.domain.festival.infra.entity.ProviderType
import com.team007.room_escape.domain.festival.infra.repository.FestivalRepository
import com.team007.room_escape.domain.member.service.MemberTrustGradeService
import com.team007.room_escape.global.exception.BusinessException
import com.team007.room_escape.global.response.code.FestivalExceptionCode
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.assertThrows
import org.junit.jupiter.params.ParameterizedTest
import org.junit.jupiter.params.provider.ValueSource
import org.mockito.Mockito.mock
import org.mockito.Mockito.verify
import org.mockito.Mockito.verifyNoInteractions
import java.time.LocalDateTime

class FestivalDeletionServiceTest {

    private val festivals = mock(FestivalRepository::class.java)
    private val grades = mock(MemberTrustGradeService::class.java)
    private val histories = mock(DeletionHistoryService::class.java)
    private val duplicates = mock(FestivalDuplicateValidator::class.java)
    private val service = FestivalDeletionService(festivals, grades, histories, duplicates)

    private val begin = LocalDateTime.of(2026, 10, 3, 10, 0)
    private val end = LocalDateTime.of(2026, 10, 3, 18, 0)

    private fun deletedFestival(
        providerType: ProviderType = ProviderType.MEMBER,
        url: String? = "https://example.com/event",
        beginDe: LocalDateTime? = begin,
        region: FestivalRegion? = FestivalRegion.GYEONGGI,
    ) = Festival(
        id = 7L, providerType = providerType, url = url, beginDe = beginDe, endDe = end, region = region,
    ).also { it.delete() }

    @ParameterizedTest(name = "참고 링크 \"{0}\"")
    @ValueSource(strings = ["", " ", "\t\n"])
    fun `회원 제보 행사는 참고 링크가 비어 있으면 복구할 수 없다`(url: String) {
        val festival = deletedFestival(url = url)

        val e = assertThrows<BusinessException> { service.restore(festival) }

        assertThat(e.exceptionCode).isEqualTo(FestivalExceptionCode.RESTORE_DATA_INCOMPLETE)
        assertThat(festival.isDeleted()).isTrue()
        verifyNoInteractions(duplicates)
    }

    @Test
    fun `회원 제보 행사는 링크, 시작일, 지역 중 하나라도 없으면 복구할 수 없다`() {
        listOf(
            deletedFestival(url = null),
            deletedFestival(beginDe = null),
            deletedFestival(region = null),
        ).forEach { festival ->
            val e = assertThrows<BusinessException> { service.restore(festival) }

            assertThat(e.exceptionCode).isEqualTo(FestivalExceptionCode.RESTORE_DATA_INCOMPLETE)
            assertThat(festival.isDeleted()).isTrue()
        }
    }

    @Test
    fun `정보가 모두 있는 회원 제보 행사는 중복 검사를 거쳐 복구된다`() {
        val festival = deletedFestival()

        service.restore(festival)

        assertThat(festival.isDeleted()).isFalse()
        verify(duplicates).validate(7L, begin, end, FestivalRegion.GYEONGGI, "https://example.com/event")
        verify(grades).refreshForFestival(festival)
    }

    @Test
    fun `공공 행사는 제보 정보 검사 없이 복구된다`() {
        val festival = deletedFestival(providerType = ProviderType.PUBLIC, url = null, beginDe = null, region = null)

        service.restore(festival)

        assertThat(festival.isDeleted()).isFalse()
        verifyNoInteractions(duplicates)
    }
}
