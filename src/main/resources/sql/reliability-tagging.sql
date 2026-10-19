-- 신뢰도 보정 1 (2026-10-19): 일부 대상/택일(OR) 조건을 전체 필수조건으로 저장한 보조금24 2건 해제.
-- 멱등: 이름+출처로 지정, 이미 NULL이면 변화 없음. 원문(eligibility_raw·support_content)은 보존.
UPDATE resource
   SET age_min = NULL,
       uncertain_note = CONCAT_WS(' / ', uncertain_note, '연령(만65세 이상)은 독거노인 대상에만 해당 — 다른 대상(수급자·차상위 등)은 연령 무관, 확인 필요'),
       updated_at = NOW()
 WHERE name = '동네관리소 간단 집수리 지원'
   AND source_name = '보조금24(대한민국 공공서비스 정보)'
   AND age_min IS NOT NULL;

UPDATE resource
   SET age_min = NULL,
       disability = NULL,
       uncertain_note = CONCAT_WS(' / ', uncertain_note, '대상이 "등록 장애인 또는 만65세 이상" 택일 — 어느 한쪽만 충족해도 해당, 확인 필요'),
       updated_at = NOW()
 WHERE name = '장애인 전동보장구 배상책임보험'
   AND source_name = '보조금24(대한민국 공공서비스 정보)'
   AND (age_min IS NOT NULL OR disability IS NOT NULL);

UPDATE resource
   SET age_min = NULL,
       uncertain_note = CONCAT_WS(' / ', uncertain_note, '대상은 "1세대가 만 70세 이상인 3세대 가구"(관내 5년 이상 동거) — 입력자 본인 연령이 아닌 가구 조건, 개별 확인 필요'),
       updated_at = NOW()
 WHERE name = '효도수당'
   AND source_name = '복지로 지자체복지서비스 API'
   AND age_min IS NOT NULL;
