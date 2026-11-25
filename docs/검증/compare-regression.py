#!/usr/bin/env python3
"""상세 판정표 '내 조건 vs 공고 조건' 회귀 (서버 :8099 필요). 판정은 SQL 태그, 이 표는 표시만 — 값 대응을 검사한다."""
import urllib.request, urllib.parse, http.cookiejar, re, sys, subprocess
def rid_of(name):
    # id 하드코딩 금지: 활성 행을 이름으로 조회(옛 seed id는 2025판 교체로 전부 바뀜)
    r = subprocess.run(['docker', 'exec', 'bokji-verify', 'mysql', '-uroot', '-pverify', '--default-character-set=utf8mb4', 'bokji', '-N', '-e',
                        "select resource_id from resource where status='A' and name='%s' order by resource_id limit 1" % name], capture_output=True, text=True)
    return int(r.stdout.split()[0])
B = 'http://127.0.0.1:8099'
bad = 0
def rows(form, rid=None, lang='ko'):
    rid = rid or MAIN
    op = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(http.cookiejar.CookieJar()))
    op.open(B + '/match?lang=' + lang, urllib.parse.urlencode(form).encode()).read()
    h = op.open(B + '/resources/%d?lang=%s' % (rid, lang)).read().decode()
    t = h[h.index('bk-judge-table'):]; t = t[:t.index('</table>')]
    return [[re.sub(r'<[^>]+>|\s+', ' ', x).strip() for x in re.findall(r'<t[hd][^>]*>(.*?)</t[hd]>', r, re.S)]
            for r in re.findall(r'<tr>(.*?)</tr>', t, re.S)][1:]
def check(name, cond):
    global bad
    print(('PASS ' if cond else 'FAIL ') + name); bad += (not cond)
MAIN = rid_of('노인맞춤돌봄 특화서비스')  # 60세 이상 + 동 목록에 정왕본동(JWB)
base = [('birthYear', 1946), ('incomeRank', 1), ('disability', 'N'), ('nationality', 'K'), ('householdTypes', 'ONE'), ('dong', 'JWB')]
DET = rid_of('영양플러스사업')  # rank 3 + 불확실 → '소득 세부기준 확인' 행
rd = {x[0]: x for x in rows(base, DET)}
r = {x[0]: x for x in rows(base)}
check('일치: 연령 80세 vs 60세 이상', r['연령'][1:] == ['80세', '60세 이상', '일치'])
check('일치: 동 정왕본동 ∈ 공고 동 목록', r['거주 동'][1] == '정왕본동' and '정왕본동' in r['거주 동'][2] and r['거주 동'][3] == '일치')
check('확인필요: 소득 세부기준 문구', rd['소득 세부기준 확인'][3] == '확인 필요' and '세부기준' in rd['소득 세부기준 확인'][2])
m = {x[0]: x for x in rows([('birthYear', 2006)] + base[1:])}
check('불일치: 연령 20세 vs 60세 이상', m['연령'][1:] == ['20세', '60세 이상', '불일치'])
n = {x[0]: x for x in rows([('birthYear', 1946), ('incomeRank', 0)], DET)}
check('모름 입력은 "입력 안 함" 표시', n['소득'][1] == '입력 안 함' if '소득' in n else '소득 세부기준 확인' in n and n['소득 세부기준 확인'][1] == '입력 안 함')
e = {x[0]: x for x in rows(base, lang='en')}
check('en 헤더·값 번역', any('Age' in k for k in e) and any('older' in v[2] for v in e.values()))
inc = [('birthYear', 1990), ('incomeRank', 2), ('disability', 'N'), ('nationality', 'K')]
for rid, why in ((rid_of('발달재활서비스'), '180% 상한(rank 4 구간)'), (rid_of('영양플러스사업'), 'rank 3 구간')):
    x = {k[0]: k for k in rows(inc, rid)}
    check('%d %s: 구간임·원문 안내 표시, 임의 상한 단정 안 함' % (rid, why), '소득' in x and '분류 구간' in x['소득'][2] and '원문' in x['소득'][2])
z = {k[0]: k for k in rows(inc, rid_of('노인맞춤돌봄서비스'))}
check('노인맞춤돌봄서비스 rank 없음+불확실: 소득 행이 확인 필요로 원문 안내', '소득' in z and z['소득'][3] == '확인 필요' and '원문' in z['소득'][2])
print('FAIL %d' % bad if bad else 'ALL PASS'); sys.exit(1 if bad else 0)
