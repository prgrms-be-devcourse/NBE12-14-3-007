package com.team007.room_escape.domain.festival.service

import com.team007.room_escape.domain.deletion.service.DeletionHistoryService
import com.team007.room_escape.domain.festival.dto.AdminFestivalRequest
import com.team007.room_escape.domain.festival.infra.entity.Festival
import com.team007.room_escape.domain.festival.infra.entity.FestivalRegion
import com.team007.room_escape.domain.festival.infra.repository.FestivalRepository
import com.team007.room_escape.global.storage.R2StorageService
import com.team007.room_escape.global.util.RichTextSanitizer
import org.junit.jupiter.api.Test
import org.mockito.Mockito.mock
import org.mockito.Mockito.verify
import org.mockito.Mockito.`when`
import java.time.LocalDateTime
import java.util.UUID

class AdminFestivalServiceImageTest {

    private val festivals = mock(FestivalRepository::class.java)
    private val storage = mock(R2StorageService::class.java)
    private val service = AdminFestivalService(
        festivals, mock(RichTextSanitizer::class.java), mock(DeletionHistoryService::class.java), storage,
    )

    private val adminId = UUID.randomUUID()
    private val authorsImage = "festivals/${UUID.randomUUID()}/author.png"

    private fun request(imgUrl: String?) = AdminFestivalRequest.Update(
        title = "행사", category = "축제", festivalContent = null, referenceUrl = null,
        region = FestivalRegion.SEOUL, regionDetail = null, imgUrl = imgUrl,
        beginDe = LocalDateTime.of(2026, 10, 1, 10, 0), endDe = LocalDateTime.of(2026, 10, 5, 18, 0),
        partcptExpnInfo = null, telnoInfo = null,
    )

    @Test
    fun `관리자가 수정하면 수정 전에 저장돼 있던 본문과 이미지를 기준으로 이미지를 확정한다`() {
        val festival = Festival(id = 7L, imgUrl = "https://img.example.com/$authorsImage")
        `when`(festivals.findByIdAndDeletedAtIsNull(7L)).thenReturn(festival)
        val previousImage = festival.imgUrl
        val adminsNewImage = "https://img.example.com/festivals/$adminId/new.png"

        service.update(7L, request(adminsNewImage), adminId)

        // 수정이 반영된 뒤의 값(관리자의 새 이미지)이 아니라 수정 전 값을 넘겨야 한다.
        verify(storage).confirmImagesForUpdate(adminId, null, previousImage, null, adminsNewImage)
    }
}
