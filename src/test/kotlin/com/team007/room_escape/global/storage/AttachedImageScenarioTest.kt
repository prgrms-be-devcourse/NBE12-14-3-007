package com.team007.room_escape.global.storage

import com.team007.room_escape.global.config.R2Properties
import com.team007.room_escape.global.exception.BusinessException
import com.team007.room_escape.global.response.code.StorageExceptionCode
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.assertThrows
import org.mockito.Mockito.mock
import org.mockito.Mockito.`when`
import software.amazon.awssdk.services.s3.S3Client
import java.util.UUID

/** 관리자가 행사 이미지를 교체한 뒤 작성자가 수정하는 흐름을, 실제 장부 규칙으로 끝까지 따라가 본다. */
class AttachedImageScenarioTest {

    private val repository = mock(UploadedImageRepository::class.java)
    private val storage = R2StorageService(
        mock(S3Client::class.java),
        R2Properties("account", "access", "secret", "my-bucket", "https://img.example.com"),
        UploadedImageService(repository),
        ImageSanitizer(maxPixels = 25_000_000),
    )

    private val author = UUID.randomUUID()
    private val admin = UUID.randomUUID()

    /** 장부에 있는 이미지. 주인이 [owner]이고 이미 사용 확정(ACTIVE)된 상태다. */
    private fun activeImage(owner: UUID, name: String = "a.png"): UploadedImage {
        val image = UploadedImage("festivals/$owner/$name", owner)
        image.activate()
        `when`(repository.findLocked(image.key)).thenReturn(image)
        return image
    }

    private fun urlOf(image: UploadedImage) = "https://img.example.com/${image.key}"

    @Nested
    inner class `관리자가 교체한 이미지` {

        @Test
        fun `작성자가 이미지를 그대로 두고 제목만 고치면 저장된다`() {
            val image = activeImage(admin)

            storage.confirmImagesForUpdate(
                author, previousContent = "<p>소개</p>", previousImage = urlOf(image),
                content = "<p>소개</p>", image = urlOf(image),
            )

            assertThat(image.state).isEqualTo(UploadState.ACTIVE)
        }

        @Test
        fun `본문 안의 이미지도 원래 붙어 있었다면 그대로 둘 수 있다`() {
            val image = activeImage(admin)
            val content = "<p>소개</p><p><img src=\"${urlOf(image)}\"></p>"

            storage.confirmImagesForUpdate(author, content, null, content, null)

            assertThat(image.state).isEqualTo(UploadState.ACTIVE)
        }

        @Test
        fun `새 글로 붙이려면(이전 값이 없으면) 거절된다`() {
            val image = activeImage(admin)

            val exception = assertThrows<BusinessException> {
                storage.confirmImages(author, null, urlOf(image))
            }

            assertThat(exception.exceptionCode).isEqualTo(StorageExceptionCode.IMAGE_NOT_OWNED)
        }
    }

    @Nested
    inner class `남의 이미지를 새로 붙이는 경우` {

        @Test
        fun `작성자가 이 행사에 붙어 있지 않은 남의 이미지를 붙이면 거절된다`() {
            val attachedOne = activeImage(admin, "attached.png")
            val someoneElses = activeImage(UUID.randomUUID(), "other.png")

            val exception = assertThrows<BusinessException> {
                storage.confirmImagesForUpdate(
                    author, previousContent = null, previousImage = urlOf(attachedOne),
                    content = null, image = urlOf(someoneElses),
                )
            }

            assertThat(exception.exceptionCode).isEqualTo(StorageExceptionCode.IMAGE_NOT_OWNED)
        }

        @Test
        fun `관리자도 이 행사에 붙어 있지 않은 남의 이미지는 붙일 수 없다`() {
            val membersProfile = UploadedImage("profiles/$author/me.png", author).also {
                it.activate()
                `when`(repository.findLocked(it.key)).thenReturn(it)
            }

            val exception = assertThrows<BusinessException> {
                storage.confirmImagesForUpdate(admin, null, null, null, urlOf(membersProfile))
            }

            assertThat(exception.exceptionCode).isEqualTo(StorageExceptionCode.IMAGE_NOT_OWNED)
        }

        @Test
        fun `관리자가 방금 올린 새 이미지는 붙일 수 있다`() {
            val fresh = UploadedImage("festivals/$admin/new.png", admin)
            `when`(repository.findLocked(fresh.key)).thenReturn(fresh)

            storage.confirmImagesForUpdate(admin, null, null, null, urlOf(fresh))

            assertThat(fresh.state).isEqualTo(UploadState.ACTIVE)
        }
    }

    @Test
    fun `붙어 있던 이미지가 이미 삭제 중이면 수정이 거절된다`() {
        val image = activeImage(admin)
        image.beginDeletion()

        val exception = assertThrows<BusinessException> {
            storage.confirmImagesForUpdate(author, null, urlOf(image), null, urlOf(image))
        }

        assertThat(exception.exceptionCode).isEqualTo(StorageExceptionCode.IMAGE_EXPIRED)
    }

    @Nested
    inner class `수정 전 값이 이상한 경우` {

        @Test
        fun `읽을 수 없는 주소가 섞여 있어도 예외 없이 나머지는 유지된다`() {
            val image = activeImage(admin)

            storage.confirmImagesForUpdate(
                author,
                previousContent = "<img src=\"https://img.example.com/a b.png\">",
                previousImage = urlOf(image),
                content = null,
                image = urlOf(image),
            )

            assertThat(image.state).isEqualTo(UploadState.ACTIVE)
        }

        @Test
        fun `이전 값이 비어 있어도 예외 없이 처리된다`() {
            storage.confirmImagesForUpdate(author, null, "", null, null)
        }
    }
}
