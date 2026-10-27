package com.team007.room_escape.global.storage

import com.team007.room_escape.global.exception.BusinessException
import com.team007.room_escape.global.response.code.StorageExceptionCode
import net.coobird.thumbnailator.Thumbnails
import org.springframework.beans.factory.annotation.Value
import org.springframework.stereotype.Component
import java.io.ByteArrayInputStream
import java.io.ByteArrayOutputStream
import java.io.IOException
import java.nio.ByteBuffer
import java.nio.ByteOrder
import javax.imageio.ImageIO

/** 업로드를 허용하는 이미지 형식. */
enum class ImageFormat(val contentType: String, val extension: String) {
    JPEG("image/jpeg", "jpg"),
    PNG("image/png", "png"),
    WEBP("image/webp", "webp");

    companion object {
        fun ofContentType(contentType: String?): ImageFormat? = entries.firstOrNull { it.contentType == contentType }
    }
}

/**
 * 올라온 파일이 정말 허용한 이미지인지 확인하고, 촬영 위치 같은 메타데이터(EXIF 등)를 지운 바이트를 돌려준다.
 * 이미지는 공개 URL로 누구나 받을 수 있어서, 올린 사진의 GPS 좌표가 그대로 새지 않게 한다.
 *
 * - JPEG·PNG: 한 번 읽어서 다시 저장한다. 메타데이터가 빠지고, 사진 방향(EXIF orientation)은 실제 픽셀에 반영한다.
 *   읽기 전에 해상도부터 보고, 너무 크면 메모리를 잡아먹기 전에 거절한다.
 * - WebP: 이 서버에는 WebP를 읽는 코드가 없어서 파일 구조만 확인하고 EXIF·XMP 덩어리를 그대로 잘라 낸다.
 */
@Component
class ImageSanitizer(
    @Value("\${storage.upload.max-pixels:25000000}") private val maxPixels: Long,
) {

    class CleanImage(val bytes: ByteArray, val format: ImageFormat)

    /** [claimedContentType]은 요청이 주장한 형식이다. 허용하지 않는 형식이거나 실제 내용과 다르면 거절한다. */
    fun sanitize(content: ByteArray, claimedContentType: String?): CleanImage {
        val claimed = ImageFormat.ofContentType(claimedContentType)
            ?: throw BusinessException(StorageExceptionCode.UNSUPPORTED_FILE_TYPE)
        val actual = detect(content) ?: throw BusinessException(StorageExceptionCode.INVALID_IMAGE)
        if (actual != claimed) throw BusinessException(StorageExceptionCode.INVALID_IMAGE)

        val clean = when (actual) {
            ImageFormat.JPEG, ImageFormat.PNG -> reencode(content, actual)
            ImageFormat.WEBP -> stripWebpMetadata(content)
        }
        return CleanImage(clean, actual)
    }

    /** 파일 맨 앞의 고정 바이트(매직 넘버)로 실제 형식을 알아낸다. */
    private fun detect(content: ByteArray): ImageFormat? = when {
        content.startsWith(JPEG_SIGNATURE) -> ImageFormat.JPEG
        content.startsWith(PNG_SIGNATURE) -> ImageFormat.PNG
        content.size >= 12 && content.startsWith(RIFF) && content.matchesAt(8, WEBP) -> ImageFormat.WEBP
        else -> null
    }

    private fun reencode(content: ByteArray, format: ImageFormat): ByteArray {
        requireWithinPixelLimit(content, format)
        return try {
            ByteArrayOutputStream().also { out ->
                Thumbnails.of(ByteArrayInputStream(content))
                    .scale(1.0)
                    .outputFormat(format.extension)
                    .outputQuality(JPEG_QUALITY)
                    .toOutputStream(out)
            }.toByteArray()
        } catch (e: IOException) {
            throw BusinessException(StorageExceptionCode.INVALID_IMAGE)
        } catch (e: RuntimeException) {
            throw BusinessException(StorageExceptionCode.INVALID_IMAGE)
        }
    }

    /** 이미지 전체를 읽지 않고 머리말만 읽어 가로x세로를 확인한다. */
    private fun requireWithinPixelLimit(content: ByteArray, format: ImageFormat) {
        val pixels = try {
            ImageIO.createImageInputStream(ByteArrayInputStream(content)).use { input ->
                val reader = ImageIO.getImageReadersByFormatName(format.extension).asSequence().firstOrNull()
                    ?: throw BusinessException(StorageExceptionCode.INVALID_IMAGE)
                try {
                    reader.input = input
                    reader.getWidth(0).toLong() * reader.getHeight(0)
                } finally {
                    reader.dispose()
                }
            }
        } catch (e: IOException) {
            throw BusinessException(StorageExceptionCode.INVALID_IMAGE)
        } catch (e: RuntimeException) {
            throw BusinessException(StorageExceptionCode.INVALID_IMAGE)
        }
        if (pixels > maxPixels) throw BusinessException(StorageExceptionCode.IMAGE_TOO_LARGE)
    }

    /**
     * WebP(RIFF) 파일을 덩어리(chunk) 단위로 읽어 EXIF·XMP 덩어리만 뺀다. 구조가 이상하면 거절한다.
     * VP8X 머리말에는 "EXIF/XMP가 있다"는 표시가 있어서 함께 끈다.
     */
    private fun stripWebpMetadata(content: ByteArray): ByteArray {
        val buffer = ByteBuffer.wrap(content).order(ByteOrder.LITTLE_ENDIAN)
        val end = (buffer.getInt(4).toLong() and UINT_MASK) + RIFF_HEADER_SIZE
        if (end > content.size || end < WEBP_HEADER_SIZE) throw BusinessException(StorageExceptionCode.INVALID_IMAGE)

        val out = ByteArrayOutputStream(content.size)
        out.write(content, 0, WEBP_HEADER_SIZE)
        var hasPicture = false
        var position = WEBP_HEADER_SIZE.toLong()
        while (position < end) {
            if (position + CHUNK_HEADER_SIZE > end) throw BusinessException(StorageExceptionCode.INVALID_IMAGE)
            val start = position.toInt()
            val tag = String(content, start, 4, Charsets.ISO_8859_1)
            val size = buffer.getInt(start + 4).toLong() and UINT_MASK
            val chunkEnd = position + CHUNK_HEADER_SIZE + size + (size and 1L) // 덩어리는 짝수 바이트로 맞춰 둔다.
            if (chunkEnd > end) throw BusinessException(StorageExceptionCode.INVALID_IMAGE)

            when (tag) {
                "EXIF", "XMP " -> Unit
                else -> {
                    if (tag == "VP8 " || tag == "VP8L" || tag == "ANMF") hasPicture = true
                    val chunk = content.copyOfRange(start, chunkEnd.toInt())
                    if (tag == "VP8X" && size >= 1) {
                        chunk[CHUNK_HEADER_SIZE] = (chunk[CHUNK_HEADER_SIZE].toInt() and VP8X_METADATA_FLAGS.inv()).toByte()
                    }
                    out.write(chunk)
                }
            }
            position = chunkEnd
        }
        if (!hasPicture) throw BusinessException(StorageExceptionCode.INVALID_IMAGE)

        return out.toByteArray().also {
            ByteBuffer.wrap(it).order(ByteOrder.LITTLE_ENDIAN).putInt(4, it.size - RIFF_HEADER_SIZE)
        }
    }

    private fun ByteArray.startsWith(prefix: ByteArray) = size >= prefix.size && matchesAt(0, prefix)

    private fun ByteArray.matchesAt(offset: Int, expected: ByteArray) =
        expected.indices.all { this[offset + it] == expected[it] }

    private companion object {
        val JPEG_SIGNATURE = byteArrayOf(0xFF.toByte(), 0xD8.toByte(), 0xFF.toByte())
        val PNG_SIGNATURE = byteArrayOf(0x89.toByte(), 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A)
        val RIFF = "RIFF".toByteArray(Charsets.ISO_8859_1)
        val WEBP = "WEBP".toByteArray(Charsets.ISO_8859_1)

        const val RIFF_HEADER_SIZE = 8
        const val WEBP_HEADER_SIZE = 12
        const val CHUNK_HEADER_SIZE = 8
        const val UINT_MASK = 0xFFFFFFFFL

        /** VP8X 플래그 중 XMP(0x04)와 EXIF(0x08) 표시 */
        const val VP8X_METADATA_FLAGS = 0x0C

        /** JPEG를 다시 저장할 때의 품질. 눈에 띄는 손실 없이 용량을 크게 늘리지 않는 값이다. */
        const val JPEG_QUALITY = 0.92f
    }
}
