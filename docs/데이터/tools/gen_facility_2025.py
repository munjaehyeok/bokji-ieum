# -*- coding: utf-8 -*-
"""2025판 seed용 복지시설현황 대조 패치 생성. 2022판 id 고정 패치(facility-refresh-20261014.sql)를 '기관명 기준'으로 다시 적용한다.
실행: python3 -I gen_facility_2025.py <시설현황대조-20261014.csv> <구 facility-refresh.sql> <new_full.tsv(resource_id,name,org_name,phone,address)> <새 seed 최대 resource_id(예 1853)> <출력 SQL> <출력 CSV>
규칙(구 대조와 동일하게 보수적): 새 행의 기관명(정규화)이 CSV의 'DB 기관명' 또는 '시설현황 시설명'과 정확히 같을 때만 대상.
 - 모든 대상: last_verified_date='2026-10-14'(대조 수행일; 근거 시설현황 2026-08-25 갱신본)
 - 확인일 표기는 '새 행의 전화(숫자)가 시설현황 대조로 확인된 번호(구 보정 후 전화)와 같을 때'만(기관명 일치만으로는 서비스별 존속을 확인한 것이 아님, R-046). 전화 갱신('전화 A→B'): 새 행의 전화가 A와 같을 때만 B로 교체(이미 다른 번호면 새 안내서 값을 존중하고 검증만 표시)
 - '전화 (없음)→B; 주소 신규': 새 행의 전화·주소가 비었을 때만 채움
 - 구 id 745 이상(복지로·보조금24 행)은 구 패치의 id를 새 행수 기준으로 이동해 그대로 옮김
"""
import sys, re, csv
def n(s): return re.sub(r'[\s\W_]+', '', str(s or ''))
digits = lambda s: re.sub(r'\D', '', str(s or ''))
rows = list(csv.DictReader(open(sys.argv[1], encoding='utf-8')))
verified_phone = {int(r['resource_id']): digits(r['phone']) for r in csv.DictReader(open(sys.argv[7], encoding='utf-8'), delimiter='\t')}
old_sql = open(sys.argv[2], encoding='utf-8').read()
new = list(csv.DictReader(open(sys.argv[3], encoding='utf-8'), delimiter='\t'))
NEW_BASE = int(sys.argv[4]); OLD_BASE = 744
assert max(int(r['resource_id']) for r in new if int(r['resource_id']) <= NEW_BASE) == NEW_BASE, '새 seed 최대 id 인수가 new_full.tsv와 맞지 않음'
addr_of = {int(m.group(2)): m.group(1) for m in re.finditer(r"address='((?:[^'\\]|\\.|'')*)'[^;]*resource_id=(\d+)", old_sql)}
# 기관 → 변경 규칙(구 대조 행에서 수집; 같은 기관에 서로 다른 규칙이 섞이면 '검증만')
rule, okphone, aphone = {}, {}, {}
for r in rows:
    i = int(r['resource_id'])
    if i > OLD_BASE: continue
    for key in (n(r['DB 기관명']), n(r['시설현황 시설명'])):
        rule.setdefault(key, []).append((r['갱신 내용'], i))
        okphone.setdefault(key, set()).add(verified_phone.get(i, ''))
        ma = re.match(r'전화 ([\d\-]+)→', r['갱신 내용'])
        if ma: aphone.setdefault(key, set()).add(digits(ma.group(1)))   # 구 번호 A: 교체 대상(검증 번호 아님)
out = ['-- 시흥시 복지시설현황(공공데이터 15117069, 2026-08-25 갱신본) 대조 — 2025판 seed 기준 재생성 (기관명 일치만 대상, 근거: docs/데이터/수집/시설현황대조-2025.csv)']
log = [['resource_id', '자원명', '기관명', '적용', '근거 규칙']]
for r in new:
    i = int(r['resource_id'])
    if i > NEW_BASE or n(r['org_name']) not in rule: continue
    key = n(r['org_name']); cands = rule[key]; ph = digits(r['phone'])
    kinds = {c[0] for c in cands}
    sets, how = None, None
    if ph and ph in okphone[key]:
        sets, how = ["last_verified_date='2026-10-14'"], '검증만(시설 확인 전화와 일치)'
    elif ph and ph in aphone.get(key, set()):
        m = re.match(r'전화 ([\d\-]+)→([\d\-]+)$', next(iter(kinds))) if len(kinds) == 1 else None
        if m and digits(m.group(1)) == ph:
            sets, how = ["last_verified_date='2026-10-14'", "phone='%s'" % m.group(2)], '전화 %s→%s' % (m.group(1), m.group(2))
    if not sets:
        log.append([i, r['name'].replace('\n', ' '), r['org_name'].replace('\n', ' '), '보류(전화가 확인 번호와 다르거나 기관 규칙 충돌)', '; '.join(sorted(kinds))]); continue
    out.append("UPDATE resource SET %s, updated_at=NOW() WHERE resource_id=%d;" % (', '.join(sets), i))
    log.append([i, r['name'].replace('\n', ' '), r['org_name'].replace('\n', ' '), how, '; '.join(sorted(kinds))])
# 구 패치 중 id>744 문장은 이동해서 유지
for m in re.finditer(r"^UPDATE resource SET [^\n]*resource_id=(\d+);$", old_sql, re.M):
    i = int(m.group(1))
    if i > OLD_BASE:
        out.append(re.sub(r'resource_id=\d+', 'resource_id=%d' % (i - OLD_BASE + NEW_BASE), m.group(0))); log.append([i - OLD_BASE + NEW_BASE, '(복지로/보조금24 행)', '', '구 패치 이동', ''])
open(sys.argv[5], 'w', encoding='utf-8').write('\n'.join(out) + '\n')
csv.writer(open(sys.argv[6], 'w', encoding='utf-8', newline='')).writerows(log)
print('대상', len(log) - 1, 'UPDATE', len(out) - 1)
