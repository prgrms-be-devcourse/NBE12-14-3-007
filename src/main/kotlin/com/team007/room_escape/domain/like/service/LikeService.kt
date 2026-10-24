package com.team007.room_escape.domain.like.service

import com.team007.room_escape.domain.festival.infra.repository.FestivalRepository
import com.team007.room_escape.domain.like.dto.LikeResponse
import com.team007.room_escape.domain.like.infra.entity.Like
import com.team007.room_escape.domain.like.infra.repository.LikeRepository
import com.team007.room_escape.domain.member.service.MemberReader
import com.team007.room_escape.domain.member.service.MemberTrustGradeService
import com.team007.room_escape.domain.post.infra.repository.PostRepository
import com.team007.room_escape.global.exception.BusinessException
import com.team007.room_escape.global.response.code.FestivalExceptionCode
import com.team007.room_escape.global.response.code.LikeExceptionCode
import com.team007.room_escape.global.response.code.PostExceptionCode
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.util.UUID

@Service
class LikeService(
    private val likeRepository: LikeRepository,
    private val postRepository: PostRepository,
    private val festivalRepository: FestivalRepository,
    private val memberReader: MemberReader,
    private val memberTrustGradeService: MemberTrustGradeService,
) {

    /** 후기 */
    @Transactional
    fun createPostLike(postId: UUID, memberId: UUID): LikeResponse {
        val member = memberReader.getUnrestrictedMember(memberId)
        val post = postRepository.findByIdAndDeletedAtIsNull(postId)
            .orElseThrow { BusinessException(PostExceptionCode.POST_NOT_FOUND) }

        if (likeRepository.existsByPostIdAndMemberId(postId, memberId)) {
            throw BusinessException(LikeExceptionCode.LIKE_ALREADY_EXISTS)
        }

        likeRepository.save(Like.of(post, member))
        postRepository.increaseLikeCount(postId)

        return LikeResponse(getPostLikeCount(postId))
    }

    @Transactional
    fun deletePostLike(postId: UUID, memberId: UUID): LikeResponse {
        if (!postRepository.existsById(postId)) {
            throw BusinessException(PostExceptionCode.POST_NOT_FOUND)
        }

        val like = likeRepository.findByPostIdAndMemberId(postId, memberId)
            ?: throw BusinessException(LikeExceptionCode.LIKE_NOT_FOUND)

        likeRepository.delete(like)
        postRepository.decreaseLikeCount(postId)

        return LikeResponse(getPostLikeCount(postId))
    }

    /** 좋아요를 누르거나 취소한 뒤 바뀐 개수를 돌려주려고 다시 읽는다 */
    private fun getPostLikeCount(postId: UUID): Long =
        postRepository.findLikeCountById(postId)
            .orElseThrow { BusinessException(PostExceptionCode.POST_NOT_FOUND) }

    /** 행사 */
    @Transactional
    fun createFestivalLike(festivalId: Long, memberId: UUID): LikeResponse {
        val member = memberReader.getUnrestrictedMember(memberId)
        val festival = festivalRepository.findByIdAndDeletedAtIsNull(festivalId)
            .orElseThrow { BusinessException(FestivalExceptionCode.FESTIVAL_NOT_FOUND) }

        if (festival.member?.id == memberId) {
            throw BusinessException(LikeExceptionCode.SELF_FESTIVAL_LIKE_NOT_ALLOWED)
        }

        if (likeRepository.existsByFestivalIdAndMemberId(festivalId, memberId)) {
            throw BusinessException(LikeExceptionCode.LIKE_ALREADY_EXISTS)
        }

        likeRepository.save(Like.of(festival, member))
        likeRepository.flush()
        memberTrustGradeService.refreshForFestival(festival)

        return LikeResponse(likeRepository.countByFestivalId(festivalId))
    }

    @Transactional(readOnly = true)
    fun getFestivalLikeCount(festivalId: Long): Long {
        if (!festivalRepository.existsByIdAndDeletedAtIsNull(festivalId)) {
            throw BusinessException(FestivalExceptionCode.FESTIVAL_NOT_FOUND)
        }

        return likeRepository.countByFestivalId(festivalId)
    }

    @Transactional
    fun deleteFestivalLike(festivalId: Long, memberId: UUID): LikeResponse {
        if (!festivalRepository.existsById(festivalId)) {
            throw BusinessException(FestivalExceptionCode.FESTIVAL_NOT_FOUND)
        }

        val like = likeRepository.findByFestivalIdAndMemberId(festivalId, memberId)
            ?: throw BusinessException(LikeExceptionCode.LIKE_NOT_FOUND)

        val festival = like.festival
        likeRepository.delete(like)
        likeRepository.flush()
        memberTrustGradeService.refreshForFestival(festival)

        return LikeResponse(likeRepository.countByFestivalId(festivalId))
    }
}
