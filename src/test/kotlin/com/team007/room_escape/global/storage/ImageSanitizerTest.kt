package com.team007.room_escape.global.storage

import com.team007.room_escape.global.exception.BusinessException
import com.team007.room_escape.global.response.code.StorageExceptionCode
import com.team007.room_escape.support.ImageFixtures
import org.assertj.core.api.Assertions.assertThat
import org.assertj.core.api.Assertions.assertThatThrownBy
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test
import java.nio.ByteBuffer
import java.nio.ByteOrder

class ImageSanitizerTest {

    private val sanitizer = ImageSanitizer(maxPixels = 10_000)

    private fun org.assertj.core.api.AbstractThrowableAssert<*, *>.isBusiness(code: StorageExceptionCode) {
        isInstanceOfSatisfying(BusinessException::class.java) { assertThat(it.exceptionCode).isEqualTo(code) }
    }

    @Nested
    inner class `실제 형식 확인` {

        @Test
        fun `형식이 맞는 이미지는 그 형식 그대로 돌려준다`() {
            assertThat(sanitizer.sanitize(ImageFixtures.jpeg(), "image/jpeg").format).isEqualTo(ImageFormat.JPEG)
            assertThat(sanitizer.sanitize(ImageFixtures.png(), "image/png").format).isEqualTo(ImageFormat.PNG)
            assertThat(sanitizer.sanitize(ImageFixtures.webp(), "image/webp").format).isEqualTo(ImageFormat.WEBP)
        }

        @Test
        fun `이미지가 아닌 파일은 이미지 형식이라고 주장해도 거절한다`() {
            val html = "<html><script>alert(1)</script></html>".toByteArray()

            assertThatThrownBy { sanitizer.sanitize(html, "image/jpeg") }.isBusiness(StorageExceptionCode.INVALID_IMAGE)
            assertThatThrownBy { sanitizer.sanitize(byteArrayOf(1, 2, 3), "image/png") }
                .isBusiness(StorageExceptionCode.INVALID_IMAGE)
        }

        @Test
        fun `주장한 형식과 실제 형식이 다르면 거절한다`() {
            assertThatThrownBy { sanitizer.sanitize(ImageFixtures.png(), "image/jpeg") }
                .isBusiness(StorageExceptionCode.INVALID_IMAGE)
            assertThatThrownBy { sanitizer.sanitize(ImageFixtures.jpeg(), "image/webp") }
                .isBusiness(StorageExceptionCode.INVALID_IMAGE)
        }

        @Test
        fun `허용하지 않는 형식을 주장하면 내용을 보기 전에 거절한다`() {
            assertThatThrownBy { sanitizer.sanitize(ImageFixtures.png(), "image/gif") }
                .isBusiness(StorageExceptionCode.UNSUPPORTED_FILE_TYPE)
            assertThatThrownBy { sanitizer.sanitize(ImageFixtures.png(), null) }
                .isBusiness(StorageExceptionCode.UNSUPPORTED_FILE_TYPE)
        }

        @Test
        fun `머리만 이미지 같고 내용이 깨진 파일은 거절한다`() {
            val truncated = ImageFixtures.jpeg().copyOf(10)
            val garbagePng = ImageFixtures.png().copyOf(12)

            assertThatThrownBy { sanitizer.sanitize(truncated, "image/jpeg") }.isBusiness(StorageExceptionCode.INVALID_IMAGE)
            assertThatThrownBy { sanitizer.sanitize(garbagePng, "image/png") }.isBusiness(StorageExceptionCode.INVALID_IMAGE)
        }
    }

    @Nested
    inner class `해상도 제한` {

        @Test
        fun `제한을 넘는 해상도는 이미지를 읽기 전에 거절한다`() {
            // 제한 10,000 화소 (100x100)
            assertThatThrownBy { sanitizer.sanitize(ImageFixtures.png(200, 200), "image/png") }
                .isBusiness(StorageExceptionCode.IMAGE_TOO_LARGE)
            assertThatThrownBy { sanitizer.sanitize(ImageFixtures.jpeg(101, 100), "image/jpeg") }
                .isBusiness(StorageExceptionCode.IMAGE_TOO_LARGE)
        }

        @Test
        fun `제한 안의 해상도는 통과한다`() {
            val clean = sanitizer.sanitize(ImageFixtures.png(100, 100), "image/png")

            assertThat(ImageFixtures.sizeOf(clean.bytes)).isEqualTo(100 to 100)
        }
    }

    @Nested
    inner class `메타데이터 제거` {

        @Test
        fun `JPEG의 위치 정보를 지운다`() {
            val original = ImageFixtures.jpegWithExif()
            assertThat(ImageFixtures.contains(original, ImageFixtures.GPS_MARKER)).isTrue()

            val clean = sanitizer.sanitize(original, "image/jpeg")

            assertThat(ImageFixtures.contains(clean.bytes, ImageFixtures.GPS_MARKER)).isFalse()
            assertThat(ImageFixtures.contains(clean.bytes, "Exif")).isFalse()
        }

        @Test
        fun `사진 방향은 지우기 전에 실제 픽셀에 반영한다`() {
            // 가로 20 x 세로 10 이고 "90도 돌려 보기"로 표시된 사진 → 세로가 긴 10 x 20 이 되어야 한다.
            val clean = sanitizer.sanitize(ImageFixtures.jpegWithExif(20, 10, orientation = 6), "image/jpeg")

            assertThat(ImageFixtures.sizeOf(clean.bytes)).isEqualTo(10 to 20)
        }

        @Test
        fun `방향 표시가 없는 사진은 크기가 그대로다`() {
            val clean = sanitizer.sanitize(ImageFixtures.jpeg(20, 10), "image/jpeg")

            assertThat(ImageFixtures.sizeOf(clean.bytes)).isEqualTo(20 to 10)
        }

        @Test
        fun `PNG는 투명 배경을 유지한다`() {
            val clean = sanitizer.sanitize(ImageFixtures.png(8, 8), "image/png")

            val image = javax.imageio.ImageIO.read(clean.bytes.inputStream())
            assertThat(image.colorModel.hasAlpha()).isTrue()
        }

        @Test
        fun `WebP의 EXIF와 XMP 덩어리를 지우고 표시도 끈다`() {
            val original = ImageFixtures.webp(withMetadata = true)
            assertThat(ImageFixtures.contains(original, ImageFixtures.GPS_MARKER)).isTrue()

            val clean = sanitizer.sanitize(original, "image/webp").bytes

            assertThat(ImageFixtures.contains(clean, ImageFixtures.GPS_MARKER)).isFalse()
            assertThat(ImageFixtures.contains(clean, "EXIF")).isFalse()
            assertThat(ImageFixtures.contains(clean, "XMP ")).isFalse()
            // VP8X 머리말의 EXIF(0x08)·XMP(0x04) 표시가 꺼져 있어야 한다. 머리말 12바이트 + 덩어리 머리말 8바이트 다음이 플래그다.
            assertThat(clean[20].toInt() and 0x0C).isEqualTo(0)
            // RIFF 크기가 실제 파일 크기와 맞아야 한다.
            val declared = ByteBuffer.wrap(clean).order(ByteOrder.LITTLE_ENDIAN).getInt(4)
            assertThat(declared).isEqualTo(clean.size - 8)
        }

        @Test
        fun `WebP는 그림 덩어리를 그대로 둔다`() {
            val clean = sanitizer.sanitize(ImageFixtures.webp(withMetadata = true), "image/webp").bytes

            assertThat(ImageFixtures.contains(clean, "VP8 ")).isTrue()
            assertThat(clean).hasSizeLessThan(ImageFixtures.webp(withMetadata = true).size)
        }
    }

    @Nested
    inner class `깨진 WebP` {

        @Test
        fun `덩어리 크기가 파일을 넘으면 거절한다`() {
            val broken = ImageFixtures.webp(withMetadata = false)
            ByteBuffer.wrap(broken).order(ByteOrder.LITTLE_ENDIAN).putInt(16, 9999) // 첫 덩어리(VP8X) 크기를 부풀린다.

            assertThatThrownBy { sanitizer.sanitize(broken, "image/webp") }.isBusiness(StorageExceptionCode.INVALID_IMAGE)
        }

        @Test
        fun `RIFF 크기가 파일보다 크면 거절한다`() {
            val broken = ImageFixtures.webp(withMetadata = false)
            ByteBuffer.wrap(broken).order(ByteOrder.LITTLE_ENDIAN).putInt(4, broken.size + 100)

            assertThatThrownBy { sanitizer.sanitize(broken, "image/webp") }.isBusiness(StorageExceptionCode.INVALID_IMAGE)
        }

        @Test
        fun `그림 덩어리가 하나도 없으면 거절한다`() {
            val header = ByteBuffer.allocate(12).order(ByteOrder.LITTLE_ENDIAN).apply {
                put("RIFF".toByteArray()); putInt(4); put("WEBP".toByteArray())
            }.array()

            assertThatThrownBy { sanitizer.sanitize(header, "image/webp") }.isBusiness(StorageExceptionCode.INVALID_IMAGE)
        }
    }
}
