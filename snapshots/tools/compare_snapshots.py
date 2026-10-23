"""두 스냅샷 파일을 요청별로 비교한다. (Python 3, 표준 라이브러리만 사용)

사용법:
    python snapshots/tools/compare_snapshots.py <기준선.txt> <새로 찍은.txt> [--strict-doc]

- 실제 API 응답(상태 코드, 응답 JSON)이 하나라도 다르면 종료 코드 1을 돌려준다.
- OpenAPI 문서에서 null 허용 표기만 다른 경우는 "알려진 차이"로 보고 기본적으로 통과시킨다.
  Kotlin의 nullable 타입(String?)을 Swagger가 ["string","null"] 로 표기하기 때문이다.
  이것도 막고 싶으면 --strict-doc 를 붙인다.
"""
import difflib
import json
import re
import sys

OPENAPI = "OpenAPI 문서"


def load(path):
    text = open(path, encoding="utf-8").read()
    text = re.sub(r"계약테스트 (행사 )?[0-9a-f]{8}", r"계약테스트 \1<t>", text)
    label = "(라벨 없음)"
    m = re.match(r"# label: (.*)", text)
    if m:
        label = m.group(1)
    sections = {}
    for block in text.split("### ")[1:]:
        title, _, body = block.partition("\n")
        sections[title.strip()] = body.rstrip("\n")
    return label, sections


def strip_nullable(node):
    """null 허용 표기를 걷어내서, 표기만 다른 문서를 같은 것으로 볼 수 있게 한다."""
    if isinstance(node, dict):
        node = dict(node)
        # oneOf: [{$ref}, {type: null}] -> {$ref}. 자식을 처리하기 전에 먼저 푼다.
        one = node.get("oneOf")
        if isinstance(one, list) and any(x == {"type": "null"} for x in one):
            rest = [x for x in one if x != {"type": "null"}]
            del node["oneOf"]
            if len(rest) == 1 and isinstance(rest[0], dict):
                node.update(rest[0])
            else:
                node["oneOf"] = rest
        out = {k: strip_nullable(v) for k, v in node.items()}
        # Void? 처럼 null 만 가능한 타입: 예전에는 타입 없음({})으로 표기되었다.
        if out == {"type": "null"}:
            return {}
        # "type": ["string", "null"] -> "string"
        t = out.get("type")
        if isinstance(t, list) and "null" in t:
            rest = [x for x in t if x != "null"]
            out["type"] = rest[0] if len(rest) == 1 else rest
        return out
    if isinstance(node, list):
        return [strip_nullable(x) for x in node]
    return node


def json_body(section):
    """섹션 본문에서 status/content-type 줄을 뺀 JSON 부분을 파싱한다. 실패하면 None."""
    lines = section.split("\n", 2)
    if len(lines) < 3:
        return None
    try:
        return json.loads(lines[2])
    except ValueError:
        return None


def show_diff(a, b, limit=30):
    n = 0
    for line in difflib.unified_diff(a.splitlines(), b.splitlines(), "기준선", "새로 찍은 것", lineterm="", n=2):
        if line.startswith(("---", "+++")):
            continue
        print("    " + line)
        n += 1
        if n >= limit:
            print("    ... (생략)")
            break


def main():
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    strict_doc = "--strict-doc" in sys.argv
    if len(args) != 2:
        print(__doc__)
        return 2
    sys.stdout.reconfigure(encoding="utf-8")

    label_a, a = load(args[0])
    label_b, b = load(args[1])
    print(f"기준선    : {label_a}")
    print(f"새로 찍은 것: {label_b}")
    print()

    same, known, real, only = [], [], [], []
    for name in a:
        if name not in b:
            only.append(f"{name} (새 스냅샷에 없음)")
        elif a[name] == b[name]:
            same.append(name)
        elif name == OPENAPI and not strict_doc:
            ja, jb = json_body(a[name]), json_body(b[name])
            if ja is not None and jb is not None and strip_nullable(ja) == strip_nullable(jb):
                known.append(name)
            else:
                real.append(name)
        else:
            real.append(name)
    for name in b:
        if name not in a:
            only.append(f"{name} (기준선에 없음)")

    print(f"요청 {len(a)}개 비교: 동일 {len(same)}개 / 알려진 차이 {len(known)}개 / 실제 차이 {len(real)}개")
    if known:
        print("  알려진 차이(통과): " + ", ".join(known) + " - null 허용 표기만 다름")
    if only:
        print("  요청 목록이 다름: " + "; ".join(only))

    for name in real:
        print()
        print(f"[실제 차이] {name}")
        show_diff(a[name], b[name])

    ok = not real and not only
    print()
    print("결과: " + ("통과 - 실제 응답이 기준선과 같습니다." if ok else "실패 - 위의 차이를 확인하세요."))
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
