# 2025 하반기 안내서 전량 교체 — 게이트·회귀 결과 (2026-11-25)

환경: 격리 MySQL 컨테이너 `bokji-verify`(빈 DB 적재), 검증 서버 `:8099`(작업 트리 빌드). 비밀·계정 값 없음.

| 항목 | 결과 |
|---|---|
| `docs/검증/data-gate.sh` | PASS 19 / FAIL 0 (적재 오류 0, 보정 SQL 멱등, 고정 수치 901/471/430/7, 출처 853/24/24, id 대역 1001~1853, F 엄격 기준) |
| `match-regression.py <url> 901 7` | PASS 34 / FAIL 0 (불변식 894, R-046~R-048 반례·상세 병존 안내 포함) |
| `age-hint-regression.py` | FAIL 0 (SKIP 1: 2022판 사례 소멸) |
| `resource-search-regression.py` | ALL PASS |
| `compare-regression.py` / `link-regression.py` / `ledger-check.py` | ALL PASS / ALL PASS / PASS |
| UI 변경 | 없음(데이터·문구 연도만) — 브라우저 스모크 대상 아님 |

한계: 이 결과는 구현자 실행 기록이다. 오제외 0을 증명하는 것이 아니라 알려진 반례를 회귀로 고정한 것이다.
