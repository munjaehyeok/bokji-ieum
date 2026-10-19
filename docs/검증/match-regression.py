#!/usr/bin/env python3
"""실제 매칭 엔진(resource-mapper.xml)을 HTTP로 호출하는 회귀 검증. usage: match-regression.py <base_url> <활성전체> <F전용>
data-gate.sh가 DB를 적재한 뒤, 같은 DB를 보는 앱을 띄워 실행한다. 실패 시 exit 1."""
import sys, json, urllib.request, urllib.parse, http.cookiejar
base, total, fonly = sys.argv[1].rstrip('/'), int(sys.argv[2]), int(sys.argv[3])
fail = 0

def match(**cond):
    cj = http.cookiejar.CookieJar()
    op = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(cj))
    data = urllib.parse.urlencode({k: v for k, v in cond.items() if v is not None}).encode()
    op.open(base + '/match', data).read()           # PRG: 세션에 조건 저장
    return json.load(op.open(base + '/match/result/list?member=0'))

def check(name, ok, detail=''):
    global fail
    print(('PASS ' if ok else 'FAIL ') + name + (f'  [{detail}]' if detail and not ok else ''))
    fail |= (not ok)

def find(rows, part):
    return [r for r in rows if part in r['displayName']]

skip = match(incomeRank=0, disability='U', nationality='K')
check('불변식(실제 매퍼): 전 필드 모름 노출 = 활성 전체 − F전용', len(skip) == total - fonly, f'{len(skip)} vs {total - fonly}')

young = match(birthYear=1996, incomeRank=1, disability='U', nationality='K')          # 30세 기초수급 대상
r = find(young, '동네관리소 간단 집수리')
check('집수리: 만30세 수급자도 노출', len(r) == 1)
check('집수리: 확인필요 표시 동반', len(r) == 1 and bool(r[0]['needCheckLabels']), r[0]['needCheckLabels'] if r else '')

dis_n_young = match(birthYear=1996, incomeRank=0, disability='N', nationality='K')    # 비장애 30세
dis_y_young = match(birthYear=1996, incomeRank=0, disability='Y', nationality='K')    # 장애 30세
dis_n_old = match(birthYear=1950, incomeRank=0, disability='N', nationality='K')      # 비장애 76세
for label, rows in (('비장애 30세', dis_n_young), ('장애 30세', dis_y_young), ('비장애 76세', dis_n_old)):
    r = find(rows, '장애인 전동보장구 배상책임보험')
    check(f'전동보장구보험: {label} 노출(택일 조건 오제외 없음)', len(r) == 1)
    check(f'전동보장구보험: {label} 확인필요 표시', len(r) == 1 and bool(r[0]['needCheckLabels']))

r = find(young, '효도수당')
check('효도수당: 만30세 입력자 노출 + 확인필요', len(r) == 1 and bool(r[0]['needCheckLabels']))

# 진짜 전체 연령 제한은 유지되어야 한다
check('연령 제한 유지: 무료급식 지원(만60세 이상)은 만30세에 미노출', len(find(young, '무료급식 지원')) == 0)
check('연령 제한 유지: 무료급식 지원(만60세 이상)은 만70세에 노출', len(find(match(birthYear=1956, incomeRank=0, disability='U', nationality='K'), '무료급식 지원')) >= 1)
sys.exit(1 if fail else 0)
