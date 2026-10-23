#!/usr/bin/env bash
# API 응답 스냅샷을 찍는다. (macOS / Linux / Git Bash)
#
# 사용법 (프로젝트 루트에서):
#     ./snapshots/tools/record.sh 내이름_작업내용
#
# 결과는 snapshots/runs/<이름>.txt 에 저장된다. (runs 폴더는 git에 올라가지 않는다)
# 기록용 테스트를 src/test 에 잠깐 복사했다가 끝나면 지운다. src/test 를 바꾸지 않는다.
# Docker 가 켜져 있어야 한다. (Testcontainers 로 임시 DB 를 띄운다)
set -euo pipefail

NAME="${1:?사용법: ./snapshots/tools/record.sh <이름>}"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/../.." && pwd)"
DEST="$ROOT/src/test/java/com/team007/room_escape/api/SnapshotRecorderTest.java"
OUT_DIR="$ROOT/snapshots/runs"
mkdir -p "$OUT_DIR"

SHORT="$(git -C "$ROOT" rev-parse --short HEAD)"
BRANCH="$(git -C "$ROOT" branch --show-current)"
[ -n "$BRANCH" ] || BRANCH="(detached)"
DIRTY=""
[ -n "$(git -C "$ROOT" status --porcelain)" ] && DIRTY=" + uncommitted-changes"

export SNAPSHOT_OUT="$OUT_DIR/$NAME.txt"
export SNAPSHOT_LABEL="$SHORT $BRANCH$DIRTY ($NAME)"

cp "$HERE/SnapshotRecorderTest.java" "$DEST"
trap 'rm -f "$DEST"' EXIT

cd "$ROOT"
# cleanTest: 코드가 그대로여도 매번 새로 실행한다. (Gradle 이 UP-TO-DATE 로 건너뛰면 새 파일이 안 만들어진다)
./gradlew cleanTest test --tests "*SnapshotRecorderTest" --console=plain

echo
echo "저장됨: $SNAPSHOT_OUT"
echo "비교: python snapshots/tools/compare_snapshots.py snapshots/baseline/java-era_324ef5e.txt $SNAPSHOT_OUT"
