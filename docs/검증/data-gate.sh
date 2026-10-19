#!/bin/bash
# 데이터 게이트 (AGENTS.md): 빈 DB 적재 → 신뢰도 보정 SQL 2회 적용 → 멱등·불변식·핵심 행 단언. 실패 시 exit 1.
# usage: docs/검증/data-gate.sh [컨테이너=bokji-verify]   (repo 루트에서)
# 준비: docker run -d --name bokji-verify -e MYSQL_ROOT_PASSWORD=verify -e MYSQL_DATABASE=bokji mysql:8 --character-set-server=utf8mb4
set -u
C=${1:-bokji-verify}; S=src/main/resources/sql; FAIL=0
M(){ docker exec -i "$C" mysql --default-character-set=utf8mb4 -uroot -pverify bokji "$@" 2>&1 | grep -v Warning; }
Q(){ M -N -e "$1"; }
snap(){ Q "set session group_concat_max_len=100000000; select md5(group_concat(concat_ws('|',resource_id,name,ifnull(age_min,'N'),ifnull(age_max,'N'),ifnull(disability,'N'),ifnull(data_base_date,'N'),ifnull(last_verified_date,'N'),ifnull(uncertain_note,'N'),ifnull(phone,'N')) order by resource_id)) from resource"; }
ok(){ if [ "$2" = "$3" ]; then echo "PASS $1"; else echo "FAIL $1 (기대 '$3', 실제 '$2')"; FAIL=1; fi; }

M -e "drop database bokji; create database bokji character set utf8mb4"
for f in schema.sql seed.sql api-update-20261014.sql facility-refresh-20261014.sql gov24-update-20261014.sql; do M < $S/$f | grep -i error && FAIL=1; done
BEFORE=$(snap)
for r in 1 2; do for f in reliability-tagging.sql reliability-provenance.sql; do M < $S/$f | grep -i error && FAIL=1; done; [ $r = 1 ] && AFTER1=$(snap); done
AFTER2=$(snap)
[ "$BEFORE" != "$AFTER1" ] && echo "PASS 보정 SQL이 데이터를 실제로 변경" || { echo "FAIL 보정 SQL 무변화"; FAIL=1; }
ok "멱등(2회 적용 = 1회 적용)" "$AFTER2" "$AFTER1"
ok "불변식 노출=전체−F전용" "$(Q "select count(*)-sum(nationality='F') from resource where status='A'")" "$(Q "select count(*) from resource where status='A' and (nationality is null or nationality<>'F')")"
ok "집수리: 연령 태그 없음" "$(Q "select count(*) from resource where name='동네관리소 간단 집수리 지원' and age_min is not null")" 0
ok "전동보장구보험: 연령·장애 태그 없음" "$(Q "select count(*) from resource where name='장애인 전동보장구 배상책임보험' and (age_min is not null or disability is not null)")" 0
ok "효도수당: 연령 태그 없음" "$(Q "select count(*) from resource where name='효도수당' and age_min is not null")" 0
ok "해제 3건 모두 확인필요 메모 보유" "$(Q "select count(*) from resource where name in ('동네관리소 간단 집수리 지원','장애인 전동보장구 배상책임보험','효도수당') and uncertain_note is not null")" 3
ok "자원 315: 본문 기준일 2022 복원·목록매칭 확인일 제거" "$(Q "select concat(data_base_date,'/',ifnull(last_verified_date,'NULL')) from resource where resource_id=315")" "2022-12-31/NULL"
ok "본문 미대조 기준일 상향 잔존 0 (seed 유래 id 15,65,66,67,200,234,315)" "$(Q "select count(*) from resource where resource_id in (15,65,66,67,200,234,315) and year(data_base_date)>2022")" 0
Q "select concat('활성=',count(*),' F전용=',sum(nationality='F'),' 기준일2026=',sum(year(data_base_date)=2026),' 기준일2022=',sum(year(data_base_date)=2022)) from resource where status='A'"
exit $FAIL
