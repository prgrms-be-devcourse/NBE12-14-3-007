package com.team007.room_escape.domain.festival.service

import com.team007.room_escape.domain.deletion.service.DeletionHistoryService
import com.team007.room_escape.domain.festival.infra.entity.Festival
import com.team007.room_escape.domain.festival.infra.entity.FestivalRegion
import com.team007.room_escape.domain.festival.infra.entity.ProviderType
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

    private val histories = mock(DeletionHistoryService::class.java)
    private val duplicates = mock(FestivalDuplicateValidator::class.java)
    private val service = FestivalDeletionService(histories, duplicates)

    private val begin = LocalDateTime.of(2026, 10, 3, 10, 0)
    private val end = LocalDateTime.of(2026, 10, 3, 18, 0)

    private fun deletedFestival(
        providerType: ProviderType = ProviderType.MEMBER,
        title: String? = "행사",
        beginDe: LocalDateTime? = begin,
        region: FestivalRegion? = FestivalRegion.GYEONGGI,
        district: String? = "수원시",
    ) = Festival(
        id = 7L, providerType = providerType, title = title, beginDe = beginDe, endDe = end,
        region = region, district = district,
    ).also { it.delete() }

    @ParameterizedTest(name = "행사명 \"{0}\"")
    @ValueSource(strings = ["", " ", "\t\n"])
    fun `회원 제보 행사는 행사명이 비어 있으면 복구할 수 없다`(title: String) {
        val festival = deletedFestival(title = title)

        val e = assertThrows<BusinessException> { service.restore(festival) }

        assertThat(e.exceptionCode).isEqualTo(FestivalExceptionCode.RESTORE_DATA_INCOMPLETE)
        assertThat(festival.isDeleted()).isTrue()
        verifyNoInteractions(duplicates)
    }

    @Test
    fun `회원 제보 행사는 행사명, 시작일, 지역, 시군구 중 하나라도 없으면 복구할 수 없다`() {
        listOf(
            deletedFestival(title = null),
            deletedFestival(beginDe = null),
            deletedFestival(region = null),
            deletedFestival(district = null),
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
        verify(duplicates).validate(7L, begin, end, FestivalRegion.GYEONGGI, "행사", "수원시")
    }

    @Test
    fun `공공 행사는 제보 정보 검사 없이 복구된다`() {
        val festival = deletedFestival(providerType = ProviderType.PUBLIC, title = null, beginDe = null, region = null, district = null)

        service.restore(festival)

        assertThat(festival.isDeleted()).isFalse()
        verifyNoInteractions(duplicates)
    }
}
