
-- 신뢰도 보정 5 (2026-11-25, R-047): 같은 이름 '출생축하금 지원'이 안내서(2025 하반기)와 복지로 API에 병존 — 대상(첫째/둘째 등)·적용 연도·금액이 서로 다를 수 있다.
-- 멱등: 이미 표기돼 있으면 변화 없음. 원문은 보존.
UPDATE resource
   SET uncertain_note = CONCAT_WS(' / ', uncertain_note, '같은 이름의 안내가 다른 출처(안내서·복지로)에도 있음 — 대상(첫째/둘째 등)·적용 연도·금액이 다를 수 있어 담당부서 확인 필요'),
       updated_at = NOW()
 WHERE name = '출생축하금 지원'
   AND (uncertain_note IS NULL OR uncertain_note NOT LIKE '%다른 출처%');
