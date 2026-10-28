package com.team007.room_escape.db

import org.assertj.core.api.Assertions.assertThat
import org.flywaydb.core.Flyway
import org.junit.jupiter.api.AfterEach
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import java.sql.Connection
import java.sql.DriverManager
import java.util.UUID

/**
 * 시연용 가짜 데이터(db/seed)가 운영에 들어가지 않는지 확인한다.
 * 운영은 db/migration + db/migration_v2 만 실행하고, 로컬은 db/seed 가 더해진다.
 * db/migration 에 데이터 INSERT 파일이 들어오면 서버를 처음 배포할 때 가짜 회원과 행사가 그대로 만들어진다.
 */
class DemoDataMigrationTest {

    private val url = "jdbc:tc:postgresql:16-alpine:///roomescape_policy_test?TC_INITSCRIPT=db/init/001_extensions.sql"
    private val schemaSuffix = UUID.randomUUID().toString().replace("-", "").take(12)

    /** Testcontainers 는 마지막 연결이 닫히면 DB를 지운다. 마이그레이션 뒤에도 조회할 수 있게 연결 하나를 열어 둔다. */
    private lateinit var keeper: Connection

    @BeforeEach
    fun openConnection() {
        keeper = DriverManager.getConnection(url, "roomescape", "roomescape")
    }

    @AfterEach
    fun closeConnection() = keeper.close()

    private fun migrate(schema: String, vararg locations: String) {
        Flyway.configure()
            .dataSource(url, "roomescape", "roomescape")
            .schemas(schema)
            .defaultSchema(schema)
            .locations(*locations)
            .load()
            .migrate()
    }

    private fun count(schema: String, table: String, where: String = "true"): Long =
        keeper.createStatement().use { statement ->
            statement.executeQuery("select count(*) from $schema.$table where $where").use { rows ->
                rows.next()
                rows.getLong(1)
            }
        }

    @Test
    fun `운영 마이그레이션만 실행하면 가짜 회원과 행사와 후기가 생기지 않는다`() {
        val schema = "prod_$schemaSuffix"

        migrate(schema, "classpath:db/migration", "classpath:db/migration_v2")

        assertThat(count(schema, "member")).isZero()
        assertThat(count(schema, "festival", "provider_type = 'MEMBER'")).isZero()
        assertThat(count(schema, "post")).isZero()
        assertThat(count(schema, "\"comment\"")).isZero()
        assertThat(count(schema, "\"like\"")).isZero()
    }

    @Test
    fun `로컬은 seed까지 실행해 시연용 데이터가 만들어진다`() {
        val schema = "local_$schemaSuffix"

        migrate(schema, "classpath:db/migration", "classpath:db/migration_v2", "classpath:db/seed")

        assertThat(count(schema, "member", "email like 'seed-%@example.com'")).isPositive()
        assertThat(count(schema, "festival", "provider_type = 'MEMBER'")).isPositive()
        assertThat(count(schema, "post")).isPositive()
    }
}
