package com.team007.room_escape.support;

import org.springframework.test.context.DynamicPropertyRegistry;

/** 테스트별 스키마와 Testcontainers의 임시 PostgreSQL을 사용한다. 고정 포트가 필요 없다. */
public final class TestDatabase {

	private static final String URL = "jdbc:tc:postgresql:16-alpine:///roomescape_policy_test"
		+ "?TC_INITSCRIPT=db/init/001_extensions.sql";

	private TestDatabase() {
	}

	public static void configure(DynamicPropertyRegistry properties, String schema) {
		properties.add("spring.datasource.url", () -> URL + "&currentSchema=" + schema + ",public");
		properties.add("spring.flyway.schemas", () -> schema);
		properties.add("spring.jpa.properties.hibernate.default_schema", () -> schema);
	}
}
