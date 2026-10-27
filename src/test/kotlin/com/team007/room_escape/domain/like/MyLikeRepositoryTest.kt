package com.team007.room_escape.domain.like

import com.team007.room_escape.domain.festival.infra.entity.Festival
import com.team007.room_escape.domain.festival.infra.entity.FestivalRegion
import com.team007.room_escape.domain.festival.infra.entity.ProviderType
import com.team007.room_escape.domain.like.infra.entity.Like
import com.team007.room_escape.domain.like.infra.repository.LikeRepository
import com.team007.room_escape.domain.member.infra.entity.Member
import com.team007.room_escape.domain.member.infra.entity.MemberRole
import com.team007.room_escape.domain.post.infra.entity.Post
import jakarta.persistence.EntityManager
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.data.jpa.test.autoconfigure.DataJpaTest
import org.springframework.boot.jdbc.test.autoconfigure.AutoConfigureTestDatabase
import org.springframework.data.domain.PageRequest
import java.time.LocalDateTime
import java.util.UUID

/**
 * 마이페이지의 "내가 좋아요한 행사·후기" 쿼리를 실제 PostgreSQL에서 확인한다.
 * 정렬·삭제 필터·페이징은 DB가 해야 의미가 있어서 목(mock)으로는 확인할 수 없다.
 */
@DataJpaTest
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.NONE)
class MyLikeRepositoryTest @Autowired constructor(
    private val em: EntityManager,
    private val likeRepository: LikeRepository,
) {

    private val token = "mylike" + UUID.randomUUID().toString().substring(0, 8)
    private lateinit var me: Member
    private lateinit var other: Member
    private lateinit var writer: Member

    @BeforeEach
    fun setUp() {
        me = member("me")
        other = member("other")
        writer = member("writer")
    }

    @Test
    fun `좋아요한 후기를 최근에 누른 순서로 돌려준다`() {
        val festival = festival("행사")
        val first = post("first", festival)
        val second = post("second", festival)
        val third = post("third", festival)
        likedAt(Like.of(first, me), BASE_TIME.plusHours(2))
        likedAt(Like.of(second, me), BASE_TIME)
        likedAt(Like.of(third, me), BASE_TIME.plusHours(1))
        flushAndClear()

        val page = likeRepository.findLikedPosts(me.id, PageRequest.of(0, 10))

        assertThat(page.content.map { it.title }).containsExactly(title("first"), title("third"), title("second"))
        assertThat(page.totalElements).isEqualTo(3)
    }

    @Test
    fun `다른 회원의 좋아요와 삭제된 후기는 목록과 전체 개수에서 빠진다`() {
        val festival = festival("행사")
        val mine = post("mine", festival)
        val deleted = post("deleted", festival)
        val othersOnly = post("others-only", festival)
        likedAt(Like.of(mine, me), BASE_TIME)
        likedAt(Like.of(deleted, me), BASE_TIME)
        likedAt(Like.of(othersOnly, other), BASE_TIME)
        deleted.delete()
        flushAndClear()

        val page = likeRepository.findLikedPosts(me.id, PageRequest.of(0, 10))

        assertThat(page.content.map { it.title }).containsExactly(title("mine"))
        assertThat(page.totalElements).isEqualTo(1)
    }

    @Test
    fun `후기 목록 응답에 필요한 작성자와 행사를 함께 읽는다`() {
        val festival = festival("행사")
        likedAt(Like.of(post("post", festival), me), BASE_TIME)
        flushAndClear()

        val post = likeRepository.findLikedPosts(me.id, PageRequest.of(0, 10)).content.single()
        val loaded = em.entityManagerFactory.persistenceUnitUtil

        assertThat(loaded.isLoaded(post, "member")).isTrue()
        assertThat(loaded.isLoaded(post, "festival")).isTrue()
    }

    @Test
    fun `좋아요한 행사를 최근에 누른 순서로 돌려준다`() {
        val older = festival("older")
        val newer = festival("newer")
        likedAt(Like.of(older, me), BASE_TIME)
        likedAt(Like.of(newer, me), BASE_TIME.plusHours(1))
        flushAndClear()

        val page = likeRepository.findLikedFestivals(me.id, PageRequest.of(0, 10))

        assertThat(page.content.map { it.title }).containsExactly(title("newer"), title("older"))
    }

    @Test
    fun `다른 회원의 좋아요와 삭제된 행사는 목록과 전체 개수에서 빠진다`() {
        val mine = festival("mine")
        val deleted = festival("deleted")
        val othersOnly = festival("others-only")
        likedAt(Like.of(mine, me), BASE_TIME)
        likedAt(Like.of(deleted, me), BASE_TIME)
        likedAt(Like.of(othersOnly, other), BASE_TIME)
        deleted.delete()
        flushAndClear()

        val page = likeRepository.findLikedFestivals(me.id, PageRequest.of(0, 10))

        assertThat(page.content.map { it.title }).containsExactly(title("mine"))
        assertThat(page.totalElements).isEqualTo(1)
    }

    @Test
    fun `후기 좋아요와 행사 좋아요는 서로의 목록에 섞이지 않는다`() {
        val festival = festival("행사")
        likedAt(Like.of(festival, me), BASE_TIME)
        likedAt(Like.of(post("post", festival), me), BASE_TIME)
        flushAndClear()

        assertThat(likeRepository.findLikedPosts(me.id, PageRequest.of(0, 10)).content.map { it.title })
            .containsExactly(title("post"))
        assertThat(likeRepository.findLikedFestivals(me.id, PageRequest.of(0, 10)).content.map { it.title })
            .containsExactly(title("행사"))
    }

    @Test
    fun `같은 시각에 누른 좋아요는 나중에 저장된 것이 먼저 오고 페이지를 넘겨도 겹치지 않는다`() {
        val festivals = List(3) { festival("same$it") }
        festivals.forEach { likedAt(Like.of(it, me), BASE_TIME) }
        flushAndClear()

        val first = likeRepository.findLikedFestivals(me.id, PageRequest.of(0, 2))
        val second = likeRepository.findLikedFestivals(me.id, PageRequest.of(1, 2))

        assertThat((first.content + second.content).map { it.title })
            .containsExactly(title("same2"), title("same1"), title("same0"))
        assertThat(first.totalElements).isEqualTo(3)
    }

    private fun member(name: String): Member = persist(
        Member(email = "$token-$name@test.local", password = "x", role = MemberRole.ROLE_UNVERIFIED, nickname = "$token-$name"),
    )

    private fun festival(name: String): Festival = persist(
        Festival(
            providerType = ProviderType.PUBLIC,
            title = title(name),
            beginDe = BASE_TIME,
            endDe = BASE_TIME.plusDays(3),
            region = FestivalRegion.SEOUL,
        ),
    )

    private fun post(name: String, festival: Festival): Post =
        persist(Post(member = writer, festival = festival, title = title(name), content = "c"))

    /** 좋아요를 저장하고 누른 시각을 정한다. created_at은 감사 기능이 채우므로 저장 뒤에 바꾼다. */
    private fun likedAt(like: Like, likedAt: LocalDateTime) {
        persist(like)
        em.flush()
        em.createNativeQuery("UPDATE \"like\" SET created_at = :likedAt WHERE id = :id")
            .setParameter("likedAt", likedAt)
            .setParameter("id", like.id)
            .executeUpdate()
    }

    private fun <T : Any> persist(entity: T): T = entity.also { em.persist(it) }

    private fun flushAndClear() {
        em.flush()
        em.clear()
    }

    private fun title(name: String) = "$token-$name"

    companion object {
        private val BASE_TIME: LocalDateTime = LocalDateTime.of(2026, 1, 1, 12, 0)
    }
}
