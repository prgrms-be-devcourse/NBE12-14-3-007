package com.team007.room_escape.domain.festival.infra.dto

import tools.jackson.dataformat.xml.annotation.JacksonXmlProperty

/** /period2 응답의 item 1건. seq로 신규 여부를, title로 내용이 바뀐 기존 행사(upsert 대상)를 판별한다. */
data class CultureInfoPeriodRow(
	@JacksonXmlProperty(localName = "seq") val seq: String,
	@JacksonXmlProperty(localName = "title") val title: String
) {
	/**
	 * DB에 저장된 title(이미 디코딩됨)과 비교할 때는 이 값을 써야 한다.
	 * title을 그대로 비교하면, 여기 담긴 값은 HTML 엔티티가 이스케이프된 원본이라
	 * 내용이 안 바뀐 행사도 전부 "제목이 다르다"고 오판된다.
	 */
	fun unescapedTitle(): String? = unescapeHtml(title)
}
