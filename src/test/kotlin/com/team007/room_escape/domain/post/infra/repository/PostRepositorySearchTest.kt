package com.team007.room_escape.domain.post.infra.repository

import com.team007.room_escape.domain.festival.infra.entity.Festival
import com.team007.room_escape.domain.festival.infra.entity.ProviderType
import com.team007.room_escape.domain.festival.infra.repository.FestivalRepository
import com.team007.room_escape.domain.member.infra.entity.Member
import com.team007.room_escape.domain.member.infra.entity.MemberRole
import com.team007.room_escape.domain.member.infra.repository.MemberRepository
import com.team007.room_escape.domain.post.infra.entity.Post
import com.team007.room_escape.domain.post.service.PostService
import com.team007.room_escape.domain.post.type.PostSearchType
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.data.domain.PageRequest
import org.springframework.data.domain.Sort
import org.springframework.transaction.annotation.Transactional
import java.time.LocalDateTime
import java.util.UUID

/** 탈퇴 회원의 원래 닉네임으로 후기를 찾을 수 없어야 한다. 화면에서 가린 이름이 검색으로 드러나면 안 된다. */
@SpringBootTest
@Transactional
class PostRepositorySearchTest @Autowired constructor(
    private val postRepository: PostRepository,
    private val memberRepository: MemberRepository,
    private val festivalRepository: FestivalRepository,
    private val postService: PostService,
) {

    private val page = PageRequest.of(0, 10)

    // 시드 데이터와 겹치지 않게 테스트마다 다른 검색어를 쓴다.
    private val token = UUID.randomUUID().toString().substring(0, 8)

    private lateinit var festival: Festival
    private lateinit var activePost: Post
    private lateinit var withdrawnPost: Post

    @BeforeEach
    fun setUp() {
        festival = festivalRepository.save(
            Festival.builder()
                .providerType(ProviderType.PUBLIC)
                .title("행사 $token")
                .beginDe(LocalDateTime.now())
                .endDe(LocalDateTime.now().plusDays(1))
                .build()
        )

        val active = memberRepository.save(member("활동$token"))
        val withdrawn = member("탈퇴$token").apply { delete() }
        memberRepository.save(withdrawn)

        activePost = postRepository.save(Post(member = active, festival = festival, title = "활동 후기 $token", content = "본문"))
        withdrawnPost = postRepository.save(Post(member = withdrawn, festival = festival, title = "탈퇴 후기 $token", content = "본문"))
    }

    @Test
    fun 닉네임_검색은_탈퇴_회원의_후기를_찾지_않는다() {
        val result = postRepository.searchPosts(PostSearchType.MEMBER_NICKNAME, token, page)

        assertThat(result.content.map { it.id }).containsExactly(activePost.id)
        assertThat(result.totalElements).isEqualTo(1)
    }

    @Test
    fun 좋아요순_닉네임_검색도_탈퇴_회원의_후기를_찾지_않는다() {
        val result = postRepository.searchPostsOrderByLikeCount(PostSearchType.MEMBER_NICKNAME.name, token, page)

        assertThat(result.content.map { it.id }).containsExactly(activePost.id)
        assertThat(result.totalElements).isEqualTo(1)
    }

    @Test
    fun 탈퇴_회원의_원래_닉네임을_그대로_넣어도_찾지_않는다() {
        val result = postRepository.searchPosts(PostSearchType.MEMBER_NICKNAME, "탈퇴$token", page)

        assertThat(result.content).isEmpty()
        assertThat(result.totalElements).isZero()
    }

    @Test
    fun 제목_검색에서는_탈퇴_회원의_후기도_그대로_나온다() {
        val latest = postRepository.searchPosts(PostSearchType.TITLE, token, page)
        val byLike = postRepository.searchPostsOrderByLikeCount(PostSearchType.TITLE.name, token, page)

        assertThat(latest.content.map { it.id }).containsExactlyInAnyOrder(activePost.id, withdrawnPost.id)
        assertThat(byLike.content.map { it.id }).containsExactlyInAnyOrder(activePost.id, withdrawnPost.id)
    }

    @Test
    fun 관리자_닉네임_검색은_탈퇴_회원의_후기도_찾는다() {
        val result = postRepository.searchPostsIncludingDeleted(PostSearchType.MEMBER_NICKNAME, token, page)

        assertThat(result.content.map { it.id }).containsExactlyInAnyOrder(activePost.id, withdrawnPost.id)
    }

    /** LIKE의 와일드카드(%, _)를 검색어에 그대로 넣으면 "할인_50"이 "할인 50"까지, "%"가 모든 후기를 찾는다. */
    @Test
    fun 검색어의_퍼센트와_밑줄은_글자_그대로_찾는다() {
        val author = memberRepository.save(member("기호$token"))
        fun save(title: String) = checkNotNull(
            postRepository.save(Post(member = author, festival = festival, title = title, content = "본문")).id
        )
        val space = save("할인 50 $token")
        val underscore = save("할인_50 $token")
        val percent = save("100% 환불 $token")
        val bang = save("느낌표! $token")
        val mine = setOf(space, underscore, percent, bang)
        val all = PageRequest.of(0, 100)
        val byLike = PageRequest.of(0, 100, Sort.by(Sort.Direction.DESC, "likeCount"))

        val searches: Map<String, (String) -> List<UUID?>> = mapOf(
            "최신순" to { k -> postService.searchPosts(PostSearchType.TITLE, k, all).content.map { it.id } },
            "좋아요순" to { k -> postService.searchPosts(PostSearchType.TITLE, k, byLike).content.map { it.id } },
            "관리자" to { k -> postService.searchPostsForAdmin(PostSearchType.TITLE, k, all).content.map { it.id } },
        )
        searches.forEach { (name, search) ->
            fun found(keyword: String) = search(keyword).filter { it in mine }
            assertThat(found("할인_50")).`as`(name).containsExactly(underscore)
            assertThat(found("0%")).`as`(name).containsExactly(percent)
            assertThat(found("%")).`as`(name).containsExactly(percent)
            assertThat(found("_")).`as`(name).containsExactly(underscore)
            assertThat(found("!")).`as`(name).containsExactly(bang)
        }
    }

    @Test
    fun 닉네임_검색도_밑줄을_글자_그대로_찾는다() {
        val underscoreAuthor = memberRepository.save(member("밑줄_$token"))
        val spaceAuthor = memberRepository.save(member("밑줄 $token"))
        val underscore = postRepository.save(Post(member = underscoreAuthor, festival = festival, title = "제목", content = "본문"))
        postRepository.save(Post(member = spaceAuthor, festival = festival, title = "제목", content = "본문"))

        val result = postService.searchPosts(PostSearchType.MEMBER_NICKNAME, "밑줄_$token", page)

        assertThat(result.content.map { it.id }).containsExactly(underscore.id)
    }

    private fun member(nickname: String): Member =
        Member.builder()
            .email("$nickname@test.com")
            .password("encoded")
            .role(MemberRole.ROLE_UNVERIFIED)
            .nickname(nickname)
            .build()
}
