package com.team007.room_escape.domain.festival.infra.repository

import com.team007.room_escape.domain.festival.infra.entity.Festival
import com.team007.room_escape.domain.festival.infra.entity.FestivalRegion
import com.team007.room_escape.domain.festival.infra.entity.FestivalStatus
import com.team007.room_escape.domain.festival.infra.entity.ProviderType
import jakarta.persistence.LockModeType
import org.springframework.data.domain.Page
import org.springframework.data.domain.Pageable
import org.springframework.data.jpa.repository.EntityGraph
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Lock
import org.springframework.data.jpa.repository.Modifying
import org.springframework.data.jpa.repository.Query
import org.springframework.data.repository.query.Param
import java.time.LocalDateTime

interface FestivalRepository : JpaRepository<Festival, Long> {

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("select f from Festival f where f.id = :id")
    fun findForDeletion(@Param("id") id: Long): Festival?

    // PostgreSQL 트랜잭션 종료 시 자동 해제. 같은 중복 조건의 등록/수정을 직렬화한다.
    @Query(value = "SELECT count(*) FROM pg_advisory_xact_lock(:key)", nativeQuery = true)
    fun lockSubmissionDuplicateKey(@Param("key") key: Long): Long

    @Query(value = """
        SELECT f.id FROM festival f
        WHERE f.deleted_at IS NULL
          AND (CAST(:currentId AS bigint) IS NULL OR f.id <> :currentId)
          AND f.begin_de >= :beginStart AND f.begin_de < :beginEnd
          AND f.end_de >= :endStart AND f.end_de < :endEnd
          AND f.region = :region AND btrim(f.title) = :title
          AND COALESCE(f.district, f.region_detail, '') = :district
        ORDER BY f.id LIMIT 1
    """, nativeQuery = true)
    fun findSubmissionDuplicateId(
        @Param("currentId") currentId: Long?,
        @Param("beginStart") beginStart: LocalDateTime,
        @Param("beginEnd") beginEnd: LocalDateTime,
        @Param("endStart") endStart: LocalDateTime,
        @Param("endEnd") endEnd: LocalDateTime,
        @Param("region") region: String,
        @Param("title") title: String,
        @Param("district") district: String,
    ): Long?

    /** 저장 건수 조회 */
    fun countByProviderType(providerType: ProviderType): Long

    /** 연도 범위(yearStart 이상 ~ yearEnd 미만)에 해당하는 저장 건수 조회 */
    fun countByProviderTypeAndBeginDeGreaterThanEqualAndBeginDeLessThan(
        providerType: ProviderType,
        yearStart: LocalDateTime,
        yearEnd: LocalDateTime,
    ): Long

    /** 전달한 external_id 중 이미 저장된 것만 돌려준다. 신규 판별(차집합)에 쓴다. */
    @Query("SELECT f.externalId FROM Festival f WHERE f.providerType = :providerType AND f.externalId IN :externalIds")
    fun findExistingExternalIds(
        @Param("providerType") providerType: ProviderType,
        @Param("externalIds") externalIds: Collection<String>,
    ): List<String>

    // TODO: PostgreSQL의 null 파라미터 타입 오류로 사용 중인 hasXxx 플래그를 QueryDSL 도입 시 제거
    /** 목록 카드에 제보자 닉네임·등급을 보여줘서 회원을 함께 불러온다. */
    @EntityGraph(attributePaths = ["member"])
    @Query("""
		SELECT f
		FROM Festival f
		WHERE f.deletedAt IS NULL
		  AND (:hasKeyword = false
				OR LOWER(COALESCE(f.title, ''))
					LIKE CONCAT('%', :keyword, '%')
				OR LOWER(COALESCE(f.regionDetail, ''))
					LIKE CONCAT('%', :keyword, '%'))
		  AND (:hasRegion = false OR f.region = :region)
		  AND (:hasRegionDetail = false OR LOWER(COALESCE(f.district, f.regionDetail, '')) = :regionDetail)
		  AND (:hasProviderType = false OR f.providerType = :providerType)
		  AND (:hasCategory = false
               OR LOWER(COALESCE(f.category, '')) = :category
               OR (:category = '행사/축제' AND LOWER(COALESCE(f.category, '')) = '축제')
               OR (:category = '교육/체험' AND LOWER(COALESCE(f.category, '')) IN ('교육', '체험')))
		  AND (:hasDate = false OR (f.beginDe < :dateEnd AND (f.endDe IS NULL OR f.endDe >= :dateStart)))
		  AND (:excludeClosed = false OR f.endDe IS NULL OR f.endDe >= CURRENT_TIMESTAMP)
		""")
    fun searchFestivals(
        @Param("hasKeyword") hasKeyword: Boolean,
        @Param("keyword") keyword: String?,

        @Param("hasRegion") hasRegion: Boolean,
        @Param("region") region: FestivalRegion?,

        @Param("hasRegionDetail") hasRegionDetail: Boolean,
        @Param("regionDetail") regionDetail: String?,

        @Param("hasProviderType") hasProviderType: Boolean,
        @Param("providerType") providerType: ProviderType?,

        @Param("hasCategory") hasCategory: Boolean,
        @Param("category") category: String?,

        @Param("hasDate") hasDate: Boolean,
        @Param("dateStart") dateStart: LocalDateTime?,
        @Param("dateEnd") dateEnd: LocalDateTime?,
        @Param("excludeClosed") excludeClosed: Boolean,

        pageable: Pageable,
    ): Page<Festival>

    /** 기본 정렬 검색. 곧 시작하는 행사 먼저, 이미 시작한 행사는 최근 시작순으로 뒤에 둔다. */
    @EntityGraph(attributePaths = ["member"])
    @Query(
        value = """
		SELECT f
		FROM Festival f
		WHERE f.deletedAt IS NULL
		  AND (:hasKeyword = false
				OR LOWER(COALESCE(f.title, ''))
					LIKE CONCAT('%', :keyword, '%')
				OR LOWER(COALESCE(f.regionDetail, ''))
					LIKE CONCAT('%', :keyword, '%'))
		  AND (:hasRegion = false OR f.region = :region)
		  AND (:hasRegionDetail = false OR LOWER(COALESCE(f.district, f.regionDetail, '')) = :regionDetail)
		  AND (:hasProviderType = false OR f.providerType = :providerType)
		  AND (:hasCategory = false
               OR LOWER(COALESCE(f.category, '')) = :category
               OR (:category = '행사/축제' AND LOWER(COALESCE(f.category, '')) = '축제')
               OR (:category = '교육/체험' AND LOWER(COALESCE(f.category, '')) IN ('교육', '체험')))
		  AND (:hasDate = false OR (f.beginDe < :dateEnd AND (f.endDe IS NULL OR f.endDe >= :dateStart)))
		  AND (:excludeClosed = false OR f.endDe IS NULL OR f.endDe >= CURRENT_TIMESTAMP)
		ORDER BY
		  CASE
			WHEN f.beginDe IS NULL THEN 2
			WHEN f.beginDe >= :today THEN 0
			ELSE 1
		  END ASC,
		  CASE WHEN f.beginDe >= :today THEN f.beginDe END ASC,
		  f.beginDe DESC,
		  f.id DESC
		""",
        countQuery = """
		SELECT COUNT(f)
		FROM Festival f
		WHERE f.deletedAt IS NULL
		  AND (:hasKeyword = false
				OR LOWER(COALESCE(f.title, ''))
					LIKE CONCAT('%', :keyword, '%')
				OR LOWER(COALESCE(f.regionDetail, ''))
					LIKE CONCAT('%', :keyword, '%'))
		  AND (:hasRegion = false OR f.region = :region)
		  AND (:hasRegionDetail = false OR LOWER(COALESCE(f.district, f.regionDetail, '')) = :regionDetail)
		  AND (:hasProviderType = false OR f.providerType = :providerType)
		  AND (:hasCategory = false
               OR LOWER(COALESCE(f.category, '')) = :category
               OR (:category = '행사/축제' AND LOWER(COALESCE(f.category, '')) = '축제')
               OR (:category = '교육/체험' AND LOWER(COALESCE(f.category, '')) IN ('교육', '체험')))
		  AND (:hasDate = false OR (f.beginDe < :dateEnd AND (f.endDe IS NULL OR f.endDe >= :dateStart)))
		  AND (:excludeClosed = false OR f.endDe IS NULL OR f.endDe >= CURRENT_TIMESTAMP)
		""",
    )
    fun searchFestivalsOrderByNearestStart(
        @Param("hasKeyword") hasKeyword: Boolean,
        @Param("keyword") keyword: String?,

        @Param("hasRegion") hasRegion: Boolean,
        @Param("region") region: FestivalRegion?,

        @Param("hasRegionDetail") hasRegionDetail: Boolean,
        @Param("regionDetail") regionDetail: String?,

        @Param("hasProviderType") hasProviderType: Boolean,
        @Param("providerType") providerType: ProviderType?,

        @Param("hasCategory") hasCategory: Boolean,
        @Param("category") category: String?,

        @Param("hasDate") hasDate: Boolean,
        @Param("dateStart") dateStart: LocalDateTime?,
        @Param("dateEnd") dateEnd: LocalDateTime?,
        @Param("excludeClosed") excludeClosed: Boolean,

        @Param("today") today: LocalDateTime,

        pageable: Pageable,
    ): Page<Festival>

    /** 좋아요순 검색. 좋아요를 행사별로 먼저 집계한 뒤 붙인다. */
    @EntityGraph(attributePaths = ["member"])
    @Query(
        value = """
		SELECT f
		FROM Festival f
		LEFT JOIN (
			SELECT l.festival.id AS festivalId, COUNT(l) AS likeCount
			FROM Like l
			WHERE l.festival IS NOT NULL
			GROUP BY l.festival.id
		) lc ON lc.festivalId = f.id
		WHERE f.deletedAt IS NULL
		  AND (:hasKeyword = false
				OR LOWER(COALESCE(f.title, ''))
					LIKE CONCAT('%', :keyword, '%')
				OR LOWER(COALESCE(f.regionDetail, ''))
					LIKE CONCAT('%', :keyword, '%'))
		  AND (:hasRegion = false OR f.region = :region)
		  AND (:hasRegionDetail = false OR LOWER(COALESCE(f.district, f.regionDetail, '')) = :regionDetail)
		  AND (:hasProviderType = false OR f.providerType = :providerType)
		  AND (:hasCategory = false
               OR LOWER(COALESCE(f.category, '')) = :category
               OR (:category = '행사/축제' AND LOWER(COALESCE(f.category, '')) = '축제')
               OR (:category = '교육/체험' AND LOWER(COALESCE(f.category, '')) IN ('교육', '체험')))
		  AND (:hasDate = false OR (f.beginDe < :dateEnd AND (f.endDe IS NULL OR f.endDe >= :dateStart)))
		  AND (:excludeClosed = false OR f.endDe IS NULL OR f.endDe >= CURRENT_TIMESTAMP)
		ORDER BY COALESCE(lc.likeCount, 0) DESC, f.beginDe ASC, f.id DESC
		""",
        countQuery = """
		SELECT COUNT(f)
		FROM Festival f
		WHERE f.deletedAt IS NULL
		  AND (:hasKeyword = false
				OR LOWER(COALESCE(f.title, ''))
					LIKE CONCAT('%', :keyword, '%')
				OR LOWER(COALESCE(f.regionDetail, ''))
					LIKE CONCAT('%', :keyword, '%'))
		  AND (:hasRegion = false OR f.region = :region)
		  AND (:hasRegionDetail = false OR LOWER(COALESCE(f.district, f.regionDetail, '')) = :regionDetail)
		  AND (:hasProviderType = false OR f.providerType = :providerType)
		  AND (:hasCategory = false
               OR LOWER(COALESCE(f.category, '')) = :category
               OR (:category = '행사/축제' AND LOWER(COALESCE(f.category, '')) = '축제')
               OR (:category = '교육/체험' AND LOWER(COALESCE(f.category, '')) IN ('교육', '체험')))
		  AND (:hasDate = false OR (f.beginDe < :dateEnd AND (f.endDe IS NULL OR f.endDe >= :dateStart)))
		  AND (:excludeClosed = false OR f.endDe IS NULL OR f.endDe >= CURRENT_TIMESTAMP)
		""",
    )
    fun searchFestivalsOrderByLikeCount(
        @Param("hasKeyword") hasKeyword: Boolean,
        @Param("keyword") keyword: String?,

        @Param("hasRegion") hasRegion: Boolean,
        @Param("region") region: FestivalRegion?,

        @Param("hasRegionDetail") hasRegionDetail: Boolean,
        @Param("regionDetail") regionDetail: String?,

        @Param("hasProviderType") hasProviderType: Boolean,
        @Param("providerType") providerType: ProviderType?,

        @Param("hasCategory") hasCategory: Boolean,
        @Param("category") category: String?,

        @Param("hasDate") hasDate: Boolean,
        @Param("dateStart") dateStart: LocalDateTime?,
        @Param("dateEnd") dateEnd: LocalDateTime?,
        @Param("excludeClosed") excludeClosed: Boolean,

        pageable: Pageable,
    ): Page<Festival>

    /** 종료일이 지났는데 아직 OPEN인 행사 조회 */
    fun findByStatusAndEndDeBefore(status: FestivalStatus, now: LocalDateTime): List<Festival>

    /** 아직 R2로 이관되지 않은(외부 URL을 쓰는) 행사 이미지 조회 */
    @Query("SELECT f FROM Festival f WHERE f.imgUrl IS NOT NULL AND f.imgUrl NOT LIKE CONCAT(:r2PublicUrl, '%')")
    fun findLegacyImages(@Param("r2PublicUrl") r2PublicUrl: String, pageable: Pageable): Page<Festival>

    /** 종료일이 지난 OPEN 행사를 CLOSED로 일괄 갱신한다. 벌크 UPDATE라 영속성 컨텍스트를 비운다. */
    @Modifying(clearAutomatically = true)
    @Query(
        "UPDATE Festival f SET f.status = com.team007.room_escape.domain.festival.infra.entity.FestivalStatus.CLOSED " +
            "WHERE f.status = com.team007.room_escape.domain.festival.infra.entity.FestivalStatus.OPEN AND f.endDe < :now",
    )
    fun closeExpiredFestivals(@Param("now") now: LocalDateTime): Int

    /** 삭제되지 않은 행사 1건 조회 (공공/민간 구분은 providerType으로) */
    fun findByIdAndProviderTypeAndDeletedAtIsNull(
        festivalId: Long,
        providerType: ProviderType,
    ): Festival?

    @EntityGraph(attributePaths = ["member"])
    fun findByIdAndDeletedAtIsNull(festivalId: Long): Festival?

    fun existsByIdAndDeletedAtIsNull(festivalId: Long): Boolean

    /** 관리자 행사 검색. keyword는 null 대신 빈 문자열을 받는다. */
    @Query(
        value = """
		SELECT f
		FROM Festival f
		WHERE (:includeDeleted = true OR f.deletedAt IS NULL)
		  AND (LOWER(COALESCE(f.title, '')) LIKE CONCAT('%', :keyword, '%')
			   OR LOWER(COALESCE(f.regionDetail, '')) LIKE CONCAT('%', :keyword, '%'))
		  AND (:providerType IS NULL OR f.providerType = :providerType)
		  AND (:excludeClosed = false OR f.endDe IS NULL OR f.endDe >= CURRENT_TIMESTAMP)
		""",
        countQuery = """
		SELECT COUNT(f)
		FROM Festival f
		WHERE (:includeDeleted = true OR f.deletedAt IS NULL)
		  AND (LOWER(COALESCE(f.title, '')) LIKE CONCAT('%', :keyword, '%')
			   OR LOWER(COALESCE(f.regionDetail, '')) LIKE CONCAT('%', :keyword, '%'))
		  AND (:providerType IS NULL OR f.providerType = :providerType)
		  AND (:excludeClosed = false OR f.endDe IS NULL OR f.endDe >= CURRENT_TIMESTAMP)
		""",
    )
    fun searchForAdmin(
        @Param("keyword") keyword: String,
        @Param("providerType") providerType: ProviderType?,
        @Param("includeDeleted") includeDeleted: Boolean,
        @Param("excludeClosed") excludeClosed: Boolean,
        pageable: Pageable,
    ): Page<Festival>
}
