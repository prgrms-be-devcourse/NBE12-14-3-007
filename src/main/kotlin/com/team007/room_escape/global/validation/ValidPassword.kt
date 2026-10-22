package com.team007.room_escape.global.validation

import jakarta.validation.Constraint
import jakarta.validation.Payload
import jakarta.validation.constraints.Pattern
import jakarta.validation.constraints.Size
import kotlin.reflect.KClass

/**
 * 비밀번호 형식 검증.
 * 8~15자, 영문·숫자·특수문자(!@#%^&*)를 모두 포함해야 한다.
 */
@MustBeDocumented
@Target(AnnotationTarget.FIELD, AnnotationTarget.VALUE_PARAMETER)
@Retention(AnnotationRetention.RUNTIME)
@Constraint(validatedBy = [])
@Size(min = 8, max = 25, message = "비밀번호는 8~25자여야 합니다.")
@Pattern(
    regexp = "^(?=.*[A-Za-z])(?=.*\\d)(?=.*[!@#%^&*]).*$",
    message = "비밀번호는 영문, 숫자, 특수문자를 모두 포함해야 합니다."
)
annotation class ValidPassword(

    val message: String = "",

    val groups: Array<KClass<*>> = [],

    val payload: Array<KClass<out Payload>> = []
)
