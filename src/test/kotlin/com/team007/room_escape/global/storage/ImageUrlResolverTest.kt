package com.team007.room_escape.global.storage

import com.team007.room_escape.global.config.R2Properties
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test

class ImageUrlResolverTest {

    private val publicUrl = "https://img.example.com"

    private val resolver = ImageUrlResolver(R2Properties("account", "access", "secret", "bucket", publicUrl))

    @Nested
    inner class `key를 공개 URL로 바꾼다` {

        @Test
        fun `key는 공개 URL 뒤에 붙인다`() {
            assertThat(resolver.resolve("posts/member/a.png")).isEqualTo("$publicUrl/posts/member/a.png")
        }

        @Test
        fun `이미 URL로 저장된 값은 그대로 돌려준다`() {
            assertThat(resolver.resolve("https://other.com/a.png")).isEqualTo("https://other.com/a.png")
            assertThat(resolver.resolve("http://other.com/a.png")).isEqualTo("http://other.com/a.png")
        }

        @Test
        fun `비었거나 공백뿐이면 null이다`() {
            assertThat(resolver.resolve(null)).isNull()
            assertThat(resolver.resolve("")).isNull()
            assertThat(resolver.resolve(" ")).isNull()
        }

        @Test
        fun `공개 URL이 슬래시로 끝나도 슬래시가 겹치지 않는다`() {
            val withSlash = ImageUrlResolver(R2Properties("account", "access", "secret", "bucket", "$publicUrl/"))

            assertThat(withSlash.resolve("posts/a.png")).isEqualTo("$publicUrl/posts/a.png")
        }
    }

    @Nested
    inner class `공개 URL을 key로 되돌린다` {

        @Test
        fun `우리 공개 URL은 앞부분을 떼서 key로 돌려준다`() {
            assertThat(resolver.toKey("$publicUrl/posts/member/a.png")).isEqualTo("posts/member/a.png")
        }

        @Test
        fun `이미 key인 값과 남의 URL은 건드리지 않는다`() {
            assertThat(resolver.toKey("posts/member/a.png")).isEqualTo("posts/member/a.png")
            assertThat(resolver.toKey("https://other.com/a.png")).isEqualTo("https://other.com/a.png")
        }

        @Test
        fun `null과 공백은 받은 그대로 돌려준다`() {
            assertThat(resolver.toKey(null)).isNull()
            assertThat(resolver.toKey("")).isEmpty()
            assertThat(resolver.toKey(" ")).isEqualTo(" ")
        }
    }
}
