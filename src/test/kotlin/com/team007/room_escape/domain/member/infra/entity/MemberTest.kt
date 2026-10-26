package com.team007.room_escape.domain.member.infra.entity

import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test
import org.junit.jupiter.params.ParameterizedTest
import org.junit.jupiter.params.provider.CsvSource
import java.util.UUID

class MemberTest {

    private fun member(
        role: MemberRole = MemberRole.ROLE_UNVERIFIED,
        phone: String? = "01012345678",
        profileImg: String? = "profiles/a.png",
        id: UUID? = UUID.randomUUID(),
    ) = Member(
        email = "user@example.com", password = "ENCODED", role = role, nickname = "기존닉네임",
        profileImg = profileImg, phone = phone, id = id,
    )

    @Nested
    inner class `등급` {

        @Test
        fun `권한 이름은 등급 이름이다`() {
            assertThat(member(MemberRole.ROLE_TRUSTED).authority()).isEqualTo("ROLE_TRUSTED")
        }

        @ParameterizedTest(name = "{0}은 {1}의 권한을 포함하는가: {2}")
        @CsvSource(
            "ROLE_ADMIN,ROLE_TRUSTED,true", "ROLE_TRUSTED,ROLE_RECOGNIZED,true", "ROLE_UNVERIFIED,ROLE_UNVERIFIED,true",
            "ROLE_WARNING,ROLE_UNVERIFIED,false", "ROLE_RECOGNIZED,ROLE_TRUSTED,false",
        )
        fun `상위 등급은 하위 등급의 권한을 포함한다`(actual: MemberRole, required: MemberRole, expected: Boolean) {
            assertThat(member(actual).hasPrivilegeOf(required)).isEqualTo(expected)
        }

        @Test
        fun `제재 등급만 제한 회원이다`() {
            assertThat(member(MemberRole.ROLE_WARNING).isRestricted).isTrue()
            assertThat(member(MemberRole.ROLE_UNVERIFIED).isRestricted).isFalse()
            assertThat(member(MemberRole.ROLE_ADMIN).isRestricted).isFalse()
        }

        @Test
        fun `관리자가 변경한 등급이 반영된다`() {
            val member = member()

            member.changeRole(MemberRole.ROLE_RECOGNIZED)

            assertThat(member.role).isEqualTo(MemberRole.ROLE_RECOGNIZED)
        }
    }

    @Nested
    inner class `프로필 수정` {

        @Test
        fun `값을 준 항목만 바꾸고 null인 항목은 그대로 둔다`() {
            val member = member()

            member.updateProfile("새닉네임", null, null)

            assertThat(member.nickname).isEqualTo("새닉네임")
            assertThat(member.phone).isEqualTo("01012345678")
            assertThat(member.profileImg).isEqualTo("profiles/a.png")
        }

        @Test
        fun `닉네임은 공백뿐이면 바꾸지 않는다`() {
            val member = member()

            member.updateProfile("   ", null, null)

            assertThat(member.nickname).isEqualTo("기존닉네임")
        }

        @Test
        fun `전화번호와 프로필 이미지는 빈 문자열이면 지운다`() {
            val member = member()

            member.updateProfile(null, "", "")

            assertThat(member.phone).isNull()
            assertThat(member.profileImg).isNull()
        }

        @Test
        fun `전화번호와 프로필 이미지는 값을 주면 바꾼다`() {
            val member = member(phone = null, profileImg = null)

            member.updateProfile(null, "01099998888", "profiles/b.png")

            assertThat(member.phone).isEqualTo("01099998888")
            assertThat(member.profileImg).isEqualTo("profiles/b.png")
        }
    }

    @Test
    fun `비밀번호를 바꾼다`() {
        val member = member()

        member.changePassword("NEW-ENCODED")

        assertThat(member.password).isEqualTo("NEW-ENCODED")
    }

    @Test
    fun `생성할 때 준 ID를 쓰고 처음에는 삭제되지 않은 상태다`() {
        val id = UUID.randomUUID()

        val member = member(id = id)

        assertThat(member.id).isEqualTo(id)
        assertThat(member.isDeleted()).isFalse()
    }

    @Test
    fun `탈퇴하면 삭제 시각이 남는다`() {
        val member = member()

        member.delete()

        assertThat(member.isDeleted()).isTrue()
    }

    @Test
    fun `탈퇴 회원 대신 보여줄 이름이 정해져 있다`() {
        assertThat(Member.WITHDRAWN_NICKNAME).isEqualTo("탈퇴한 사용자")
    }
}

class MemberRoleTest {

    @Test
    fun `선언 순서가 곧 권한 계층이다`() {
        assertThat(MemberRole.entries).containsExactly(
            MemberRole.ROLE_WARNING, MemberRole.ROLE_UNVERIFIED, MemberRole.ROLE_RECOGNIZED,
            MemberRole.ROLE_TRUSTED, MemberRole.ROLE_ADMIN,
        )
    }

    @Test
    fun `관리자만 관리자다`() {
        assertThat(MemberRole.entries.filter { it.isAdmin }).containsExactly(MemberRole.ROLE_ADMIN)
    }

    @Test
    fun `자기 자신과 아래 등급의 권한을 포함한다`() {
        assertThat(MemberRole.ROLE_TRUSTED.includes(MemberRole.ROLE_TRUSTED)).isTrue()
        assertThat(MemberRole.ROLE_TRUSTED.includes(MemberRole.ROLE_WARNING)).isTrue()
        assertThat(MemberRole.ROLE_TRUSTED.includes(MemberRole.ROLE_ADMIN)).isFalse()
    }
}
