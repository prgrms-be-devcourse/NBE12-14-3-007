package com.team007.room_escape.global.util

import com.team007.room_escape.global.config.R2Properties
import org.owasp.html.HtmlPolicyBuilder
import org.owasp.html.PolicyFactory
import org.springframework.stereotype.Component
import java.util.regex.Pattern

/**
 * 사용자가 작성한 글쓰기 에디터 HTML에서 화면 표시에 필요한 태그만 남긴다.
 */
@Component
class RichTextSanitizer
/**
 * 본문 이미지는 우리 R2에 올린 것만 남긴다. 외부 주소를 허용하면 핫링크나 추적 픽셀을 심을 수 있다.
 * src가 허용되지 않은 img는 속성이 하나도 남지 않아 태그째 지워진다.
 */
// TODO 본문에서 빠지거나 글이 삭제된 이미지를 R2에서 지울 기준을 정할 것 (지금은 R2에 계속 남는다)
constructor(r2Properties: R2Properties) {

    private val policy: PolicyFactory

    init {
        val publicUrl = r2Properties.publicUrl()
        val prefix = if (publicUrl.endsWith("/")) publicUrl else "$publicUrl/"
        val r2ImageUrl = Pattern.compile(Pattern.quote(prefix) + "[^\\s\"'<>]+")

        this.policy = HtmlPolicyBuilder()
            .allowElements("p", "h2", "strong", "em", "ul", "ol", "li", "blockquote", "br")
            .allowUrlProtocols("http", "https")
            .allowElements("a")
            .allowAttributes("href").onElements("a")
            .requireRelNofollowOnLinks()
            .allowElements("img")
            .allowAttributes("src").matching(r2ImageUrl).onElements("img")
            .allowAttributes("alt").onElements("img")
            .toFactory()
    }

    fun sanitize(content: String?): String? {
        if (content == null) {
            return null
        }

        // Java String.trim()과 같은 기준(U+0020 이하)으로 자른다. Kotlin trim()은 NBSP 등도 자른다.
        return policy.sanitize(content).trim { it <= ' ' }
    }

    fun hasVisibleText(sanitizedContent: String?): Boolean {
        if (sanitizedContent == null) {
            return false
        }

        val textOnly = sanitizedContent
            .replace(Regex("<[^>]*>"), "")
            .replace("&nbsp;", "")
            .replace("&#160;", "")

        return !textOnly.isBlankLikeJava()
    }
}
