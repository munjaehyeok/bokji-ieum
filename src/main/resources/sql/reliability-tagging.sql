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

-- 신뢰도 보정 2 (2026-10-23, R-024 교차확인): '외국인 전용(F)'으로 태깅됐으나 원문은 "외국 국적인 및 국외 이주자"를 지원제외로 두고
-- 영주권·결혼이주(F5·F6) 등 일부만 예외 허용 — 내국인 임산부가 목록에서 제외되는 오제외(false negative)였다. F 태그를 해제하고 확인필요로 남긴다.
-- 멱등: 이미 NULL이면 변화 없음. 원문(eligibility_raw)은 보존.
UPDATE resource
   SET nationality = NULL,
       uncertain_note = CONCAT_WS(' / ', uncertain_note, '국적: 외국 국적자는 원칙적 지원제외(영주권·결혼이주 F5·F6·난민 등 예외 허용) — 외국인 전용이 아님, 확인 필요'),
       updated_at = NOW()
 WHERE resource_id = 181
   AND name = '고위험 임산부 의료비 지원사업'
   AND nationality = 'F';

-- 신뢰도 보정 3 (2026-10-23, R-025): 'F(외국인 전용)'이나 원문이 내국인(비이주배경·선주민)도 대상으로 명시한 2건. 내국인 오제외 방지로 F 해제 + 확인필요.
-- 멱등: 이미 NULL이면 변화 없음. 원문 보존. (다문화·외국인 병기만 있는 나머지 F 행은 원문이 내국인 포함을 명시하지 않아 유지)
UPDATE resource
   SET nationality = NULL,
       uncertain_note = CONCAT_WS(' / ', uncertain_note, '국적: 원문이 비이주배경(내국인) 아동도 대상으로 명시 — 외국인 전용이 아님, 확인 필요'),
       updated_at = NOW()
 WHERE resource_id = 479 AND name = '이주배경청소년문화지원사업' AND nationality = 'F';

UPDATE resource
   SET nationality = NULL,
       uncertain_note = CONCAT_WS(' / ', uncertain_note, '국적: 참여대상에 관내 선주민(내국인)이 포함 — 외국인 전용이 아님, 확인 필요'),
       updated_at = NOW()
 WHERE resource_id = 755 AND name = '결혼이민자 한국사회 이해증진' AND nationality = 'F';
