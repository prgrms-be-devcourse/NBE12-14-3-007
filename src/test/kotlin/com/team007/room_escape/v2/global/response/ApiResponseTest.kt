package com.team007.room_escape.v2.global.response

import com.team007.room_escape.global.response.ApiResponse
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test
import tools.jackson.databind.json.JsonMapper

class ApiResponseTest {

    private val mapper = JsonMapper.builder().build()

    @Test
    fun `성공 응답은 기본 코드 0000과 빈 메시지로 데이터를 담는다`() {
        val response = ApiResponse.success("데이터")

        assertThat(response.success).isTrue()
        assertThat(response.code).isEqualTo("0000")
        assertThat(response.message).isEmpty()
        assertThat(response.data).isEqualTo("데이터")
    }

    @Test
    fun `성공 응답에 메시지를 줄 수 있다`() {
        val response = ApiResponse.success(42, "처리했습니다.")

        assertThat(response.success).isTrue()
        assertThat(response.code).isEqualTo("0000")
        assertThat(response.message).isEqualTo("처리했습니다.")
        assertThat(response.data).isEqualTo(42)
    }

    @Test
    fun `돌려줄 데이터가 없는 성공 응답은 data가 null이다`() {
        val response = ApiResponse.noContentSuccess()

        assertThat(response.success).isTrue()
        assertThat(response.code).isEqualTo("0000")
        assertThat(response.message).isEmpty()
        assertThat(response.data).isNull()
    }

    @Test
    fun `돌려줄 데이터가 없는 성공 응답에도 메시지를 줄 수 있다`() {
        val response = ApiResponse.noContentSuccess("삭제했습니다.")

        assertThat(response.success).isTrue()
        assertThat(response.message).isEqualTo("삭제했습니다.")
        assertThat(response.data).isNull()
    }

    @Test
    fun `실패 응답은 success가 false이고 코드와 메시지를 담는다`() {
        val response = ApiResponse.error("찾을 수 없습니다.", "MEMBER000")

        assertThat(response.success).isFalse()
        assertThat(response.code).isEqualTo("MEMBER000")
        assertThat(response.message).isEqualTo("찾을 수 없습니다.")
        assertThat(response.data).isNull()
    }

    @Test
    fun `실패 응답에 상세 데이터를 함께 줄 수 있다`() {
        val response = ApiResponse.error("잘못된 입력", "COMMON_INVALID_INPUT", listOf("title"))

        assertThat(response.success).isFalse()
        assertThat(response.data).containsExactly("title")
    }

    @Test
    fun `JSON에는 success, code, message, data 네 개 필드만 나간다`() {
        val json = mapper.readTree(mapper.writeValueAsString(ApiResponse.success("값")))

        assertThat(json.propertyNames().toList())
            .containsExactlyInAnyOrder("success", "code", "message", "data")
        assertThat(json.path("success").asBoolean()).isTrue()
        assertThat(json.path("code").asString()).isEqualTo("0000")
        assertThat(json.path("data").asString()).isEqualTo("값")
    }

    @Test
    fun `데이터가 없어도 data 필드는 null로 내려간다`() {
        val json = mapper.readTree(mapper.writeValueAsString(ApiResponse.error("오류", "E1")))

        assertThat(json.has("data")).isTrue()
        assertThat(json.path("data").isNull).isTrue()
    }
}
