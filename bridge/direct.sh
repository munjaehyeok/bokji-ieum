#!/bin/sh
# usage: bridge/direct.sh bridge/Q-001-xxx.md   (repo 루트에서)
# Codex(읽기 전용)가 디렉터로서 방향·우선순위·수용기준을 reviews/direction-<질문파일명>.md 에 반환.
set -e
Q=${1:?질문 파일 경로}
OUT="reviews/direction-$(basename "$Q" .md).md"
mkdir -p reviews
perl -e 'alarm($ENV{REVIEW_TIMEOUT}||900); exec @ARGV' codex exec -s read-only -C "$PWD" -c model_reasoning_effort=high -o "$OUT" \
"너는 이 프로젝트의 디렉터(방향 결정·승인 담당)다. AGENTS.md, bridge/BRIEF.md, $Q, 필요하면 docs/ 를 읽어라. 구현은 Claude가 한다. 파일은 수정하지 마라. 다음 형식의 한국어 지시서를 출력해라: 1) 진단(사실과 추정을 구분) 2) 우선순위 작업 목록(작업마다: 목적, 구현자가 할 일, 수용기준=검증 가능한 문장, 소유 파일 경로) 3) 하지 말 것 4) 사람에게 확인받을 것 5) 구현 완료 후 네가 승인하려면 봐야 할 증거 목록. AGENTS.md의 고정 규칙(시흥시 범위, 태깅 원칙)을 어기는 제안은 하지 마라. 근거 없는 수치는 만들지 마라." < /dev/null || { echo "direct 실패 또는 시간 초과. 사람에게 알린다." >&2; exit 1; }
echo "saved: $OUT"
