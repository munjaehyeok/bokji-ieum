# R-005 리뷰 요청: AGE_HINT + 결과 구분 (커밋 9579228, 브랜치 munjaehyeok/reopen-session-5efbcbdd)
사람 지시(2026-10-19): "실제 서비스 개발 업체처럼 끝까지 진행". 룰 필터 유효성 측정(docs/검증/필터유효성-측정.md)에서 노출 377~532건 중 ~90%가 일치 항목 없음, 연령 태그 없는 행 170건은 대상 집단어가 있어도 판정이 없음을 확인했다.
## 변경
1. SPEC.md 하단 "연령 대상 힌트(AGE_HINT)" 계약, 매퍼 `ageHintCond`(제외·점수 불변, 확인필요에만 추가), 4개 언어 태그명.
2. 결과: 일치 묶음 먼저(안정 분할, MatchService) + 머리글 2개(최초 렌더·AJAX).
3. 테스트: docs/검증/age-hint-regression.py(스펙에서 독립 작성, 74 PASS), match-regression 20/20, persona-scenarios.py(노출 건수 불변).
## 판단 요청
- AGENTS.md "명시된 만 N세만 연령 필드" 원칙과 충돌하는가? (연령 필드가 아니라 확인필요 표시만이라 충돌 아니라고 본다.)
- 집단어·연령 범위 표(SPEC)가 적절한가. 오탐 위험(예: 사업명 '아동' + 대상 성인) 평가.
- P0/P1/P2와 마지막 줄 `판정: APPROVE|REVISE`. 출력: reviews/review-R-005.md
