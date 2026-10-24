package com.team007.room_escape.v2.global.util

import com.team007.room_escape.global.config.R2Properties
import com.team007.room_escape.global.util.RichTextSanitizer
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test

class RichTextSanitizerTest {

    private val publicUrl = "https://img.example.com"

    private val sanitizer = RichTextSanitizer(R2Properties("account", "access", "secret", "bucket", publicUrl))

    @Test
    fun `허용한 서식은 유지한다`() {
        val content = "<h2>행사 후기</h2><p><strong>즐거웠어요.</strong></p><ul><li>준비물</li></ul>"

        assertThat(sanitizer.sanitize(content)).isEqualTo(content)
    }

    @Test
    fun `스크립트와 이벤트 속성은 제거한다`() {
        val content = """<p onclick="alert(1)">안전한 내용</p><script>alert(2)</script>"""

        assertThat(sanitizer.sanitize(content)).isEqualTo("<p>안전한 내용</p>")
    }

    @Test
    fun `자바스크립트 링크는 제거한다`() {
        val content = """<p><a href="javascript:alert(1)">위험한 링크</a></p>"""

        assertThat(sanitizer.sanitize(content))
            .doesNotContain("javascript:")
            .contains("위험한 링크")
    }

    @Test
    fun `R2에 올린 본문 이미지는 유지한다`() {
        val content = """<p>현장 사진</p><img src="$publicUrl/post/a.webp" alt="무대" />"""

        assertThat(sanitizer.sanitize(content))
            .contains("""<img src="$publicUrl/post/a.webp" alt="무대" />""")
    }

    @Test
    fun `외부 주소의 이미지는 제거한다`() {
        val content = """<p>현장 사진</p><img src="https://evil.example.com/track.gif" />""" +
            """<img src="$publicUrl.evil.com/a.webp" />"""

        assertThat(sanitizer.sanitize(content)).isEqualTo("<p>현장 사진</p>")
    }

    @Test
    fun `공개 주소가 슬래시로 끝나도 같은 이미지를 허용한다`() {
        val withSlash = RichTextSanitizer(R2Properties("account", "access", "secret", "bucket", "$publicUrl/"))
        val content = """<img src="$publicUrl/post/a.webp" />"""

        assertThat(withSlash.sanitize(content)).contains("$publicUrl/post/a.webp")
    }

    @Test
    fun `링크에는 nofollow를 붙인다`() {
        val content = """<p><a href="https://example.com">링크</a></p>"""

        assertThat(sanitizer.sanitize(content)).contains("""rel="nofollow"""")
    }

    @Test
    fun `태그만 남은 본문은 내용이 없는 것으로 판단한다`() {
        assertThat(sanitizer.hasVisibleText("<p><br></p>")).isFalse()
        assertThat(sanitizer.hasVisibleText("<h2>소제목</h2>")).isTrue()
    }

    @Test
    fun `공백 엔티티만 있는 본문도 내용이 없는 것으로 판단한다`() {
        assertThat(sanitizer.hasVisibleText("<p>&nbsp;</p>")).isFalse()
        assertThat(sanitizer.hasVisibleText("<p>&#160;</p>")).isFalse()
    }

    @Test
    fun `null은 그대로 null이고 내용도 없는 것으로 본다`() {
        assertThat(sanitizer.sanitize(null)).isNull()
        assertThat(sanitizer.hasVisibleText(null)).isFalse()
    }
}
