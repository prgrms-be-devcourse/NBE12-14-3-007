package com.team007.room_escape.domain.member.infra.entity

import com.team007.room_escape.global.entity.SoftDeletableEntity
import com.team007.room_escape.global.util.StringUtil.emptyToNull
import com.team007.room_escape.global.util.isBlankLikeJava
import jakarta.persistence.Column
import jakarta.persistence.Entity
import jakarta.persistence.EnumType
import jakarta.persistence.Enumerated
import jakarta.persistence.Id
import jakarta.persistence.Table
import org.hibernate.annotations.DynamicUpdate
import org.hibernate.annotations.UuidGenerator
import java.util.UUID

// 탈퇴 회원의 글·댓글 조회가 깨지지 않게 @SQLRestriction을 걸지 않는다. 활동 회원은 deletedAtIsNull 메서드로 거른다.
// 프로필·탈퇴 등 다른 변경이 DB의 최신 등급까지 덮어쓰지 않도록 @DynamicUpdate로 변경한 컬럼만 저장한다.
@Entity
@DynamicUpdate
@Table(name = "member")
class Member(
    email: String,
    password: String,
    role: MemberRole,
    nickname: String,
    profileImg: String? = null,
    phone: String? = null,
    id: UUID? = null,
) : SoftDeletableEntity() {

    /** 저장할 때 만들어진다. 저장 전에는 읽을 수 없다. */
    @Id
    @UuidGenerator(style = UuidGenerator.Style.VERSION_7)
    lateinit var id: UUID
        protected set

    @Column(nullable = false)
    var email: String = email
        protected set

    @Column(nullable = false)
    var password: String = password
        protected set

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 32)
    var role: MemberRole = role
        protected set

    @Column(nullable = false)
    var nickname: String = nickname
        protected set

    @Column(name = "profile_img", length = 2048)
    var profileImg: String? = profileImg
        protected set

    var phone: String? = phone
        protected set

    init {
        if (id != null) this.id = id
    }

    fun authority(): String = role.name

    fun hasPrivilegeOf(required: MemberRole): Boolean = role.includes(required)

    /** ROLE_WARNING(제재) 등급인지. 정보 수정 등 일부 기능을 막는 데 쓴다. */
    val isRestricted: Boolean get() = role == MemberRole.ROLE_WARNING

    /** 마이페이지 수정. null은 건드리지 않고 빈 문자열이면 지운다. nickname은 지울 수 없다. */
    fun updateProfile(nickname: String?, phone: String?, profileImg: String?) {
        nickname?.takeUnless { it.isBlankLikeJava() }?.let { this.nickname = it }
        phone?.let { this.phone = emptyToNull(it) }
        profileImg?.let { this.profileImg = emptyToNull(it) }
    }

    /** @param encodedPassword 반드시 인코딩된 값이어야 한다. 평문을 넣으면 로그인이 깨진다. */
    fun changePassword(encodedPassword: String) {
        password = encodedPassword
    }

    /** 관리자가 직접 권한을 바꿀 때만 사용한다. */
    // TODO 변경 사유를 이력 테이블에 남길 것 (행사·후기 숨김 사유와 함께 설계)
    fun changeRole(role: MemberRole) {
        this.role = role
    }

    companion object {

        /** 탈퇴 회원 대신 보여줄 이름. 파기 배치와 응답 DTO가 같은 값을 쓰도록 여기 둔다. */
        const val WITHDRAWN_NICKNAME = "탈퇴한 사용자"
    }
}
