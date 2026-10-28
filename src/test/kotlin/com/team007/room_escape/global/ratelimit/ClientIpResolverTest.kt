package com.team007.room_escape.global.ratelimit

import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test
import org.springframework.mock.web.MockHttpServletRequest

class ClientIpResolverTest {

    private fun request(remoteAddr: String = "10.0.0.9", vararg forwardedFor: String) =
        MockHttpServletRequest().apply {
            this.remoteAddr = remoteAddr
            forwardedFor.forEach { addHeader("X-Forwarded-For", it) }
        }

    private fun resolver(mode: ClientIpMode, hops: Int = 1) = ClientIpResolver(ClientIpProperties(mode, hops))

    @Test
    fun `NONE이면 IP를 쓰지 않는다`() {
        assertThat(resolver(ClientIpMode.NONE).resolve(request("203.0.113.5"))).isNull()
    }

    @Test
    fun `REMOTE_ADDR이면 연결된 상대의 IP를 쓰고 헤더는 무시한다`() {
        val ip = resolver(ClientIpMode.REMOTE_ADDR).resolve(request("203.0.113.5", "1.2.3.4"))

        assertThat(ip).isEqualTo("203.0.113.5")
    }

    @Nested
    inner class `X-Forwarded-For` {

        @Test
        fun `오른쪽에서 프록시 수만큼 센 주소가 사용자 IP다`() {
            val chain = request(forwardedFor = arrayOf("198.51.100.7, 203.0.113.20"))

            assertThat(resolver(ClientIpMode.FORWARDED_FOR, hops = 1).resolve(chain)).isEqualTo("203.0.113.20")
            assertThat(resolver(ClientIpMode.FORWARDED_FOR, hops = 2).resolve(chain)).isEqualTo("198.51.100.7")
        }

        @Test
        fun `사용자가 왼쪽에 위조해서 붙인 주소는 쓰지 않는다`() {
            val spoofed = request(forwardedFor = arrayOf("6.6.6.6, 198.51.100.7, 203.0.113.20"))

            assertThat(resolver(ClientIpMode.FORWARDED_FOR, hops = 2).resolve(spoofed)).isEqualTo("198.51.100.7")
        }

        @Test
        fun `헤더가 여러 줄로 나뉘어 와도 하나로 이어서 센다`() {
            val split = request(forwardedFor = arrayOf("198.51.100.7", "203.0.113.20"))

            assertThat(resolver(ClientIpMode.FORWARDED_FOR, hops = 2).resolve(split)).isEqualTo("198.51.100.7")
        }

        @Test
        fun `헤더가 없거나 프록시 수보다 짧으면 null이다`() {
            assertThat(resolver(ClientIpMode.FORWARDED_FOR, hops = 1).resolve(request())).isNull()
            assertThat(
                resolver(ClientIpMode.FORWARDED_FOR, hops = 3).resolve(request(forwardedFor = arrayOf("198.51.100.7")))
            ).isNull()
        }

        @Test
        fun `IP 모양이 아닌 값은 쓰지 않는다`() {
            val garbage = request(forwardedFor = arrayOf("<script>alert(1)</script>"))

            assertThat(resolver(ClientIpMode.FORWARDED_FOR).resolve(garbage)).isNull()
        }

        @Test
        fun `IPv6 주소도 받는다`() {
            val v6 = request(forwardedFor = arrayOf("2001:db8::1"))

            assertThat(resolver(ClientIpMode.FORWARDED_FOR).resolve(v6)).isEqualTo("2001:db8::1")
        }

        @Test
        fun `프록시 수가 0 이하면 믿지 않는다`() {
            val chain = request(forwardedFor = arrayOf("198.51.100.7"))

            assertThat(resolver(ClientIpMode.FORWARDED_FOR, hops = 0).resolve(chain)).isNull()
        }
    }
}
