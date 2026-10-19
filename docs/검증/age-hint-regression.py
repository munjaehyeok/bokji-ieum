#!/usr/bin/env python3
"""AGE_HINT('연령 대상 확인') 계약 회귀 검증 (SPEC.md '연령 대상 힌트' 표 기준, 구현 비참조).
usage: python3 -I age-hint-regression.py <base_url>   종료코드 = FAIL 수.
한계: 본인(member=0)은 birthYear 필수(미입력 시 /match가 error=birthYear로 redirect)라 '연령 모름'을
  본인으로 표현할 수 없다. 구성원 birthYear 공란 + member=N 경로는 폼/세션 계약이 불확실해 생략 -> 단언 3은
  '입력이 거부되어 결과가 없음'만 확인한다.
노출 건수 상수는 두지 않는다(WHERE 불변은 구조적 단언 4a/4b/5로 대체)."""
import sys, json, datetime, urllib.request, urllib.parse, http.cookiejar
base = sys.argv[1].rstrip('/')
fail = 0
HINT = '연령 대상 확인'
YEAR = datetime.date.today().year
GROUPS = {  # 집단어 -> 힌트가 붙는 나이 판정(스펙 표)
    ('어르신', '노인', '경로'): lambda a: a < 60,
    ('아동', '영유아', '유아', '어린이', '신생아', '영아'): lambda a: a >= 19,
    ('청소년',): lambda a: a < 9 or a >= 25,
    ('청년',): lambda a: a < 19 or a >= 40,
}

def match(age, sort='', **extra):
    cond = dict(birthYear=YEAR - age, incomeRank=0, disability='U', nationality='K'); cond.update(extra)
    op = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(http.cookiejar.CookieJar()))
    op.open(base + '/match', urllib.parse.urlencode(cond).encode()).read()
    return json.load(op.open(base + '/match/result/list?member=0' + (('&sort=' + sort) if sort else '')))

def check(name, ok, detail=''):
    global fail
    print(('PASS ' if ok else 'FAIL ') + name + (f'  [{detail}]' if detail and not ok else ''))
    fail += (not ok)

# applicant는 JSON에 없다. 이름과 다른 집단어가 applicant에 있으면 스펙의 '하나라도 맞으면 힌트 없음'이 적용되므로
# 이름만으로 판정할 수 없는 행을 DB(docker 컨테이너 bokji-verify)에서 읽어 제외한다. 컨테이너가 없으면 제외 없이 진행한다.
import subprocess
def _mixed():
    q = ("select resource_id from resource where status='A' and age_min is null and age_max is null "
         "and applicant regexp '어르신|노인|경로|아동|영유아|유아|어린이|신생아|영아|청소년|청년'")
    try:
        out = subprocess.run(['docker', 'exec', 'bokji-verify', 'mysql', '-uroot', '-pverify', '--default-character-set=utf8mb4',
                              'bokji', '-N', '-e', q], capture_output=True, text=True, timeout=30).stdout
        return {int(x) for x in out.split()}
    except Exception:
        return set()
APPLICANT_MIXED = _mixed()

def nm(r): return r.get('name') or r.get('displayName') or ''
def hint(r): return HINT in r['needCheckLabels']
def has_age_tag(r):  # 태그명 '연령'(tag.AGE). 힌트 라벨은 제외
    return any(l.startswith('연령') and l != HINT for l in list(r['matchedLabels']) + list(r['needCheckLabels']))
def expected(r, age):
    if r.get('resourceId') in APPLICANT_MIXED: return None  # 스펙: 행 name에 든 집단어 전부가 불일치일 때만 True. 해당 집단어 없으면 None
    n = nm(r).replace('아동발달지원센터', '')
    if '성인' in n: return None   # 스펙: 성인이 있으면 힌트 억제
    hits = [f for ws, f in GROUPS.items() if any(w in n for w in ws)]
    return None if not hits else all(f(age) for f in hits)

# 1) 어르신 사업: 8세 -> 힌트, 70세 -> 힌트 없음. 사업이 여러 개면 age 태그 없고 '어르신'만(다른 집단어 없음) 든 행 전부(all)
def pure(rows, word, others):
    return [r for r in rows if '성인' not in nm(r) and '아동발달지원센터' not in nm(r) and r.get('resourceId') not in APPLICANT_MIXED and word in nm(r) and not has_age_tag(r) and not any(o in nm(r) for o in others)]
OTHERS = lambda w: [x for ws in GROUPS for x in ws if x != w]
r8, r70 = match(8), match(70)
t8 = pure(r8, '어르신', OTHERS('어르신')); t70 = pure(r70, '어르신', OTHERS('어르신'))
check('1 어르신(age 태그 없음) 8세: 해당 행 1건 이상 존재', len(t8) >= 1)
check('1 어르신 8세: 해당 행 전부 연령 대상 확인 보유(all)', all(hint(r) for r in t8), str([nm(r) for r in t8 if not hint(r)][:3]))
check('1 어르신 70세: 해당 행 전부 힌트 없음(all)', all(not hint(r) for r in t70), str([nm(r) for r in t70 if hint(r)][:3]))

# 2) 집단별 경계 (나이, 힌트 기대): 단일 집단어 행만 대상, age 태그 없는 행만
BOUNDS = [('어르신', 59, True), ('어르신', 60, False),
          ('아동', 18, False), ('아동', 19, True),
          ('청소년', 8, True), ('청소년', 9, False), ('청소년', 24, False), ('청소년', 25, True),
          ('청년', 18, True), ('청년', 19, False), ('청년', 39, False), ('청년', 40, True)]
cache = {}
for word, age, want in BOUNDS:
    rows = cache.setdefault(age, match(age))
    grp = next(ws for ws in GROUPS if word in ws)
    tgt = pure(rows, word, [x for x in sum(map(list, GROUPS), []) if x not in grp])
    if not tgt:
        check(f'2 {word} {age}세: 대상 행 존재(시드에 없으면 테스트 준비 실패)', False); continue
    check(f'2 {word} {age}세: 힌트 {"있음" if want else "없음"} (대상 {len(tgt)}건 all)', all(hint(r) == want for r in tgt),
          str([nm(r) for r in tgt if hint(r) != want][:3]))

# 3) 연령 모름: /match는 birthYear 공란을 허용한다(invalidBirthYear는 NULL 통과). 정상 응답·비어 있지 않음·힌트 없음. 통신/파싱 실패는 FAIL.
op = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(http.cookiejar.CookieJar()))
op.open(base + '/match', urllib.parse.urlencode(dict(incomeRank=0, disability='U', nationality='K')).encode()).read()
rows = json.load(op.open(base + '/match/result/list?member=0'))
check('3 연령 모름: 결과가 비어 있지 않고 힌트 없음', len(rows) > 0 and not any(hint(r) for r in rows), str(len(rows)))

# 3b) 통제 사례: id=309(기관명 '아동발달지원센터' + 성인 대상)는 성인에게 힌트 없음
r30 = match(30)
r309 = [r for r in r30 if r['resourceId'] == 309]
check('3b 오탐 사례 id=309 성인(30세): 노출되고 힌트 없음', len(r309) == 1 and not hint(r309[0]), str(r309 and r309[0]['needCheckLabels']))

# 3c) 노출 불변: AGE_HINT 도입 전 측정값(docs/검증/필터유효성-측정.md)과 같아야 한다
BASE = [('1990년생 전부모름', dict(birthYear=1990, incomeRank=0, disability='U', nationality='K'), 532),
        ('80세 수급 독거', dict(birthYear=1946, incomeRank=1, disability='N', nationality='K', householdTypes='ONE'), 482),
        ('8세 아동', dict(birthYear=2018, incomeRank=3, disability='N', nationality='K'), 463),
        ('45세 중증장애', dict(birthYear=1981, incomeRank=1, disability='Y', nationality='K'), 529),
        ('30세 외국인', dict(birthYear=1996, incomeRank=0, disability='N', nationality='F'), 452),
        ('40세 일반', dict(birthYear=1986, incomeRank=4, disability='N', nationality='K'), 377)]
for label, c, n in BASE:
    op = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(http.cookiejar.CookieJar()))
    op.open(base + '/match', urllib.parse.urlencode(c).encode()).read()
    got = len(json.load(op.open(base + '/match/result/list?member=0')))
    check(f'3c 노출 불변 {label}: {n}건', got == n, f'{got}')

# 3d) 안정 분할: 일치 묶음이 항상 먼저, 묶음 안 순서는 정렬 기준(추천순=score, 최신순=기준일) 유지
for sort in ('', 'latest'):
    for age in (8, 30, 70):
        rows = match(age, sort=sort)
        m = [bool(r['matchedLabels']) for r in rows]
        check(f'3d 분할 sort={sort or "추천"} {age}세: 일치 묶음이 먼저', m == sorted(m, reverse=True))
        for grp in (True, False):
            g = [r for r in rows if bool(r['matchedLabels']) == grp]
            key = (lambda r: r['dataBaseDate'] or '') if sort else (lambda r: r['score'])
            check(f'3d 묶음 내 순서 sort={sort or "추천"} {age}세 일치={grp}', all(key(g[i]) >= key(g[i + 1]) for i in range(len(g) - 1)))

# 4) 구조 단언 (연령 0~100 샘플 전수 + 7명 대표 사용자 포함). 노출 건수 상수 없음
for age in (0, 8, 9, 18, 19, 24, 25, 30, 39, 40, 59, 60, 70, 85):
    rows = cache.setdefault(age, match(age))
    check(f'4a {age}세: 힌트 행은 matchedLabels에 힌트 없음(AGE_HINT 비일치)·age 태그 없음',
          all(HINT not in r['matchedLabels'] and not has_age_tag(r) for r in rows if hint(r)),
          str([nm(r) for r in rows if hint(r) and (HINT in r['matchedLabels'] or has_age_tag(r))][:3]))
    check(f'4b {age}세: age 태그 있는 행에는 힌트 없음', all(not hint(r) for r in rows if has_age_tag(r)))
    ids = [r['resourceId'] for r in rows]
    check(f'4c {age}세: resourceId 중복 없음/비어있지 않음', len(ids) == len(set(ids)) and len(ids) > 0)
    exp = [(nm(r), expected(r, age), hint(r)) for r in rows if not has_age_tag(r)]
    bad = [e for e in exp if e[1] is not None and e[1] != e[2]]
    check(f'4d {age}세: age 태그 없는 행의 힌트 = 스펙 표(집단어 전부 불일치) 판정', not bad, str(bad[:3]))
    # 집단어 없는 행에는 힌트 없음 (applicant 기반 힌트는 JSON에 applicant가 없어 name 기준으로만 불가 -> 힌트 허용)

# 5) AGE_HINT는 matchedLabels에 절대 없다 (원문 태그명 포함)
allrows = [r for rows in cache.values() for r in rows]
check('5 matchedLabels에 연령 대상 확인/AGE_HINT 없음', all(HINT not in r['matchedLabels'] and 'AGE_HINT' not in r['matchedLabels'] for r in allrows))
check('5 needCheckLabels에 원문 키 AGE_HINT 노출 없음(번역 누락 방지)', all('AGE_HINT' not in r['needCheckLabels'] for r in allrows))
sys.exit(fail)
