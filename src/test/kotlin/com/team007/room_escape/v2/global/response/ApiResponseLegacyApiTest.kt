package com.team007.room_escape.v2.global.response

import com.team007.room_escape.global.response.ApiResponse
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test

/**
 * 아직 Java 코드가 부르는 옛 모양이 예전과 똑같은 응답을 만드는지 확인한다.
 * Java 호출부가 모두 사라지면 옛 모양과 이 테스트를 함께 지운다.
 */
@Suppress("DEPRECATION_ERROR")
class ApiResponseLegacyApiTest {

    @Test
    fun `success는 ok와 같은 응답을 만든다`() {
        val old = ApiResponse.success("데이터")

        assertThat(old.success).isTrue()
        assertThat(old.code).isEqualTo("0000")
        assertThat(old.message).isEmpty()
        assertThat(old.data).isEqualTo("데이터")
    }

    @Test
    fun `success에 메시지로 null을 주면 메시지가 null인 응답이 된다`() {
        val old = ApiResponse.success("데이터", null)

        assertThat(old.message).isNull()
        assertThat(old.data).isEqualTo("데이터")
    }

    @Test
    fun `noContentSuccess는 noContent와 같은 응답을 만든다`() {
        val old = ApiResponse.noContentSuccess()

        assertThat(old.success).isTrue()
        assertThat(old.code).isEqualTo("0000")
        assertThat(old.message).isEmpty()
        assertThat(old.data).isNull()
        assertThat(ApiResponse.noContentSuccess("삭제했습니다.").message).isEqualTo("삭제했습니다.")
    }

    @Test
    fun `error는 코드와 메시지를 그대로 담고 null도 허용한다`() {
        val old = ApiResponse.error("찾을 수 없습니다.", "MEMBER000")

        assertThat(old.success).isFalse()
        assertThat(old.code).isEqualTo("MEMBER000")
        assertThat(old.message).isEqualTo("찾을 수 없습니다.")
        assertThat(old.data).isNull()
        assertThat(ApiResponse.error(null, null).code).isNull()
    }

    @Test
    fun `error에 상세 데이터를 함께 줄 수 있다`() {
        val old = ApiResponse.error("잘못된 입력", "COMMON_INVALID_INPUT", listOf("title"))

        assertThat(old.success).isFalse()
        assertThat(old.data).containsExactly("title")
    }
}
