package com.team007.room_escape.domain.member.service

import com.team007.room_escape.domain.member.infra.entity.Member
import com.team007.room_escape.domain.member.infra.entity.MemberRole
import com.team007.room_escape.domain.member.infra.repository.MemberRepository
import com.team007.room_escape.global.exception.BusinessException
import com.team007.room_escape.global.response.code.MemberExceptionCode
import org.assertj.core.api.Assertions.assertThat
import org.assertj.core.api.Assertions.assertThatThrownBy
import org.junit.jupiter.api.Test
import org.mockito.Mockito.mock
import org.mockito.Mockito.`when`
import java.util.UUID

class MemberReaderTest {

    private val memberRepository = mock(MemberRepository::class.java)
    private val reader = MemberReader(memberRepository)

    private val memberId = UUID.randomUUID()

    private fun member(role: MemberRole) =
        Member(email = "a@example.com", password = "pw", role = role, nickname = "닉네임", id = memberId)

    private fun org.assertj.core.api.AbstractThrowableAssert<*, *>.isBusiness(code: MemberExceptionCode) {
        isInstanceOfSatisfying(BusinessException::class.java) {
            assertThat(it.exceptionCode).isEqualTo(code)
        }
    }

    @Test
    fun `탈퇴하지 않은 회원을 돌려준다`() {
        val member = member(MemberRole.ROLE_UNVERIFIED)
        `when`(memberRepository.findByIdAndDeletedAtIsNull(memberId)).thenReturn(member)

        assertThat(reader.getActiveMember(memberId)).isSameAs(member)
    }

    @Test
    fun `없거나 탈퇴한 회원은 찾을 수 없다`() {
        `when`(memberRepository.findByIdAndDeletedAtIsNull(memberId)).thenReturn(null)

        assertThatThrownBy { reader.getActiveMember(memberId) }.isBusiness(MemberExceptionCode.MEMBER_NOT_FOUND)
    }

    @Test
    fun `제재 회원도 활동 회원으로는 조회된다`() {
        val member = member(MemberRole.ROLE_WARNING)
        `when`(memberRepository.findByIdAndDeletedAtIsNull(memberId)).thenReturn(member)

        assertThat(reader.getActiveMember(memberId)).isSameAs(member)
    }

    @Test
    fun `제한 없는 회원만 getUnrestrictedMember를 통과한다`() {
        val member = member(MemberRole.ROLE_RECOGNIZED)
        `when`(memberRepository.findByIdAndDeletedAtIsNull(memberId)).thenReturn(member)

        assertThat(reader.getUnrestrictedMember(memberId)).isSameAs(member)
    }

    @Test
    fun `제재 회원은 getUnrestrictedMember에서 거절한다`() {
        `when`(memberRepository.findByIdAndDeletedAtIsNull(memberId)).thenReturn(member(MemberRole.ROLE_WARNING))

        assertThatThrownBy { reader.getUnrestrictedMember(memberId) }.isBusiness(MemberExceptionCode.MEMBER_RESTRICTED)
    }

    @Test
    fun `getUnrestrictedMember도 없는 회원은 찾을 수 없다`() {
        `when`(memberRepository.findByIdAndDeletedAtIsNull(memberId)).thenReturn(null)

        assertThatThrownBy { reader.getUnrestrictedMember(memberId) }.isBusiness(MemberExceptionCode.MEMBER_NOT_FOUND)
    }
}
