package com.team007.room_escape.domain.festival.service

import com.team007.room_escape.domain.festival.dto.FestivalResponse
import com.team007.room_escape.domain.festival.dto.FestivalSearchRequest
import com.team007.room_escape.domain.festival.infra.client.FestivalPublicApiClientV2
import com.team007.room_escape.domain.festival.infra.dto.CultureInfoDetailRow
import com.team007.room_escape.domain.festival.infra.dto.CultureInfoPeriodRow
import com.team007.room_escape.domain.festival.infra.dto.FestivalVoteCount
import com.team007.room_escape.domain.festival.infra.entity.Festival
import com.team007.room_escape.domain.festival.infra.entity.FestivalAccuracyVote
import com.team007.room_escape.domain.festival.infra.entity.FestivalAccuracyVoteType
import com.team007.room_escape.domain.festival.infra.entity.FestivalStatus
import com.team007.room_escape.domain.festival.infra.entity.ProviderType
import com.team007.room_escape.domain.festival.infra.entity.PublicFestivalSource
import com.team007.room_escape.domain.festival.infra.repository.FestivalAccuracyVoteRepository
import com.team007.room_escape.domain.festival.infra.repository.FestivalRepository
import com.team007.room_escape.domain.festival.infra.repository.PublicFestivalSourceRepository
import com.team007.room_escape.domain.like.infra.dto.FestivalLikeCount
import com.team007.room_escape.domain.like.infra.repository.LikeRepository
import com.team007.room_escape.domain.like.type.LikeSort
import com.team007.room_escape.global.config.R2Properties
import com.team007.room_escape.global.exception.BusinessException
import com.team007.room_escape.global.response.code.FestivalExceptionCode
import com.team007.room_escape.global.storage.ImageUrlResolver
import org.slf4j.LoggerFactory
import org.springframework.data.domain.Page
import org.springframework.data.domain.Pageable
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import org.springframework.transaction.support.TransactionTemplate
import tools.jackson.databind.ObjectMapper
import java.time.LocalDate
import java.time.LocalDateTime
import java.util.Locale
import java.util.UUID

@Service
class FestivalService(
    private val festivalRepository: FestivalRepository,
    private val accuracyVoteRepository: FestivalAccuracyVoteRepository,
    private val likeRepository: LikeRepository,
    private val publicFestivalSourceRepository: PublicFestivalSourceRepository, // 원본 저장용
    private val festivalPublicApiClientV2: FestivalPublicApiClientV2,
    private val objectMapper: ObjectMapper,
    private val imageUrlResolver: ImageUrlResolver,
    private val festivalImageProcessor: FestivalImageProcessor,
    private val r2Properties: R2Properties,
    private val transactionTemplate: TransactionTemplate
) {
    private val log = LoggerFactory.getLogger(javaClass)

    /** 오래 걸리는 API 호출·이미지 처리는 트랜잭션 밖에서 하고, DB 작업만 짧은 트랜잭션으로 커밋한다. */
    fun syncPublicFestivals(): FestivalResponse.SyncResponse {
        // 종료일이 지난 기존 행사를 먼저 CLOSED로 갱신한다.
        val closedFestivals: List<FestivalResponse.SyncedFestival> = transactionTemplate.execute {
            closeExpiredFestivals()
        }

        val currentYear = LocalDate.now().year
        val allRows = fetchAllRows("${currentYear}0101", "${currentYear}1231")

        // 원본 스냅샷 저장
        saveRawSource(allRows)

        // seq 존재 여부로 신규 행사를 정확히 판별한다 (건수 비교보다 API 응답 순서에 안전하다).
        val seqs = allRows.map { it.seq } // 14,592건에서 seq 값들만 뽑아서 리스트로 만듦
        val existingSeqs = festivalRepository.findExistingExternalIds(ProviderType.PUBLIC, seqs) // seq들 중 이미 DB에 저장된 것만 조회
        val newSeqs = seqs.filter { it !in existingSeqs } // seqs에서 existingSeqs에 없는 것만 걸러냄 → 신규 행사

        if (newSeqs.isEmpty()) {
            log.info("신규 행사 없음 ({}년 전체 {}건, 신규 0건)", currentYear, allRows.size)
            migrateLegacyImages()
            return FestivalResponse.SyncResponse(
                closedFestivals = closedFestivals,
                savedFestivals = emptyList(),
                detailLookupCount = 0,
                skippedCount = 0,
                interrupted = false
            )
        }

        val savedFestivals = mutableListOf<FestivalResponse.SyncedFestival>()
        var skippedCount = 0
        var interrupted = false
        // 원본 스냅샷은 이미 커밋돼서 여기서 실패해도 남는다.
        try {
            // 신규 건만 상세조회(가격 등 포함)까지 받아서 엔티티로 변환한다.
            // 호출 사이에 간격을 둬서 429 Too Many Requests를 피하고, DETAIL_SAVE_BATCH_SIZE건마다 중간 저장한다
            // (실패해도 그때까지 모은 건 안 날아가고, DB에서 진행 상황을 바로 확인할 수 있다).
            var buffer = mutableListOf<Festival>()
            var processed = 0
            for (seq in newSeqs) {
                val detail: CultureInfoDetailRow? = festivalPublicApiClientV2.fetchDetail(seq)
                if (detail != null) { // 상세 조회가 빈 값으로 오는 경우 방어
                    buffer.add(toCultureInfoFestival(detail)) // 이미지 다운로드·업로드가 여기서 일어난다
                } else {
                    skippedCount++
                }
                processed++

                // 버퍼가 다 찼거나, 마지막 건이라 더 안 채워져도 남은 걸 지금 저장해야 할 때
                if (buffer.size >= DETAIL_SAVE_BATCH_SIZE || processed == newSeqs.size) {
                    savedFestivals.addAll(saveBatch(buffer))
                    buffer = mutableListOf() // 저장에 쓴 리스트는 그대로 두고, 다음 배치는 새 리스트에 담는다.
                    log.info("공공 행사 동기화 진행 중 ({}/{}건)", processed, newSeqs.size)
                }

                Thread.sleep(DETAIL_FETCH_INTERVAL)
            }
            log.info("공공 행사 {}건 저장 완료 (건너뜀 {}건)", savedFestivals.size, skippedCount)
        } catch (e: InterruptedException) {
            // 서버 종료 등으로 중단된 것이지 공공 API 호출 실패가 아니다. 인터럽트 상태를 복구해서
            // 호출자(스레드 풀 등)가 종료 신호를 계속 인식하게 하고, 더 이상 작업을 이어가지 않는다.
            Thread.currentThread().interrupt()
            interrupted = true
            log.warn("신규 행사 저장 중단됨 (서버 종료 등, 지금까지 {}건 저장됨)", savedFestivals.size)
            return FestivalResponse.SyncResponse(
                closedFestivals = closedFestivals,
                savedFestivals = savedFestivals,
                detailLookupCount = newSeqs.size,
                skippedCount = skippedCount,
                interrupted = interrupted
            )
        } catch (e: Exception) {
            interrupted = true
            log.error("신규 행사 저장 실패 (지금까지 {}건 저장됨), 원본 스냅샷은 반영됨", savedFestivals.size, e)
        }
        migrateLegacyImages()
        return FestivalResponse.SyncResponse(
            closedFestivals = closedFestivals,
            savedFestivals = savedFestivals,
            detailLookupCount = newSeqs.size,
            skippedCount = skippedCount,
            interrupted = interrupted
        )
    }

    /** 이미지 처리까지 끝난 행사 묶음을 한 트랜잭션으로 저장한다. 저장 후에 id가 채워진 목록을 돌려준다. */
    private fun saveBatch(batch: List<Festival>): List<FestivalResponse.SyncedFestival> {
        if (batch.isEmpty()) {
            return emptyList()
        }
        festivalRepository.saveAll(batch)
        return batch.map { FestivalResponse.SyncedFestival.from(it) }
    }

    /** 검색어와 선택 필터로 공공행사와 사용자 등록 행사를 통합 검색한다. */
    @Transactional(readOnly = true)
    fun searchFestivals(
        request: FestivalSearchRequest,
        pageable: Pageable
    ): Page<FestivalResponse.ListItem> {
        val keyword = normalize(request.keyword)
        val category = when (val value = normalize(request.category)) {
            "축제" -> "행사/축제"
            "교육", "체험" -> "교육/체험"
            else -> value
        }
        val regionDetail = normalize(request.regionDetail)

        val dateStart = request.date?.atStartOfDay()
        val dateEnd = request.date?.plusDays(1)?.atStartOfDay()

        if (LikeSort.isRequested(pageable)) {
            return toListItems(
                festivalRepository.searchFestivalsOrderByLikeCount(
                    keyword != null,
                    keyword,

                    request.region != null,
                    request.region,

                    regionDetail != null,
                    regionDetail,

                    request.providerType != null,
                    request.providerType,

                    category != null,
                    category,

                    request.date != null,
                    dateStart,
                    dateEnd,
                    true == request.excludeClosed,

                    LikeSort.withoutSort(pageable)
                )
            )
        }

        // 정렬을 지정하지 않으면 오늘 기준으로 가장 가깝게 시작하는 행사부터 보여준다.
        if (pageable.sort.isUnsorted) {
            return toListItems(
                festivalRepository.searchFestivalsOrderByNearestStart(
                    keyword != null,
                    keyword,

                    request.region != null,
                    request.region,

                    regionDetail != null,
                    regionDetail,

                    request.providerType != null,
                    request.providerType,

                    category != null,
                    category,

                    request.date != null,
                    dateStart,
                    dateEnd,
                    true == request.excludeClosed,

                    LocalDate.now().atStartOfDay(),

                    pageable
                )
            )
        }

        return toListItems(
            festivalRepository.searchFestivals(
                keyword != null,
                keyword,

                request.region != null,
                request.region,

                regionDetail != null,
                regionDetail,

                request.providerType != null,
                request.providerType,

                category != null,
                category,

                request.date != null,
                dateStart,
                dateEnd,
                true == request.excludeClosed,

                pageable
            )
        )
    }

    /**
     * 페이지에 담긴 행사들의 좋아요·투표 수를 한 번에 센다. (N+1 방지)
     * 마이페이지의 좋아요한 행사 목록도 같은 카드로 보여 주려고 이 함수를 쓴다.
     */
    fun toListItems(festivals: Page<Festival>): Page<FestivalResponse.ListItem> {
        if (festivals.isEmpty) {
            return festivals.map { festival ->
                FestivalResponse.ListItem.from(festival, 0L, 0L, 0L, imageUrlResolver)
            }
        }

        // Festival.id는 Kotlin에서 nullable(Long?)로 선언돼 있어 그대로 nullable로 다룬다.
        val festivalIds: List<Long?> = festivals.content.map { it.id }
        val counts = listCounts(festivalIds)

        return festivals.map { festival ->
            val count = counts.getValue(festival.id)
            FestivalResponse.ListItem.from(
                festival,
                count.likeCount,
                count.accurateCount,
                count.inaccurateCount,
                imageUrlResolver
            )
        }
    }

    /** 좋아요와 정확도 투표를 행사 번호 하나로 모은다. 없는 값은 0이다. */
    private fun listCounts(festivalIds: List<Long?>): Map<Long?, ListCounts> {
        val nonNullIds = festivalIds.filterNotNull()
        val likeCounts: Map<Long, Long> = likeRepository.countByFestivalIds(nonNullIds)
            .associate { it.festivalId to it.likeCount }
        val voteCounts: Map<Long, ListCounts> = accuracyVoteRepository.countByFestivalIds(nonNullIds.toMutableList())
            .groupingBy { it.festivalId }
            .fold(ListCounts.EMPTY) { acc, row -> ListCounts.mergeVotes(acc, ListCounts.fromVote(row)) }

        return festivalIds.associateWith { id ->
            val vote = id?.let { voteCounts[it] } ?: ListCounts.EMPTY
            vote.withLike(id?.let { likeCounts[it] } ?: 0L)
        }
    }

    /** 행사 상세와 정확도 평가·좋아요 정보를 한 번에 조회한다. */
    @Transactional(readOnly = true)
    fun getFestival(festivalId: Long, memberId: UUID?): FestivalResponse.Detail {
        val festival = festivalRepository.findByIdAndDeletedAtIsNull(festivalId)
            ?: throw BusinessException(FestivalExceptionCode.FESTIVAL_NOT_FOUND)

        var accurateCount = 0L
        var inaccurateCount = 0L
        var myVote: FestivalAccuracyVoteType? = null

        if (festival.providerType == ProviderType.MEMBER) {
            accurateCount = accuracyVoteRepository.countByFestivalAndVoteType(
                festival,
                FestivalAccuracyVoteType.ACCURATE
            )
            inaccurateCount = accuracyVoteRepository.countByFestivalAndVoteType(
                festival,
                FestivalAccuracyVoteType.INACCURATE
            )

            if (memberId != null) {
                myVote = accuracyVoteRepository
                    .findByFestivalIdAndMemberId(festivalId, memberId)
                    ?.voteType
            }
        }

        val likeCount = likeRepository.countByFestivalId(festivalId)
        val likedByMe = memberId != null && likeRepository.existsByFestivalIdAndMemberId(festivalId, memberId)
        return FestivalResponse.Detail.from(
            festival,
            accurateCount,
            inaccurateCount,
            myVote,
            likeCount,
            likedByMe,
            imageUrlResolver
        )
    }

    /** 종료일이 지난 OPEN 행사를 CLOSED로 갱신하고, 갱신된 목록을 돌려준다. */
    private fun closeExpiredFestivals(): List<FestivalResponse.SyncedFestival> {
        val now = LocalDateTime.now()
        // 일괄 UPDATE는 바뀐 행을 돌려주지 않아서 갱신 전에 목록을 먼저 뽑는다.
        val closed = festivalRepository.findByStatusAndEndDeBefore(FestivalStatus.OPEN, now)
            .map { FestivalResponse.SyncedFestival.from(it) }
        festivalRepository.closeExpiredFestivals(now)
        log.info("종료된 행사 {}건 CLOSED로 갱신", closed.size)
        return closed
    }

    /** 받은 건수가 요청한 페이지 크기보다 적을 때까지(=마지막 페이지) 전부 받는다. */
    private fun fetchAllRows(from: String, to: String): List<CultureInfoPeriodRow> {
        val rows = mutableListOf<CultureInfoPeriodRow>()
        var pageNo = 1
        while (true) {
            val page = festivalPublicApiClientV2.fetchPeriod(pageNo, CULTURE_INFO_PAGE_SIZE, from, to)
            if (page.isEmpty()) {
                break
            }
            rows.addAll(page)
            if (page.size < CULTURE_INFO_PAGE_SIZE) {
                break // 요청한 개수보다 적게 왔으면 마지막 페이지
            }
            pageNo++
        }
        return rows
    }

    /** 원본 스냅샷은 누적하지 않고 최신 1건만 유지한다. */
    private fun saveRawSource(rows: List<CultureInfoPeriodRow>) {
        try {
            val json = objectMapper.writeValueAsString(rows)
            // 지우기와 저장을 한 트랜잭션으로 묶어 스냅샷이 비지 않게 한다.
            transactionTemplate.executeWithoutResult {
                publicFestivalSourceRepository.deleteAll()
                // jsonb를 파싱하지 않고 건수를 보려고 따로 저장한다.
                publicFestivalSourceRepository.save(PublicFestivalSource(json, rows.size))
            }
        } catch (e: Exception) {
            // 원본 저장은 부가 기능이라 실패해도 배치를 막지 않는다.
            log.warn("원본 데이터 저장 실패, 배치는 계속 진행", e)
        }
    }

    /** R2로 옮겨지지 않은 기존 행사 이미지를 배치마다 조금씩 이관한다. 실패해도 동기화는 계속한다. */
    private fun migrateLegacyImages() {
        try {
            val legacy = festivalRepository.findLegacyImages(
                r2Properties.publicUrl, Pageable.ofSize(LEGACY_IMAGE_BATCH_SIZE)
            )

            val processedUrls: Map<Long, String?> = legacy.mapNotNull { festival ->
                festival.id?.let { id -> id to festivalImageProcessor.process(festival.imgUrl) }
            }.toMap()

            transactionTemplate.executeWithoutResult {
                festivalRepository.findAllById(processedUrls.keys)
                    .forEach { festival -> festival.id?.let { id -> festival.updateImgUrl(processedUrls[id]) } }
            }
            log.info("기존 행사 이미지 {}건 이관 시도", processedUrls.size)
        } catch (e: Exception) {
            log.warn("기존 이미지 이관 실패, 동기화는 계속 진행", e)
        }
    }

    /** 전국 문화정보 API 상세 행을 엔티티로 바꾼다. 이미지 다운로드·R2 업로드는 여기서 한다. */
    private fun toCultureInfoFestival(row: CultureInfoDetailRow): Festival =
        row.toFestival(festivalImageProcessor.process(row.imgUrl))

    /** 입력값의 앞뒤 공백을 제거하고, 빈 문자열은 검색 조건에서 제외한다. */
    private fun normalize(value: String?): String? {
        if (value.isNullOrBlank()) {
            return null
        }
        return value.trim().lowercase(Locale.ROOT)
    }

    /** 목록 한 줄에 붙일 좋아요·정확해요·부정확해요 개수. */
    private data class ListCounts(val likeCount: Long, val accurateCount: Long, val inaccurateCount: Long) {
        fun withLike(likeCount: Long): ListCounts = ListCounts(likeCount, accurateCount, inaccurateCount)

        companion object {
            val EMPTY = ListCounts(0, 0, 0)

            fun fromVote(row: FestivalVoteCount): ListCounts =
                if (row.voteType == FestivalAccuracyVoteType.ACCURATE) ListCounts(0, row.count, 0)
                else ListCounts(0, 0, row.count)

            fun mergeVotes(left: ListCounts, right: ListCounts): ListCounts =
                ListCounts(0, left.accurateCount + right.accurateCount, left.inaccurateCount + right.inaccurateCount)
        }
    }

    companion object {
        private const val CULTURE_INFO_PAGE_SIZE = 9999
        private const val LEGACY_IMAGE_BATCH_SIZE = 30
        private val DETAIL_FETCH_INTERVAL: java.time.Duration = java.time.Duration.ofMillis(200) // 429 Too Many Requests 방지
        private const val DETAIL_SAVE_BATCH_SIZE = 50 // 이 건수마다 중간 저장해서 진행 상황을 DB에서 바로 확인할 수 있게 한다
    }
}
