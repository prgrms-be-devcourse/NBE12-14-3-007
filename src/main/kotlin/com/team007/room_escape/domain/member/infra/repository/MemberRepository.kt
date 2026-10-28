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

    /** 탈퇴하지 않은 회원 조회. Member엔 @SQLRestriction이 없어서 findById 대신 이걸 쓴다. */
    fun findByIdAndDeletedAtIsNull(id: UUID): Member?

    fun existsByIdAndDeletedAtIsNull(id: UUID): Boolean

    fun findByEmailAndDeletedAtIsNull(email: String?): Member?

    /** 탈퇴 회원 포함 이메일 중복 확인. 탈퇴 직후 재가입은 DB 인덱스가 아니라 여기서만 막는다. */
    fun existsByEmail(email: String?): Boolean

    fun existsByEmailAndDeletedAtIsNull(email: String?): Boolean

    fun existsByNicknameAndDeletedAtIsNull(nickname: String?): Boolean

    /**
     * 파기하면 사라질 프로필 이미지. 파기 쿼리가 key를 지우기 전에 읽어 R2 파일을 같이 지운다.
     * 조건은 아래 [purgeWithdrawnBefore]와 같아야 한다.
     */
    @Query(
        """
        SELECT new com.team007.room_escape.domain.member.infra.repository.PurgedProfileImage(m.id, m.profileImg)
        FROM Member m
        WHERE m.deletedAt IS NOT NULL
          AND m.deletedAt < :threshold
          AND m.email NOT LIKE 'purged-%'
          AND m.profileImg IS NOT NULL
        """,
    )
    fun findProfileImagesToPurge(@Param("threshold") threshold: LocalDateTime): List<PurgedProfileImage>

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

/** 개인정보 파기로 지워질 회원의 프로필 이미지 key. */
data class PurgedProfileImage(val memberId: UUID, val key: String)
