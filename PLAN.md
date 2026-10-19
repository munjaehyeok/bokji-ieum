# 데이터 신뢰도 보정 분해 계획

스펙: `SPEC.md`. 규칙은 PLAN.template.md와 동일.

| id | 작업 | 종류 | 소유 경로 | 의존 | 검증 | 슬라이스 |
|---|---|---|---|---|---|---|
| T0 | 계약: 날짜 필드 의미·스펙 | 구현 | SPEC.md, PLAN.md | - | plan-check | - |
| T1 | 오태깅·기준일 보정 SQL | 구현 | src/main/resources/sql/reliability-tagging.sql, src/main/resources/sql/reliability-provenance.sql, docs/데이터/수집/기준일복원-20261019.csv | T0 | data-gate.sh | 보정 |
| T2 | 보정 데이터 게이트 | 테스트 | docs/검증/data-gate.sh | T0 | 구현 후 통과 | 보정 |
| T3 | 확인 범위 표시(카드·상세·AJAX·4개 언어) | 구현 | src/main/webapp/WEB-INF/views, src/main/webapp/static/js/bokji.js, src/main/resources/messages, src/main/resources/mappers/resource-mapper.xml, src/main/java/com/ieum/bokji/dto | T1 | 브라우저 스모크 | 표시 |
| T4 | 표시 스모크 (데스크톱·모바일·4개 언어·콘솔) | 테스트 | reviews/argonaut-smoke.md | T0 | 구현 후 통과 | 표시 |
| T5 | 우선순위 본문 대조 + 대장 | 구현 | docs/데이터/수집/본문검증대장.csv, docs/데이터/수집/본문검증로그.md, src/main/resources/sql/reliability-content.sql | T1 | 대장 역추적 | 본문 |
| T6 | 발표 수치 재정의·결과 문서 | 구현 | docs/검증/발표숫자.md, docs/검증/데이터신뢰도-결과.md | T3, T5 | 집계 SQL | 통합 |
