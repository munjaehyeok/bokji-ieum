#!/bin/sh
# usage: review.sh [base-branch]   (프로젝트 repo 루트에서, 구현 브랜치 위에서 실행)
# Codex를 읽기 전용 샌드박스로 돌려 reviews/<branch>.md 에 지적만 저장한다.
set -e
BASE=${1:-main}
BR=$(git rev-parse --abbrev-ref HEAD | tr / -)
mkdir -p reviews
perl -e 'alarm($ENV{REVIEW_TIMEOUT}||600); exec @ARGV' codex exec -s read-only -C "$PWD" -o "reviews/$BR.md" \
"REVIEW.md 규칙대로(그리고 REVIEW.standards.md가 있으면 그 규칙도 적용해) 이 브랜치를 리뷰해라. 시작점 문서는 SPEC.md 또는 EXPERIMENT.md(있으면)와 AGENTS.md. 변경 범위는 'git diff $BASE...HEAD'. 파일은 수정하지 마라." < /dev/null || { echo "리뷰 실패 또는 시간 초과(REVIEW_TIMEOUT=${REVIEW_TIMEOUT:-600}초). 조용히 넘어가지 말고 사람에게 알린다." >&2; exit 1; }
echo "saved: reviews/$BR.md"
