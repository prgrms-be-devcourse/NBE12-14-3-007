package com.team007.room_escape.domain.member.dto

import com.team007.room_escape.domain.member.infra.entity.Member
import com.team007.room_escape.domain.member.infra.entity.MemberRole
import com.team007.room_escape.global.storage.ImageUrlResolver
import io.swagger.v3.oas.annotations.media.Schema
import java.time.LocalDateTime
import java.util.UUID

class MemberResponse private constructor() {

    /** 마이페이지 응답. 본인만 보므로 개인정보를 포함한다. password는 절대 내려보내지 않는다. */
    data class MyPageInfo(
        val id: UUID,
        val email: String,
        val nickname: String,
        val profileImg: String?,
        val phone: String?,
        val role: MemberRole,
        val createdAt: LocalDateTime?,
        val updatedAt: LocalDateTime?,
    ) {

        companion object {

            fun from(member: Member, profileImgUrl: String?) = MyPageInfo(
                id = member.id,
                email = member.email,
                nickname = member.nickname,
                profileImg = profileImgUrl,
                phone = member.phone,
                role = member.role,
                createdAt = member.createdAt,
                updatedAt = member.updatedAt,
            )
        }
    }

    /** 관리자 화면 회원 정보. 목록·단건·등급 변경에서 함께 쓴다. */
    data class AdminInfo(
        val id: UUID,
        val email: String,
        val nickname: String,
        /** R2 key를 변환한 공개 URL. 이미지가 없으면 null */
        val profileImg: String?,
        val phone: String?,
        val role: MemberRole,
        /** 관리자가 직접 바꿔 고정한 등급인지. 고정이면 자정 집계가 등급을 바꾸지 않는다 */
        val roleLocked: Boolean,
        val createdAt: LocalDateTime?,
        val updatedAt: LocalDateTime?,
        /** 탈퇴 시각. 탈퇴하지 않았으면 null */
        val deletedAt: LocalDateTime?,
    ) {

        companion object {

            fun from(member: Member, profileImgUrl: String?) = AdminInfo(
                id = member.id,
                email = member.email,
                nickname = member.nickname,
                profileImg = profileImgUrl,
                phone = member.phone,
                role = member.role,
                roleLocked = member.roleLocked,
                createdAt = member.createdAt,
                updatedAt = member.updatedAt,
                deletedAt = member.deletedAt,
            )
        }
    }

    /** 관리자 등급 변경 이력 한 건. */
    @Schema(name = "MemberRoleHistoryItem", description = "관리자 등급 변경 이력")
    data class RoleHistoryItem(
        val oldRole: MemberRole,
        val newRole: MemberRole,
        /** 변경 사유. 제재가 아닌 변경은 비어 있을 수 있다 */
        val reason: String?,
        /** 바꾼 관리자의 닉네임. 알 수 없으면 null */
        val actorNickname: String?,
        val changedAt: LocalDateTime,
    )

    /** 다른 도메인 응답에 붙는 작성자 정보. 탈퇴 회원은 닉네임만 "탈퇴한 사용자"로 내려준다. */
    @Schema(name = "MemberInfo", description = "작성자 정보")
    data class MemberInfo(
        val id: UUID? = null,
        val nickname: String,
        val role: MemberRole? = null,
        val profileImg: String? = null,
    ) {

        companion object {

            /** Member엔 @SQLRestriction이 없어서 탈퇴 회원도 로딩되므로 여기서 가린다. */
            fun from(member: Member?, imageUrlResolver: ImageUrlResolver): MemberInfo {
                if (member == null || member.isDeleted()) {
                    return MemberInfo(nickname = Member.WITHDRAWN_NICKNAME)
                }
                return MemberInfo(
                    id = member.id,
                    nickname = member.nickname,
                    role = member.role,
                    profileImg = imageUrlResolver.resolve(member.profileImg),
                )
            }
        }
    }
}
