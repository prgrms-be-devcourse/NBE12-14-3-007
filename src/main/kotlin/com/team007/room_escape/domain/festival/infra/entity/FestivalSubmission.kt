package com.team007.room_escape.domain.festival.infra.entity

import com.team007.room_escape.global.entity.BaseTimeEntity
import jakarta.persistence.Entity
import jakarta.persistence.FetchType
import jakarta.persistence.Id
import jakarta.persistence.JoinColumn
import jakarta.persistence.ManyToOne
import jakarta.persistence.Table
import java.util.UUID
import org.hibernate.annotations.UuidGenerator

@Entity
@Table(name = "festival_submission")
class FestivalSubmission protected constructor() : BaseTimeEntity() {
    @field:Id
    @field:UuidGenerator(style = UuidGenerator.Style.VERSION_7)
    var id: UUID? = null
        protected set

    @field:ManyToOne(fetch = FetchType.LAZY, optional = false)
    @field:JoinColumn(name = "festival_id", nullable = false)
    var festival: Festival? = null
        protected set


    companion object {
        @Deprecated("Kotlin에서는 create()를 사용하세요. Java 호출 호환용입니다.")
        @JvmStatic
        fun builder(): FestivalSubmissionBuilder = FestivalSubmissionBuilder()

        fun create(
            id: UUID? = null,
            festival: Festival? = null
        ): FestivalSubmission = FestivalSubmission().also {
            it.id = id
            it.festival = festival
        }
    }

    class FestivalSubmissionBuilder {
        private var id: UUID? = null
        private var festival: Festival? = null

        fun id(id: UUID?): FestivalSubmissionBuilder = apply { this.id = id }
        fun festival(festival: Festival?): FestivalSubmissionBuilder = apply { this.festival = festival }

        fun build(): FestivalSubmission = FestivalSubmission().also {
            it.id = id
            it.festival = festival
        }
    }
}
