package com.team007.room_escape.domain.festival.service

import com.team007.room_escape.global.storage.ImageUrlResolver
import com.team007.room_escape.global.storage.R2StorageService
import java.io.ByteArrayInputStream
import java.io.ByteArrayOutputStream
import java.time.Duration
import net.coobird.thumbnailator.Thumbnails
import org.slf4j.LoggerFactory
import org.springframework.http.client.SimpleClientHttpRequestFactory
import org.springframework.stereotype.Component
import org.springframework.web.client.RestClient

/** 공공 행사 이미지를 리사이즈해 R2에 올린다. 실패하면 원본 URL을 그대로 돌려준다. */
@Component
class FestivalImageProcessor(
    private val r2StorageService: R2StorageService,
    private val imageUrlResolver: ImageUrlResolver
) {
    private val log = LoggerFactory.getLogger(javaClass)

    // 타임아웃용 requestFactory를 먼저 조립해야 해서 프로퍼티 초기화에서 만든다.
    private val restClient: RestClient = RestClient.builder()
        .requestFactory(
            SimpleClientHttpRequestFactory().apply {
                setConnectTimeout(DOWNLOAD_TIMEOUT.toMillis().toInt())
                setReadTimeout(DOWNLOAD_TIMEOUT.toMillis().toInt())
            }
        )
        .build()

    /** 리사이즈해 R2에 올리고 새 URL을 돌려준다. 어디서 실패하든 원본 URL을 돌려준다. */
    fun process(originalUrl: String?): String? {
        if (originalUrl.isNullOrBlank()) {
            return originalUrl
        }
        return try {
            val original: ByteArray = checkNotNull(
                restClient.get().uri(originalUrl).retrieve().body(ByteArray::class.java)
            ) { "이미지 다운로드 응답 본문이 비어있음" }

            val resized = resize(original)
            val key = r2StorageService.upload(resized, OUTPUT_CONTENT_TYPE, DIRECTORY)
            imageUrlResolver.resolve(key)
        } catch (e: Exception) {
            log.warn("행사 이미지 리사이즈 실패, 원본 URL 유지: {}", originalUrl, e)
            originalUrl
        }
    }

    /** 원본 포맷과 상관없이 jpg로 통일해서 저장한다. */
    private fun resize(original: ByteArray): ByteArray {
        val out = ByteArrayOutputStream()
        Thumbnails.of(ByteArrayInputStream(original))
            .width(MAX_WIDTH) // 높이는 안 정해줘도 원본 비율 유지해서 자동 계산됨
            .outputFormat("jpg")
            .toOutputStream(out)
        return out.toByteArray()
    }

    companion object {
        private const val MAX_WIDTH = 1200
        private const val DIRECTORY = "festivals"
        private const val OUTPUT_CONTENT_TYPE = "image/jpeg"

        /** weserv.nl 프록시가 무한 대기한 적이 있어 다운로드에도 타임아웃을 둔다. */
        private val DOWNLOAD_TIMEOUT: Duration = Duration.ofSeconds(10)
    }
}
