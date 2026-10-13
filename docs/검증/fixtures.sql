-- ============================================================
-- 매칭 결정표 단위 테스트용 가상 자원 (검증/단위케이스.md 대응)
-- 규약: resource_id 9000번대, name 'TEST-' 접두사, status='A'
--       실데이터(AUTO_INCREMENT, TEST- 없음)와 절대 겹치지 않음
-- 스키마: 설계/02-데이터베이스-설계.md §2 resource (테이블명 전부 소문자 확정; §3.5 추가 컬럼은 NULL 허용 가정 → 미지정)
-- 정리(원복): DELETE FROM resource WHERE resource_id BETWEEN 9000 AND 9099;
--            ALTER TABLE resource AUTO_INCREMENT = 745;  -- fixtures로 상승한 AUTO_INCREMENT 원복
-- ============================================================

DELETE FROM resource WHERE resource_id BETWEEN 9000 AND 9099;

INSERT INTO resource
  (resource_id, name, category, provider_type, org_name, support_content,
   age_min, age_max, dong_codes, household_types, income_rank, income_uncertain,
   disability, nationality, edu_work, uncertain_note,
   source_name, data_base_date, status, created_at, updated_at)
VALUES
-- 연령
(9001, 'TEST-연령 65~80', 'CARE',   'PUB', 'QA', '연령 양측 경계 검증용',
   65, 80, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
   'QA-fixture', '2026-10-01', 'A', NOW(), NOW()),
(9002, 'TEST-연령 65이상(상한없음)', 'CARE', 'PUB', 'QA', '한쪽 경계(min만) 검증용 — 보충 Q3 확정(없는 쪽 무제한)',
   65, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
   'QA-fixture', '2026-10-01', 'A', NOW(), NOW()),
-- 거주 동
(9003, 'TEST-동 정왕본·정왕1', 'DAILY', 'PUB', 'QA', '동 코드 포함/미포함/모름 검증용',
   NULL, NULL, 'JWB,JW1', NULL, NULL, NULL, NULL, NULL, NULL, NULL,
   'QA-fixture', '2026-10-01', 'A', NOW(), NOW()),
-- 가구형태
(9004, 'TEST-가구 1인·한부모', 'DAILY', 'PUB', 'QA', '가구형태 교집합/해당없음/미선택 검증용',
   NULL, NULL, NULL, 'ONE,SPAR', NULL, NULL, NULL, NULL, NULL, NULL,
   'QA-fixture', '2026-10-01', 'A', NOW(), NOW()),
-- 소득 4×5 전 칸 (c=1~4)
(9005, 'TEST-소득 수급만(c=1)', 'DAILY', 'PUB', 'QA', '소득 결정표 c=1 열',
   NULL, NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL,
   'QA-fixture', '2026-10-01', 'A', NOW(), NOW()),
(9006, 'TEST-소득 차상위까지(c=2)', 'DAILY', 'PUB', 'QA', '소득 결정표 c=2 열',
   NULL, NULL, NULL, NULL, 2, NULL, NULL, NULL, NULL, NULL,
   'QA-fixture', '2026-10-01', 'A', NOW(), NOW()),
(9007, 'TEST-소득 중위100까지(c=3)', 'DAILY', 'PUB', 'QA', '소득 결정표 c=3 열',
   NULL, NULL, NULL, NULL, 3, NULL, NULL, NULL, NULL, NULL,
   'QA-fixture', '2026-10-01', 'A', NOW(), NOW()),
(9008, 'TEST-소득 중위150까지(c=4)', 'DAILY', 'PUB', 'QA', '소득 결정표 c=4 열 — u=4 확인필요 칸 포함',
   NULL, NULL, NULL, NULL, 4, NULL, NULL, NULL, NULL, NULL,
   'QA-fixture', '2026-10-01', 'A', NOW(), NOW()),
(9009, 'TEST-소득 중위75이하(세부기준)', 'DAILY', 'PUB', 'QA', 'income_uncertain=Y 병기(INC-06)·모름 시 미병기(INC-07, 보충 Q5) 검증용',
   NULL, NULL, NULL, NULL, 3, 'Y', NULL, NULL, NULL, NULL,
   'QA-fixture', '2026-10-01', 'A', NOW(), NOW()),
-- 장애
(9010, 'TEST-장애인 대상', 'HEALTH', 'PUB', 'QA', '장애 Y/N/U 검증용',
   NULL, NULL, NULL, NULL, NULL, NULL, 'Y', NULL, NULL, NULL,
   'QA-fixture', '2026-10-01', 'A', NOW(), NOW()),
-- 국적
(9011, 'TEST-외국인 대상(F)', 'RIGHTS', 'PUB', 'QA', '국적 F 자원',
   NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'F', NULL, NULL,
   'QA-fixture', '2026-10-01', 'A', NOW(), NOW()),
(9012, 'TEST-내국인 한정(K)', 'RIGHTS', 'PUB', 'QA', '국적 K 자원 — K×외국인=확인필요(제외 금지) 검증용',
   NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'K', NULL, NULL,
   'QA-fixture', '2026-10-01', 'A', NOW(), NOW()),
-- 학업/취업
(9013, 'TEST-구직·대학생 대상', 'JOB', 'PUB', 'QA', '학업/취업 교집합/해당없음/미선택 검증용',
   NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'SEEK,UNIV', NULL,
   'QA-fixture', '2026-10-01', 'A', NOW(), NOW()),
-- 공통 규칙
(9014, 'TEST-서술형조건 보유', 'DAILY', 'PUB', 'QA', 'uncertain_note → NOTE 태그 무조건 추가 검증용',
   NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '국가유공자 우선',
   'QA-fixture', '2026-10-01', 'A', NOW(), NOW()),
(9015, 'TEST-제약없음', 'DAILY', 'PUB', 'QA', '전 조건 무관(c=NULL) — 점수 0·태그 없음·항상 포함 검증용',
   NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
   'QA-fixture', '2026-10-01', 'A', NOW(), NOW()),
-- 조합
(9016, 'TEST-조합 연령+동+소득', 'CARE', 'PUB', 'QA', 'CMB-01: 3+1+2=6점 합산 검증용',
   65, 80, 'JWB,JW1', NULL, 3, NULL, NULL, NULL, NULL, NULL,
   'QA-fixture', '2026-10-01', 'A', NOW(), NOW()),
(9017, 'TEST-조합 연령+장애+국적K', 'HEALTH', 'PUB', 'QA', 'CMB-02: 일치/확인필요 혼재 검증용',
   65, 80, NULL, NULL, NULL, NULL, 'Y', 'K', NULL, NULL,
   'QA-fixture', '2026-10-01', 'A', NOW(), NOW()),
(9018, 'TEST-7조건 전부 제약', 'EDU', 'PUB', 'QA', 'CMB-03: 전 필드 모름 → 7개 전부 확인필요·절대 제외 금지',
   20, 30, 'EH', 'MCUL', 2, NULL, 'Y', 'K', 'SEEK', NULL,
   'QA-fixture', '2026-10-01', 'A', NOW(), NOW()),
-- 기준일 뱃지 (판정과 별개)
(9019, 'TEST-기준일 12개월경과', 'DAILY', 'PUB', 'QA', 'CMN-03: 자료 기준일 확인 뱃지 표시 검증용',
   NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
   'QA-fixture', '2025-09-01', 'A', NOW(), NOW());
