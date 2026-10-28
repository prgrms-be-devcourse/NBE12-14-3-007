package com.team007.room_escape.domain.member.dto

import com.team007.room_escape.domain.member.infra.entity.Member
import com.team007.room_escape.domain.member.infra.entity.MemberRole
import com.team007.room_escape.global.config.R2Properties
import com.team007.room_escape.global.storage.ImageUrlResolver
import jakarta.validation.Validation
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test
import org.junit.jupiter.params.ParameterizedTest
import org.junit.jupiter.params.provider.ValueSource
import java.util.UUID

class MemberDtoTest {

    private val validator = Validation.buildDefaultValidatorFactory().validator

    // 기본 메시지는 실행 환경의 언어를 따라가서, 언어와 상관없는 메시지 템플릿(또는 직접 쓴 메시지)으로 비교한다.
    private fun violationsOf(target: Any): Set<String> =
        validator.validate(target).map { "${it.propertyPath}: ${it.messageTemplate}" }.toSet()

    private val notBlank = "{jakarta.validation.constraints.NotBlank.message}"
    private val size = "{jakarta.validation.constraints.Size.message}"

    @Nested
    inner class `요청 검증` {

        @Test
        fun `마이페이지 수정은 모두 선택이고 올바른 값이면 위반이 없다`() {
            assertThat(violationsOf(MemberRequest.UpdateMyPage(null, null, null))).isEmpty()
            assertThat(violationsOf(MemberRequest.UpdateMyPage("축제좋아", "01012345678", "profiles/a.png"))).isEmpty()
            assertThat(violationsOf(MemberRequest.UpdateMyPage(null, "", ""))).isEmpty()
        }

        @ParameterizedTest(name = "닉네임 길이 {0}자")
        @ValueSource(ints = [1, 31])
        fun `닉네임은 2자 이상 30자 이하여야 한다`(length: Int) {
            assertThat(violationsOf(MemberRequest.UpdateMyPage("가".repeat(length), null, null)))
                .containsExactly("nickname: $size")
        }

        @Test
        fun `전화번호는 하이픈 없는 휴대폰 번호만 받는다`() {
            assertThat(violationsOf(MemberRequest.UpdateMyPage(null, "010-1234-5678", null)))
                .containsExactly("phone: 휴대폰 번호는 하이픈 없이 숫자만 입력해 주세요.")
        }

        @Test
        fun `프로필 이미지 key는 2048자까지다`() {
            assertThat(violationsOf(MemberRequest.UpdateMyPage(null, null, "a".repeat(2049)))).containsExactly("profileImg: $size")
        }

        @ParameterizedTest(name = "인증 코드 \"{0}\"")
        @ValueSource(strings = ["12345", "1234567", "abcdef", "12 456"])
        fun `인증 코드는 6자리 숫자여야 한다`(code: String) {
            assertThat(violationsOf(MemberRequest.VerifyPassword(code))).containsExactly("code: 인증 코드는 6자리 숫자입니다.")
        }

        @Test
        fun `인증 코드가 올바르거나 비어 있을 때`() {
            assertThat(violationsOf(MemberRequest.VerifyPassword("042913"))).isEmpty()
            assertThat(violationsOf(MemberRequest.VerifyPassword(null))).contains("code: $notBlank")
        }

        @Test
        fun `새 비밀번호는 비밀번호 규칙을 따른다`() {
            assertThat(violationsOf(MemberRequest.ChangePassword("NewPassword1!"))).isEmpty()
            assertThat(violationsOf(MemberRequest.ChangePassword("Password12")))
                .containsExactly("newPassword: 비밀번호는 영문, 숫자, 특수문자를 모두 포함해야 합니다.")
            assertThat(violationsOf(MemberRequest.ChangePassword(null))).contains("newPassword: $notBlank")
        }

        @Test
        fun `탈퇴 비밀번호는 규칙 없이 비어 있지만 않으면 된다`() {
            assertThat(violationsOf(MemberRequest.Withdraw("short"))).isEmpty()
            assertThat(violationsOf(MemberRequest.Withdraw(""))).containsExactly("password: 비밀번호를 입력해 주세요.")
        }

        @Test
        fun `등급 변경은 등급이 있어야 한다`() {
            assertThat(violationsOf(AdminMemberRequest.ChangeRole(MemberRole.ROLE_TRUSTED))).isEmpty()
            assertThat(violationsOf(AdminMemberRequest.ChangeRole(null)))
                .containsExactly("role: {jakarta.validation.constraints.NotNull.message}")
        }

        @Test
        fun `등급 변경 사유는 500자까지다`() {
            assertThat(violationsOf(AdminMemberRequest.ChangeRole(MemberRole.ROLE_WARNING, "가".repeat(500)))).isEmpty()
            assertThat(violationsOf(AdminMemberRequest.ChangeRole(MemberRole.ROLE_WARNING, "가".repeat(501))))
                .containsExactly("reason: $size")
        }
    }

    @Nested
    inner class `관리자 검색 조건` {

        @Test
        fun `검색어는 앞뒤 공백을 지우고 소문자로 바꾼다`() {
            assertThat(AdminMemberRequest.Search("  AuTumn  ", null, null).keywordOrEmpty()).isEqualTo("autumn")
        }

        @Test
        fun `검색어가 없거나 공백뿐이면 빈 문자열이다`() {
            assertThat(AdminMemberRequest.Search(null, null, null).keywordOrEmpty()).isEmpty()
            assertThat(AdminMemberRequest.Search(" \t\n ", null, null).keywordOrEmpty()).isEmpty()
        }

        @Test
        fun `탈퇴 회원 포함 여부는 true일 때만 켜진다`() {
            assertThat(AdminMemberRequest.Search(null, null, true).includeDeletedOrFalse()).isTrue()
            assertThat(AdminMemberRequest.Search(null, null, false).includeDeletedOrFalse()).isFalse()
            assertThat(AdminMemberRequest.Search(null, null, null).includeDeletedOrFalse()).isFalse()
        }
    }

    @Nested
    inner class `응답 변환` {

        private val resolver = ImageUrlResolver(R2Properties("account", "access", "secret", "bucket", "https://img.example.com"))
        private val memberId = UUID.randomUUID()

        private fun member() = Member(
            email = "user@example.com", password = "SECRET", role = MemberRole.ROLE_TRUSTED, nickname = "닉네임",
            profileImg = "profiles/a.png", phone = "01012345678", id = memberId,
        )

        @Test
        fun `작성자 정보는 활동 회원의 닉네임과 등급과 프로필 URL을 담는다`() {
            val info = MemberResponse.MemberInfo.from(member(), resolver)

            assertThat(info.id).isEqualTo(memberId)
            assertThat(info.nickname).isEqualTo("닉네임")
            assertThat(info.role).isEqualTo(MemberRole.ROLE_TRUSTED)
            assertThat(info.profileImg).isEqualTo("https://img.example.com/profiles/a.png")
        }

        @Test
        fun `탈퇴한 회원이나 회원이 없는 경우 작성자는 탈퇴한 사용자로만 보인다`() {
            val withdrawn = member().also { it.delete() }

            listOf(MemberResponse.MemberInfo.from(withdrawn, resolver), MemberResponse.MemberInfo.from(null, resolver))
                .forEach { info ->
                    assertThat(info.nickname).isEqualTo("탈퇴한 사용자")
                    assertThat(info.id).isNull()
                    assertThat(info.role).isNull()
                    assertThat(info.profileImg).isNull()
                }
        }

        @Test
        fun `마이페이지 응답에는 비밀번호가 없고 이미지는 넘겨 받은 URL을 쓴다`() {
            val info = MemberResponse.MyPageInfo.from(member(), "https://img.example.com/x.png")

            assertThat(info.email).isEqualTo("user@example.com")
            assertThat(info.phone).isEqualTo("01012345678")
            assertThat(info.profileImg).isEqualTo("https://img.example.com/x.png")
            assertThat(info.toString()).doesNotContain("SECRET")
        }

        @Test
        fun `관리자 응답은 탈퇴 시각까지 담는다`() {
            val withdrawn = member().also { it.delete() }

            assertThat(MemberResponse.AdminInfo.from(withdrawn, null).deletedAt).isNotNull()
            assertThat(MemberResponse.AdminInfo.from(member(), null).deletedAt).isNull()
        }
    }
}
