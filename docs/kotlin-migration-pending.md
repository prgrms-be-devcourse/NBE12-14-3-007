# Kotlin 마이그레이션 보류 항목

AGENTS.md 규칙 때문에 멈춘 항목과 발견만 하고 고치지 않은 항목을 기록한다. 해당 작업이 풀리면 이 문서에서 지운다.

## 기준선 (Java 상태 테스트)

- `./gradlew test`: 360개 중 13개 실패
- 실패는 모두 `MemberTrustGradeConcurrencyTest`
- 원인: 로컬 Postgres(`localhost:55432`)에 연결할 수 없어 Flyway가 시작되지 못함 (코드 문제 아님)
- 변환 후에도 같은 13개만 실패하면 정상으로 본다. DB를 띄운 환경에서는 전체 통과를 확인한다.

## 보류 1. `*Properties` 4개 (festival 작업 종료 후 진행)

대상: `AuthMailProperties`, `R2Properties`, `JwtProperties`, `AuthCookieProperties`

`record` → `data class`로 바꾸면 Java 호출부가 `xxx()` → `getXxx()`로 바뀌어야 한다 (AGENTS.md §3 허용 예외).
여러 패키지에 걸치고 `domain/festival`이 작업 중이라 보류한다.

| 호출부 (Java) | 패키지 |
|---|---|
| `R2Config` | global/config |
| `JwtProvider` | global/jwt |
| `MailSendService` | global/mail |
| `CookieUtil` | global/util |
| `ImageUrlResolver` | global/storage |
| `R2StorageService` | global/storage |
| `AuthService` | domain/auth |
| `EmailVerificationService` | domain/auth |
| `FestivalService` | domain/festival (`r2Properties.publicUrl()`) |

- `RichTextSanitizer.kt`(이미 변환됨)도 `r2Properties.publicUrl()` → `publicUrl`로 함께 바꿔야 한다.
- `src/test`는 생성자(`new R2Properties(...)`)만 쓰고 접근자는 쓰지 않아 영향 없음.
- `AuthMailProperties.cacheRetentionMinutes()`, `R2Properties.endpoint()`는 메서드이므로 이름 유지.
- `RoomescapeApplication`, `R2Config`, `SecurityConfig`의 `@EnableConfigurationProperties`는 그대로 둔다.

## 보류 2. `JwtAuthenticationFilter`

`CustomUserDetails`의 `@RequiredArgsConstructor` 생성자를 Kotlin이 인식하지 못한다 (AGENTS.md §4.1).
`CustomUserDetails`를 먼저 변환한 뒤 같이 진행한다.

## 발견했지만 고치지 않은 것

- `ValidPassword` Javadoc은 "8~15자"인데 실제 `@Size`는 `max = 25`다. 주석과 코드가 다르다.
- `CommonExceptionCode.java`가 deprecated API를 사용한다는 컴파일러 안내가 있다. 해당 파일 변환 때 확인한다.

## 변환 중 동작 보존을 위해 맞춘 부분

- `StringUtil.emptyToNull`, `RichTextSanitizer.sanitize/hasVisibleText`: Kotlin의 `isBlank()`/`trim()`은 NBSP 등 일부 공백을 다르게 처리해서 Java `String` 기준으로 맞췄다. 주석으로 이유를 남겨 두었다.

## 변환 완료 (진행 현황)

- global 1단계: `ExceptionCode`, `ValidPassword`, `ValidPhone`, `StringUtil`, `RichTextSanitizer`
- global 2단계: `JwtAccessDeniedHandler`, `JwtAuthenticationEntryPoint`, `OpenApiConfig`
