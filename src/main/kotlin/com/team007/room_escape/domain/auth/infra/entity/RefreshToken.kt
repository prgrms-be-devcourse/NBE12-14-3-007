package com.team007.room_escape.domain.auth.infra.entity

import com.team007.room_escape.domain.member.infra.entity.Member
import jakarta.persistence.Column
import jakarta.persistence.Entity
import jakarta.persistence.EntityListeners
import jakarta.persistence.FetchType
import jakarta.persistence.GeneratedValue
import jakarta.persistence.GenerationType
import jakarta.persistence.Id
import jakarta.persistence.JoinColumn
import jakarta.persistence.ManyToOne
import jakarta.persistence.Table
import org.springframework.data.annotation.CreatedDate
import org.springframework.data.jpa.domain.support.AuditingEntityListener
import java.time.LocalDateTime

/** 회원당 하나만 두는 리프레시 토큰. 원문이 아니라 해시만 저장한다. */
@Entity
@Table(name = "refresh_token")
@EntityListeners(AuditingEntityListener::class)
class RefreshToken(
    member: Member,
    tokenHash: String,
    expiresAt: LocalDateTime,
) {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    var id: Long? = null
        protected set

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "member_id", nullable = false)
    var member: Member = member
        protected set

    @Column(name = "token_hash", nullable = false)
    var tokenHash: String = tokenHash
        protected set

    @Column(name = "expires_at", nullable = false)
    var expiresAt: LocalDateTime = expiresAt
        protected set

    @CreatedDate
    @Column(name = "created_at", nullable = false, updatable = false)
    var createdAt: LocalDateTime? = null
        protected set

    val isExpired: Boolean get() = expiresAt.isBefore(LocalDateTime.now())

    fun matches(tokenHash: String): Boolean = this.tokenHash == tokenHash

    fun rotate(tokenHash: String, expiresAt: LocalDateTime) {
        this.tokenHash = tokenHash
        this.expiresAt = expiresAt
    }
}
