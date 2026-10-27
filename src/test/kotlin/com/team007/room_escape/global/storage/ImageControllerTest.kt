package com.team007.room_escape.global.storage

import com.team007.room_escape.domain.member.infra.entity.Member
import com.team007.room_escape.domain.member.infra.entity.MemberRole
import com.team007.room_escape.domain.member.infra.repository.MemberRepository
import com.team007.room_escape.domain.member.service.MemberReader
import com.team007.room_escape.global.exception.BusinessException
import com.team007.room_escape.global.response.code.MemberExceptionCode
import com.team007.room_escape.global.config.R2Properties
import com.team007.room_escape.global.security.CustomUserDetails
import org.assertj.core.api.Assertions.assertThat
import org.assertj.core.api.Assertions.assertThatThrownBy
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.junit.jupiter.params.ParameterizedTest
import org.junit.jupiter.params.provider.CsvSource
import org.mockito.Mockito.mock
import org.mockito.Mockito.verify
import org.mockito.Mockito.verifyNoInteractions
import org.mockito.Mockito.`when`
import org.springframework.mock.web.MockMultipartFile
import java.util.UUID

class ImageControllerTest {

    private val storage = mock(R2StorageService::class.java)
    private val resolver = ImageUrlResolver(R2Properties("account", "access", "secret", "bucket", "https://img.example.com"))
    private val members = mock(MemberRepository::class.java)
    private val controller = ImageController(storage, resolver, MemberReader(members))

    private val me = UUID.randomUUID()
    private val principal = CustomUserDetails(me, "닉네임", "ROLE_UNVERIFIED", null, null)
    private val file = MockMultipartFile("file", "a.png", "image/png", byteArrayOf(1))

    @BeforeEach
    fun setUp() {
        `when`(members.findByIdAndDeletedAtIsNull(me)).thenReturn(
            Member(email = "member@test.com", password = "pw", role = MemberRole.ROLE_UNVERIFIED,
                nickname = "닉네임", id = me)
        )
    }

    @Test
    fun `토큰은 일반 회원이어도 DB에서 제재된 회원이면 업로드하지 않는다`() {
        `when`(members.findByIdAndDeletedAtIsNull(me)).thenReturn(
            Member(email = "member@test.com", password = "pw", role = MemberRole.ROLE_WARNING,
                nickname = "닉네임", id = me)
        )

        assertThatThrownBy { controller.upload(principal, ImageController.ImageType.POST, file) }
            .isInstanceOfSatisfying(BusinessException::class.java) {
                assertThat(it.exceptionCode).isEqualTo(MemberExceptionCode.MEMBER_RESTRICTED)
            }
        verifyNoInteractions(storage)
    }

    @Test
    fun `유효한 토큰이 있어도 DB에서 탈퇴한 회원이면 업로드하지 않는다`() {
        `when`(members.findByIdAndDeletedAtIsNull(me)).thenReturn(null)

        assertThatThrownBy { controller.upload(principal, ImageController.ImageType.POST, file) }
            .isInstanceOfSatisfying(BusinessException::class.java) {
                assertThat(it.exceptionCode).isEqualTo(MemberExceptionCode.MEMBER_NOT_FOUND)
            }
        verifyNoInteractions(storage)
    }

    @Test
    fun `업로드하면 저장 key와 공개 URL을 함께 돌려준다`() {
        `when`(storage.upload(file, "posts", me)).thenReturn("posts/$me/a.png")

        val response = controller.upload(principal, ImageController.ImageType.POST, file)

        assertThat(response.statusCode.value()).isEqualTo(200)
        assertThat(response.body?.success).isTrue()
        assertThat(response.body?.data).isEqualTo(
            ImageController.UploadInfo("posts/$me/a.png", "https://img.example.com/posts/$me/a.png")
        )
    }

    @ParameterizedTest(name = "{0} -> {1}")
    @CsvSource("POST,posts", "PROFILE,profiles", "INQUIRY,inquiries", "FESTIVAL,festivals")
    fun `이미지 종류마다 정해진 폴더에 올린다`(type: ImageController.ImageType, directory: String) {
        `when`(storage.upload(file, directory, me)).thenReturn("$directory/$me/a.png")

        controller.upload(principal, type, file)

        verify(storage).upload(file, directory, me)
    }
}
