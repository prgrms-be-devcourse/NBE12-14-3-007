package com.team007.room_escape.global.storage

import com.team007.room_escape.global.config.R2Properties
import com.team007.room_escape.global.exception.BusinessException
import com.team007.room_escape.global.response.code.StorageExceptionCode
import com.team007.room_escape.support.ImageFixtures
import org.assertj.core.api.Assertions.assertThat
import org.assertj.core.api.Assertions.assertThatCode
import org.assertj.core.api.Assertions.assertThatThrownBy
import org.junit.jupiter.api.AfterEach
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test
import org.junit.jupiter.params.ParameterizedTest
import org.junit.jupiter.params.provider.CsvSource
import org.mockito.ArgumentCaptor
import org.mockito.ArgumentMatchers.any
import org.mockito.Mockito.doThrow
import org.mockito.Mockito.mock
import org.mockito.Mockito.never
import org.mockito.Mockito.verify
import org.mockito.Mockito.`when`
import org.springframework.mock.web.MockMultipartFile
import org.springframework.transaction.support.TransactionSynchronization
import org.springframework.transaction.support.TransactionSynchronizationManager
import org.springframework.web.multipart.MultipartFile
import software.amazon.awssdk.core.exception.SdkClientException
import software.amazon.awssdk.core.sync.RequestBody
import software.amazon.awssdk.services.s3.S3Client
import software.amazon.awssdk.services.s3.model.DeleteObjectRequest
import software.amazon.awssdk.services.s3.model.PutObjectRequest
import java.io.IOException
import java.util.UUID

class R2StorageServiceTest {

    private val s3Client = mock(S3Client::class.java)
    private val uploads = mock(UploadedImageService::class.java).also { tracking ->
        org.mockito.Mockito.doAnswer { invocation ->
            invocation.getArgument<() -> String>(1).invoke()
        }.`when`(tracking).upload(org.mockito.ArgumentMatchers.anyString(), org.mockito.ArgumentMatchers.any<() -> String>() ?: { "" })
    }
    private val service = R2StorageService(
        s3Client,
        R2Properties("account", "access", "secret", "my-bucket", "https://img.example.com"),
        uploads,
        ImageSanitizer(maxPixels = 25_000_000),
    )

    private val me = UUID.randomUUID()
    private val other = UUID.randomUUID()

    @Test
    fun `본문과 첨부 이미지의 공개 URL을 key로 변환하여 사용 확정한다`() {
        val key = "posts/$me/a.png"
        service.confirmImages(me, "<p><img src=\"https://img.example.com/$key?preview=1\"></p>", key)
        verify(uploads).confirm(listOf(key, key), me)
    }

    @Test
    fun `사용 확정된 관리 이미지는 교체하더라도 직접 삭제하지 않는다`() {
        val key = "posts/$me/a.png"
        `when`(uploads.isTracked(key)).thenReturn(true)
        service.deleteOwnedBy(key, me)
        verify(s3Client, never()).deleteObject(any(DeleteObjectRequest::class.java))
    }

    private fun pngFile() = MockMultipartFile("file", "a.png", "image/png", ImageFixtures.png())

    private fun uploadedRequest(): PutObjectRequest {
        val captor = ArgumentCaptor.forClass(PutObjectRequest::class.java)
        verify(s3Client).putObject(captor.capture(), any(RequestBody::class.java))
        return captor.value
    }

    @Nested
    inner class `주인 확인` {

        @Test
        fun `key의 두 번째 자리가 회원 ID와 같을 때만 본인 파일로 본다`() {
            assertThat(service.isOwnedBy("profiles/$me/a.png", me)).isTrue()
            assertThat(service.isOwnedBy("profiles/$other/a.png", me)).isFalse()
            assertThat(service.isOwnedBy("profiles/a.png", me)).isFalse()
            assertThat(service.isOwnedBy("profiles/guest/a.png", me)).isFalse()
        }

        @Test
        fun `key나 회원 ID가 없으면 본인 파일이 아니다`() {
            assertThat(service.isOwnedBy(null, me)).isFalse()
            assertThat(service.isOwnedBy("profiles/$me/a.png", null)).isFalse()
        }

        @Test
        fun `경로가 세 칸이 아니면 본인 파일로 보지 않는다`() {
            assertThat(service.isOwnedBy("profiles/$me/sub/a.png", me)).isFalse()
            assertThat(service.isOwnedBy("profiles/$me/", me)).isFalse()
        }

        @Test
        fun `남이 올린 이미지 key로 바꾸려 하면 거절한다`() {
            assertThatThrownBy { service.requireOwnedBy("inquiries/$other/a.png", null, me) }
                .isInstanceOfSatisfying(BusinessException::class.java) {
                    assertThat(it.exceptionCode).isEqualTo(StorageExceptionCode.IMAGE_NOT_OWNED)
                }
        }

        @Test
        fun `비우거나 지금 값을 그대로 보내면 주인 확인 없이 통과한다`() {
            val legacy = "profiles/legacy.png"

            assertThatCode { service.requireOwnedBy(null, legacy, me) }.doesNotThrowAnyException()
            assertThatCode { service.requireOwnedBy("", legacy, me) }.doesNotThrowAnyException()
            assertThatCode { service.requireOwnedBy(legacy, legacy, me) }.doesNotThrowAnyException()
        }
    }

    @Nested
    inner class `파일 업로드` {

        @Test
        fun `업로드하면 폴더 회원ID 무작위값 확장자 순서의 key를 돌려준다`() {
            val key = service.upload(pngFile(), "posts", me)

            assertThat(key).matches("posts/$me/[0-9a-f\\-]{36}\\.png")
        }

        @Test
        fun `버킷 콘텐츠 타입 캐시 설정을 담아 S3에 올린다`() {
            val key = service.upload(pngFile(), "posts", me)

            val request = uploadedRequest()
            assertThat(request.bucket()).isEqualTo("my-bucket")
            assertThat(request.key()).isEqualTo(key)
            assertThat(request.contentType()).isEqualTo("image/png")
            assertThat(request.cacheControl()).isEqualTo("public, max-age=31536000, immutable")
        }

        @ParameterizedTest(name = "{0} -> .{1}")
        @CsvSource("image/jpeg,jpg", "image/png,png", "image/webp,webp")
        fun `허용한 형식은 정해진 확장자로 저장한다`(contentType: String, extension: String) {
            val content = when (contentType) {
                "image/jpeg" -> ImageFixtures.jpeg()
                "image/png" -> ImageFixtures.png()
                else -> ImageFixtures.webp()
            }
            val file = MockMultipartFile("file", "x", contentType, content)

            assertThat(service.upload(file, "posts", me)).endsWith(".$extension")
        }

        @Test
        fun `이미지가 아닌 파일은 이미지 형식이라고 주장해도 올리지 않는다`() {
            val fake = MockMultipartFile("file", "a.png", "image/png", "<script>alert(1)</script>".toByteArray())

            assertThatThrownBy { service.upload(fake, "posts", me) }.isBusiness(StorageExceptionCode.INVALID_IMAGE)
            verify(s3Client, never()).putObject(any(PutObjectRequest::class.java), any(RequestBody::class.java))
            verify(uploads, never()).register(org.mockito.ArgumentMatchers.anyString(), any(UUID::class.java) ?: me)
        }

        @Test
        fun `올라가는 파일에는 위치 정보가 없다`() {
            val photo = MockMultipartFile("file", "a.jpg", "image/jpeg", ImageFixtures.jpegWithExif())

            service.upload(photo, "posts", me)

            val captor = ArgumentCaptor.forClass(RequestBody::class.java)
            verify(s3Client).putObject(any(PutObjectRequest::class.java), captor.capture())
            val stored = captor.value.contentStreamProvider().newStream().use { it.readBytes() }
            assertThat(ImageFixtures.contains(stored, ImageFixtures.GPS_MARKER)).isFalse()
        }

        @Test
        fun `비어 있는 파일은 거절한다`() {
            val empty = MockMultipartFile("file", "a.png", "image/png", ByteArray(0))

            assertThatThrownBy { service.upload(empty, "posts", me) }.isBusiness(StorageExceptionCode.EMPTY_FILE)
            assertThatThrownBy { service.upload(null, "posts", me) }.isBusiness(StorageExceptionCode.EMPTY_FILE)
        }

        @Test
        fun `허용하지 않는 형식은 거절한다`() {
            val gif = MockMultipartFile("file", "a.gif", "image/gif", byteArrayOf(1))

            assertThatThrownBy { service.upload(gif, "posts", me) }.isBusiness(StorageExceptionCode.UNSUPPORTED_FILE_TYPE)
        }

        @Test
        fun `S3 업로드가 실패하면 업로드 실패 예외로 바꾼다`() {
            `when`(s3Client.putObject(any(PutObjectRequest::class.java), any(RequestBody::class.java)))
                .thenThrow(SdkClientException.create("연결 실패"))

            assertThatThrownBy { service.upload(pngFile(), "posts", me) }.isBusiness(StorageExceptionCode.UPLOAD_FAILED)
        }

        @Test
        fun `파일 내용을 읽다가 실패해도 업로드 실패 예외로 바꾼다`() {
            val broken = mock(MultipartFile::class.java)
            `when`(broken.isEmpty).thenReturn(false)
            `when`(broken.contentType).thenReturn("image/png")
            `when`(broken.inputStream).thenThrow(IOException("읽기 실패"))

            assertThatThrownBy { service.upload(broken, "posts", me) }.isBusiness(StorageExceptionCode.UPLOAD_FAILED)
        }
    }

    @Nested
    inner class `바이트 업로드` {

        @Test
        fun `버킷 콘텐츠 타입 캐시 설정을 담아 S3에 올린다`() {
            val key = service.upload(byteArrayOf(1, 2), "image/jpeg", "festivals")

            val request = uploadedRequest()
            assertThat(request.bucket()).isEqualTo("my-bucket")
            assertThat(request.key()).isEqualTo(key)
            assertThat(request.contentType()).isEqualTo("image/jpeg")
            assertThat(request.cacheControl()).isEqualTo("public, max-age=31536000, immutable")
        }

        @Test
        fun `S3 업로드가 실패하면 업로드 실패 예외로 바꾼다`() {
            `when`(s3Client.putObject(any(PutObjectRequest::class.java), any(RequestBody::class.java)))
                .thenThrow(SdkClientException.create("연결 실패"))

            assertThatThrownBy { service.upload(byteArrayOf(1), "image/png", "festivals") }
                .isBusiness(StorageExceptionCode.UPLOAD_FAILED)
        }

        @Test
        fun `회원 ID 없이 폴더 무작위값 확장자 순서의 key를 돌려준다`() {
            val key = service.upload(byteArrayOf(1, 2), "image/webp", "festivals")

            assertThat(key).matches("festivals/[0-9a-f\\-]{36}\\.webp")
            assertThat(uploadedRequest().contentType()).isEqualTo("image/webp")
        }

        @Test
        fun `허용하지 않는 형식은 거절한다`() {
            assertThatThrownBy { service.upload(byteArrayOf(1), "text/html", "festivals") }
                .isBusiness(StorageExceptionCode.UNSUPPORTED_FILE_TYPE)
        }
    }

    @Nested
    inner class `삭제` {

        @Test
        fun `남의 파일이나 주인을 알 수 없는 옛 파일은 지우지 않는다`() {
            service.deleteOwnedBy("profiles/$other/a.png", me)
            service.deleteOwnedBy("profiles/legacy.png", me)

            verify(s3Client, never()).deleteObject(any(DeleteObjectRequest::class.java))
        }

        @Test
        fun `본인 파일은 지운다`() {
            service.deleteOwnedBy("profiles/$me/a.png", me)

            verify(s3Client).deleteObject(any(DeleteObjectRequest::class.java))
        }

        @Test
        fun `비어 있는 key는 아무것도 하지 않는다`() {
            service.delete(null)
            service.delete("")
            service.delete("  ")

            verify(s3Client, never()).deleteObject(any(DeleteObjectRequest::class.java))
        }

        @Test
        fun `삭제가 실패해도 예외를 던지지 않는다`() {
            doThrow(SdkClientException.create("삭제 실패")).`when`(s3Client).deleteObject(any(DeleteObjectRequest::class.java))

            assertThatCode { service.delete("profiles/$me/a.png") }.doesNotThrowAnyException()
        }

        @Test
        fun `삭제 요청에는 버킷과 key를 담는다`() {
            service.delete("profiles/$me/a.png")

            val captor = ArgumentCaptor.forClass(DeleteObjectRequest::class.java)
            verify(s3Client).deleteObject(captor.capture())
            assertThat(captor.value.bucket()).isEqualTo("my-bucket")
            assertThat(captor.value.key()).isEqualTo("profiles/$me/a.png")
        }
    }

    /** DB 트랜잭션 안에서 부르면, 롤백될 수도 있으니 커밋된 뒤에야 파일을 지운다 */
    @Nested
    inner class `트랜잭션 안에서 삭제` {

        @BeforeEach
        fun startTransaction() = TransactionSynchronizationManager.initSynchronization()

        @AfterEach
        fun endTransaction() = TransactionSynchronizationManager.clear()

        private fun commit() = TransactionSynchronizationManager.getSynchronizations().forEach { it.afterCommit() }

        @Test
        fun `커밋되기 전에는 지우지 않고 커밋된 뒤에 지운다`() {
            service.deleteOwnedBy("profiles/$me/a.png", me)

            verify(s3Client, never()).deleteObject(any(DeleteObjectRequest::class.java))

            commit()

            verify(s3Client).deleteObject(any(DeleteObjectRequest::class.java))
        }

        @Test
        fun `롤백되면 지우지 않는다`() {
            service.deleteOwnedBy("profiles/$me/a.png", me)

            TransactionSynchronizationManager.getSynchronizations()
                .forEach { it.afterCompletion(TransactionSynchronization.STATUS_ROLLED_BACK) }

            verify(s3Client, never()).deleteObject(any(DeleteObjectRequest::class.java))
        }

        @Test
        fun `남의 파일은 커밋 뒤에도 지우지 않는다`() {
            service.deleteOwnedBy("profiles/$other/a.png", me)

            commit()

            verify(s3Client, never()).deleteObject(any(DeleteObjectRequest::class.java))
        }
    }

    /** 던져진 예외가 해당 에러 코드의 비즈니스 예외인지 확인한다 */
    private fun org.assertj.core.api.AbstractThrowableAssert<*, *>.isBusiness(code: StorageExceptionCode) {
        isInstanceOfSatisfying(BusinessException::class.java) {
            assertThat(it.exceptionCode).isEqualTo(code)
        }
    }
}
