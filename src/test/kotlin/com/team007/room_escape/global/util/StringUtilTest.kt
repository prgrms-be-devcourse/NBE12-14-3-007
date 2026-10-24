package com.team007.room_escape.global.util

import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test
import org.junit.jupiter.params.ParameterizedTest
import org.junit.jupiter.params.provider.NullSource
import org.junit.jupiter.params.provider.ValueSource

class StringUtilTest {

    @ParameterizedTest(name = "[{index}] \"{0}\"")
    @NullSource
    @ValueSource(strings = ["", " ", "   ", "\t", "\n", " \t\n "])
    fun `null이거나 공백뿐이면 null로 모은다`(value: String?) {
        assertThat(StringUtil.emptyToNull(value)).isNull()
    }

    @ParameterizedTest(name = "[{index}] \"{0}\"")
    @ValueSource(strings = ["a", " a ", "값", "a b"])
    fun `글자가 하나라도 있으면 앞뒤 공백까지 그대로 돌려준다`(value: String) {
        assertThat(StringUtil.emptyToNull(value)).isSameAs(value)
    }

    /**
     * Java String.isBlank()는 줄바꿈 없는 공백(NBSP)을 공백으로 보지 않는다.
     * Kotlin isBlank()로 바꾸면 이 동작이 달라지므로, 바꿀 때는 의도한 변경인지 확인하라는 표시다.
     */
    @Test
    fun `줄바꿈 없는 공백(NBSP)만 있는 값은 공백으로 보지 않는다`() {
        val nbsp = " "

        assertThat(StringUtil.emptyToNull(nbsp)).isEqualTo(nbsp)
    }
}
