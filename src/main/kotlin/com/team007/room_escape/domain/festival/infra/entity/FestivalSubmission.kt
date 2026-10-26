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
class FestivalSubmission(
    festival: Festival,
    id: UUID? = null,
) : BaseTimeEntity() {
    @field:Id
    @field:UuidGenerator(style = UuidGenerator.Style.VERSION_7)
    var id: UUID? = id
        protected set

    @field:ManyToOne(fetch = FetchType.LAZY, optional = false)
    @field:JoinColumn(name = "festival_id", nullable = false)
    var festival: Festival = festival
        protected set
}
