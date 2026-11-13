#!/bin/sh
# MySQL 컨테이너가 "빈 볼륨"으로 처음 뜰 때만 자동 실행된다 (docker-entrypoint-initdb.d).
# 적재 순서가 중요하다: schema → seed → API/시설/보조금24 갱신 → 신뢰도 보정 2종.
set -e
for f in schema seed api-update-20261014 facility-refresh-20261014 gov24-update-20261014 reliability-tagging reliability-provenance; do
  echo "[bokji] loading $f.sql"
  mysql --default-character-set=utf8mb4 -uroot -p"$MYSQL_ROOT_PASSWORD" "$MYSQL_DATABASE" < "/sql/$f.sql"
done
echo "[bokji] 적재 완료: 활성 자원 $(mysql -N -uroot -p"$MYSQL_ROOT_PASSWORD" "$MYSQL_DATABASE" -e "select count(*) from resource where status='A'")건 (기대값 792)"
