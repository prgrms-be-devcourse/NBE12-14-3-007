package com.team007.room_escape.global.response

import com.team007.room_escape.global.response.code.CommonExceptionCode
import com.team007.room_escape.global.response.code.MemberExceptionCode
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test
import tools.jackson.databind.json.JsonMapper

class ApiResponseTest {

    private val mapper = JsonMapper.builder().build()

    @Test
    fun `성공 응답은 기본 코드 0000과 빈 메시지로 데이터를 담는다`() {
        val response = ApiResponse.ok("데이터")

        assertThat(response.success).isTrue()
        assertThat(response.code).isEqualTo("0000")
        assertThat(response.message).isEmpty()
        assertThat(response.data).isEqualTo("데이터")
    }

    @Test
    fun `성공 응답에 메시지를 줄 수 있다`() {
        val response = ApiResponse.ok(42, "처리했습니다.")

        assertThat(response.success).isTrue()
        assertThat(response.code).isEqualTo("0000")
        assertThat(response.message).isEqualTo("처리했습니다.")
        assertThat(response.data).isEqualTo(42)
    }

    @Test
    fun `돌려줄 데이터가 없는 성공 응답은 data가 null이다`() {
        val response = ApiResponse.noContent()

        assertThat(response.success).isTrue()
        assertThat(response.code).isEqualTo("0000")
        assertThat(response.message).isEmpty()
        assertThat(response.data).isNull()
    }

    @Test
    fun `돌려줄 데이터가 없는 성공 응답에도 메시지를 줄 수 있다`() {
        val response = ApiResponse.noContent("삭제했습니다.")

        assertThat(response.success).isTrue()
        assertThat(response.message).isEqualTo("삭제했습니다.")
        assertThat(response.data).isNull()
    }

    @Test
    fun `실패 응답은 에러 코드의 코드와 기본 메시지를 담는다`() {
        val response = ApiResponse.fail(MemberExceptionCode.MEMBER_NOT_FOUND)

        assertThat(response.success).isFalse()
        assertThat(response.code).isEqualTo("MEMBER000")
        assertThat(response.message).isEqualTo("회원을 찾을 수 없습니다.")
        assertThat(response.data).isNull()
    }

    @Test
    fun `실패 응답의 메시지는 따로 줄 수 있고 코드는 그대로다`() {
        val response = ApiResponse.fail(CommonExceptionCode.INVALID_INPUT, "title: 필수입니다.")

        assertThat(response.success).isFalse()
        assertThat(response.code).isEqualTo("COMMON_INVALID_INPUT")
        assertThat(response.message).isEqualTo("title: 필수입니다.")
    }

    @Test
    fun `JSON에는 success, code, message, data 네 개 필드만 나간다`() {
        val json = mapper.readTree(mapper.writeValueAsString(ApiResponse.ok("값")))

        assertThat(json.propertyNames().toList())
            .containsExactlyInAnyOrder("success", "code", "message", "data")
        assertThat(json.path("success").asBoolean()).isTrue()
        assertThat(json.path("code").asString()).isEqualTo("0000")
        assertThat(json.path("data").asString()).isEqualTo("값")
    }

    @Test
    fun `데이터가 없어도 data 필드는 null로 내려간다`() {
        val json = mapper.readTree(mapper.writeValueAsString(ApiResponse.fail(CommonExceptionCode.INTERNAL_ERROR)))

        assertThat(json.has("data")).isTrue()
        assertThat(json.path("data").isNull).isTrue()
    }
}
