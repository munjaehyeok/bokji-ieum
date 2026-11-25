# -*- coding: utf-8 -*-
"""2022판 seed(744행) 기준으로 쓰인 resource_id 고정 패치 SQL을 2025판 seed 기준으로 옮긴다.
실행: python3 -I remap_ids_2025.py <old_db.tsv> <new_db.tsv> <새 seed 최대 resource_id(안내서 행의 마지막 id, 예 1853)> <입력 SQL> <출력 SQL> <대응 CSV>
 old_db.tsv/new_db.tsv = resource 덤프(resource_id,name,org_name). 규칙:
 - id 1..744(구 seed 행): 정규화한 서비스명+기관명이 새 seed에서 정확히 1건 일치할 때만 그 id. 그 외(이름만 일치 포함)는 '이관 불가'(문장 제거).
 - id 745 이상(구 패치가 INSERT한 행): 새 행수 − 744 만큼 이동(패치 적재 순서 유지).
 - 문장 안의 id 목록(IN (...) 포함)이 전부 이관 불가이면 문장을 제거, 일부만이면 가능한 id만 남긴다.
"""
import sys, re, csv

def n(s): return re.sub(r'[\s\W_]+', '', str(s or ''))
old = {int(r['resource_id']): r for r in csv.DictReader(open(sys.argv[1], encoding='utf-8'), delimiter='\t')}
new = list(csv.DictReader(open(sys.argv[2], encoding='utf-8'), delimiter='\t'))
NEW_BASE, OLD_BASE = int(sys.argv[3]), 744
assert max(int(r['resource_id']) for r in new if int(r['resource_id']) <= NEW_BASE) == NEW_BASE and not any(NEW_BASE < int(r['resource_id']) < NEW_BASE + 1 for r in new), '새 seed 최대 id 인수가 new_db.tsv와 맞지 않음'
by_name, by_key = {}, {}
for r in new:
    i = int(r['resource_id'])
    if i > NEW_BASE: continue
    by_name.setdefault(n(r['name']), []).append(i)
    by_key.setdefault((n(r['name']), n(r['org_name'])), []).append(i)

def mapid(i):
    """return (new_id or None, 방식)"""
    if i > OLD_BASE: return i - OLD_BASE + NEW_BASE, 'offset'
    o = old[i]
    c = by_key.get((n(o['name']), n(o['org_name'])), [])
    if len(c) == 1: return c[0], 'name+org'
    # 서비스명만 같고 제공기관이 다른 경우는 같은 사업이라는 근거가 없어 이관하지 않는다(R-046).
    c = by_name.get(n(o['name']), [])
    return None, ('이름만 일치(기관 상이) %d건' % len(c)) if c else '새 목록에 없음'

log = []
def ids_in(stmt):
    out = []
    for m in re.finditer(r'resource_id\s*=\s*(\d+)', stmt): out.append(int(m.group(1)))
    for m in re.finditer(r'resource_id\s+IN\s*\(([\d,\s]+)\)', stmt): out += [int(x) for x in m.group(1).split(',')]
    return out

def rewrite(stmt):
    ids = ids_in(stmt)
    if not ids: return stmt
    res = {i: mapid(i) for i in ids}
    for i, (j, how) in res.items(): log.append((i, old[i]['name'].replace('\n', ' ') if i in old else '(구 패치 INSERT 행)', j or '', how))
    ok = {i: j for i, (j, _) in res.items() if j}
    if not ok: return None
    if re.search(r'resource_id\s+IN\s*\(', stmt):
        def sub_in(m):
            kept = [str(ok[int(x)]) for x in m.group(1).split(',') if int(x) in ok]
            return 'resource_id IN (%s)' % ', '.join(kept)
        stmt = re.sub(r'resource_id\s+IN\s*\(([\d,\s]+)\)', sub_in, stmt)
    def sub_eq(m):
        i = int(m.group(1))
        return 'resource_id=%d' % ok[i] if m.group(0).replace(' ', '') == m.group(0) else 'resource_id = %d' % ok[i]
    if len(ids) == 1 and ids[0] not in ok: return None
    return re.sub(r'resource_id\s*=\s*(\d+)', lambda m: ('resource_id=' if '=' in m.group(0) and ' ' not in m.group(0) else 'resource_id = ') + str(ok[int(m.group(1))]) if int(m.group(1)) in ok else m.group(0), stmt)

src = open(sys.argv[4], encoding='utf-8').read()
# 문장 단위 분리: 세미콜론 + 줄끝 (문자열 안의 ; 은 줄 끝에 오지 않는다고 가정)
parts = re.split(r'(?<=;)\n', src)
out, dropped = [], 0
for p in parts:
    body = re.sub(r'(?m)^--.*\n?', '', p)
    if 'resource_id' in body and re.match(r'\s*UPDATE', body):
        r = rewrite(p)
        if r is None: dropped += 1; out.append('-- [이관 불가로 제거] ' + body.strip().replace('\n', ' ')[:120]); continue
        out.append(r)
    else:
        out.append(p)
text = '\n'.join(out)
open(sys.argv[5], 'w', encoding='utf-8').write(text if text.endswith('\n') else text + '\n')
with open(sys.argv[6], 'a', encoding='utf-8', newline='') as fo:
    w = csv.writer(fo)
    seen = set()
    for row in log:
        if (sys.argv[4], row[0]) in seen: continue
        seen.add((sys.argv[4], row[0])); w.writerow([sys.argv[4].rsplit('/', 1)[-1]] + list(row))
print(sys.argv[4].rsplit('/', 1)[-1], '문장 제거', dropped, '대응', len(seen), '이관불가', sum(1 for r in log if not r[2]))
