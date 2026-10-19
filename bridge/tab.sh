#!/bin/sh
# usage: bridge/tab.sh <메시지파일>   — 오르카의 Codex 탭(핸들은 bridge/.codex-tab)에 한 줄 지시를 보낸다.
# 대화 기록은 탭에 남고, 상세 응답은 Codex가 reviews/ 에 쓴다. 응답 확인: orca terminal read --terminal $(cat bridge/.codex-tab)
set -e
H=$(cat "$(dirname "$0")/.codex-tab")
F=${1:?메시지 파일}
orca terminal send --terminal "$H" --enter --wait-submit 20 --text "AGENTS.md와 bridge/BRIEF.md를 읽고 $F 를 읽어라. 너는 디렉터·리뷰어(읽기 전용)다: reviews/ 외 어떤 파일도 수정·삭제하지 말고, 응답은 파일에 적힌 reviews/ 경로에 쓴 뒤 이 탭에는 3줄 이내 요약만 남겨라." || { sleep 3; orca terminal send --terminal "$H" --enter; }  # 입력창에 남았을 때 제출만 재시도
