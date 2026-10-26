package com.team007.room_escape.domain.member.infra.repository

import com.team007.room_escape.domain.member.infra.entity.Member
import com.team007.room_escape.domain.member.infra.entity.MemberRole
import org.springframework.data.domain.Page
import org.springframework.data.domain.Pageable
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Modifying
import org.springframework.data.jpa.repository.Query
import org.springframework.data.repository.query.Param
import java.time.LocalDateTime
import java.util.UUID

interface MemberRepository : JpaRepository<Member, UUID> {

    /** 자동 등급만 갱신한다. 먼저 조회한 객체가 아니라 DB의 현재 탈퇴·제재 상태로 판단한다. */
    @Modifying(flushAutomatically = true)
    @Query(
        """
        UPDATE Member m
        SET m.role = :grade, m.updatedAt = :updatedAt
        WHERE m.id = :memberId
          AND m.deletedAt IS NULL
          AND m.role <> :grade
          AND m.role IN (
            com.team007.room_escape.domain.member.infra.entity.MemberRole.ROLE_UNVERIFIED,
            com.team007.room_escape.domain.member.infra.entity.MemberRole.ROLE_RECOGNIZED,
            com.team007.room_escape.domain.member.infra.entity.MemberRole.ROLE_TRUSTED
          )
        """,
    )
    fun updateTrustGrade(
        @Param("memberId") memberId: UUID,
        @Param("grade") grade: MemberRole,
        @Param("updatedAt") updatedAt: LocalDateTime,
    ): Int

    /** 탈퇴하지 않은 회원 조회. Member엔 @SQLRestriction이 없어서 findById 대신 이걸 쓴다. */
    fun findByIdAndDeletedAtIsNull(id: UUID): Member?

    fun existsByIdAndDeletedAtIsNull(id: UUID): Boolean

    fun findByEmailAndDeletedAtIsNull(email: String?): Member?

    /** 탈퇴 회원 포함 이메일 중복 확인. 탈퇴 직후 재가입은 DB 인덱스가 아니라 여기서만 막는다. */
    fun existsByEmail(email: String?): Boolean

    fun existsByEmailAndDeletedAtIsNull(email: String?): Boolean

    fun existsByNicknameAndDeletedAtIsNull(nickname: String?): Boolean

    /** 보관 기간이 지난 탈퇴 회원의 개인정보를 비운다. 글이 참조하므로 행은 남긴다. */
    @Modifying(clearAutomatically = true)
    @Query(
        """
        UPDATE Member m
        SET m.email = CONCAT('purged-', m.id, '@removed.local'),
            m.nickname = '탈퇴한 사용자',
            m.phone = null,
            m.profileImg = null
        WHERE m.deletedAt IS NOT NULL
          AND m.deletedAt < :threshold
          AND m.email NOT LIKE 'purged-%'
        """,
    )
    fun purgeWithdrawnBefore(@Param("threshold") threshold: LocalDateTime): Int

    /** 관리자 회원 검색. keyword는 null 대신 빈 문자열을 받는다. */
    @Query(
        value = """
        SELECT m
        FROM Member m
        WHERE (:includeDeleted = true OR m.deletedAt IS NULL)
          AND (LOWER(m.nickname) LIKE CONCAT('%', :keyword, '%')
               OR LOWER(m.email) LIKE CONCAT('%', :keyword, '%'))
          AND (:role IS NULL OR m.role = :role)
        """,
        countQuery = """
        SELECT COUNT(m)
        FROM Member m
        WHERE (:includeDeleted = true OR m.deletedAt IS NULL)
          AND (LOWER(m.nickname) LIKE CONCAT('%', :keyword, '%')
               OR LOWER(m.email) LIKE CONCAT('%', :keyword, '%'))
          AND (:role IS NULL OR m.role = :role)
        """,
    )
    fun search(
        @Param("keyword") keyword: String,
        @Param("role") role: MemberRole?,
        @Param("includeDeleted") includeDeleted: Boolean,
        pageable: Pageable,
    ): Page<Member>
}
