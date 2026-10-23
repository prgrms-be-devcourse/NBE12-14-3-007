package com.team007.room_escape.domain.festival.infra.entity

import com.team007.room_escape.global.entity.BaseTimeEntity
import jakarta.persistence.Column
import jakarta.persistence.Entity
import jakarta.persistence.GeneratedValue
import jakarta.persistence.GenerationType
import jakarta.persistence.Id
import jakarta.persistence.Table
import org.hibernate.annotations.JdbcTypeCode
import org.hibernate.type.SqlTypes

@Entity
@Table(name = "public_festival_source")
class PublicFestivalSource(
	@field:JdbcTypeCode(SqlTypes.JSON)
	@field:Column(nullable = false, columnDefinition = "jsonb")
	val source: String,

	/** 이번 배치에서 받아온 행 개수. jsonb를 파싱하지 않고 건수를 보려고 둔다. */
	@field:Column(name = "total_count", nullable = false)
	val totalCount: Int
) : BaseTimeEntity() {

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	var id: Long? = null
		protected set
}
