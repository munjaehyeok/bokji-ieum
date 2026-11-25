-- 담당 기관 주소 오타 정정 (지도 표시용). 여러 번 실행해도 안전하다.
--   시흥식 금오로 → 시흥시 금오로 / 경기시 → 경기도 / 경시도 → 경기도 / 서재로 7번길 → 새재로 7번길
-- 사용: mysql -ubokji -p --default-character-set=utf8mb4 bokji < src/main/resources/sql/address-typo-fix-20261125.sql
UPDATE resource SET address = REPLACE(address, '시흥식 금오로', '시흥시 금오로') WHERE address LIKE '%시흥식 금오로%';
UPDATE resource SET address = REPLACE(address, '경기시 시흥시 포도원로', '경기도 시흥시 포도원로') WHERE address LIKE '%경기시 시흥시 포도원로%';
UPDATE resource SET address = REPLACE(address, '경시도 시흥시 소래산길', '경기도 시흥시 소래산길') WHERE address LIKE '%경시도 시흥시 소래산길%';
UPDATE resource SET address = REPLACE(address, '서재로 7번길 6-1', '새재로 7번길 6-1') WHERE address LIKE '%서재로 7번길 6-1%';
