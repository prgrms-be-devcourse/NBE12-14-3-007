package com.team007.room_escape.domain.member.service

import com.team007.room_escape.domain.member.dto.AdminMemberRequest
import com.team007.room_escape.domain.member.dto.MemberResponse
import com.team007.room_escape.domain.member.infra.entity.Member
import com.team007.room_escape.domain.member.infra.entity.MemberRole
import com.team007.room_escape.domain.member.infra.entity.MemberRoleHistory
import com.team007.room_escape.domain.member.infra.repository.MemberRepository
import com.team007.room_escape.domain.member.infra.repository.MemberRoleHistoryRepository
import com.team007.room_escape.global.exception.BusinessException
import com.team007.room_escape.global.response.code.MemberExceptionCode
import com.team007.room_escape.global.storage.ImageUrlResolver
import com.team007.room_escape.global.util.StringUtil.emptyToNull
import com.team007.room_escape.global.util.trimLikeJava
import org.springframework.data.domain.Page
import org.springframework.data.domain.Pageable
import org.springframework.data.repository.findByIdOrNull
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.util.UUID

@Service
class AdminMemberService(
    private val memberRepository: MemberRepository,
    private val roleHistories: MemberRoleHistoryRepository,
    private val imageUrlResolver: ImageUrlResolver,
) {

    /** 관리자 회원 검색. 조건을 비우면 전체를 조회한다. */
    @Transactional(readOnly = true)
    fun search(request: AdminMemberRequest.Search, pageable: Pageable): Page<MemberResponse.AdminInfo> =
        memberRepository.search(
            request.keywordOrEmpty(),
            request.role,
            request.includeDeletedOrFalse(),
            pageable,
        ).map { toAdminInfo(it) }

    /** 관리자 회원 단건 조회. 탈퇴 회원도 찾는다. */
    @Transactional(readOnly = true)
    fun get(memberId: UUID): MemberResponse.AdminInfo = toAdminInfo(findOrThrow(memberId))

    /** 회원 등급 변경. API를 직접 호출할 수 있으니 아래 네 가지는 서버에서 막는다. */
    @Transactional
    fun changeRole(actorId: UUID, targetId: UUID, request: AdminMemberRequest.ChangeRole): MemberResponse.AdminInfo {
        // 1. 자기 등급을 내리면 복구할 권한까지 잃는다.
        if (actorId == targetId) throw BusinessException(MemberExceptionCode.MEMBER_ROLE_SELF_CHANGE_DENIED)

        // 2. 관리자 부여는 권한 상승 경로라 막는다.
        //  TODO : 나중에 최고관리자 역할을 또 만들어서 관리자 만들수 있게 할수도있음
        val role = requireNotNull(request.role) { "검증을 통과한 요청에는 등급이 있다." }
        if (role == MemberRole.ROLE_ADMIN) throw BusinessException(MemberExceptionCode.MEMBER_ROLE_ADMIN_GRANT_DENIED)

        val target = findOrThrow(targetId)

        // 3. 관리자끼리 등급 박탈 금지. 관리자 해제는 DB에서 직접 한다.
        if (target.role == MemberRole.ROLE_ADMIN) throw BusinessException(MemberExceptionCode.MEMBER_ROLE_ADMIN_PROTECTED)

        // 4. 탈퇴 회원은 등급을 바꿔도 의미가 없다.
        if (target.isDeleted()) throw BusinessException(MemberExceptionCode.MEMBER_ALREADY_DELETED)

        // 5. 제재는 회원에게 불이익이 크니 이유를 남긴다. 나머지 변경은 사유가 선택이다.
        val reason = request.reason?.trimLikeJava()?.let(::emptyToNull)
        if (role == MemberRole.ROLE_WARNING && reason == null) {
            throw BusinessException(MemberExceptionCode.MEMBER_ROLE_REASON_REQUIRED)
        }

        val previousRole = target.role
        // 바꾼 등급은 고정돼서 자정 집계가 덮어쓰지 않는다. 이력은 같은 트랜잭션에서 남긴다.
        target.changeRole(role)
        roleHistories.save(MemberRoleHistory(targetId, actorId, previousRole, role, reason))

        return toAdminInfo(target)
    }

    /** 회원의 등급 변경 이력. 최근 것부터 돌려준다. */
    @Transactional(readOnly = true)
    fun roleHistory(memberId: UUID, pageable: Pageable): Page<MemberResponse.RoleHistoryItem> {
        findOrThrow(memberId)
        val page = roleHistories.findByMemberId(memberId, pageable)
        val actorNicknames = memberRepository.findAllById(page.content.map { it.actorId }.toSet())
            .associate { it.id to it.nickname }
        return page.map {
            MemberResponse.RoleHistoryItem(it.oldRole, it.newRole, it.reason, actorNicknames[it.actorId], it.createdAt)
        }
    }

    private fun findOrThrow(memberId: UUID): Member =
        memberRepository.findByIdOrNull(memberId) ?: throw BusinessException(MemberExceptionCode.MEMBER_NOT_FOUND)

    /** 프로필 이미지 key를 공개 URL로 바꿔 내려준다. */
    private fun toAdminInfo(member: Member) =
        MemberResponse.AdminInfo.from(member, imageUrlResolver.resolve(member.profileImg))
}
