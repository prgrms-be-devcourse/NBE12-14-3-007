package com.team007.room_escape.domain.like.service

import com.team007.room_escape.domain.festival.dto.FestivalResponse
import com.team007.room_escape.domain.festival.service.FestivalService
import com.team007.room_escape.domain.like.infra.repository.LikeRepository
import com.team007.room_escape.domain.member.service.MemberReader
import com.team007.room_escape.domain.post.dto.PostResponse
import com.team007.room_escape.global.storage.ImageUrlResolver
import org.springframework.data.domain.Page
import org.springframework.data.domain.PageRequest
import org.springframework.data.domain.Pageable
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.util.UUID

/** 마이페이지의 "내가 좋아요한 행사·후기". 항목은 공개 목록과 같은 모양이다. */
@Service
@Transactional(readOnly = true)
class MyLikeService(
    private val likeRepository: LikeRepository,
    private val festivalService: FestivalService,
    private val members: MemberReader,
    private val imageUrlResolver: ImageUrlResolver,
) {

    fun findLikedFestivals(memberId: UUID, pageable: Pageable): Page<FestivalResponse.ListItem> {
        members.getActiveMember(memberId)
        return festivalService.toListItems(likeRepository.findLikedFestivals(memberId, withoutSort(pageable)))
    }

    fun findLikedPosts(memberId: UUID, pageable: Pageable): Page<PostResponse.ListItem> {
        members.getActiveMember(memberId)
        return likeRepository.findLikedPosts(memberId, withoutSort(pageable))
            .map { PostResponse.ListItem.from(it, imageUrlResolver) }
    }

    /** 순서는 좋아요를 누른 시각으로 고정한다. 클라이언트가 보낸 정렬은 버린다. */
    private fun withoutSort(pageable: Pageable): Pageable = PageRequest.of(pageable.pageNumber, pageable.pageSize)
}
