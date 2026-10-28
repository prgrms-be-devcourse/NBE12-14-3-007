package com.team007.room_escape.domain.member.infra.entity

import jakarta.persistence.Column
import jakarta.persistence.Entity
import jakarta.persistence.EnumType
import jakarta.persistence.Enumerated
import jakarta.persistence.GeneratedValue
import jakarta.persistence.GenerationType
import jakarta.persistence.Id
import jakarta.persistence.Table
import java.time.LocalDateTime
import java.util.UUID

/** 관리자가 회원 등급을 바꾼 기록. 한 번 남기면 고치지 않는다. */
@Entity
@Table(name = "member_role_history")
class MemberRoleHistory(
    @Column(name = "member_id", nullable = false)
    val memberId: UUID,

    @Column(name = "actor_id", nullable = false)
    val actorId: UUID,

    @Enumerated(EnumType.STRING)
    @Column(name = "old_role", nullable = false, length = 32)
    val oldRole: MemberRole,

    @Enumerated(EnumType.STRING)
    @Column(name = "new_role", nullable = false, length = 32)
    val newRole: MemberRole,

    @Column(length = 500)
    val reason: String?,
) {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    var id: Long? = null
        protected set

    @Column(name = "created_at", nullable = false)
    val createdAt: LocalDateTime = LocalDateTime.now()
}
