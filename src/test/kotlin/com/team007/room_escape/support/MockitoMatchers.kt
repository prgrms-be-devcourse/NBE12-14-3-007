package com.team007.room_escape.support

import org.mockito.ArgumentCaptor
import org.mockito.ArgumentMatchers
import java.time.LocalDateTime

// Kotlin의 non-null 파라미터에는 Mockito 매처가 돌려주는 null을 넣을 수 없다.
// 아래 함수들은 매처는 그대로 등록하고, 실제로 넘기는 값만 null 대신 자리표시 값으로 바꾼다.

fun <T : Any> anyOf(type: Class<T>, placeholder: T): T = ArgumentMatchers.any(type) ?: placeholder

fun <T : Any> eqOf(value: T): T = ArgumentMatchers.eq(value) ?: value

fun <T : Any> capture(captor: ArgumentCaptor<T>, placeholder: T): T = captor.capture() ?: placeholder

fun anyDateTime(): LocalDateTime = anyOf(LocalDateTime::class.java, LocalDateTime.MIN)

fun anyText(): String = ArgumentMatchers.anyString() ?: ""

fun anyStrings(): Collection<String> = ArgumentMatchers.anyCollection<String>() ?: emptyList()
