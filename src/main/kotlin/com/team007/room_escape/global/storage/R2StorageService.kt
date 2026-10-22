package com.team007.room_escape.global.storage

import com.team007.room_escape.global.config.R2Properties
import com.team007.room_escape.global.exception.BusinessException
import com.team007.room_escape.global.response.code.StorageExceptionCode
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

/** Cloudflare R2 파일 저장소. DB에는 URL이 아니라 key만 저장해서 도메인이 바뀌어도 데이터를 안 건드린다. */
@Service
class R2StorageService(
    private val s3Client: S3Client,
    private val properties: R2Properties
) {

    private val log = LoggerFactory.getLogger(javaClass)

    /** 업로드 후 key를 돌려준다. key는 공개되므로 주인 확인용으로 key에 회원 ID를 넣는다. (예: posts/{회원ID}/0198....jpg) */
    fun upload(file: MultipartFile?, directory: String, ownerId: UUID): String {
        if (file == null || file.isEmpty) {
            throw BusinessException(StorageExceptionCode.EMPTY_FILE)
        }

        val extension = ALLOWED_TYPES.get(file.contentType)
        if (extension == null) {
            throw BusinessException(StorageExceptionCode.UNSUPPORTED_FILE_TYPE)
        }

        val key = "$directory/$ownerId/${UUID.randomUUID()}.$extension"
        try {
            s3Client.putObject(
                PutObjectRequest.builder()
                    .bucket(properties.bucket())
                    .key(key)
                    .contentType(file.contentType)
                    // key가 UUID라 내용이 안 바뀌어서 1년 캐시해도 안전하다.
                    .cacheControl("public, max-age=31536000, immutable")
                    .build(),
                RequestBody.fromInputStream(file.inputStream, file.size)
            )
        } catch (e: IOException) {
            log.error("R2 업로드 실패 key={}", key, e)
            throw BusinessException(StorageExceptionCode.UPLOAD_FAILED)
        } catch (e: SdkException) {
            log.error("R2 업로드 실패 key={}", key, e)
            throw BusinessException(StorageExceptionCode.UPLOAD_FAILED)
        }
        return key
    }

    /** 서버가 만든 바이트 배열을 업로드한다. 배치처럼 MultipartFile이 없을 때 쓰고, contentType은 직접 넘긴다. */
    fun upload(content: ByteArray, contentType: String, directory: String): String {
        val extension = ALLOWED_TYPES.get(contentType)
        if (extension == null) {
            throw BusinessException(StorageExceptionCode.UNSUPPORTED_FILE_TYPE)
        }

        val key = "$directory/${UUID.randomUUID()}.$extension"
        try {
            s3Client.putObject(
                PutObjectRequest.builder()
                    .bucket(properties.bucket())
                    .key(key)
                    .contentType(contentType)
                    .cacheControl("public, max-age=31536000, immutable")
                    .build(),
                RequestBody.fromBytes(content)
            )
        } catch (e: SdkException) {
            log.error("R2 업로드 실패 key={}", key, e)
            throw BusinessException(StorageExceptionCode.UPLOAD_FAILED)
        }
        return key
    }

    /** 이 회원이 올린 key인지. 형식은 {폴더}/{회원ID}/{파일명}이고, 회원 ID가 없는 옛 key는 false다. */
    fun isOwnedBy(key: String?, memberId: UUID?): Boolean {
        if (key == null || memberId == null) {
            return false
        }
        // Java String.split과 같게 끝의 빈 문자열은 버린다.
        val parts = key.split("/").dropLastWhile { it.isEmpty() }
        return parts.size == 3 && parts[1] == memberId.toString()
    }

    /** 새로 저장할 key가 본인 것인지 확인한다. 비우거나 지금 값 그대로면 통과시킨다. */
    fun requireOwnedBy(newKey: String?, currentKey: String?, memberId: UUID?) {
        if (newKey == null || isBlank(newKey) || newKey == currentKey) {
            return
        }
        if (!isOwnedBy(newKey, memberId)) {
            throw BusinessException(StorageExceptionCode.IMAGE_NOT_OWNED)
        }
    }

    /** 본인 파일만 지운다. 롤백 시 이미지가 깨지지 않게 트랜잭션 커밋 후에 지운다. */
    fun deleteOwnedBy(key: String?, memberId: UUID?) {
        if (!isOwnedBy(key, memberId)) {
            return
        }
        if (!TransactionSynchronizationManager.isSynchronizationActive()) {
            delete(key)
            return
        }
        TransactionSynchronizationManager.registerSynchronization(object : TransactionSynchronization {
            override fun afterCommit() {
                delete(key)
            }
        })
    }

    /** 삭제 실패는 로그만 남긴다. 파일이 남는 것보다 비즈니스 흐름이 끊기는 게 더 나쁘다. */
    fun delete(key: String?) {
        if (key == null || isBlank(key)) {
            return
        }
        try {
            s3Client.deleteObject(
                DeleteObjectRequest.builder()
                    .bucket(properties.bucket())
                    .key(key)
                    .build()
            )
        } catch (e: SdkException) {
            log.warn("R2 삭제 실패 key={}", key, e)
        }
    }

    // Kotlin의 isBlank()는 NBSP도 공백으로 봐서, Java String.isBlank()와 같은 기준으로 맞춘다.
    private fun isBlank(value: String): Boolean {
        return value.all { Character.isWhitespace(it) }
    }

    companion object {

        /** 허용 Content-Type과 저장 시 사용할 확장자 */
        private val ALLOWED_TYPES: Map<String, String> = java.util.Map.of(
            "image/jpeg", "jpg",
            "image/png", "png",
            "image/webp", "webp"
        )
    }
}
