package com.team007.room_escape.domain.member.service

import com.team007.room_escape.domain.member.dto.AdminMemberRequest
import com.team007.room_escape.domain.member.dto.MemberResponse
import com.team007.room_escape.domain.member.infra.entity.Member
import com.team007.room_escape.domain.member.infra.entity.MemberRole
import com.team007.room_escape.domain.member.infra.repository.MemberRepository
import com.team007.room_escape.global.exception.BusinessException
import com.team007.room_escape.global.response.code.MemberExceptionCode
import com.team007.room_escape.global.storage.ImageUrlResolver
import org.springframework.data.domain.Page
import org.springframework.data.domain.Pageable
import org.springframework.data.repository.findByIdOrNull
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.util.UUID

@Service
class AdminMemberService(
    private val memberRepository: MemberRepository,
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

        // TODO 변경 사유를 함께 받아 이력 테이블에 남길 것. Member.changeRole()의 TODO 참고.
        target.changeRole(role)

        return toAdminInfo(target)
    }

    private fun findOrThrow(memberId: UUID): Member =
        memberRepository.findByIdOrNull(memberId) ?: throw BusinessException(MemberExceptionCode.MEMBER_NOT_FOUND)

    /** 프로필 이미지 key를 공개 URL로 바꿔 내려준다. */
    private fun toAdminInfo(member: Member) =
        MemberResponse.AdminInfo.from(member, imageUrlResolver.resolve(member.profileImg))
}
