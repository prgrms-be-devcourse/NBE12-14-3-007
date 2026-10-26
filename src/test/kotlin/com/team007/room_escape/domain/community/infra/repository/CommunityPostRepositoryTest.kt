package com.team007.room_escape.domain.community.infra.repository

import com.team007.room_escape.domain.community.infra.entity.CommunityPost
import com.team007.room_escape.domain.community.service.CommunityService
import com.team007.room_escape.domain.community.type.CommunityCategory
import com.team007.room_escape.domain.member.infra.entity.Member
import com.team007.room_escape.domain.member.infra.entity.MemberRole
import com.team007.room_escape.domain.member.infra.repository.MemberRepository
import org.assertj.core.api.Assertions.assertThat
import org.assertj.core.api.Assertions.assertThatCode
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.data.domain.PageRequest
import org.springframework.jdbc.core.JdbcTemplate
import org.springframework.transaction.PlatformTransactionManager
import org.springframework.transaction.TransactionDefinition
import org.springframework.transaction.annotation.Propagation
import org.springframework.transaction.annotation.Transactional
import org.springframework.transaction.support.TransactionTemplate
import java.util.UUID

@SpringBootTest
@Transactional
class CommunityPostRepositoryTest @Autowired constructor(
    private val postRepository: CommunityPostRepository,
    private val communityService: CommunityService,
    private val memberRepository: MemberRepository,
    private val transactionManager: PlatformTransactionManager,
    private val jdbcTemplate: JdbcTemplate,
) {

    @Test
    fun 검색어가_없어도_목록을_조회할_수_있다() {
        assertThatCode { postRepository.search(null, "", PageRequest.of(0, 10)) }
            .doesNotThrowAnyException()
    }

    /** LIKE의 와일드카드(%, _)와 escape 문자(!)를 검색어에 그대로 넣으면 "할인_50"이 "할인 50"까지, "%"가 모든 글을 찾는다. */
    @Test
    fun 검색어의_퍼센트와_밑줄은_글자_그대로_찾는다() {
        val author = newMember()
        val tag = UUID.randomUUID().toString().substring(0, 8)
        val space = save(CommunityPost(member = author, category = CommunityCategory.FREE, title = "할인 50 $tag", content = "본문"))
        val underscore = save(CommunityPost(member = author, category = CommunityCategory.FREE, title = "할인_50 $tag", content = "본문"))
        val percent = save(CommunityPost(member = author, category = CommunityCategory.FREE, title = "100% 환불 $tag", content = "본문"))
        val bang = save(CommunityPost(member = author, category = CommunityCategory.FREE, title = "느낌표! $tag", content = "본문"))
        val mine = setOf(space, underscore, percent, bang)

        fun found(keyword: String): List<UUID> =
            communityService.getPosts(null, keyword, PageRequest.of(0, 100)).content.map { it.id }.filter { it in mine }

        assertThat(found("할인_50")).containsExactly(underscore)
        assertThat(found("0%")).containsExactly(percent)
        assertThat(found("%")).containsExactly(percent)
        assertThat(found("_")).containsExactly(underscore)
        // escape 문자로 쓰는 '!'도 글자 그대로 찾는다.
        assertThat(found("!")).containsExactly(bang)
    }

    /**
     * 글을 읽은 뒤 다른 요청이 조회수를 올리고, 그다음 수정 내용이 저장되는 순서.
     * 엔티티를 저장할 때 view_count까지 쓰면 처음 읽은 값으로 되돌아가 그사이 오른 조회수가 사라진다.
     */
    @Test
    @Transactional(propagation = Propagation.NOT_SUPPORTED)
    fun 글을_수정해도_그사이_오른_조회수를_덮어쓰지_않는다() {
        val author = newMember()
        val postId = save(CommunityPost(member = author, category = CommunityCategory.FREE, title = "조회수 글", content = "<p>본문</p>"))
        val newTransaction = TransactionTemplate(transactionManager).apply {
            propagationBehavior = TransactionDefinition.PROPAGATION_REQUIRES_NEW
        }
        try {
            TransactionTemplate(transactionManager).executeWithoutResult {
                val post = requireNotNull(postRepository.findWithMemberById(postId))
                newTransaction.executeWithoutResult { postRepository.increaseViewCount(postId) }
                post.update(CommunityCategory.EVENT, "고친 제목", "<p>고친 본문</p>")
            }

            val row = jdbcTemplate.queryForMap("select title, view_count from community_post where id = ?", postId)
            assertThat(row["title"]).isEqualTo("고친 제목")
            assertThat(row["view_count"]).isEqualTo(1L)
        } finally {
            jdbcTemplate.update("delete from community_post where id = ?", postId)
            jdbcTemplate.update("delete from member where id = ?", author.id)
        }
    }

    private fun save(post: CommunityPost): UUID = checkNotNull(postRepository.save(post).id)

    private fun newMember(): Member {
        val nickname = "검색" + UUID.randomUUID().toString().substring(0, 8)
        return memberRepository.save(
            Member.builder()
                .email("$nickname@test.com")
                .password("encoded")
                .role(MemberRole.ROLE_UNVERIFIED)
                .nickname(nickname)
                .build()
        )
    }
}
