plugins {
	java
	kotlin("jvm") version "2.3.21"
	kotlin("plugin.spring") version "2.3.21"
	kotlin("plugin.jpa") version "2.3.21"
	// Java 클래스의 Lombok이 만든 getter·생성자·builder를 Kotlin이 인식하게 한다.
	kotlin("plugin.lombok") version "2.3.21"
	id("org.springframework.boot") version "4.1.1"
	id("io.spring.dependency-management") version "1.1.7"
}

group = "com.team007"
version = "0.0.1-SNAPSHOT"

java {
	toolchain {
		languageVersion = JavaLanguageVersion.of(25)
	}
}

kotlin {
	jvmToolchain(25)
	compilerOptions {
		// Spring의 null 어노테이션을 Kotlin 타입에 반영하고, 파라미터 이름을 남긴다.
		freeCompilerArgs.addAll("-Xjsr305=strict", "-java-parameters")
	}
}

// Kotlin 클래스는 기본이 final이라 Hibernate 지연 로딩 프록시가 동작하지 않는다.
// 엔티티 관련 클래스를 자동으로 open 처리한다. (AGENTS.md §4.2 참고)
allOpen {
	annotation("jakarta.persistence.Entity")
	annotation("jakarta.persistence.MappedSuperclass")
	annotation("jakarta.persistence.Embeddable")
}

repositories {
	mavenCentral()
}

dependencies {
	implementation("org.jetbrains.kotlin:kotlin-reflect")
	implementation("tools.jackson.module:jackson-module-kotlin")

	// Cloudflare R2는 S3 호환이라 AWS S3 SDK를 엔드포인트만 바꿔서 사용한다.
	implementation(platform("software.amazon.awssdk:bom:2.35.0"))
	implementation("software.amazon.awssdk:s3")

	// 이메일 인증 코드를 담아두는 로컬 캐시. expireAfterWrite로 만료를 알아서 처리한다.
	implementation("com.github.ben-manes.caffeine:caffeine")

	// 행사 이미지를 R2에 올리기 전 리사이즈하는 데 사용한다.
	implementation("net.coobird:thumbnailator:0.4.20")

	// 메트릭 수집. /actuator/prometheus 로 Prometheus 형식 메트릭을 내보낸다.
	implementation("org.springframework.boot:spring-boot-starter-actuator")
	runtimeOnly("io.micrometer:micrometer-registry-prometheus")

	// 전국 문화정보 API(period2/detail2) 응답이 XML이라 JSON 대신 XML 파싱용 모듈을 추가한다.
	implementation("tools.jackson.dataformat:jackson-dataformat-xml")

	implementation("org.springframework.boot:spring-boot-starter-data-jpa")
	implementation("org.springframework.boot:spring-boot-starter-flyway")
	implementation("org.springframework.boot:spring-boot-starter-mail")
	implementation("org.springframework.boot:spring-boot-starter-security")
	implementation("org.springframework.boot:spring-boot-starter-validation")
	implementation("org.springframework.boot:spring-boot-starter-webclient")
	implementation("org.springframework.boot:spring-boot-starter-webmvc")
	implementation("org.flywaydb:flyway-database-postgresql")
	implementation("org.springdoc:springdoc-openapi-starter-webmvc-ui:3.1.0")
	implementation("io.jsonwebtoken:jjwt-api:0.12.6")
	// 사용자가 작성한 후기·행사 소개 HTML에서 허용하지 않은 태그와 속성을 제거한다.
	implementation("com.googlecode.owasp-java-html-sanitizer:owasp-java-html-sanitizer:20260924.2")
	runtimeOnly("io.jsonwebtoken:jjwt-impl:0.12.6")
	runtimeOnly("io.jsonwebtoken:jjwt-jackson:0.12.6")
	compileOnly("org.projectlombok:lombok")
	runtimeOnly("org.postgresql:postgresql")
	annotationProcessor("org.projectlombok:lombok")
	testImplementation("org.springframework.boot:spring-boot-starter-data-jpa-test")
	testImplementation("org.springframework.boot:spring-boot-starter-flyway-test")
	testImplementation("org.springframework.boot:spring-boot-starter-mail-test")
	testImplementation("org.springframework.boot:spring-boot-starter-security-test")
	testImplementation("org.springframework.boot:spring-boot-starter-validation-test")
	testImplementation("org.springframework.boot:spring-boot-starter-webclient-test")
	testImplementation("org.springframework.boot:spring-boot-starter-webmvc-test")
	// Docker Desktop만 켜면 테스트가 임시 PostgreSQL을 자동으로 준비한다.
	testImplementation("org.testcontainers:testcontainers-postgresql")
	testCompileOnly("org.projectlombok:lombok")
	testRuntimeOnly("org.junit.platform:junit-platform-launcher")
	testAnnotationProcessor("org.projectlombok:lombok")
}

// 컴파일된 클래스에 파라미터 이름을 남긴다.
// 이게 없으면 @RequestParam / @PathVariable 에 이름을 생략했을 때
// Spring 이 인자 이름을 못 읽어 "parameter name information not available" 로 실패한다.
tasks.withType<JavaCompile> {
	options.compilerArgs.add("-parameters")
}

tasks.withType<Test> {
	useJUnitPlatform()
}
