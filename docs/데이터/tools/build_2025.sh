#!/bin/bash
# 2025판 seed·패치 재생성 파이프라인 (격리 MySQL 컨테이너 필요: bokji-verify, root/verify).
# usage: OLD_REF=<2022판 커밋> docs/데이터/tools/build_2025.sh <담당자열 제외 권장 xlsx> <작업디렉터리>   (repo 루트에서; OLD_REF 필수 — 데이터 교체 PR 병합 전 커밋)
# 담당자 열이 있는 원본은 ALLOW_PERSONAL_COLUMNS=1 이 있어야 읽는다. 생성 후 반드시 docs/검증/data-gate.sh 와 회귀를 돌려 통과한 뒤 커밋한다.
# 입력 xlsx는 저장소에 올리지 않는다(담당자 개인정보 포함 가능). 결과: src/main/resources/sql/*.sql, docs/데이터/수집/*-2025.csv
set -euo pipefail
X=${1:?xlsx}; W=${2:?작업디렉터리}; T=docs/데이터/tools; SQL=src/main/resources/sql; C=docs/데이터/수집
m(){ docker exec -i bokji-verify mysql --default-character-set=utf8mb4 -uroot -pverify "$@" 2> >(grep -v 'Using a password' >&2); }   # 종료 코드 보존(set -e)
mkdir -p "$W/orig"
for f in api-update-20261014 facility-refresh-20261014 gov24-update-20261014 reliability-tagging reliability-provenance seed schema; do
  [ -f "$W/orig/$f.sql" ] || git show "${OLD_REF:?OLD_REF=2022판 커밋 필수}:$SQL/$f.sql" > "$W/orig/$f.sql"; done   # 2022판 원본(id 이관 입력)
m -e "drop database if exists olddb; create database olddb character set utf8mb4"
for f in schema seed api-update-20261014 facility-refresh-20261014 gov24-update-20261014 reliability-tagging reliability-provenance; do m olddb < "$W/orig/$f.sql"; done
[ "$(m -N olddb -e 'select count(*) from resource')" = 792 ] || { echo 'OLD_REF가 2022판(활성 792건)이 아닙니다' >&2; exit 1; }
m -B olddb -e "select resource_id,name,org_name,category,provider_type,source_name from resource" > "$W/old_db.tsv"
m -B olddb -e "select resource_id,phone from resource" > "$W/old_phone.tsv"
python3 -I $T/parse_tag_2025.py "$X" "$W/seed.sql" "$C/분류매핑-2025.csv"
m -e "drop database if exists newdb; create database newdb character set utf8mb4"; m newdb < "$W/orig/schema.sql"; m newdb < "$W/seed.sql"
m -B newdb -e "select resource_id,name,org_name from resource" > "$W/new_db.tsv"
m -B newdb -e "select resource_id,name,org_name,phone,address from resource" > "$W/new_full.tsv"
MAXID=$(m -N newdb -e "select max(resource_id) from resource"); : > "$W/idmap.csv"; mkdir -p "$W/patched"
for f in gov24-update-20261014 reliability-provenance reliability-tagging api-update-20261014; do
  python3 -I $T/remap_ids_2025.py "$W/old_db.tsv" "$W/new_db.tsv" "$MAXID" "$W/orig/$f.sql" "$W/patched/$f.sql" "$W/idmap.csv"; done
python3 -I $T/gen_facility_2025.py "$C/시설현황대조-20261014.csv" "$W/orig/facility-refresh-20261014.sql" "$W/new_full.tsv" "$MAXID" "$W/patched/facility-refresh-20261014.sql" "$C/시설현황대조-2025.csv" "$W/old_phone.tsv"
sed -i.bak "s/2022-12-31/2025-12-31/g" "$W/patched/reliability-provenance.sql" && rm -f "$W/patched/reliability-provenance.sql.bak"
cp "$W/seed.sql" $SQL/seed.sql; cp "$W"/patched/*.sql $SQL/
cat $T/extra-tagging-2025.sql >> $SQL/reliability-tagging.sql   # 2025판 전용 보정 추가
python3 -I - "$W" "$C" <<'PY'
import csv, re, sys
W, C = sys.argv[1] + '/', sys.argv[2] + '/'
rows = list(csv.reader(open(W + 'idmap.csv', encoding='utf-8')))
w = csv.writer(open(C + 'id이관-2025.csv', 'w', encoding='utf-8', newline=''))
w.writerow(['패치 파일', '구 resource_id', '구 자원명', '새 resource_id(빈칸=이관 불가·문장 제거)', '방식'])
w.writerows([[r[0].rsplit('/', 1)[-1].replace('orig_', '')] + r[1:] for r in rows])
n = lambda s: re.sub(r'[\s\W_]+', '', str(s or ''))
old = [r for r in csv.DictReader(open(W + 'old_db.tsv', encoding='utf-8'), delimiter='\t') if r['source_name'].startswith('시흥시 복지자원')]
new = [r for r in csv.DictReader(open(W + 'new_db.tsv', encoding='utf-8'), delimiter='\t')]
nn = {n(r['name']) for r in new}; nk = {(n(r['name']), n(r['org_name'])) for r in new}
ver = {int(r['resource_id']) for r in csv.DictReader(open(C + '시설현황대조-20261014.csv', encoding='utf-8'))}
w = csv.writer(open(C + '2022판-제외목록-20261125.csv', 'w', encoding='utf-8', newline=''))
w.writerow(['구 resource_id', '자원명', '제공기관', '카테고리', '구분', '2026-10 시설현황 대조 있음', '판정', '비고'])
for r in old:
    if (n(r['name']), n(r['org_name'])) in nk: continue
    j = '기관 상이·동명 후보(확인 필요)' if n(r['name']) in nn else '새 목록에 없음(종료·개편·명칭변경 미확인)'
    w.writerow([r['resource_id'], r['name'].replace('\n', ' '), r['org_name'].replace('\n', ' '), r['category'], r['provider_type'], 'Y' if int(r['resource_id']) in ver else '', j, '새 DB에 id 이관 없음'])
PY
