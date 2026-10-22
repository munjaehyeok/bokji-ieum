#!/bin/bash
# 데이터 게이트: 빈 DB 적재 → 보정 SQL 적용 → 멱등 → 정상 최신화 보존 → 핵심 행·고정 수치 단언. 실패 시 exit 1.
# usage: docs/검증/data-gate.sh [컨테이너=bokji-verify]   (repo 루트에서; 대상 DB bokji를 DROP하므로 격리 컨테이너 전용)
# 준비: docker run -d --name bokji-verify -e MYSQL_ROOT_PASSWORD=verify -e MYSQL_DATABASE=bokji -p 3399:3306 mysql:8 --character-set-server=utf8mb4
# 앱 단 회귀(실제 매퍼)는 이 DB를 보는 앱을 띄운 뒤 docs/검증/match-regression.py 로 따로 실행한다.
set -u
C=${1:-bokji-verify}; S=src/main/resources/sql; FAIL=0
M(){ local out rc; out=$(docker exec -i "$C" mysql --default-character-set=utf8mb4 -uroot -pverify bokji "$@" 2>&1); rc=$?; printf '%s\n' "$out" | grep -v 'Using a password'; [ $rc -eq 0 ] && ! printf '%s' "$out" | grep -q '^ERROR' ; }
Q(){ M -N -e "$1"; }
snap(){ Q "set session group_concat_max_len=100000000; select md5(group_concat(concat_ws('|',resource_id,name,ifnull(age_min,'N'),ifnull(age_max,'N'),ifnull(disability,'N'),ifnull(data_base_date,'N'),ifnull(last_verified_date,'N'),ifnull(uncertain_note,'N'),ifnull(phone,'N')) order by resource_id)) from resource"; }
ok(){ if [ "$2" = "$3" ]; then echo "PASS $1"; else echo "FAIL $1 (기대 '$3', 실제 '$2')"; FAIL=1; fi; }
load(){ M < "$S/$1" >/dev/null || { echo "FAIL 적재 오류: $1"; FAIL=1; }; }
apply_fix(){ load reliability-tagging.sql; load reliability-provenance.sql; }

M -e "drop database if exists bokji; create database bokji character set utf8mb4" >/dev/null || { echo "FAIL DB 초기화"; exit 1; }
for f in schema.sql seed.sql api-update-20261014.sql facility-refresh-20261014.sql gov24-update-20261014.sql; do load $f; done
ok "적재 후 활성 792건(보정 전)" "$(Q "select count(*) from resource where status='A'")" 792
BEFORE=$(snap); apply_fix; AFTER1=$(snap); apply_fix; AFTER2=$(snap)
[ "$BEFORE" != "$AFTER1" ] && echo "PASS 보정 SQL이 데이터를 실제로 변경" || { echo "FAIL 보정 SQL 무변화"; FAIL=1; }
ok "멱등(2회 적용 = 1회 적용)" "$AFTER2" "$AFTER1"

# 정상 최신화(본문 대조 반영·확인일 갱신)가 있었던 뒤 재적용해도 보존되는가
Q "update resource set data_base_date='2026-10-20' where resource_id=15; update resource set last_verified_date='2026-10-25' where resource_id=315; update resource set data_base_date='2026-10-21' where resource_id=750;" >/dev/null
apply_fix
ok "후속 정상 최신화 보존(15: 2026-10-20)" "$(Q "select data_base_date from resource where resource_id=15")" 2026-10-20
ok "후속 정상 최신화 보존(315 확인일 2026-10-25)" "$(Q "select last_verified_date from resource where resource_id=315")" 2026-10-25
ok "후속 정상 최신화 보존(750: 2026-10-21)" "$(Q "select data_base_date from resource where resource_id=750")" 2026-10-21
Q "update resource set data_base_date='2022-12-31' where resource_id=15; update resource set last_verified_date=NULL where resource_id=315; update resource set data_base_date='2026-08-15' where resource_id=750;" >/dev/null   # 스냅샷 기준 상태로 복귀

ok "데이터 분할: 활성−F전용 = 국적 NULL·K 수" "$(Q "select count(*)-sum(nationality='F') from resource where status='A'")" "$(Q "select count(*) from resource where status='A' and (nationality is null or nationality<>'F')")"
ok "고정 수치 활성/PUB/PRV/F전용" "$(Q "select concat(count(*),'/',sum(provider_type='PUB'),'/',sum(provider_type='PRV'),'/',sum(nationality='F')) from resource where status='A'")" "792/246/546/20"
ok "고정 수치 기준일 2026/2022" "$(Q "select concat(sum(year(data_base_date)=2026),'/',sum(year(data_base_date)=2022)) from resource where status='A'")" "47/744"
ok "181 고위험임산부: F 태그 해제·메모 1회(R-024)" "$(Q "select concat(ifnull(nationality,'NULL'),'/',((length(uncertain_note)-length(replace(uncertain_note,'외국인 전용이 아님',''))) div length('외국인 전용이 아님'))) from resource where resource_id=181")" "NULL/1"
ok "479·755: F 태그 해제(R-025)" "$(Q "select count(*) from resource where resource_id in (479,755) and nationality is null and uncertain_note like '%외국인 전용이 아님%'")" 2
ok "집수리: 연령 태그 없음" "$(Q "select count(*) from resource where name='동네관리소 간단 집수리 지원' and age_min is not null")" 0
ok "전동보장구보험: 연령·장애 태그 없음" "$(Q "select count(*) from resource where name='장애인 전동보장구 배상책임보험' and (age_min is not null or disability is not null)")" 0
ok "효도수당: 연령 태그 없음" "$(Q "select count(*) from resource where name='효도수당' and age_min is not null")" 0
ok "해제 3건 메모 보유·중복 없음" "$(Q "select count(*) from resource where name in ('동네관리소 간단 집수리 지원','장애인 전동보장구 배상책임보험','효도수당') and uncertain_note is not null and (length(uncertain_note)-length(replace(uncertain_note,' / ','')))/3 <= 1")" 3
ok "자원 315: 본문 기준일 2022 복원·목록매칭 확인일 제거" "$(Q "select concat(data_base_date,'/',ifnull(last_verified_date,'NULL')) from resource where resource_id=315")" "2022-12-31/NULL"
ok "seed 유래 7건 본문 기준일 2022" "$(Q "select count(*) from resource where resource_id in (15,65,66,67,200,234,315) and data_base_date<>'2022-12-31'")" 0
exit $FAIL
