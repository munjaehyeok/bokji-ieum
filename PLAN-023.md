# PLAN-023 완성도 향상 (Codex Q-023 계획)

| id | 작업 | 종류 | 소유 경로 | 의존 | 검증 | 슬라이스 |
|---|---|---|---|---|---|---|
| T0 | 현행 사실·과장 표현 검색 대장 | 문서 | reviews/evidence-inventory-023.md | - | rg 결과·근거 경로 기록 | - |
| T1 | 외국인 통계 출처 선택 | 사람전용 | reviews/source-decision-023.md | T0 | 원문 정의·기준일·승인 기록 | - |
| T2 | 기존 서비스 동등 과제 비교 | 사람전용 | reviews/competitor-evidence-023.md | T0 | 비교표·캡처·미확인 명시 | - |
| T3 | 본문 대조 프로토콜 | 문서 | reviews/body-audit-protocol-023.md | T0 | 24+12 고유 ID·strata·seed·확장 규칙 기록 | - |
| T4 | 저장소 다국어 커버리지 확인 | 검증 | reviews/i18n-audit-023.md | T0 | DB/언어/필드별 집계 | - |
| T5 | 관리자 초기 계정 정책 승인 | 사람전용 | reviews/admin-security-decision-023.md | T0 | 변경 승인 또는 보류 | - |
| T6 | README·설계 개요 카피 교정 | 문서 | README.md, docs/설계/00-설계서-개요.md | T1 | 문구 grep·수치 근거 대조 | - |
| T7 | 데모·숫자·설계·수집 현황 정합화 | 문서 | docs/데모.md, docs/검증/발표숫자.md, docs/설계/02-데이터베이스-설계.md, docs/데이터/태깅-현황.md, docs/데이터/수집/수집로그.md, bridge/BRIEF.md | T1 | 792/246/546, 47/1/744 및 역사값 검토 | - |
| T8 | 본문 36건 외부 원문 확인 | 사람전용 | docs/데이터/수집/본문검증대장.csv, docs/데이터/수집/본문검증로그.md | T3, T7 | 원문·위치·전후값·미확인 필드 | - |
| T9 | 비교자료에 기반한 포지셔닝 정리 | 문서 | reviews/differentiation-023.md | T2, T6 | 확인된 차이만 최대 3개 | - |
| T10 | 사용성 프로토콜 사전 등록 | 문서 | reviews/usability-protocol-023.md | T2, T7 | 과제·측정·순서·성공 기준 동결 | - |
| T11 | 사용성 테스트 수행 | 사람전용 | reviews/usability-results-023.md | T10 | 실제 n·시간·성공/포기·설문 기록 | - |
| T12 | 다국어 사용자 확인 | 사람전용 | reviews/i18n-validation-023.md | T4, T11 | UI/본문 구분 시나리오 기록 | - |
| T13 | 검증된 본문 차이 멱등 SQL 반영 | 구현 | src/main/resources/sql/reliability-content.sql | T8 | 대장 ID와 SQL 1:1, 전값 조건 | - |
| T14 | 대장·데이터·회귀·화면 게이트 | 검증 | reviews/content-validation-023.md | T13 | ledger, data-gate, 회귀, 조건부 스모크 | - |
| T15 | 초기 관리자 계정 동작 변경·테스트 | 구현 | src/main/java/com/ieum/bokji/service/AdminInitializer.java, src/test/java/com/ieum/bokji/service/AdminInitializerTest.java | T5 | 승인 동작의 단위 테스트·빌드 | - |
| T16 | 시 부서 운영·최신 안내서 상태 확인 | 사람전용 | reviews/ops-decision-023.md | T8 | 회신 근거·운영 주체/책임 기록 | - |
| T17 | 팀원 실제 분담·일정 확인 | 사람전용 | reviews/team-contribution-023.md | T10 | 네 팀원 확인을 받은 산출물/기한 | - |
| T18 | 최종 영상 개요·대본 | 문서 | reviews/video-outline-023.md | T6, T7, T9, T11, T12, T14, T16, T17 | 5~7분, 모든 숫자·한계 근거 연결 | - |
| T19 | 공개 배포 준비·사람 승인 | 사람전용 | reviews/release-decision-023.md | T12, T14, T15, T16, T18 | 승인/보류 결정 기록, 배포는 별도 사람 수행 | 통합 |
