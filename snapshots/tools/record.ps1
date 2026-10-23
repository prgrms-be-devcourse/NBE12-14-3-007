<#
  API 응답 스냅샷을 찍는다. (Windows PowerShell)

  사용법 (프로젝트 루트에서):
      ./snapshots/tools/record.ps1 -Name 내이름_작업내용

  결과는 snapshots/runs/<Name>.txt 에 저장된다. (runs 폴더는 git에 올라가지 않는다)
  기록용 테스트를 src/test 에 잠깐 복사했다가 끝나면 지운다. src/test 를 바꾸지 않는다.
  Docker 가 켜져 있어야 한다. (Testcontainers 로 임시 DB 를 띄운다)
#>
param(
    [Parameter(Mandatory = $true)][string]$Name
)

# Gradle 이 stderr 에 내는 경고(JDK 경고 등)를 PowerShell 5.1 이 오류로 취급하지 않도록 Continue 로 둔다.
# 성공 여부는 아래에서 종료 코드와 결과 파일로 판단한다.
$ErrorActionPreference = "Continue"
$root = (Resolve-Path "$PSScriptRoot\..\..").Path
$recorder = Join-Path $PSScriptRoot "SnapshotRecorderTest.java"
$dest = Join-Path $root "src\test\java\com\team007\room_escape\api\SnapshotRecorderTest.java"
$runs = Join-Path $root "snapshots\runs"
New-Item -ItemType Directory -Force $runs | Out-Null
$out = Join-Path $runs "$Name.txt"

$short = "$(git -C $root rev-parse --short HEAD)".Trim()
$branch = "$(git -C $root branch --show-current)".Trim()
if (-not $branch) { $branch = "(detached)" }
# 라벨은 환경변수로 넘기므로 한글이 깨지지 않게 ASCII 로 쓴다.
$dirty = if ("$(git -C $root status --porcelain)".Trim().Length -gt 0) { " + uncommitted-changes" } else { "" }
$env:SNAPSHOT_LABEL = "$short $branch$dirty ($Name)"
$env:SNAPSHOT_OUT = $out

Copy-Item $recorder $dest -Force
try {
    Push-Location $root
    # cleanTest: 코드가 그대로여도 매번 새로 실행한다. (Gradle 이 UP-TO-DATE 로 건너뛰면 새 파일이 안 만들어진다)
    & ./gradlew cleanTest test --tests "*SnapshotRecorderTest" --console=plain
    $exit = $LASTEXITCODE
}
finally {
    Pop-Location
    Remove-Item $dest -Force -ErrorAction SilentlyContinue
}

if ($exit -ne 0 -or -not (Test-Path $out)) {
    Write-Host "스냅샷 기록에 실패했습니다. (컴파일 오류이거나 Docker 가 꺼져 있을 수 있습니다)" -ForegroundColor Red
    exit 1
}
Write-Host ""
Write-Host "저장됨: $out" -ForegroundColor Green
Write-Host "비교: python snapshots/tools/compare_snapshots.py snapshots/baseline/java-era_324ef5e.txt $out"
