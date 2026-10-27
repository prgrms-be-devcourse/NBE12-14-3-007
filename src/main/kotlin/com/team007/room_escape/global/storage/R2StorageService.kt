package com.team007.room_escape.global.storage

import com.team007.room_escape.global.config.R2Properties
import com.team007.room_escape.global.exception.BusinessException
import com.team007.room_escape.global.response.code.StorageExceptionCode
import com.team007.room_escape.global.util.isBlankLikeJava
import org.slf4j.LoggerFactory
import org.springframework.stereotype.Service
import org.springframework.transaction.support.TransactionSynchronization
import org.springframework.transaction.support.TransactionSynchronizationManager
import org.springframework.web.multipart.MultipartFile
import software.amazon.awssdk.core.exception.SdkException
import software.amazon.awssdk.core.sync.RequestBody
import software.amazon.awssdk.services.s3.S3Client
import software.amazon.awssdk.services.s3.model.DeleteObjectRequest
import software.amazon.awssdk.services.s3.model.PutObjectRequest
import java.io.IOException
import java.util.UUID
import org.springframework.web.util.HtmlUtils
import java.net.URI

/** Cloudflare R2 파일 저장소. DB에는 URL이 아니라 key만 저장해서 도메인이 바뀌어도 데이터를 안 건드린다. */
@Service
class R2StorageService(
    private val s3Client: S3Client,
    private val properties: R2Properties,
    private val uploadedImages: UploadedImageService,
) {

    private val log = LoggerFactory.getLogger(javaClass)

    /** 업로드 후 key를 돌려준다. key는 공개되므로 주인 확인용으로 key에 회원 ID를 넣는다. (예: posts/{회원ID}/0198....jpg) */
    fun upload(file: MultipartFile?, directory: String, ownerId: UUID): String {
        if (file == null || file.isEmpty) throw BusinessException(StorageExceptionCode.EMPTY_FILE)

        val key = "$directory/$ownerId/${UUID.randomUUID()}.${extensionOf(file.contentType)}"
        uploadedImages.register(key, ownerId)
        return uploadedImages.upload(key) {
            put(key, file.contentType) { RequestBody.fromInputStream(file.inputStream, file.size) }
        }
    }

    /** 서버가 만든 바이트 배열을 업로드한다. 배치처럼 MultipartFile이 없을 때 쓰고, contentType은 직접 넘긴다. */
    fun upload(content: ByteArray, contentType: String, directory: String): String {
        val key = "$directory/${UUID.randomUUID()}.${extensionOf(contentType)}"
        return put(key, contentType) { RequestBody.fromBytes(content) }
    }

    /** 이 회원이 올린 key인지. 형식은 {폴더}/{회원ID}/{파일명}이고, 회원 ID가 없는 옛 key는 false다. */
    fun isOwnedBy(key: String?, memberId: UUID?): Boolean {
        if (key == null || memberId == null) return false
        // Java String.split과 같게 끝의 빈 문자열은 버린다.
        val parts = key.split("/").dropLastWhile { it.isEmpty() }
        return parts.size == 3 && parts[1] == memberId.toString()
    }

    /** 새로 저장할 key가 본인 것인지 확인한다. 비우거나 지금 값 그대로면 통과시킨다. */
    fun requireOwnedBy(newKey: String?, currentKey: String?, memberId: UUID?) {
        if (newKey == null || newKey.isBlankLikeJava() || newKey == currentKey) return
        if (!isOwnedBy(newKey, memberId)) throw BusinessException(StorageExceptionCode.IMAGE_NOT_OWNED)
    }

    /** 새 글의 본문·첨부에 든 신규 관리 이미지를 글 저장과 함께 확정한다. 미추적 기존 이미지는 보존한다. */
    fun confirmImages(ownerId: UUID, content: String? = null, vararg attachments: String?) {
        val keys = imageKeys(content, attachments)
        if (keys.isNotEmpty()) uploadedImages.confirm(keys, ownerId)
    }

    /**
     * 글을 수정할 때 쓴다. 수정 전에 저장돼 있던 본문·이미지는 올린 사람이 달라도 그대로 유지할 수 있고,
     * 새로 붙이는 이미지만 올린 사람이 저장하는 사람과 같아야 한다.
     * (관리자가 교체한 이미지를 작성자가 그대로 두고 수정하는 경우)
     *
     * previous* 는 수정 반영 전에 읽은 값이어야 한다. 이미 저장된 값이라 읽을 수 없는 주소는 예외 대신 건너뛴다.
     */
    fun confirmImagesForUpdate(
        ownerId: UUID,
        previousContent: String?,
        previousImage: String?,
        content: String?,
        image: String?,
    ) {
        val keys = imageKeys(content, arrayOf(image))
        if (keys.isEmpty()) return
        val attached = imageKeys(previousContent, arrayOf(previousImage), lenient = true).toSet()
        uploadedImages.confirm(keys, ownerId, attached)
    }

    private fun imageKeys(content: String?, attachments: Array<out String?>, lenient: Boolean = false): List<String> {
        val base = URI(properties.publicUrl.removeSuffix("/") + "/")
        fun key(value: String): String? {
            val decoded = HtmlUtils.htmlUnescape(value)
            return runCatching {
                val uri = URI(decoded)
                val path = if (uri.isAbsolute) {
                    if (!uri.rawAuthority.equals(base.rawAuthority, ignoreCase = true) ||
                        uri.scheme.lowercase() !in setOf("http", "https") || !uri.path.startsWith(base.path)) {
                        return decoded // 다른 저장소/공공 API 주소는 추적하지 않는다.
                    }
                    uri.path.removePrefix(base.path)
                } else uri.path
                // 공개 URL의 인코딩/쿼리/점 경로도 하나의 저장 key로 취급한다.
                URI(null, null, "/$path", null).normalize().path.removePrefix("/")
            }
                .getOrElse { if (lenient) null else throw BusinessException(StorageExceptionCode.IMAGE_EXPIRED) }
        }
        return (attachments.filterNotNull().filter { it.isNotBlank() }.map(::key) +
            IMAGE_SOURCE.findAll(content.orEmpty()).map { key(it.groupValues[1]) }.toList()).filterNotNull()
    }

    /** 본인 파일만 지운다. 롤백 시 이미지가 깨지지 않게 트랜잭션 커밋 후에 지운다. */
    fun deleteOwnedBy(key: String?, memberId: UUID?) {
        if (!isOwnedBy(key, memberId)) return
        // 사용이 확정된 관리 이미지는 다른 글/복구 대상에서 재사용될 수 있어 유지한다.
        if (uploadedImages.isTracked(checkNotNull(key))) return
        deleteAfterCommit(key)
    }

    /**
     * 개인정보 파기처럼 이미지를 더는 쓰지 않을 때 지운다. 본인 파일만 대상이다.
     * 장부에 있는 이미지는 정리 대상으로만 돌리고(정리 작업이 지우며 실패하면 다시 시도한다),
     * 장부에 없는 옛 이미지는 커밋 뒤에 바로 지운다.
     */
    fun discardOwnedBy(key: String?, memberId: UUID?) {
        if (!isOwnedBy(key, memberId)) return
        if (uploadedImages.markForDeletion(checkNotNull(key))) return
        deleteAfterCommit(key)
    }

    private fun deleteAfterCommit(key: String) {
        if (!TransactionSynchronizationManager.isSynchronizationActive()) {
            delete(key)
            return
        }
        TransactionSynchronizationManager.registerSynchronization(object : TransactionSynchronization {
            override fun afterCommit() = delete(key)
        })
    }

    /** 삭제 실패는 로그만 남긴다. 파일이 남는 것보다 비즈니스 흐름이 끊기는 게 더 나쁘다. */
    fun delete(key: String?) {
        if (key == null || key.isBlankLikeJava()) return
        tryDelete(key)
    }

    /** 정리 작업은 실패를 알아야 삭제 상태를 남겨 다음 회차에 재시도할 수 있다. */
    fun tryDelete(key: String): Boolean {
        try {
            s3Client.deleteObject(DeleteObjectRequest.builder().bucket(properties.bucket).key(key).build())
            return true
        } catch (e: SdkException) {
            log.warn("R2 삭제 실패 key={}", key, e)
            return false
        }
    }

    /** 허용한 형식이면 저장할 확장자를, 아니면 지원하지 않는 형식 예외를 던진다. */
    private fun extensionOf(contentType: String?): String =
        ALLOWED_TYPES[contentType] ?: throw BusinessException(StorageExceptionCode.UNSUPPORTED_FILE_TYPE)

    /** S3에 올리고 key를 돌려준다. 읽기·전송이 실패하면 업로드 실패 예외로 바꾼다. */
    private fun put(key: String, contentType: String?, body: () -> RequestBody): String {
        try {
            s3Client.putObject(
                PutObjectRequest.builder()
                    .bucket(properties.bucket)
                    .key(key)
                    .contentType(contentType)
                    // key가 UUID라 내용이 안 바뀌어서 1년 캐시해도 안전하다.
                    .cacheControl("public, max-age=31536000, immutable")
                    .build(),
                body(),
            )
        } catch (e: IOException) {
            throw uploadFailed(key, e)
        } catch (e: SdkException) {
            throw uploadFailed(key, e)
        }
        return key
    }

    private fun uploadFailed(key: String, e: Exception): BusinessException {
        log.error("R2 업로드 실패 key={}", key, e)
        return BusinessException(StorageExceptionCode.UPLOAD_FAILED)
    }

    companion object {
        private val IMAGE_SOURCE = Regex("<img\\b[^>]*\\bsrc=\"([^\"]+)\"", RegexOption.IGNORE_CASE)

        /** 허용 Content-Type과 저장 시 사용할 확장자 */
        private val ALLOWED_TYPES: Map<String, String> = java.util.Map.of(
            "image/jpeg", "jpg",
            "image/png", "png",
            "image/webp", "webp",
        )
    }
}
