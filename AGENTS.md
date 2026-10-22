# AGENTS.md — Java → Kotlin 마이그레이션 공통 규칙

GPT, Claude 등 이 저장소에서 작업하는 모든 AI와 팀원이 따르는 공통 규칙이다.
작업을 시작하기 전에 반드시 끝까지 읽는다. 규칙과 사용자 지시가 충돌하면 멈추고 질문한다.

## 1. 작업 범위

- 대상: 백엔드 운영 코드(`src/main/java`) Java → Kotlin
- 제외: 프론트(`client/`), 테스트 코드(`src/test`)의 Kotlin 전환
- 유지: API 형식, DB 구조(Flyway 마이그레이션), 권한·비즈니스 정책
- 금지
  - 임의 정책 변경
  - 실패한 테스트의 삭제·약화·수정
  - **전체 Kotlin 마이그레이션이 끝나기 전까지 기능 수정·추가** (끝난 뒤에 진행한다)
  - 변환과 함께 하는 리팩터링 (1:1 변환 원칙)
- 변환 중 발견한 버그·개선점은 고치지 말고 사용자에게 보고만 한다.
- 변환 순서와 담당은 팀이 정한 별도 계획을 따른다. 계획에 없는 파일은 변환하지 않는다.

## 2. 반드시 팀과 공유할 일 (AI는 직접 진행하지 말고 먼저 멈추고 보고)

- 파일 삭제
- 대량 변경 (여러 패키지에 걸치거나 한 번에 많은 파일을 바꾸는 작업)
- 의존성 추가·변경·제거 (`build.gradle.kts`)
- 빌드 설정, 플러그인, JDK·Kotlin·Gradle 버전 변경
- `client/`(프론트), `src/test`(테스트) 수정이 필요해 보이는 경우: 이유만 보고하고 멈춘다. 사람이 팀과 상의한 뒤 지시한다.
- 정책이나 설계 판단이 모호한 경우: 추측하지 말고 질문한다.

## 3. 이름·구조 유지 규칙

다음은 바꾸지 않는다.

- 클래스, 패키지, 메서드, 필드, 변수 이름
- API 경로, 요청/응답 JSON 필드명
- DB 테이블명·컬럼명, `@Table`, `@Column(name=...)`
- 에러 코드 문자열과 메시지 (예: `AUTH001`)
- enum 항목의 이름·값·정의 순서
- `application*.yaml` 설정 키 (설정 클래스 필드명 = 설정 키)
- 기존 주석(Javadoc → KDoc)과 `// TODO`

허용되는 예외: Java `record` → Kotlin `data class` 변환으로 생기는 접근 형태 변화
(`dto.email()` → `dto.getEmail()`). 아직 Java인 **호출부**만 고치고, 선언 이름은 바꾸지 않는다.

## 4. Kotlin 변환 규칙

### 4.1 파일·구조
- `Xxx.java` → `Xxx.kt`, 같은 패키지 경로(`src/main/kotlin/...`)에 둔다. 파일 구조는 1:1로 유지한다.
- Java와 Kotlin 혼용을 허용한다.
- **Kotlin 컴파일러는 Lombok이 만든 메서드(`getXxx()`, `builder()` 등)를 인식하지 못한다.**
  Lombok을 쓰는 Java 클래스를 Kotlin 코드가 호출하면 컴파일이 깨진다.
  변환 순서 계획을 지키고, 이 문제가 생기면 임의로 우회하지 말고 보고한다.

### 4.2 Entity (JPA)
- `data class` 금지. 일반 `class`를 사용한다.
- 필드는 외부 setter 없이 `var ... private set` / `protected set`으로 기존 접근 수준을 재현한다.
  - 단, 아래 `allOpen` 설정 때문에 엔티티 프로퍼티는 기본적으로 `open` 상태다. Kotlin은 `open` 프로퍼티에 `private set`을 허용하지 않는다
    (`Private setters for open properties are prohibited` 컴파일 에러). 그래서 엔티티의 `id`처럼 생성자로 못 받고 나중에 채워지는
    필드는 `private set` 대신 **`protected set`을 기본으로 쓴다.**
- 연관관계의 `fetch`, `nullable`, `optional`은 기존과 정확히 일치시킨다.
- `@NoArgsConstructor(access = PROTECTED)`는 `kotlin-jpa` 플러그인으로 대체한다. (플러그인 도입은 §2 공유 대상)
- **`allOpen` 설정 (팀 공유 사항)**: Kotlin 클래스는 기본이 `final`이라 Hibernate의 지연 로딩 프록시(상속 기반)가 동작하지 않는다.
  그래서 `build.gradle.kts`에 `allOpen`으로 `@Entity`, `@MappedSuperclass`, `@Embeddable`이 붙은 클래스를 자동으로 `open` 처리한다.
  엔티티에 `open`을 직접 붙이지 않는다. 이 설정을 바꾸거나 빼야 할 것 같으면 직접 고치지 말고 팀과 상의 후 진행한다. (§2 빌드 설정 변경)
- `@Builder`: **수동 빌더를 `companion object`에 만든다.** 기존 테스트의 `Xxx.builder().field(v).build()` 호출이
  그대로 컴파일·동작해야 한다. 빌더·메서드 이름은 Lombok이 만들던 것과 같아야 한다.
- `BaseTimeEntity`, `SoftDeletableEntity`의 `delete()` / `restore()` / `isDeleted()` 이름과 동작을 유지한다.

### 4.3 DTO
- `record` → `data class`. 중첩 구조(`AuthRequest.Login` 등)를 그대로 유지한다.
- **검증 어노테이션은 항상 `@field:` 사용 대상을 명시한다.**
  (`@field:NotBlank`, `@field:Email`, `@field:Size`, `@field:ValidPassword`, `@field:ValidPhone` 등)
  명시하지 않으면 검증이 에러 없이 사라질 수 있다.
- `@Schema`의 설명과 example을 그대로 옮긴다.
- JSON 필드명이 바뀌지 않는지 확인한다.

### 4.4 Service / Component
- `@RequiredArgsConstructor` → 주 생성자 주입.
- `@Slf4j` → `private val log = LoggerFactory.getLogger(javaClass)` (클래스 멤버로 선언)
- `@Transactional` 위치와 옵션을 그대로 유지한다.
- 예외는 기존 `BusinessException` + `ExceptionCode`를 그대로 사용한다.

### 4.5 Enum / ExceptionCode
- `enum class Xxx(override val code: String, ...) : ExceptionCode` 형태로 변환하되 항목의 값과 순서를 바꾸지 않는다.

### 4.6 설정 클래스
- `@ConfigurationProperties` record → `data class`. 필드명(설정 키)을 바꾸지 않는다.

### 4.7 Repository
- `interface`로 유지한다. 쿼리 메서드 이름, `@Query`, `@Param`을 그대로 둔다.
- `Optional` 반환 시그니처는 바꾸지 않는다.

### 4.8 Null 처리
- `!!` 사용 금지. 불가피하면 이유를 주석으로 남기고 보고한다.
- Java에서 null이 가능했던 곳만 `?`로 표현한다. 원래 null이 아니던 값을 nullable로 풀어 주지 않는다.

## 5. 실행 환경과 비밀 정보

- JDK, Kotlin, Gradle 버전은 팀이 정한 값으로 통일한다. 임의로 올리거나 내리지 않는다.
- 개발 DB와 테스트 DB를 분리한다. AI는 개발·운영 DB에 직접 접속해 쓰기 작업을 하지 않는다.
- 환경변수는 `.env`로 관리하고, 팀원이 개별적으로 공유한다 (이메일 등).
  - `.env`는 `.gitignore`에 포함하고, 키 이름만 담은 `.env.example`을 저장소에 둔다.
  - **AI는 `.env` 파일을 읽거나 내용을 출력·전송하지 않는다.**
  - 실제 인증키, 비밀번호, 토큰은 코드·문서·로그·커밋에 포함하지 않는다.

## 6. 검증과 완료 기준

"AI가 끝났다고 말했다"가 아니라 결과로 판단한다.

- 컴파일과 패키징이 통과해야 한다.
- 관련 테스트와 전체 백엔드 테스트가 통과해야 한다.
- 변환 전(Java 상태)의 테스트 결과를 먼저 확인해서, 기존 실패와 새 실패를 구분한다.
- 테스트가 실패하면 테스트를 고치지 말고 원인을 보고한다.
- 프론트 동작 확인: 담당자가 시나리오(로그인, 주요 CRUD, 권한별 접근 등)를 직접 한 번씩 수행하고 결과를 남긴다.
- 검증 어노테이션이 있는 DTO를 바꿨다면, 잘못된 값 요청 시 400이 나오는지 담당자가 확인한다.

## 7. 보고와 커밋

작업이 끝나면 다음을 보고한다.

- 변경한 파일 목록
- 실행한 검증과 결과
- 검증하지 못한 항목
- 발견했지만 고치지 않은 버그·개선점
- 규칙 때문에 멈춘 항목

커밋·푸시 규칙

- **사용자가 명시적으로 "커밋해/푸시해"라고 확답하기 전에는 `git commit`, `git push`, 머지, 브랜치 삭제를 실행하지 않는다.**
- 이전 승인은 다음 작업에 이어지지 않는다. 매번 새로 확인한다.
- 작성자가 변경 코드와 이유를 확인한 뒤에 커밋한다.
- 같은 파일을 두 사람(또는 AI)이 동시에 변환하지 않는다. 담당 범위 밖 파일은 건드리기 전에 확인한다.
