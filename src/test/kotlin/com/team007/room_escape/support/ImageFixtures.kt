package com.team007.room_escape.support

import java.awt.image.BufferedImage
import java.io.ByteArrayInputStream
import java.io.ByteArrayOutputStream
import java.nio.ByteBuffer
import java.nio.ByteOrder
import javax.imageio.ImageIO

/** 업로드 테스트에 쓰는 진짜 이미지 바이트. 위치 정보(EXIF)가 든 파일도 만든다. */
object ImageFixtures {

    /** 테스트에서 "이 글자가 파일에 남아 있으면 위치 정보가 새는 것"이라고 보는 표식 */
    const val GPS_MARKER = "GPS-MARKER-37.5665N-126.9780E"

    fun png(width: Int = 4, height: Int = 4): ByteArray = encode(width, height, "png", BufferedImage.TYPE_INT_ARGB)

    fun jpeg(width: Int = 4, height: Int = 4): ByteArray = encode(width, height, "jpg", BufferedImage.TYPE_INT_RGB)

    /** 사진 방향([orientation], 6이면 90도 돌려 봐야 하는 사진)과 위치 표식이 든 EXIF를 붙인 JPEG */
    fun jpegWithExif(width: Int = 20, height: Int = 10, orientation: Int = 6): ByteArray {
        val plain = jpeg(width, height)
        val tiff = ByteBuffer.allocate(8 + 2 + 12 + 4).order(ByteOrder.BIG_ENDIAN).apply {
            put("MM".toByteArray()); putShort(0x002A); putInt(8) // 머리말, IFD0 위치
            putShort(1) // 항목 1개
            putShort(0x0112); putShort(3); putInt(1); putShort(orientation.toShort()); putShort(0) // 사진 방향
            putInt(0) // 다음 IFD 없음
        }.array()
        val payload = "Exif\u0000\u0000".toByteArray(Charsets.ISO_8859_1) + tiff + GPS_MARKER.toByteArray()
        val app1 = ByteBuffer.allocate(4 + payload.size).order(ByteOrder.BIG_ENDIAN).apply {
            putShort(0xFFE1.toShort()); putShort((payload.size + 2).toShort()); put(payload)
        }.array()
        // 파일 맨 앞(SOI 2바이트) 바로 뒤에 EXIF 구간을 끼워 넣는다.
        return plain.copyOfRange(0, 2) + app1 + plain.copyOfRange(2, plain.size)
    }

    /**
     * 구조만 맞춘 WebP. 그림 데이터는 가짜지만, EXIF·XMP 덩어리와 VP8X 표시를 갖춘다.
     * 서버가 WebP를 해석하지 않고 덩어리만 다루기 때문에 이걸로 충분하다.
     */
    fun webp(withMetadata: Boolean = true): ByteArray {
        val chunks = ByteArrayOutputStream()
        fun chunk(tag: String, data: ByteArray) {
            chunks.write(tag.toByteArray(Charsets.ISO_8859_1))
            chunks.write(ByteBuffer.allocate(4).order(ByteOrder.LITTLE_ENDIAN).putInt(data.size).array())
            chunks.write(data)
            if (data.size % 2 == 1) chunks.write(0)
        }
        val flags = if (withMetadata) 0x08 or 0x04 else 0
        chunk("VP8X", byteArrayOf(flags.toByte(), 0, 0, 0, 3, 0, 0, 3, 0, 0)) // 4x4 캔버스
        chunk("VP8 ", byteArrayOf(1, 2, 3, 4, 5, 6))
        if (withMetadata) {
            chunk("EXIF", GPS_MARKER.toByteArray())
            chunk("XMP ", "<x:xmpmeta>$GPS_MARKER</x:xmpmeta>".toByteArray())
        }
        val body = chunks.toByteArray()
        return ByteBuffer.allocate(12 + body.size).order(ByteOrder.LITTLE_ENDIAN).apply {
            put("RIFF".toByteArray()); putInt(4 + body.size); put("WEBP".toByteArray()); put(body)
        }.array()
    }

    /** 이미지를 읽어 가로 x 세로를 돌려준다. */
    fun sizeOf(bytes: ByteArray): Pair<Int, Int> {
        val image = checkNotNull(ImageIO.read(ByteArrayInputStream(bytes))) { "이미지를 읽을 수 없다" }
        return image.width to image.height
    }

    fun contains(bytes: ByteArray, text: String): Boolean = String(bytes, Charsets.ISO_8859_1).contains(text)

    private fun encode(width: Int, height: Int, format: String, type: Int): ByteArray {
        val image = BufferedImage(width, height, type)
        return ByteArrayOutputStream().also { check(ImageIO.write(image, format, it)) }.toByteArray()
    }
}
