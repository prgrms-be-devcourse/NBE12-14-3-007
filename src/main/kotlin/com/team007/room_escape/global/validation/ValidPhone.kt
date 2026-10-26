package com.team007.room_escape.global.validation

import jakarta.validation.Constraint
import jakarta.validation.Payload
import jakarta.validation.constraints.Pattern
import kotlin.reflect.KClass

/** 휴대폰 번호 형식 검증. 숫자만 받고(하이픈은 프론트가 표시), 빈 문자열은 "번호 지우기"라 허용한다. */
@MustBeDocumented
@Target(AnnotationTarget.FIELD, AnnotationTarget.VALUE_PARAMETER)
@Retention(AnnotationRetention.RUNTIME)
@Constraint(validatedBy = [])
@Pattern(
    regexp = "^$|^01[016789]\\d{7,8}$",
    message = "휴대폰 번호는 하이픈 없이 숫자만 입력해 주세요.",
)
annotation class ValidPhone(

    val message: String = "",

    val groups: Array<KClass<*>> = [],

    val payload: Array<KClass<out Payload>> = [],
)
