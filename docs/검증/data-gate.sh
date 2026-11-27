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
ok "적재 후 활성 901건(보정 전)" "$(Q "select count(*) from resource where status='A'")" 901
BEFORE=$(snap); apply_fix; AFTER1=$(snap); apply_fix; AFTER2=$(snap)
[ "$BEFORE" != "$AFTER1" ] && echo "PASS 보정 SQL이 데이터를 실제로 변경" || { echo "FAIL 보정 SQL 무변화"; FAIL=1; }
ok "멱등(2회 적용 = 1회 적용)" "$AFTER2" "$AFTER1"

# id는 seed 행 순서라 데이터 교체 때마다 바뀐다 — 핵심 행은 이름으로 찾는다(2025판 seed 기준).
# 정상 최신화(본문 대조 반영)가 있었던 뒤 재적용해도 보존되는가 — 보정 SQL이 실제로 기준일을 바꾸는(복원하는) 행 하나를 골라 검증한다.
# reliability-provenance 가 2026-09-22 → 2025-05-31 로 복원하는 복지로 행(보조금24 매칭분)을 대상으로 삼는다.
T=$(Q "select resource_id from resource where source_name like '복지로%' and data_base_date='2025-05-31' limit 1")
ok "복원 패치 적용: 복지로 행 1건이 본문 기준일 2025-05-31로 복원" "$(Q "select count(*) from resource where source_name like '복지로%' and data_base_date='2025-05-31'")" 1
Q "update resource set data_base_date='2026-10-20' where resource_id=$T" >/dev/null
apply_fix
ok "후속 정상 최신화 보존(기준일 2026-10-20)" "$(Q "select data_base_date from resource where resource_id=$T")" 2026-10-20
Q "update resource set data_base_date='2025-05-31' where resource_id=$T" >/dev/null   # 스냅샷 기준 상태로 복귀
ok "seed 유래 행에 2025 외 기준일 없음" "$(Q "select count(*) from resource where source_name like '시흥시 복지자원%' and year(data_base_date)<>2025")" 0
ok "id 대역: 안내서 행은 1001~1853(2022판 id와 불충돌)" "$(Q "select concat(min(resource_id),'-',max(resource_id)) from resource where source_name like '시흥시 복지자원%'")" "1001-1853"
ok "출생축하금 지원: 안내서·복지로 병존 표기가 두 행 모두, 1회씩" "$(Q "select count(*) from resource where name='출생축하금 지원' and uncertain_note like '%다른 출처%' and (length(uncertain_note)-length(replace(uncertain_note,'다른 출처','')))/length('다른 출처')=1")" 2
ok "데이터 분할: 활성−F전용 = 국적 NULL·K 수" "$(Q "select count(*)-sum(nationality='F') from resource where status='A'")" "$(Q "select count(*) from resource where status='A' and (nationality is null or nationality<>'F')")"
ok "고정 수치 활성/PUB/PRV/F전용" "$(Q "select concat(count(*),'/',sum(provider_type='PUB'),'/',sum(provider_type='PRV'),'/',sum(nationality='F')) from resource where status='A'")" "901/471/430/7"
ok "고정 수치 출처별(안내서 853·API 24·보조금24 24)" "$(Q "select group_concat(c order by s) from (select source_name s, count(*) c from resource group by 1) t")" "24,24,853"
ok "고정 수치 기준일 2026/2025/2022" "$(Q "select concat(sum(year(data_base_date)=2026),'/',sum(year(data_base_date)=2025),'/',sum(year(data_base_date)=2022)) from resource where status='A'")" "47/854/0"
ok "고위험 임산부: F 태그 없음(R-024)" "$(Q "select count(*) from resource where name like '고위험 임산부%' and nationality is not null")" 0
ok "국적 F 는 엄격 기준(외국인주민·결혼이민자 등)만 — 다문화가족·이주배경·내/외국인 표기 행은 F 아님(R-025·R-026)" "$(Q "select count(*) from resource where nationality='F' and source_name like '시흥시 복지자원%' and (name like '%다문화가족%' or eligibility_raw like '%내/외국인%' or eligibility_raw like '%비이주%' or eligibility_raw like '%선주민%')")" 0
ok "집수리: 연령 태그 없음" "$(Q "select count(*) from resource where name='동네관리소 간단 집수리 지원' and age_min is not null")" 0
ok "전동보장구보험: 연령·장애 태그 없음" "$(Q "select count(*) from resource where name='장애인 전동보장구 배상책임보험' and (age_min is not null or disability is not null)")" 0
ok "효도수당: 연령 태그 없음" "$(Q "select count(*) from resource where name='효도수당' and age_min is not null")" 0
ok "해제 3건 메모 보유·중복 없음" "$(Q "select count(*) from resource where name in ('동네관리소 간단 집수리 지원','장애인 전동보장구 배상책임보험','효도수당') and uncertain_note is not null and (length(uncertain_note)-length(replace(uncertain_note,' / ','')))/3 <= 1")" 3
ok "seed 유래 행 중 기준일 복원 대상(보조금24 매칭)이 2026 기준일로 남지 않음" "$(Q "select count(*) from resource where source_name like '시흥시 복지자원%' and year(data_base_date)=2026")" 0
# 신청 링크 보완(2026-11-27): 도메인만 적힌 55건에 https:// — 멱등, 원문 도메인과 일치, 이름 불일치 행 무변경
AU0=$(Q "select count(*) from resource where status='A' and apply_url<>''")
load apply-url-fix-20261127.sql
AU1=$(Q "select count(*) from resource where status='A' and apply_url<>''")
ok "신청 링크 보완: 55건 증가" "$((AU1-AU0))" 55
SNAPAU=$(Q "select md5(group_concat(concat_ws('|',resource_id,ifnull(apply_url,'N')) order by resource_id)) from resource")
load apply-url-fix-20261127.sql
ok "신청 링크 보완 멱등(2회째 무변화)" "$(Q "select md5(group_concat(concat_ws('|',resource_id,ifnull(apply_url,'N')) order by resource_id)) from resource")" "$SNAPAU"
ok "보완 링크는 https:// 로 시작하고 원문(신청방법)에 같은 도메인이 있음" "$(Q "select count(*) from resource where apply_url like 'https://%' and apply_method is not null and locate(substr(apply_url,9), apply_method)=0 and resource_id in (1002,1058,1073,1181,1454,1851,1852)")" 0
ok "전 필드 모름 노출 = 활성 − F전용 불변식 유지" "$(Q "select count(*) from resource where status='A' and (nationality is null or nationality<>'F')")" 894
exit $FAIL
