#!/usr/bin/env python3
"""탐색 모드(GET /resources) 계약 회귀 — docs/설계/07-탐색모드.md 계약에서 기대값을 DB로 따로 계산해 HTTP 결과와 대조한다.
usage: python3 -I docs/검증/resource-search-regression.py <base_url> [컨테이너=bokji-verify]   종료코드 = FAIL 수
DB 조회 실패는 SKIP이 아니라 FAIL. 검증 DB(792건) 전용: 비활성 테스트 시 resource 1행의 status를 바꿨다가 복원한다."""
import re, subprocess, sys, urllib.parse, urllib.request

base = sys.argv[1].rstrip('/')
C = sys.argv[2] if len(sys.argv) > 2 else 'bokji-verify'
fails = 0

def check(name, ok, detail=''):
    global fails
    if not ok: fails += 1
    print(('PASS ' if ok else 'FAIL ') + name + (f'  [{detail}]' if detail and not ok else ''))

def sql(q):
    r = subprocess.run(['docker', 'exec', '-i', C, 'mysql', '--default-character-set=utf8mb4', '-uroot', '-pverify', 'bokji', '-N', '-e', q],
                       capture_output=True, text=True)
    if r.returncode != 0 or 'ERROR' in r.stderr:
        check('DB 조회 가능: ' + q[:40], False, r.stderr[:80]); return []
    return [l for l in r.stdout.splitlines() if l]

def oracle(where, join=''):
    return set(int(x) for x in sql(f"select r.resource_id from resource r {join} where r.status='A' and ({where})"))

def fetch(qs='', page=None):
    url = base + '/resources' + ('?' + qs if qs else '')
    if page: url += ('&' if qs else '?') + f'page={page}'
    try:
        with urllib.request.urlopen(url) as r: return r.status, r.read().decode()
    except urllib.error.HTTPError as e: return e.code, ''

def total(html):
    m = re.search(r'총 (\d+)건', html); return int(m.group(1)) if m else -1

def ids(html): return [int(x) for x in re.findall(r'<h3><a href="[^"]*?/resources/(\d+)"', html)]

def all_ids(qs):
    st, h = fetch(qs); t = total(h); out = ids(h); p = 2
    while len(out) < t and p < 200:
        out += ids(fetch(qs, p)[1]); p += 1
    return t, out

def q(**kw): return urllib.parse.urlencode(kw, doseq=True)

AGE = "(r.age_min is not null or r.age_max is not null)"
UNT = "(r.age_min is null and r.age_max is null)"
def overlap(lo, hi): return f"({AGE} and coalesce(r.age_min,0)<={hi} and coalesce(r.age_max,200)>={lo})"

# 1) 기본 = 활성 전체, 쪽 이동에 중복·누락 없음
t, got = all_ids('')
act = oracle('1=1')
check('1 기본 호출 = 활성 전체', t == len(act) == 792, f'{t}/{len(act)}')
check('1 전 쪽 순회: 중복·누락 없음', len(got) == len(set(got)) == t and set(got) == act)
order = [int(x) for x in sql("select resource_id from resource where status='A' order by name, resource_id")]
names = {int(a): b for a, b in (l.split('\t') for l in sql("select resource_id,name from resource where status='A'"))}
check('1 기본 정렬 = 이름순(동률 id, DB 정렬 기준)', got == order)

# 2) 관심주제: 단일, 복수 OR
j = oracle("r.category='JOB'"); e = oracle("r.category='EDU'")
check('2 cat=JOB', set(all_ids(q(cat='JOB'))[1]) == j)
check('2 cat=JOB&cat=EDU (OR)', set(all_ids(q(cat=['JOB', 'EDU']))[1]) == j | e)
check('2 cat 서로 다른 축 AND (cat+hh=DIS)', set(all_ids(q(cat='JOB', hh='DIS'))[1]) == oracle("r.category='JOB' and r.disability='Y'"))

# 3) 생애주기: 구간 겹침 + 미분류 포함/제외, ±1 관용 없음, 경계
RANGES = {'INF': (0, 5), 'CHD': (6, 12), 'TEEN': (13, 18), 'YOUTH': (19, 39), 'MID': (40, 64), 'SENIOR': (65, 200)}
for code, (lo, hi) in RANGES.items():
    tagged = oracle(overlap(lo, hi)); untagged = oracle(UNT)
    check(f'3 life={code} strict', set(all_ids(q(life=code, strict=1))[1]) == tagged)
    check(f'3 life={code} 기본(미분류 포함)', set(all_ids(q(life=code))[1]) == tagged | untagged)
check('3 life 복수 OR', set(all_ids(q(life=['INF', 'SENIOR'], strict=1))[1]) == oracle(overlap(0, 5)) | oracle(overlap(65, 200)))
for age in (0, 5, 6, 12, 13, 18, 19, 39, 40, 64, 65):
    exp = oracle(f"{AGE} and {age} between coalesce(r.age_min,0) and coalesce(r.age_max,200)")
    check(f'3 age={age} strict (±1 없음)', set(all_ids(q(age=age, strict=1))[1]) == exp)
check('3 age=70 기본', set(all_ids(q(age=70))[1]) == oracle(f"({AGE} and 70 between coalesce(r.age_min,0) and coalesce(r.age_max,200)) or {UNT}"))

# 4) 가구상황: 코드별, F는 다문화와 분리, LOW/incx
HH = {'SPAR': "find_in_set('SPAR',r.household_types)", 'MCHD': "find_in_set('MCHD',r.household_types)", 'MCUL': "find_in_set('MCUL',r.household_types)",
      'NKOR': "find_in_set('NKOR',r.household_types)", 'ONE': "find_in_set('ONE',r.household_types)", 'PREG': "find_in_set('PREG',r.household_types)",
      'DIS': "r.disability='Y'", 'FOR': "r.nationality='F'", 'LOW': "r.income_rank in (1,2)"}
for code, w in HH.items():
    check(f'4 hh={code}', set(all_ids(q(hh=code))[1]) == oracle(w))
check('4 hh 복수 OR', set(all_ids(q(hh=['SPAR', 'DIS']))[1]) == oracle(HH['SPAR']) | oracle(HH['DIS']))
check('4 FOR(국적 F) ≠ MCUL (섞이지 않음)', set(all_ids(q(hh='FOR'))[1]) != set(all_ids(q(hh='MCUL'))[1]))
check('4 LOW+incx=1 은 income_uncertain 포함', set(all_ids(q(hh='LOW', incx=1))[1]) == oracle("r.income_rank in (1,2) or r.income_uncertain='Y'"))
check('4 incx 단독은 hh 없으면 영향 없음', all_ids(q(incx=1))[0] == 792)

# 5) 동
check('5 dong=JWB: 동 미지정 자원 + 해당 동 포함', set(all_ids(q(dong='JWB'))[1]) == oracle("r.dong_codes is null or find_in_set('JWB',r.dong_codes)"))

# 6) 검색: 단어 AND, 제외어 우선, 와일드카드 리터럴
txt = "concat_ws(' ', r.name, i.name_tr, r.support_content, r.org_name, r.applicant)"
J = "left join resource_i18n i on i.resource_id=r.resource_id and i.lang='ko'"
check('6 q=돌봄', set(all_ids(q(q='돌봄'))[1]) == oracle(f"{txt} like '%돌봄%'", J))
check('6 q=돌봄 상담 (AND)', set(all_ids(q(q='돌봄 상담'))[1]) == oracle(f"{txt} like '%돌봄%' and {txt} like '%상담%'", J))
check('6 xq=돌봄 (제외)', set(all_ids(q(xq='돌봄'))[1]) == oracle(f"{txt} not like '%돌봄%'", J))
check('6 q=돌봄&xq=돌봄 → 제외 우선 0건', all_ids(q(q='돌봄', xq='돌봄'))[0] == 0)
check("6 q='%' 는 와일드카드가 아니라 리터럴", all_ids(q(q='%'))[0] == len(oracle(f"{txt} like '%\\\\%%'", J)))
check("6 q='_' 는 리터럴", all_ids(q(q='_'))[0] == len(oracle(f"{txt} like '%\\\\_%'", J)))
for evil in ("'", '"', "' OR 1=1 --", '\\', 'a' * 300, ''):
    st, h = fetch(q(q=evil)); check(f'6 위험 입력 q={evil[:12]!r}: 200 + 건수 표시', st == 200 and total(h) >= 0)

# 7) 온라인 신청 안내
RX = "r.apply_method regexp '온라인|인터넷 ?신청|복지로|정부24|e보건소|누리집 ?신청|홈페이지 ?신청'"
check('7 online=1', set(all_ids(q(online=1))[1]) == oracle(RX))

# 8) 정렬
st, h = fetch(q(sort='latest')); ds = re.findall(r'사업내용 기준\s*(\d{4}-\d{2}-\d{2})', h)
check('8 최신순: 기준일 내림차순', ds == sorted(ds, reverse=True) and len(ds) > 0, str(ds[:3]))
t_pop, got_pop = all_ids(q(sort='popular'))
st, h = fetch(q(sort='popular'))
check('8 인기순: 표본 부족이면 이름순 대체 + 안내', ('표본 부족' in h) and ids(h) == order[:12])
check('8 인기순도 전체 유지(중복·누락 없음)', set(got_pop) == act and len(got_pop) == len(set(got_pop)))

# 9) 잘못된 입력은 SQL 오류 없이 무시
for qs in ('cat=XX&life=ZZ&hh=Q&age=abc&dong=ZZ&sort=zzz&page=-1', 'age=999', 'age=-3', 'page=abc', 'cat=JOB&cat=JOB&cat=JOB'):
    st, h = fetch(qs); check(f'9 {qs[:40]}', st == 200 and total(h) >= 0)
st, h = fetch('cat=XX&life=ZZ&hh=Q&age=abc&dong=ZZ&sort=zzz&page=-1'); check('9 허용값 밖 입력은 필터 없음(792)', total(h) == 792)
st, h = fetch('', 99999); check('9 쪽 번호 초과는 마지막 쪽으로 보정', st == 200 and ids(h) == order[-(792 % 12 or 12):], str(len(ids(h))))

# 10) 찜 ids
st, h = fetch('ids=abc'); check('10 ids 무효 → 0건·200', st == 200 and total(h) == 0)
st, h = fetch('ids=1,2,999999,1'); check('10 ids 중복·없는 ID 제거', st == 200 and total(h) == 2 and set(ids(h)) == {1, 2})
st, h = fetch('ids=' + ','.join(str(i) for i in range(1, 80))); check('10 ids 최대 50개', st == 200 and total(h) == 50)

# 11) 비활성 자원은 반환하지 않는다
sql("update resource set status='I' where resource_id=1")
st, h = fetch(''); t_off = total(h)
sql("update resource set status='A' where resource_id=1")
check('11 비활성(status<>A) 제외', t_off == 791, str(t_off))
st, h = fetch(''); check('11 복원 후 792', total(h) == 792)

# 12) 쪽·정렬 링크가 필터를 보존
st, h = fetch(q(cat='EDU')); check('12 쪽 이동 링크에 cat=EDU 보존', 'cat=EDU' in h and 'page=2' in h)
st, h = fetch(q(cat='EDU', sort='latest'), 2); check('12 2쪽·정렬 유지', st == 200 and 'cat=EDU' in h)

print(f'FAIL {fails}건' if fails else 'ALL PASS')
sys.exit(fails)
