package com.team007.room_escape.domain.member.service

import com.team007.room_escape.domain.member.dto.AdminMemberRequest
import com.team007.room_escape.domain.member.infra.entity.Member
import com.team007.room_escape.domain.member.infra.entity.MemberRole
import com.team007.room_escape.domain.member.infra.repository.MemberRepository
import com.team007.room_escape.global.config.R2Properties
import com.team007.room_escape.global.exception.BusinessException
import com.team007.room_escape.global.response.code.MemberExceptionCode
import com.team007.room_escape.global.storage.ImageUrlResolver
import org.assertj.core.api.Assertions.assertThat
import org.assertj.core.api.Assertions.assertThatThrownBy
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test
import org.mockito.Mockito.mock
import org.mockito.Mockito.`when`
import org.springframework.data.domain.PageImpl
import org.springframework.data.domain.PageRequest
import java.util.Optional
import java.util.UUID

class AdminMemberServiceTest {

    private val memberRepository = mock(MemberRepository::class.java)
    private val imageUrlResolver =
        ImageUrlResolver(R2Properties("account", "access", "secret", "bucket", "https://img.example.com"))
    private val service = AdminMemberService(memberRepository, imageUrlResolver)

    private val actorId = UUID.randomUUID()
    private val targetId = UUID.randomUUID()

    private fun member(
        id: UUID = targetId,
        role: MemberRole = MemberRole.ROLE_UNVERIFIED,
        profileImg: String? = "profiles/a.png",
    ) = Member(email = "user@example.com", password = "pw", role = role, nickname = "닉네임", profileImg = profileImg, id = id)

    private fun givenTarget(member: Member?) =
        `when`(memberRepository.findById(targetId)).thenReturn(Optional.ofNullable(member))

    private fun org.assertj.core.api.AbstractThrowableAssert<*, *>.isBusiness(code: MemberExceptionCode) {
        isInstanceOfSatisfying(BusinessException::class.java) {
            assertThat(it.exceptionCode).isEqualTo(code)
        }
    }

    @Nested
    inner class `조회` {

        @Test
        fun `검색어는 정리해서 넘기고 프로필 이미지는 공개 URL로 바꾼다`() {
            val pageable = PageRequest.of(0, 20)
            `when`(memberRepository.search("autumn", MemberRole.ROLE_WARNING, true, pageable))
                .thenReturn(PageImpl(listOf(member()), pageable, 1))

            val page = service.search(AdminMemberRequest.Search("  AuTumn ", MemberRole.ROLE_WARNING, true), pageable)

            assertThat(page.content.single().profileImg).isEqualTo("https://img.example.com/profiles/a.png")
        }

        @Test
        fun `조건이 비어 있으면 빈 검색어에 삭제 회원 제외로 조회한다`() {
            val pageable = PageRequest.of(0, 20)
            `when`(memberRepository.search("", null, false, pageable)).thenReturn(PageImpl(listOf(member()), pageable, 1))

            val page = service.search(AdminMemberRequest.Search(null, null, null), pageable)

            assertThat(page.totalElements).isEqualTo(1)
        }

        @Test
        fun `단건 조회는 탈퇴 회원도 찾는다`() {
            val withdrawn = member().also { it.delete() }
            givenTarget(withdrawn)

            val info = service.get(targetId)

            assertThat(info.id).isEqualTo(targetId)
            assertThat(info.deletedAt).isNotNull()
        }

        @Test
        fun `없는 회원은 찾을 수 없다`() {
            givenTarget(null)

            assertThatThrownBy { service.get(targetId) }.isBusiness(MemberExceptionCode.MEMBER_NOT_FOUND)
        }
    }

    @Nested
    inner class `등급 변경` {

        private fun change(role: MemberRole?, actor: UUID = actorId) =
            service.changeRole(actor, targetId, AdminMemberRequest.ChangeRole(role))

        @Test
        fun `관리자가 아닌 회원의 등급을 바꾼다`() {
            val target = member()
            givenTarget(target)

            val info = change(MemberRole.ROLE_TRUSTED)

            assertThat(target.role).isEqualTo(MemberRole.ROLE_TRUSTED)
            assertThat(info.role).isEqualTo(MemberRole.ROLE_TRUSTED)
        }

        @Test
        fun `자기 자신의 등급은 바꿀 수 없다`() {
            givenTarget(member())

            assertThatThrownBy { change(MemberRole.ROLE_TRUSTED, actor = targetId) }
                .isBusiness(MemberExceptionCode.MEMBER_ROLE_SELF_CHANGE_DENIED)
        }

        @Test
        fun `관리자 권한은 부여할 수 없다`() {
            val target = member()
            givenTarget(target)

            assertThatThrownBy { change(MemberRole.ROLE_ADMIN) }.isBusiness(MemberExceptionCode.MEMBER_ROLE_ADMIN_GRANT_DENIED)
            assertThat(target.role).isEqualTo(MemberRole.ROLE_UNVERIFIED)
        }

        @Test
        fun `관리자의 등급은 바꿀 수 없다`() {
            val admin = member(role = MemberRole.ROLE_ADMIN)
            givenTarget(admin)

            assertThatThrownBy { change(MemberRole.ROLE_WARNING) }.isBusiness(MemberExceptionCode.MEMBER_ROLE_ADMIN_PROTECTED)
            assertThat(admin.role).isEqualTo(MemberRole.ROLE_ADMIN)
        }

        @Test
        fun `탈퇴한 회원의 등급은 바꿀 수 없다`() {
            givenTarget(member().also { it.delete() })

            assertThatThrownBy { change(MemberRole.ROLE_TRUSTED) }.isBusiness(MemberExceptionCode.MEMBER_ALREADY_DELETED)
        }

        @Test
        fun `없는 회원의 등급은 바꿀 수 없다`() {
            givenTarget(null)

            assertThatThrownBy { change(MemberRole.ROLE_TRUSTED) }.isBusiness(MemberExceptionCode.MEMBER_NOT_FOUND)
        }
    }
}
