# API 응답 스냅샷

Kotlin 마이그레이션(또는 이후 리팩터링)을 하면서 **API 동작이 예전과 같은지** 확인하는 도구입니다.

## 스냅샷이란

같은 요청을 보내고, 돌아온 **상태 코드와 응답 JSON을 파일로 저장**한 것입니다.
코드를 바꾼 뒤 같은 요청을 다시 보내 저장한 파일과 비교하면, 달라진 곳이 곧 동작이 바뀐 곳입니다.

테스트는 사람이 미리 적어 둔 기대값만 확인하지만, 스냅샷은 기대값을 적지 않아도 응답 전체를 비교합니다.
그래서 테스트가 놓친 변화(필드 이름, 검증 메시지, 문서 표기 등)도 잡습니다.

## 폴더 구성

```
snapshots/
 ├ README.md
 ├ baseline/                          기준선 (git에 올라감)
 │   ├ java-era_324ef5e.txt            Java 위주였던 시점 (Java 155 / Kotlin 18)
 │   └ kotlin-mid_a41e11f.txt          변환 중간 시점 (Java 92 / Kotlin 81)
 ├ tools/
 │   ├ SnapshotRecorderTest.java       요청을 보내고 응답을 저장하는 기록기
 │   ├ record.ps1 / record.sh          기록기를 실행하는 스크립트
 │   └ compare_snapshots.py            두 스냅샷 비교
 └ runs/                              내가 찍은 결과 (git에 올라가지 않음)
```

## 사전 준비

- Docker 실행 중 (Testcontainers가 임시 DB를 띄웁니다)
- JDK 25, Python 3 (비교 스크립트용, 표준 라이브러리만 사용)

## 사용법

### 1. 스냅샷 찍기

프로젝트 루트에서 실행합니다. 이름은 자유롭게 붙입니다.

```powershell
# Windows PowerShell
./snapshots/tools/record.ps1 -Name 내이름_inquiry변환후
```

```bash
# macOS / Linux / Git Bash
./snapshots/tools/record.sh 내이름_inquiry변환후
```

- 결과는 `snapshots/runs/<이름>.txt`에 저장됩니다.
- 기록기는 실행하는 동안만 `src/test`에 복사되고 끝나면 지워집니다. **`src/test`는 바뀌지 않습니다.**
- 첫 줄의 `# label:`에 어느 커밋에서 찍었는지(작업 중 변경 포함 여부도) 기록됩니다.

### 2. 기준선과 비교

```bash
python snapshots/tools/compare_snapshots.py snapshots/baseline/java-era_324ef5e.txt snapshots/runs/내이름_inquiry변환후.txt
```

결과는 이렇게 나옵니다.

```
요청 44개 비교: 동일 43개 / 알려진 차이 1개 / 실제 차이 0개
결과: 통과 - 실제 응답이 기준선과 같습니다.
```

- **동일**: 상태 코드와 응답 JSON이 똑같음
- **알려진 차이**: OpenAPI 문서(`/v3/api-docs`)에서 null 허용 표기만 다름 (아래 참고). 기본적으로 통과 처리
- **실제 차이**: 실제 응답이 달라짐 → 종료 코드 1, 달라진 줄이 출력됨. 원인을 확인해야 함

문서 표기 차이도 막고 싶으면 `--strict-doc`를 붙입니다.

### 3. 코드를 바꿀 때마다 반복

1. 변환(또는 리팩터링) 전 `main` 최신 상태에서 스냅샷을 한 번 찍어 둡니다 (또는 `baseline/` 파일을 씁니다)
2. 코드를 바꿉니다
3. 다시 찍고 비교합니다 → `실제 차이 0개`면 응답이 그대로라는 증거입니다

## 알려진 차이: OpenAPI 문서의 null 허용 표기

Kotlin의 nullable 타입(`String?`)을 Swagger가 `"type": ["string", "null"]`로, 객체 참조는
`oneOf: [{$ref}, {type: null}]`로 표기합니다. Java 때는 `"type": "string"`이었습니다.
`Void?`는 예전에는 타입 없음(`{}`)이었는데 `{"type": "null"}`로 표기됩니다 (`ApiResponseVoid.data`).

- 필드 추가·삭제·이름 변경, `required` 목록 변화는 없었습니다 (확인 완료).
- 특히 `ApiResponse<T>.data`가 `T?`라서 모든 응답의 `data`가 null 가능으로 문서화됩니다.
- 프론트가 OpenAPI 문서로 타입을 자동 생성한다면 영향이 있을 수 있어 확인이 필요합니다.

## 한계 (꼭 읽어 주세요)

- 기록하는 요청은 **44개**입니다. 문의, 후기, 날씨, 오류 응답, OpenAPI 문서 위주이고
  로그인, 회원, 행사, 댓글, 커뮤니티, 좋아요는 아직 포함하지 않았습니다.
  **여기서 "동일"이라는 말은 이 요청들에 한한 것**입니다.
- 기상청 실제 응답 파싱은 API 키가 필요해서 확인하지 못합니다 (UNKNOWN 경로만 기록됨).
- 메일 본문, 이미지 업로드 성공 경로, 스케줄러 같은 부수 효과는 기록하지 않습니다.
- 매번 달라지는 값(UUID, 시각, 임의 문자열)은 `<uuid>`, `<ts>`, `<t>`로 바꿔 비교합니다.

## 요청을 늘리려면

`tools/SnapshotRecorderTest.java`에 `record("이름", 요청)` 한 줄을 추가합니다.
추가하면 **기준선 파일도 같은 방식으로 다시 찍어야** 하니(예전 커밋을 체크아웃해서),
팀과 상의해서 정하세요.

## 기준선 갱신 규칙

- `baseline/` 파일은 임의로 덮어쓰지 않습니다. 동작이 바뀐 것이 의도된 변경일 때만, 이유와 함께 새 기준선을 추가합니다.
- 내가 찍은 결과는 `runs/`에 두면 git에 올라가지 않습니다.
