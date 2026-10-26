package com.team007.room_escape.domain.like

import com.team007.room_escape.domain.festival.infra.entity.Festival
import com.team007.room_escape.domain.festival.infra.entity.FestivalRegion
import com.team007.room_escape.domain.festival.infra.entity.ProviderType
import com.team007.room_escape.domain.festival.infra.repository.FestivalRepository
import com.team007.room_escape.domain.like.infra.entity.Like
import com.team007.room_escape.domain.like.infra.repository.LikeRepository
import com.team007.room_escape.domain.member.infra.entity.Member
import com.team007.room_escape.domain.member.infra.entity.MemberRole
import com.team007.room_escape.domain.post.infra.entity.Post
import com.team007.room_escape.domain.post.infra.repository.PostRepository
import jakarta.persistence.EntityManager
import org.assertj.core.api.Assertions.assertThat
import org.assertj.core.api.Assertions.entry
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.data.jpa.test.autoconfigure.DataJpaTest
import org.springframework.boot.jdbc.test.autoconfigure.AutoConfigureTestDatabase
import org.springframework.data.domain.Page
import org.springframework.data.domain.PageRequest
import java.time.LocalDateTime
import java.util.UUID

/**
 * 좋아요순 정렬 쿼리와 후기 좋아요 수(post.like_count) 갱신을 실제 PostgreSQL 에서 검증한다.
 * 정렬, 동점 처리, 페이징, UPDATE 쿼리는 DB 가 해야 의미가 있어서 목(mock)으로는 확인할 수 없다.
 *
 * test 프로필의 임시 PostgreSQL(Testcontainers)에 붙고, 테스트마다 트랜잭션이 롤백된다.
 * 로컬 DB에 다른 데이터가 있어도 섞이지 않게, 테스트마다 고유 토큰을 제목에 넣고 그 토큰으로 검색한다.
 */
@DataJpaTest
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.NONE)
class LikeSortRepositoryTest @Autowired constructor(
    private val em: EntityManager,
    private val postRepository: PostRepository,
    private val festivalRepository: FestivalRepository,
    private val likeRepository: LikeRepository,
) {

    private val token = "likesort" + UUID.randomUUID().toString().substring(0, 8)
    private lateinit var likers: List<Member>

    @BeforeEach
    fun setUp() {
        likers = List(5) { i ->
            persist(
                Member.builder()
                    .email("$token$i@test.local")
                    .password("x")
                    .role(MemberRole.ROLE_UNVERIFIED)
                    .nickname("$token-member$i")
                    .build()
            )
        }
    }

    @Nested
    @DisplayName("후기 좋아요순")
    inner class PostLikeSort {

        private lateinit var festival: Festival

        @BeforeEach
        fun setUp() {
            festival = festival("후기용 행사", BASE_TIME, FestivalRegion.entries.first())
        }

        @Test
        @DisplayName("좋아요가 많은 순으로 정렬되고, 좋아요가 없는 후기는 뒤에 온다")
        fun ordersByLikeCountDesc() {
            val three = post("three")
            post("none")
            val one = post("one")
            likePost(three, 3)
            likePost(one, 1)
            flushAndClear()

            val page = searchByToken(PageRequest.of(0, 10))

            assertThat(titles(page)).containsExactly(title("three"), title("one"), title("none"))
        }

        @Test
        @DisplayName("좋아요 수가 같으면 최신 작성순, 작성 시각도 같으면 id 역순으로 고정된다")
        fun breaksTiesByCreatedAtThenId() {
            val older = post("older")
            val newer = post("newer")
            val sameTimeFirst = post("same-first")
            val sameTimeSecond = post("same-second")
            listOf(older, newer, sameTimeFirst, sameTimeSecond).forEach { likePost(it, 2) }
            setCreatedAt(older, BASE_TIME)
            setCreatedAt(newer, BASE_TIME.plusHours(2))
            setCreatedAt(sameTimeFirst, BASE_TIME.plusHours(1))
            setCreatedAt(sameTimeSecond, BASE_TIME.plusHours(1))
            flushAndClear()

            val page = searchByToken(PageRequest.of(0, 10))

            // UUID v7 은 나중에 만든 쪽이 더 크다 → id 역순이면 same-second 가 먼저
            assertThat(titles(page)).containsExactly(
                title("newer"), title("same-second"), title("same-first"), title("older")
            )
        }

        @Test
        @DisplayName("삭제된 후기는 좋아요가 많아도 목록과 전체 개수에서 빠진다")
        fun excludesDeletedPosts() {
            val deleted = post("deleted")
            val alive = post("alive")
            likePost(deleted, 5)
            likePost(alive, 1)
            deleted.delete()
            flushAndClear()

            val page = searchByToken(PageRequest.of(0, 10))

            assertThat(titles(page)).containsExactly(title("alive"))
            assertThat(page.totalElements).isEqualTo(1)
        }

        @Test
        @DisplayName("검색어 없는 전체 목록은 좋아요 많은 후기가 앞에 오고, 삭제된 후기는 전체 개수에서 빠진다")
        fun listsAllPostsWithoutKeyword() {
            // 로컬 DB에 다른 후기가 있어도 되도록, 좋아요 수를 크게 줘서 맨 앞에 오게 하고 개수는 증감으로 본다
            val top = post("top")
            val deleted = post("deleted")
            em.flush()
            // 좋아요 행 없이 정렬만 확인하려고 수만 올린다
            em.createNativeQuery("UPDATE post SET like_count = 1000000000 WHERE id = :id")
                .setParameter("id", top.id)
                .executeUpdate()
            val before = postRepository.findAllOrderByLikeCount(PageRequest.of(0, 1)).totalElements

            deleted.delete()
            flushAndClear()
            val page = postRepository.findAllOrderByLikeCount(PageRequest.of(0, 1))

            assertThat(titles(page)).containsExactly(title("top"))
            assertThat(page.totalElements).isEqualTo(before - 1)
            assertThat(page.totalElements)
                .isEqualTo(postRepository.findAllNotDeleted(PageRequest.of(0, 1)).totalElements)
        }

        @Test
        @DisplayName("페이지를 넘겨도 중복·누락 없이 전체 순서가 이어진다")
        fun keepsOrderAcrossPageBoundaries() {
            // 동점(2개)이 페이지 경계에 걸치도록 구성
            likePost(post("p4"), 4)
            likePost(post("p2-a"), 2)
            likePost(post("p2-b"), 2)
            likePost(post("p1"), 1)
            post("p0")
            flushAndClear()

            val expected = titles(searchByToken(PageRequest.of(0, 10)))
            val page = searchByToken(PageRequest.of(0, 2))
            val paged = (0..2).flatMap { titles(searchByToken(PageRequest.of(it, 2))) }

            assertThat(page.totalElements).isEqualTo(5)
            assertThat(page.totalPages).isEqualTo(3)
            assertThat(paged).containsExactlyElementsOf(expected).doesNotHaveDuplicates()
            assertThat(expected.first()).isEqualTo(title("p4"))
            assertThat(expected.last()).isEqualTo(title("p0"))
        }

        @Test
        @DisplayName("행사별 목록은 그 행사의 후기만 좋아요순으로 보여준다")
        fun filtersByFestival() {
            val other = festival("다른 행사", BASE_TIME, FestivalRegion.entries.first())
            val mine = post("mine")
            val others = savePost("others", other)
            likePost(mine, 1)
            likePost(others, 3)
            flushAndClear()

            val page = postRepository.findAllByFestivalIdOrderByLikeCount(festival.id, PageRequest.of(0, 10))

            assertThat(titles(page)).containsExactly(title("mine"))
            assertThat(page.totalElements).isEqualTo(1)
        }

        @Test
        @DisplayName("행사별 좋아요순 목록도 삭제된 후기는 좋아요가 많아도 목록과 전체 개수에서 뺀다")
        fun festivalListExcludesDeletedPosts() {
            val deleted = post("deleted")
            val alive = post("alive")
            likePost(deleted, 5)
            likePost(alive, 1)
            deleted.delete()
            flushAndClear()

            val page = postRepository.findAllByFestivalIdOrderByLikeCount(festival.id, PageRequest.of(0, 10))

            assertThat(titles(page)).containsExactly(title("alive"))
            assertThat(page.totalElements).isEqualTo(1)
        }

        private fun searchByToken(pageable: PageRequest): Page<Post> =
            postRepository.searchPostsOrderByLikeCount("TITLE", token, pageable)

        private fun post(name: String): Post = savePost(name, festival, content = "content")
    }

    @Nested
    @DisplayName("후기 좋아요 수 (post.like_count)")
    inner class PostLikeCountUpdate {

        private lateinit var post: Post
        private lateinit var festival: Festival

        /** 저장한 뒤에 쓰므로 id가 있다. */
        private val postId: UUID get() = checkNotNull(post.id)

        @BeforeEach
        fun setUp() {
            festival = festival("좋아요 수 행사", BASE_TIME, FestivalRegion.entries.first())
            post = savePost("post", festival)
            em.flush()
        }

        @Test
        @DisplayName("증가·감소가 DB에 바로 반영되고 0 아래로는 내려가지 않는다")
        fun increasesAndDecreasesWithoutGoingNegative() {
            postRepository.increaseLikeCount(postId)
            postRepository.increaseLikeCount(postId)
            postRepository.decreaseLikeCount(postId)

            assertThat(postRepository.findLikeCountById(postId)).isEqualTo(1L)

            postRepository.decreaseLikeCount(postId)
            val updated = postRepository.decreaseLikeCount(postId)

            assertThat(updated).isZero()
            assertThat(postRepository.findLikeCountById(postId)).isEqualTo(0L)
        }

        @Test
        @DisplayName("후기를 수정·삭제해 저장해도 그 사이 늘어난 좋아요 수를 덮어쓰지 않는다")
        fun entitySaveDoesNotOverwriteLikeCount() {
            // post 엔티티는 like_count = 0 으로 읽힌 상태에서, 다른 요청이 좋아요를 누른 상황
            postRepository.increaseLikeCount(postId)
            postRepository.increaseLikeCount(postId)

            post.update("수정한 제목", "c", null)
            post.delete()
            em.flush()

            assertThat(postRepository.findLikeCountById(postId)).isEqualTo(2L)
        }

        @Test
        @DisplayName("행사에 누른 좋아요는 후기 좋아요 수에 섞이지 않는다")
        fun ignoresFestivalLikes() {
            likePost(post, 1)
            likeFestival(festival, 4)
            flushAndClear()

            assertThat(postRepository.findLikeCountById(postId)).isEqualTo(1L)
        }
    }

    @Nested
    @DisplayName("행사 좋아요순")
    inner class FestivalLikeSort {

        @Test
        @DisplayName("좋아요 많은 순, 같으면 곧 시작하는 순, 그것도 같으면 id 역순이다")
        fun ordersByLikeCountThenBeginDeThenId() {
            val region = FestivalRegion.entries.first()
            val many = festival("many", BASE_TIME.plusDays(9), region)
            val tieLater = festival("tie-later", BASE_TIME.plusDays(5), region)
            val tieSoonFirst = festival("tie-soon-first", BASE_TIME.plusDays(1), region)
            val tieSoonSecond = festival("tie-soon-second", BASE_TIME.plusDays(1), region)
            val none = festival("none", BASE_TIME, region)
            likeFestival(many, 3)
            listOf(tieLater, tieSoonFirst, tieSoonSecond).forEach { likeFestival(it, 2) }
            flushAndClear()

            val page = searchFestivalsByToken(hasRegion = false, region = null, pageable = PageRequest.of(0, 10))

            assertThat(festivalTitles(page)).containsExactly(
                title("many"), title("tie-soon-second"), title("tie-soon-first"),
                title("tie-later"), title("none")
            )
            assertThat(none.id).isNotNull()
        }

        @Test
        @DisplayName("검색 조건은 그대로 적용되고 삭제된 행사는 빠진다")
        fun appliesFiltersAndExcludesDeleted() {
            val region = FestivalRegion.entries[0]
            val otherRegion = FestivalRegion.entries[1]
            val match = festival("match", BASE_TIME, region)
            val otherPlace = festival("other-place", BASE_TIME, otherRegion)
            val deleted = festival("deleted", BASE_TIME, region)
            likeFestival(match, 1)
            likeFestival(otherPlace, 3)
            likeFestival(deleted, 4)
            deleted.delete()
            flushAndClear()

            val page = searchFestivalsByToken(hasRegion = true, region = region, pageable = PageRequest.of(0, 10))

            assertThat(festivalTitles(page)).containsExactly(title("match"))
            assertThat(page.totalElements).isEqualTo(1)
        }

        @Test
        @DisplayName("후기에 누른 좋아요는 행사 좋아요 수에 섞이지 않는다")
        fun ignoresPostLikes() {
            val festival = festival("festival", BASE_TIME, FestivalRegion.entries.first())
            val post = savePost("post", festival)
            likeFestival(festival, 1)
            likePost(post, 4)
            flushAndClear()

            val counts = likeRepository.countByFestivalIds(listOf(festival.id))
                .associate { it.festivalId to it.likeCount }

            assertThat(counts).containsExactly(entry(festival.id, 1L))
        }

        private fun searchFestivalsByToken(
            hasRegion: Boolean, region: FestivalRegion?, pageable: PageRequest,
        ): Page<Festival> =
            // 서비스는 검색어를 소문자로 바꿔서 넘긴다
            festivalRepository.searchFestivalsOrderByLikeCount(
                true, token.lowercase(),
                hasRegion, region,
                false, null,
                false, null,
                false, null,
                false, null, null,
                false,
                pageable,
            )
    }

    private fun festival(name: String, beginDe: LocalDateTime, region: FestivalRegion): Festival =
        persist(
            Festival.builder()
                .providerType(ProviderType.PUBLIC)
                .title(title(name))
                .beginDe(beginDe)
                .endDe(beginDe.plusDays(3))
                .region(region)
                .build()
        )

    private fun savePost(name: String, festival: Festival, content: String = "c"): Post =
        persist(
            Post(member = likers.first(), festival = festival, title = title(name), content = content)
        )

    /** LikeService 와 같은 순서로 좋아요를 저장하고 post.like_count 를 올린다. */
    private fun likePost(post: Post, count: Int) {
        repeat(count) { i ->
            persist(Like.of(post, likers[i]))
            postRepository.increaseLikeCount(checkNotNull(post.id))
        }
    }

    private fun likeFestival(festival: Festival, count: Int) {
        repeat(count) { i -> persist(Like.of(festival, likers[i])) }
    }

    private fun setCreatedAt(post: Post, createdAt: LocalDateTime) {
        em.flush()
        em.createNativeQuery("UPDATE post SET created_at = :createdAt WHERE id = :id")
            .setParameter("createdAt", createdAt)
            .setParameter("id", post.id)
            .executeUpdate()
    }

    private fun title(name: String) = "$token-$name"

    private fun titles(page: Page<Post>): List<String> = page.content.map { it.title }

    private fun festivalTitles(page: Page<Festival>): List<String> = page.content.map { it.title }

    private fun <T : Any> persist(entity: T): T = entity.also { em.persist(it) }

    private fun flushAndClear() {
        em.flush()
        em.clear()
    }

    companion object {
        private val BASE_TIME: LocalDateTime = LocalDateTime.of(2026, 1, 1, 12, 0)
    }
}
