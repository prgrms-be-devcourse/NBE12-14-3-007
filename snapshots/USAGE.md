# 스냅샷 사용 방법

처음 쓰는 사람을 위한 순서별 안내입니다. 개념과 한계는 [README.md](README.md)를 먼저 보세요.

## 한눈에 보기

```
① 변환 전 상태를 찍는다 (또는 baseline 파일을 쓴다)
② 코드를 변환한다
③ 다시 찍는다
④ 둘을 비교한다  →  "실제 차이 0개"면 응답이 그대로라는 뜻
```

## 0. 준비물 확인 (처음 한 번)

| 필요한 것 | 확인 방법 |
|---|---|
| Docker 실행 중 | Docker Desktop을 켜 둔다. 테스트용 임시 DB를 Docker로 띄운다 |
| JDK 25 | `java -version` |
| Python 3 | `python --version` (안 되면 `py --version`) |

## 1. 스냅샷 찍기

프로젝트 **루트 폴더**에서 실행합니다.

**Windows (PowerShell)**
```powershell
./snapshots/tools/record.ps1 -Name 내이름_inquiry변환후
```

**Mac / Linux / Git Bash**
```bash
./snapshots/tools/record.sh 내이름_inquiry변환후
```

- `-Name` 뒤에는 알아볼 수 있는 이름을 자유롭게 붙입니다. (예: `홍길동_post변환전`, `홍길동_post변환후`)
- 1~2분 걸립니다. Docker로 DB를 띄우고 테스트를 한 번 실행하기 때문입니다.
- 끝나면 이렇게 나옵니다.
  ```
  BUILD SUCCESSFUL in 34s
  저장됨: ...\snapshots\runs\내이름_inquiry변환후.txt
  ```
- 결과 파일은 `snapshots/runs/` 폴더에 생깁니다. 이 폴더는 git에 올라가지 않으니 마음껏 찍어도 됩니다.
- `src/test` 폴더는 바뀌지 않습니다. 기록용 테스트를 실행하는 동안만 잠깐 복사했다가 자동으로 지웁니다.

## 2. 기준선과 비교하기

```bash
python snapshots/tools/compare_snapshots.py snapshots/baseline/java-era_324ef5e.txt snapshots/runs/내이름_inquiry변환후.txt
```

(Windows에서 `python`이 안 되면 앞부분을 `py`로 바꿉니다.)

비교할 대상은 목적에 따라 고릅니다.

| 비교 대상 | 언제 쓰나 |
|---|---|
| `baseline/java-era_324ef5e.txt` | **"Java 시절과 같은가?"** 를 확인할 때. 마이그레이션 전체의 기준 |
| `baseline/kotlin-mid_a41e11f.txt` | **"내가 바꾸기 전의 dev와 같은가?"** 를 확인할 때 |
| 내가 변환 전에 찍어 둔 파일 | **"내 변경 하나가 응답을 바꿨나?"** 를 확인할 때 (가장 정확함) |

## 3. 결과 읽는 법

### 통과한 경우
```
요청 44개 비교: 동일 43개 / 알려진 차이 1개 / 실제 차이 0개
  알려진 차이(통과): OpenAPI 문서 - null 허용 표기만 다름

결과: 통과 - 실제 응답이 기준선과 같습니다.
```

| 항목 | 뜻 |
|---|---|
| **동일** | 상태 코드와 응답 JSON이 완전히 같음 |
| **알려진 차이** | OpenAPI 문서(Swagger)의 null 표기만 다름. Kotlin으로 바꾸면 자연스럽게 생기는 차이라 통과로 봄 |
| **실제 차이** | 실제 API 응답이 달라짐. **0개여야 합니다** |

### 실패한 경우
```
[실제 차이] 문의 등록 - 제목 없음
    -status: 400
    +status: 500
결과: 실패 - 위의 차이를 확인하세요.
```

- `-` 줄이 **기준선(예전)**, `+` 줄이 **방금 찍은 것(지금)** 입니다.
- 위 예는 "제목이 없으면 400이 나와야 하는데 500이 났다"는 뜻이라, 내가 바꾼 코드에서 오류가 난 것입니다.
- 의도하지 않은 변화라면 코드를 고치고 다시 찍어서 비교합니다.

## 4. 스냅샷 파일 직접 열어 보기

`snapshots/runs/내이름_....txt`나 `baseline/*.txt`는 **사람이 읽을 수 있는 텍스트**입니다. 메모장이나 VS Code로 엽니다. 요청 하나가 이런 모양입니다.

```
### 문의 등록 - 제목 없음           ← 어떤 요청인지 (이름표)
status: 400                          ← 서버가 돌려준 상태 코드
content-type: application/json       ← 응답 종류
{                                    ← 응답 본문 (API가 돌려준 JSON)
  "code" : "COMMON_INVALID_INPUT",
  "data" : null,
  "message" : "title: must not be blank",
  "success" : false
}
```

- 맨 첫 줄 `# label:`에는 어느 커밋에서 찍었는지가 적혀 있습니다. 작업 중이던 변경이 있으면 `uncommitted-changes`가 붙습니다.
- `<uuid>`, `<ts>`는 실행할 때마다 달라지는 값(ID, 시각)을 같은 글자로 바꿔 둔 것입니다.
- 날씨 응답의 `<today>`, `<today+1y>`는 요청한 날짜(오늘, 1년 뒤)를 바꿔 둔 것입니다. 날짜가 지나도 기준선과 비교할 수 있습니다.
- 파일이 길어서(약 6,500줄) 처음부터 끝까지 읽을 필요는 없습니다. 비교 스크립트가 달라진 곳만 알려 줍니다.

## 5. 도메인 하나를 변환할 때 권장 순서

1. 최신 `dev`에서 새 브랜치를 만든다.
2. **변환하기 전에** 먼저 찍는다.
   ```powershell
   ./snapshots/tools/record.ps1 -Name 내이름_post변환전
   ```
3. 도메인을 Kotlin으로 변환하고 `./gradlew test`로 테스트를 통과시킨다.
4. **변환한 뒤에** 다시 찍는다.
   ```powershell
   ./snapshots/tools/record.ps1 -Name 내이름_post변환후
   ```
5. 두 파일을 비교한다.
   ```bash
   python snapshots/tools/compare_snapshots.py snapshots/runs/내이름_post변환전.txt snapshots/runs/내이름_post변환후.txt
   ```
6. `실제 차이 0개`면 PR 설명에 결과를 붙인다.

### PR 설명에 붙이는 예시
```
## 스냅샷 비교
- 변환 전/후 각각 44개 요청 비교: 동일 44개 / 실제 차이 0개
- 확인 범위: 문의, 후기, 날씨, 오류 응답, OpenAPI 문서 (README 참고)
```

## 6. 문제가 생겼을 때

| 증상 | 원인과 해결 |
|---|---|
| `스냅샷 기록에 실패했습니다` | Docker가 꺼져 있거나 컴파일 오류입니다. Docker Desktop을 켜고, `./gradlew compileKotlin compileJava`로 컴파일을 먼저 확인합니다 |
| `...running scripts is disabled on this system` (PowerShell) | 스크립트 실행 정책 때문입니다. `powershell -ExecutionPolicy Bypass -File ./snapshots/tools/record.ps1 -Name 이름`으로 실행합니다 |
| `python`을 찾을 수 없음 | Python 3을 설치하거나 `py`로 바꿔 실행합니다 |
| `record.sh`에서 `$'\r': command not found` | 줄바꿈이 CRLF로 받아진 경우입니다. `.gitattributes`에 규칙이 있으니 `git pull` 후 파일을 다시 받거나, PowerShell용 `record.ps1`을 씁니다 |
| `BUILD SUCCESSFUL`인데 결과 파일이 없음 | 테스트가 건너뛰어진 경우입니다. 스크립트는 `cleanTest`를 쓰므로 보통은 생기지 않습니다. `snapshots/tools/`가 최신인지 확인합니다 |
| 같은 코드를 두 번 찍었는데 차이가 남 | 요청 순서나 시간에 의존하는 값이 섞였을 수 있습니다. 어떤 요청이 다른지 보고 팀에 알려 주세요 |
| 비교가 "요청 목록이 다름"으로 나옴 | 기록기(`SnapshotRecorderTest.java`) 버전이 두 파일에서 다릅니다. 같은 버전으로 다시 찍어야 합니다 |

## 7. 해도 되는 것 / 하면 안 되는 것

| 해도 됨 | 하면 안 됨 |
|---|---|
| 얼마든지 찍기 (`runs/` 폴더) | `baseline/` 파일을 임의로 덮어쓰기 |
| `compare_snapshots.py`로 비교하기 | `src/test`에 `SnapshotRecorderTest.java`를 직접 두고 커밋하기 |
| 새 요청 추가를 팀에 제안하기 | 실제 차이가 나는데 "문서 차이겠지" 하고 넘어가기 |

기준선이 필요하다면 이유를 적어 팀과 상의한 뒤 새 파일을 **추가**합니다 (예: `baseline/kotlin-mid_<커밋>.txt`).
