package com.team007.room_escape.global.ratelimit

import jakarta.servlet.http.HttpServletRequest
import org.springframework.boot.context.properties.ConfigurationProperties
import org.springframework.stereotype.Component

/** 요청한 사용자의 IP를 어디서 읽을지. */
enum class ClientIpMode {
    /** IP를 쓰지 않는다. 프록시 뒤에서 IP를 믿을 수 있는지 모를 때의 기본값이다. */
    NONE,

    /** 연결된 상대의 IP를 그대로 쓴다. 프록시 없이 직접 접속하는 로컬 개발용이다. */
    REMOTE_ADDR,

    /** X-Forwarded-For 에서 [ClientIpProperties.proxyHops]번째 프록시가 붙인 주소를 쓴다. */
    FORWARDED_FOR,
}

/**
 * client-ip.* 설정.
 *
 * 운영은 프록시(Vercel, Render) 뒤에 있어서 연결된 상대의 IP가 모든 사용자에게 같다.
 * 그 값으로 IP별 제한을 걸면 전체 사용자가 한 묶음으로 막히므로, 사용자 IP를 믿을 수 있을 때만 켠다.
 */
@ConfigurationProperties(prefix = "client-ip")
data class ClientIpProperties(
    val mode: ClientIpMode = ClientIpMode.NONE,
    /** 요청이 거쳐 오는 신뢰할 수 있는 프록시 수. X-Forwarded-For 의 오른쪽 끝에서 이 수만큼 센 주소가 사용자 IP다. */
    val proxyHops: Int = 1,
)

/**
 * IP별 제한에 쓸 사용자 IP를 알아낸다. 믿을 수 없으면 null을 돌려주고, 호출한 쪽은 IP 없이 동작한다.
 *
 * X-Forwarded-For 는 사용자가 마음대로 써서 보낼 수 있다. 왼쪽 값은 위조될 수 있으므로 쓰지 않고,
 * 우리 쪽 프록시가 오른쪽에 덧붙인 값만 본다.
 */
@Component
class ClientIpResolver(
    private val properties: ClientIpProperties,
) {

    fun resolve(request: HttpServletRequest): String? = when (properties.mode) {
        ClientIpMode.NONE -> null
        ClientIpMode.REMOTE_ADDR -> request.remoteAddr?.takeIf { it.isNotBlank() }
        ClientIpMode.FORWARDED_FOR -> forwardedFor(request)
    }

    private fun forwardedFor(request: HttpServletRequest): String? {
        val hops = properties.proxyHops
        if (hops < 1) return null

        val addresses = request.getHeaders(FORWARDED_FOR).toList()
            .flatMap { it.split(",") }
            .map { it.trim() }
            .filter { it.isNotEmpty() }
        if (addresses.size < hops) return null

        return addresses[addresses.size - hops].takeIf { LOOKS_LIKE_IP.matches(it) }
    }

    private companion object {
        const val FORWARDED_FOR = "X-Forwarded-For"

        /** IPv4 또는 IPv6 글자만 허용한다. key에 이상한 문자열이 들어가는 것을 막는다. */
        val LOOKS_LIKE_IP = Regex("^[0-9a-fA-F:.]{2,45}$")
    }
}
