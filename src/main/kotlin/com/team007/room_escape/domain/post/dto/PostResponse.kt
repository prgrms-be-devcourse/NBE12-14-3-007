package com.team007.room_escape.domain.post.dto

import com.team007.room_escape.domain.festival.infra.entity.Festival
import com.team007.room_escape.domain.member.dto.MemberResponse
import com.team007.room_escape.domain.post.infra.entity.Post
import com.team007.room_escape.global.storage.ImageUrlResolver
import io.swagger.v3.oas.annotations.media.Schema
import org.owasp.html.HtmlPolicyBuilder
import org.springframework.web.util.HtmlUtils
import java.time.LocalDateTime
import java.util.UUID

/** 이미지 필드(profileImg, thumbnail)는 DB의 key가 아니라 공개 URL로 내려준다. */
class PostResponse private constructor() {

    @Schema(name = "PostCreate", description = "후기 작성 결과")
    data class Create(
        val id: UUID,
    ) {
        companion object {
            fun from(post: Post): Create = Create(savedId(post))
        }
    }

    @Schema(name = "PostListItem", description = "후기 목록 항목")
    data class ListItem(
        val id: UUID,
        val member: MemberResponse.MemberInfo,
        val festivalId: Long,
        val festivalTitle: String,
        val title: String,
        val thumbnail: String?,
        val date: LocalDateTime?,
        val likeCount: Long,
        @field:Schema(description = "사진 없는 후기의 본문 미리보기. HTML을 제외한 최대 240자")
        val preview: String? = null,
    ) {
        companion object {
            fun from(post: Post, imageUrlResolver: ImageUrlResolver): ListItem {
                val festival = festivalOf(post)
                return ListItem(
                    id = savedId(post),
                    member = MemberResponse.MemberInfo.from(post.member, imageUrlResolver),
                    festivalId = festival.requiredId,
                    festivalTitle = titleOf(festival),
                    title = post.title,
                    thumbnail = imageUrlResolver.resolve(post.thumbnail),
                    date = post.updatedAt,
                    likeCount = post.likeCount,
                    preview = if (post.thumbnail.isNullOrBlank()) previewOf(post.content) else null,
                )
            }
        }
    }

    @Schema(name = "PostAdminListItem", description = "관리자 후기 목록 항목")
    data class AdminListItem(
        val id: UUID,
        val member: MemberResponse.MemberInfo,
        val festivalId: Long,
        val festivalTitle: String,
        val title: String,
        val thumbnail: String?,
        val date: LocalDateTime?,
        val deletedAt: LocalDateTime?,
    ) {
        companion object {
            fun from(post: Post, imageUrlResolver: ImageUrlResolver): AdminListItem {
                val festival = festivalOf(post)
                return AdminListItem(
                    id = savedId(post),
                    member = MemberResponse.MemberInfo.from(post.member, imageUrlResolver),
                    festivalId = festival.requiredId,
                    festivalTitle = titleOf(festival),
                    title = post.title,
                    thumbnail = imageUrlResolver.resolve(post.thumbnail),
                    date = post.updatedAt,
                    deletedAt = post.deletedAt,
                )
            }
        }
    }

    @Schema(name = "PostDetail", description = "후기 상세")
    data class Detail(
        val id: UUID,
        val member: MemberResponse.MemberInfo,
        val festivalId: Long,
        val festivalTitle: String,
        val title: String,
        val content: String,
        val thumbnail: String?,
        val date: LocalDateTime?,
        val likeCount: Long,
        val likedByMe: Boolean,
    ) {
        companion object {
            fun from(post: Post, likedByMe: Boolean, imageUrlResolver: ImageUrlResolver): Detail {
                val festival = festivalOf(post)
                return Detail(
                    id = savedId(post),
                    member = MemberResponse.MemberInfo.from(post.member, imageUrlResolver),
                    festivalId = festival.requiredId,
                    festivalTitle = titleOf(festival),
                    title = post.title,
                    content = post.content,
                    thumbnail = imageUrlResolver.resolve(post.thumbnail),
                    date = post.updatedAt,
                    likeCount = post.likeCount,
                    likedByMe = likedByMe,
                )
            }
        }
    }

    private companion object {
        val plainTextPolicy = HtmlPolicyBuilder().toFactory()
        val blockBoundary = Regex("<(?:br\\s*/?|/(?:p|h[1-6]|li|blockquote|div))\\s*>", RegexOption.IGNORE_CASE)
        val whitespace = Regex("[\\s\\u00a0]+")

        fun previewOf(content: String): String = HtmlUtils.htmlUnescape(
            plainTextPolicy.sanitize(content.replace(blockBoundary, " ")),
        ).replace(whitespace, " ").trim().take(240)

        fun savedId(post: Post): UUID =
            requireNotNull(post.id) { "저장되지 않은 후기는 응답으로 만들 수 없습니다." }

        fun titleOf(festival: Festival): String =
            requireNotNull(festival.title) { "제목 없는 행사는 후기 응답으로 만들 수 없습니다: ${festival.id}" }

        /** 응답에는 행사가 꼭 있어야 한다. 행사 없는 후기는 API로 만들 수 없다. */
        fun festivalOf(post: Post): Festival =
            requireNotNull(post.festival) { "행사 없는 후기는 응답으로 만들 수 없습니다." }
    }
}
