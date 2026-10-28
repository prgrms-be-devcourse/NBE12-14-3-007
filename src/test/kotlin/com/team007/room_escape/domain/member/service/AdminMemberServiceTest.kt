package com.team007.room_escape.domain.member.service

import com.team007.room_escape.domain.member.dto.AdminMemberRequest
import com.team007.room_escape.domain.member.infra.entity.Member
import com.team007.room_escape.domain.member.infra.entity.MemberRole
import com.team007.room_escape.domain.member.infra.entity.MemberRoleHistory
import com.team007.room_escape.domain.member.infra.repository.MemberRepository
import com.team007.room_escape.domain.member.infra.repository.MemberRoleHistoryRepository
import com.team007.room_escape.support.capture
import org.mockito.ArgumentCaptor
import org.mockito.Mockito.verify
import org.mockito.Mockito.verifyNoInteractions
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
    private val roleHistories = mock(MemberRoleHistoryRepository::class.java)
    private val imageUrlResolver =
        ImageUrlResolver(R2Properties("account", "access", "secret", "bucket", "https://img.example.com"))
    private val service = AdminMemberService(memberRepository, roleHistories, imageUrlResolver)

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

        private fun change(role: MemberRole?, actor: UUID = actorId, reason: String? = null) =
            service.changeRole(actor, targetId, AdminMemberRequest.ChangeRole(role, reason))

        private fun savedHistory(): MemberRoleHistory {
            val captor = ArgumentCaptor.forClass(MemberRoleHistory::class.java)
            verify(roleHistories).save(capture(captor, MemberRoleHistory(targetId, actorId, MemberRole.ROLE_UNVERIFIED, MemberRole.ROLE_UNVERIFIED, null)))
            return captor.value
        }

        @Test
        fun `바꾼 등급은 고정되어 자정 집계가 덮어쓰지 못한다`() {
            val target = member()
            givenTarget(target)
            assertThat(target.roleLocked).isFalse()

            val info = change(MemberRole.ROLE_TRUSTED)

            assertThat(target.roleLocked).isTrue()
            assertThat(info.roleLocked).isTrue()
        }

        @Test
        fun `누가 어떤 등급에서 어떤 등급으로 바꿨는지 이력에 남긴다`() {
            givenTarget(member(role = MemberRole.ROLE_RECOGNIZED))

            change(MemberRole.ROLE_TRUSTED, reason = "행사 제보 품질이 좋음")

            val history = savedHistory()
            assertThat(history.memberId).isEqualTo(targetId)
            assertThat(history.actorId).isEqualTo(actorId)
            assertThat(history.oldRole).isEqualTo(MemberRole.ROLE_RECOGNIZED)
            assertThat(history.newRole).isEqualTo(MemberRole.ROLE_TRUSTED)
            assertThat(history.reason).isEqualTo("행사 제보 품질이 좋음")
        }

        @Test
        fun `제재로 바꿀 때는 사유가 필수라서 없으면 거절하고 아무것도 바꾸지 않는다`() {
            val target = member()
            givenTarget(target)

            listOf(null, "", "   ", "\t\n").forEach { reason ->
                assertThatThrownBy { change(MemberRole.ROLE_WARNING, reason = reason) }
                    .isBusiness(MemberExceptionCode.MEMBER_ROLE_REASON_REQUIRED)
            }

            assertThat(target.role).isEqualTo(MemberRole.ROLE_UNVERIFIED)
            assertThat(target.roleLocked).isFalse()
            verifyNoInteractions(roleHistories)
        }

        @Test
        fun `제재 사유가 있으면 앞뒤 공백을 지워 저장한다`() {
            val target = member()
            givenTarget(target)

            change(MemberRole.ROLE_WARNING, reason = "  허위 행사 제보 반복  ")

            assertThat(target.role).isEqualTo(MemberRole.ROLE_WARNING)
            assertThat(savedHistory().reason).isEqualTo("허위 행사 제보 반복")
        }

        @Test
        fun `제재가 아닌 변경은 사유가 없어도 되고 빈 사유는 비워서 저장한다`() {
            givenTarget(member())

            change(MemberRole.ROLE_RECOGNIZED, reason = "   ")

            assertThat(savedHistory().reason).isNull()
        }

        @Test
        fun `거절된 변경은 이력을 남기지 않고 고정도 하지 않는다`() {
            val target = member()
            givenTarget(target)

            assertThatThrownBy { change(MemberRole.ROLE_ADMIN) }.isInstanceOf(BusinessException::class.java)
            assertThatThrownBy { change(MemberRole.ROLE_TRUSTED, actor = targetId) }.isInstanceOf(BusinessException::class.java)

            assertThat(target.roleLocked).isFalse()
            verifyNoInteractions(roleHistories)
        }

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

    @Nested
    inner class `등급 변경 이력` {

        @Test
        fun `바꾼 관리자의 닉네임과 함께 돌려준다`() {
            val pageable = PageRequest.of(0, 20)
            givenTarget(member())
            val history = MemberRoleHistory(targetId, actorId, MemberRole.ROLE_UNVERIFIED, MemberRole.ROLE_WARNING, "도배")
            `when`(roleHistories.findByMemberId(targetId, pageable)).thenReturn(PageImpl(listOf(history), pageable, 1))
            `when`(memberRepository.findAllById(setOf(actorId))).thenReturn(
                listOf(Member(email = "admin@example.com", password = "pw", role = MemberRole.ROLE_ADMIN, nickname = "운영자", id = actorId)),
            )

            val item = service.roleHistory(targetId, pageable).content.single()

            assertThat(item.oldRole).isEqualTo(MemberRole.ROLE_UNVERIFIED)
            assertThat(item.newRole).isEqualTo(MemberRole.ROLE_WARNING)
            assertThat(item.reason).isEqualTo("도배")
            assertThat(item.actorNickname).isEqualTo("운영자")
        }

        @Test
        fun `바꾼 관리자를 찾을 수 없으면 닉네임은 비워 둔다`() {
            val pageable = PageRequest.of(0, 20)
            givenTarget(member())
            val history = MemberRoleHistory(targetId, actorId, MemberRole.ROLE_UNVERIFIED, MemberRole.ROLE_TRUSTED, null)
            `when`(roleHistories.findByMemberId(targetId, pageable)).thenReturn(PageImpl(listOf(history), pageable, 1))
            `when`(memberRepository.findAllById(setOf(actorId))).thenReturn(emptyList())

            assertThat(service.roleHistory(targetId, pageable).content.single().actorNickname).isNull()
        }

        @Test
        fun `없는 회원의 이력은 조회할 수 없다`() {
            givenTarget(null)

            assertThatThrownBy { service.roleHistory(targetId, PageRequest.of(0, 20)) }
                .isBusiness(MemberExceptionCode.MEMBER_NOT_FOUND)
        }
    }
}
