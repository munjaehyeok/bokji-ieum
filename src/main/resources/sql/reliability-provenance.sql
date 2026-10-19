-- 신뢰도 보정 2 (2026-10-19): 본문을 대조하지 않은 채 원천 수정일로 올린 기준일을 본문 출처의 기준일로 복원.
-- 근거: docs/데이터/수집/기준일복원-20261019.csv. 알려진 잘못된 상태(변경 전 값 = CSV '잘못된 값')와 정확히 같을 때만 갱신 — 이후 정상 최신화는 보존. 존속·연락처 확인은 last_verified_date로 유지.
-- 자원 315는 '(추가형)'과 동일 사업인지 불확실 — 목록 매칭을 확인 근거로 쓰지 않도록 last_verified_date도 되돌린다(시설현황 대조 대상 아님).
UPDATE resource SET data_base_date='2022-12-31', updated_at=NOW() WHERE resource_id=15 AND data_base_date='2026-09-21';
UPDATE resource SET data_base_date='2022-12-31', updated_at=NOW() WHERE resource_id=65 AND data_base_date='2026-09-21';
UPDATE resource SET data_base_date='2022-12-31', updated_at=NOW() WHERE resource_id=66 AND data_base_date='2026-09-26';
UPDATE resource SET data_base_date='2022-12-31', updated_at=NOW() WHERE resource_id=67 AND data_base_date='2026-09-21';
UPDATE resource SET data_base_date='2022-12-31', updated_at=NOW() WHERE resource_id=200 AND data_base_date='2026-08-28';
UPDATE resource SET data_base_date='2022-12-31', updated_at=NOW() WHERE resource_id=234 AND data_base_date='2026-09-21';
UPDATE resource SET data_base_date='2022-12-31', updated_at=NOW() WHERE resource_id=315 AND data_base_date='2026-08-26';
UPDATE resource SET data_base_date='2026-07-29', updated_at=NOW() WHERE resource_id=747 AND data_base_date='2026-08-25';
UPDATE resource SET data_base_date='2026-07-29', updated_at=NOW() WHERE resource_id=748 AND data_base_date='2026-08-25';
UPDATE resource SET data_base_date='2026-08-15', updated_at=NOW() WHERE resource_id=750 AND data_base_date='2026-09-21';
UPDATE resource SET data_base_date='2025-05-31', updated_at=NOW() WHERE resource_id=758 AND data_base_date='2026-09-22';
UPDATE resource SET data_base_date='2026-07-29', updated_at=NOW() WHERE resource_id=761 AND data_base_date='2026-08-25';
UPDATE resource SET data_base_date='2026-06-30', updated_at=NOW() WHERE resource_id=764 AND data_base_date='2026-09-23';
UPDATE resource SET data_base_date='2026-07-29', updated_at=NOW() WHERE resource_id=765 AND data_base_date='2026-08-25';
UPDATE resource SET data_base_date='2026-06-30', updated_at=NOW() WHERE resource_id=766 AND data_base_date='2026-09-23';
UPDATE resource SET data_base_date='2026-07-23', updated_at=NOW() WHERE resource_id=768 AND data_base_date='2026-09-21';
UPDATE resource SET last_verified_date=NULL, updated_at=NOW() WHERE resource_id=315 AND data_base_date='2022-12-31' AND last_verified_date='2026-10-14';
