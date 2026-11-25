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
check('연령 제한 유지: 무료급식 지원(만60세 이상)은 만30세에 미노출', len([r for r in young if r['displayName'].strip() == '무료급식 지원']) == 0)
check('연령 제한 유지: 무료급식 지원(만60세 이상)은 만70세에 노출', len([r for r in match(birthYear=1956, incomeRank=0, disability='U', nationality='K') if r['displayName'].strip() == '무료급식 지원']) >= 1)
# T8: 중위소득 180% 이하(구간 밖)로 rank=4+uncertain 처리한 사업은 어떤 소득 입력에서도 제외되지 않고, '그 이상'은 확인필요
for rank in (0, 1, 2, 3, 4):
    rows = find(match(birthYear=2015, incomeRank=rank, disability='Y', nationality='K'), '발달재활서비스')
    check(f'180% 사업(발달재활서비스): 소득입력 {rank}에서 노출', len(rows) >= 1, f'{len(rows)}건')
def one(rows, name):
    return next((r for r in rows if r['displayName'] == name), None)
# 이름 '발달재활서비스'(정확 일치) = 중위 180% 이하(rank=4, uncertain=Y) 사업 (id 하드코딩 금지)
NAME180 = '발달재활서비스'
r4 = one(match(birthYear=2015, incomeRank=4, disability='Y', nationality='K'), NAME180)
check("180% 사업(발달재활서비스 정확명): 소득 '그 이상'(4)은 일치가 아닌 확인필요(소득)", r4 is not None and '소득' in r4['needCheckLabels'] and '소득' not in r4['matchedLabels'], str(r4 and (r4['matchedLabels'], r4['needCheckLabels'])))
r2 = one(match(birthYear=2015, incomeRank=2, disability='Y', nationality='K'), NAME180)
check('180% 사업(발달재활서비스 정확명): 차상위(2)는 소득 일치 + 세부기준 확인', r2 is not None and '소득' in r2['matchedLabels'] and '소득 세부기준 확인' in r2['needCheckLabels'], str(r2 and (r2['matchedLabels'], r2['needCheckLabels'])))
rows = find(match(birthYear=1960, incomeRank=2, disability='U', nationality='K'), '노인일자리지원사업')
check('rank=NULL+uncertain 사업(노인일자리): 소득입력 2에서도 노출, 확인필요(추가 조건) 전달', len(rows) >= 1 and all('추가 조건 확인' in ' '.join(r['needCheckLabels']) for r in rows), str([r['needCheckLabels'] for r in rows][:1]))
# R-046: 감면·우선·택일 문구가 '필수 자격'으로 저장되어 일반 사용자를 오제외하던 사례(2025판) — 대표 행은 일반 입력자에게 노출되어야 한다
kid = match(birthYear=2018, incomeRank=4, disability='N', nationality='K')          # 8세, 비장애, 소득 중위150 초과
for nm in ('어린이발레', '아이누리 돌봄센터', '지역아동센터 방과후 돌봄 지원'):
    check(f'{nm}: 일반 8세 아동 노출(감면·우선 문구 오제외 없음)', len(find(kid, nm)) >= 1)
preg = match(birthYear=1996, incomeRank=4, disability='N', nationality='K', householdTypes='PREG')   # 30세 임산부
check('바우처 택시: 30세 임산부 노출(택일 대상 오제외 없음)', len(find(preg, '바우처 택시')) >= 1)
gen = match(birthYear=1986, incomeRank=4, disability='N', nationality='K')
check('종량제봉투 무상지급: 일반 40세 노출(또는 조건 택일 오제외 없음)', len(find(gen, '종량제봉투')) >= 1)

# R-047 반례(제공기관까지 지정): 가족·소득 예외·복수 대상군 문구가 필수 자격으로 저장되던 행
def has(rows, name, org):
    return any(r['displayName'].strip().startswith(name) and org in (r.get('orgName') or r.get('org') or org) for r in rows)
c55 = match(birthYear=1971, incomeRank=4, disability='N', nationality='K')
check('청년정신건강사업(시흥시정신건강복지센터): 55세 가족 입력자 노출', has(c55, '청년정신건강사업', '정신건강복지센터'))
check('우리 같이 한 아이 키우기 사업(함현상생종합사회복지관): 소득 중위150 초과 노출', has(c55, '우리 같이 한 아이 키우기 사업', '함현'))
frn = match(birthYear=1986, incomeRank=4, disability='N', nationality='F', householdTypes='NONE')
check('결혼이민자가족코칭상담사파견사업(시흥시가족센터): 외국인·가구 해당없음 노출', has(frn, '결혼이민자가족코칭상담사파견사업', '가족센터'))

# R-048 반례: 예외 선정·대상자 열거·진학 희망 문구를 필수 자격으로 저장하던 행
c52 = match(birthYear=1974, incomeRank=4, disability='N', nationality='K')
check('치매치료관리비 지원사업: 52세(초로기 예외) 노출', has(c52, '치매치료관리비 지원사업', ''))
teen = match(birthYear=2014, incomeRank=4, disability='N', nationality='K')
check('결식아동 급식지원: 소득 중위150 초과 아동도 노출(대상자 열거)', has(teen, '결식아동 급식지원', ''))
check('대입 컨설팅 운영: 현재 대학생이 아닌 만 20세 노출(진학 희망)', has(match(birthYear=2006, incomeRank=4, disability='N', nationality='K'), '대입 컨설팅 운영', ''))
# 상세: 조건 입력 없이 열어도 '추가 조건' 안내(출처 병존·연도 한정)가 보인다. id 대역 1001~1853 고정 시드 기준
def detail(i):
    return urllib.request.urlopen(base + '/resources/%d' % i).read().decode('utf-8')
check('출생축하금 지원(안내서 1233·복지로 1873): 직접 상세에도 병존 안내', '다른 출처' in detail(1233) and '다른 출처' in detail(1873))
check('결혼이민자 한국어교육 응시료 지원사업(1602): 2024년 응시 한정 안내', '2024년 이하 연도로 한정' in detail(1602))
check('외국인주민 긴급지원(1594): 인용 기준 연도를 자격 한정으로 오표기하지 않음', '연도로 한정' not in detail(1594))

sys.exit(1 if fail else 0)
