# -*- coding: utf-8 -*-
"""복지이음 — 2025 하반기 시흥시 복지자원 종합안내서(단일 시트 '복지자원') → seed.sql + 분류매핑 CSV.
실행: python3 -I parse_tag_2025.py <안내서.xlsx> <seed.sql 출력경로> <분류매핑 CSV 출력경로>
- 태깅(연령·소득·가구·장애·국적·학업취업·지역)은 2022판과 같은 규칙(parse_tag.tag_row)을 그대로 쓴다 — 애매하면 확인필요.
- 개인정보: 담당자 성명·직통·이메일 열(AA–AC)은 읽는 열 범위(C–Z) 밖이라 행 데이터로 받지 않는다.
- 분류: 새 대분류 11종·중분류 36종 → 서비스 카테고리 9종. 규칙은 CAT_RULE(문서 데이터/수집/분류매핑-2025.csv 로 산출 근거 공개).
열(0기반, Excel 문자): C담당기관(2) D공개(3) E구분(4) F대분류(5) G중분류(6) H유형(7) I서비스명(8) J상세(9) L대상(11) M기준(12)
  N소요(13) O시기(14) P제공주체(15) Q연락처(16) R주소(17) S지역(18) T신청권자(19) U방법(20) V서류(21) W부담여부(22) X금액(23) Y비고(24) Z관련부서(25)
"""
import sys, os, re, csv, datetime, collections
import openpyxl
sys.path.insert(0, __file__.rsplit('/', 1)[0])
import parse_tag as P

SOURCE_NAME = '시흥시 복지자원 종합안내서(2025 하반기)'
DATA_BASE_DATE = '2025-12-31'   # 2025 하반기판의 대푯값(판 말일; 2022판의 2022-12-31 관례와 동일). 사업별 접수 연도 증빙이 아님
ID_BASE = 1000   # 2022판 id(1~744)와 겹치지 않도록 1001부터 — 옛 찜·URL이 다른 사업을 가리키지 않게 함

# (대분류, 중분류) → 서비스 카테고리. 근거: 표준분류체계 시트의 예시 + 2022판과 이름이 일치한 행의 다수 카테고리.
CAT_RULE = {
    ('경제(현금중심)', '의료비 지원'): 'HEALTH', ('경제(현금중심)', '일상생활 관련 비용지원'): 'DAILY',
    ('경제(현금중심)', '보육 및 교육 관련 비용지원'): 'EDU', ('경제(현금중심)', '일자리 관련 비용지원'): 'JOB',
    ('경제(현금중심)', '주거 관련 비용지원'): 'HOUSE', ('경제(현금중심)', '보호·돌봄·요양 관련 비용지원'): 'CARE',
    ('경제(현금중심)', '문화·여가 관련 비용지원'): 'CULTURE', ('경제(현금중심)', '법률지원 관련 비용지원'): 'RIGHTS',
    ('관계', '상담 및 정신건강 프로그램(관계)'): 'MIND',
    ('돌봄(일상생활)', '시설보호'): 'CARE', ('돌봄(일상생활)', '경제생활 지원'): 'CARE',
    ('문화 및 여가', '문화복지'): 'CULTURE', ('문화 및 여가', '평생교육'): 'EDU',
    ('법률 및 권익보장', '인권교육'): 'RIGHTS', ('법률 및 권익보장', '법률상담'): 'RIGHTS',
    ('안전', '학대·폭력피해 지원'): 'RIGHTS', ('안전', '안전 교육·점검'): 'RIGHTS',
}
BIG_ONLY = {'신체적 건강': 'HEALTH', '정신적 건강': 'MIND', '일자리': 'JOB', '주거': 'HOUSE', '보육 및 교육': 'EDU'}
CARE_WORDS = re.compile(r'돌봄|요양|간병|입소|재가|활동지원')   # '방문'·'보호' 같은 전달 방식/일반어 단독으로 CARE 확정 금지(R-046)
LEISURE_WORDS = re.compile(r'노래|요가|댄스|공예|사진|운동|체조|악기|합창|미술|스포츠|문화|예술|공연|여가')

def categorize(big, mid, name, content):
    big, mid = (big or '').strip(), (mid or '').strip()
    if (big, mid) == ('문화 및 여가', '평생교육') and LEISURE_WORDS.search(name):   # 문해·정보화·한국어는 EDU, 여가 중심 프로그램은 CULTURE
        return 'CULTURE', 'keyword'
    if (big, mid) in CAT_RULE:
        return CAT_RULE[(big, mid)], 'rule'
    if big == '돌봄(일상생활)':   # 일상생활 유지·돌봄 지원: 돌봄 성격 키워드가 있으면 CARE, 아니면 DAILY
        return ('CARE' if CARE_WORDS.search(name + content) else 'DAILY'), 'keyword'
    if big in BIG_ONLY:
        return BIG_ONLY[big], 'big'
    raise SystemExit('분류 매핑 없음: %r / %r' % (big, mid))

# 국적 F(외국인 전용) 정제 — R-024~R-026 원칙: 내국인이 포함될 수 있으면 F 를 달지 않고 확인필요로 둔다(오제외 방지).
F_STRICT = re.compile(r'외국인주민|외국국적|외국인근로자|재외동포|외국인\(성인\)')   # 결혼이민자는 귀화자(한국 국적)를 포함할 수 있어 단독으로는 F 근거가 아님(R-047)
F_LOOSE = re.compile(r'다문화|내국인|내/외국인|비이주|선주민|주민등록|중도입국')   # 중도입국자녀는 한국 국적자일 수 있어 F 아님
ALIAS_TR = {'외국인주민 긴급지원': '외국인주민 긴급지원(생계비)'}   # 2025판 이름 → 번역 샘플이 있는 구 이름(같은 사업)

def refine_nationality(name, tgt, crit, f):
    if f['nationality'] != 'F':
        return
    # 대상 대분류(tgt)는 '외국인·다문화'처럼 붙어 있어 제외 판정에서 뺀다(서비스명·지원기준 원문만 본다)
    if F_STRICT.search(name + ' ' + tgt + ' ' + crit) and not F_LOOSE.search(name + ' ' + crit):
        return
    f['nationality'] = None
    note = '국적: 외국인·다문화 표기가 있으나 내국인 포함 가능 — 외국인 전용으로 단정할 수 없음, 확인 필요'
    f['uncertain_note'] = '; '.join(([f['uncertain_note']] if f['uncertain_note'] else []) + [note])[:300]


# 감면·우선·택일·가족 구성원 문구는 '신청자 전체 필수 자격'이 아니다 — 2022판 문자열 규칙이 이를 필수 태그로 저장하던 오제외 위험(R-046 P1)을 막는다.
SOFT_MARK = re.compile(r'감면|면제|우선|할인|가산|차등|본인부담|부담금|택일|중\s*하나|예외|(?:아동|자|인)도\s*(?:대상|포함)|포함된\s*(?:가정|가구)|가구원|(?:와|과|및)\s*가족|가족\s*(?:포함|구성원)|조부모|무관|상관없|관계없')
OR_MARK = re.compile(r'또는|혹은|및/또는')
TAG_KEYS = ('age_min', 'age_max', 'income_rank', 'income_uncertain', 'household_types', 'disability', 'edu_work')

def soften_tags(name, crit, f):
    text = name + ' ' + crit
    yrs = [int(y) for y in re.findall(r'(20[12]\d)\s*년(?:도)?[^.\n]{0,25}(?:응시|신청|모집|접수|참여)', crit)]   # '기준 준용' 같은 인용 연도는 제외
    if yrs and max(yrs) <= 2024:
        f['uncertain_note'] = '; '.join(([f['uncertain_note']] if f['uncertain_note'] else []) + ['지원 자격이 %d년 이하 연도로 한정 — 현재 모집·지원 여부 확인 필요' % max(yrs)])[:300]
    hit = SOFT_MARK.search(text)
    kinds = sum(1 for k in ('age_min', 'income_rank', 'household_types', 'disability') if f[k] is not None)
    if hit or (OR_MARK.search(crit) and kinds >= 2):
        cleared = [k for k in TAG_KEYS if f[k] is not None]
        if cleared:
            for k in TAG_KEYS: f[k] = None
            why = '감면·우선·택일·가족 조건이 섞여 필수 자격으로 단정할 수 없음 — 원문 확인'
            f['uncertain_note'] = '; '.join(([f['uncertain_note']] if f['uncertain_note'] else []) + [why])[:300]
    # 나열형 대상자 목록(수급자·차상위·한부모·… 아동)은 택일이다: 자격 종류가 2개 이상 섞이면 연령만 남기고 소득·가구·장애·학업취업은 확인필요
    kinds2 = sum(1 for k in ('income_rank', 'household_types', 'disability') if f[k] is not None)
    if kinds2 >= 2 and (crit.count(',') + crit.count('·') + crit.count('、')) >= 3:
        for k in ('income_rank', 'income_uncertain', 'household_types', 'disability', 'edu_work'): f[k] = None
        f['uncertain_note'] = '; '.join(([f['uncertain_note']] if f['uncertain_note'] else []) + ['대상자 열거(택일) — 소득·가구·장애 조건은 원문 확인'])[:300]
    # 진학 '고민·희망·예정'은 현재 학적 상태가 아니다 — UNIV 필수로 단정하지 않는다
    if f['edu_work'] and 'UNIV' in f['edu_work'].split(',') and re.search(r'진학|고민|희망|준비|예정', text):
        rest = [x for x in f['edu_work'].split(',') if x != 'UNIV']
        f['edu_work'] = ','.join(rest) or None
    # MCUL(다문화 가구)은 서비스명·지원기준 원문에 '다문화'가 있을 때만 — 대상 대분류 라벨('외국인·다문화')만으로는 필수 조건이 아니다
    if f['household_types'] and 'MCUL' in f['household_types'].split(',') and ('다문화' not in text or '외국인' in text):
        rest = [x for x in f['household_types'].split(',') if x != 'MCUL']
        f['household_types'] = ','.join(rest) or None

# 개인 연락처 제외: 휴대폰 번호·이메일은 공개 저장소 후보에 싣지 않는다(기관 대표 유선 번호만 유지)
MOBILE = re.compile(r'01[016789][-\s.]?\d{3,4}[-\s.]?\d{4}')
EMAIL = re.compile(r'[\w.+-]+@[\w-]+(?:\.[\w-]+)+')
def scrub(v):
    if not v: return v, False
    out = EMAIL.sub('(이메일 제외)', MOBILE.sub('(휴대폰 제외)', v))
    return out, out != v

def read(path):
    wb = openpyxl.load_workbook(path, read_only=True, data_only=True)
    if wb['복지자원'].max_column > 26 and not os.environ.get('ALLOW_PERSONAL_COLUMNS'):
        raise SystemExit('입력 xlsx에 담당자 열(AA 이후)이 있습니다. 담당자 열을 제거한 사본을 쓰거나, 라이브러리 내부 해석을 수용하면 ALLOW_PERSONAL_COLUMNS=1 로 실행하세요(R-045~R-048).')
    out = []
    for r in wb['복지자원'].iter_rows(min_row=7, min_col=3, max_col=26, values_only=True):
        if any(c not in (None, '') for c in r):
            out.append(((None, None) + tuple(r)))
    wb.close()
    return out

def main():
    xlsx, out_sql, out_map = sys.argv[1:4]
    rows_raw = read(xlsx)
    s = lambda v: '' if v is None else str(v).strip()
    seen, rows, dups, cmap, pii_log = set(), [], [], collections.Counter(), []
    for r in rows_raw:
        v = [s(x) for x in r]
        key = tuple(v[2:])
        if key in seen:
            dups.append(v[8]); continue
        seen.add(key)
        (dept_c, openflag, ptype, big, mid, stype, name, content, _cnt, tgt, crit, period, cycle, org, phone, addr, area,
         applicant, method, docs, costf, costa, note, dept_z) = v[2:26]
        if openflag and openflag != '공개':
            continue   # 비공개 행은 적재하지 않음(현 파일은 전부 '공개')
        cat, how = categorize(big, mid, name, content)
        note, note_hit = scrub(note)
        f = P.tag_row(tgt, crit, area, note)
        refine_nationality(name, tgt, crit, f)
        soften_tags(name, crit, f)
        pii = ['note'] if note_hit else []
        for lab, val in (('phone', phone), ('method', method), ('docs', docs), ('note', note)):
            _, hit = scrub(val)
            if hit: pii.append(lab)
        phone, _ = scrub(phone); method, _ = scrub(method); docs, _ = scrub(docs)
        if phone and not re.search(r'\d', phone): phone = ''   # 공개 가능한 번호가 없으면 NULL(상세 화면 tel 링크 방지)
        if pii:
            f['uncertain_note'] = '; '.join(([f['uncertain_note']] if f['uncertain_note'] else []) + ['개인 연락처(휴대폰·이메일)는 게시하지 않음 — 담당기관 문의'])[:300]
        pii_log.append((name, ','.join(pii))) if pii else None
        tr = []
        if phone and len(phone) > 150: tr.append('연락처 일부 절단(원문/신청방법 참조)')
        if addr and len(addr) > 200: tr.append('주소 일부 절단(담당기관 문의)')
        if tr:
            f['uncertain_note'] = '; '.join(([f['uncertain_note']] if f['uncertain_note'] else []) + tr)[:300]
        m = P.URL_RE.search(method or '')
        rows.append(dict(name=name or '(서비스명 미기재)', category=cat, sub_category=mid or None, service_type=stype or None,
                         provider_type=P.map_provider(ptype), org_name=org or dept_c or '(기재 없음)', dept_name=dept_z or dept_c or None,
                         phone=phone or None, address=addr or None, support_content=content or name or '(내용 미기재)',
                         apply_method=method or None, documents=docs or None, apply_url=m.group(1) if m else None,
                         eligibility_raw=crit or None, decision_period=period or None, service_cycle=cycle or None,
                         applicant=applicant or None, cost_flag=P.map_cost(costf), cost_amount=costa or None, **f))
        cmap[(big, mid, cat, how)] += 1
    cols = ['resource_id', 'name', 'category', 'sub_category', 'service_type', 'provider_type', 'org_name', 'dept_name', 'phone',
            'address', 'support_content', 'apply_method', 'documents', 'apply_url', 'age_min', 'age_max', 'dong_codes',
            'household_types', 'income_rank', 'income_uncertain', 'disability', 'nationality', 'edu_work', 'uncertain_note',
            'eligibility_raw', 'decision_period', 'service_cycle', 'applicant', 'cost_flag', 'cost_amount',
            'source_name', 'source_url', 'data_base_date', 'status']
    q, sv = P.sql_str, P.sql_val
    lines = ['-- 복지이음 seed.sql — parse_tag_2025.py 자동 생성 (%s)' % datetime.date.today(),
             '-- 원본: 시흥시 복지자원 종합안내서 2025 하반기 (%d건, 완전중복 %d행 제외)' % (len(rows), len(dups)), 'SET NAMES utf8mb4;', '']
    chunk = []
    for i, w in enumerate(rows, 1):
        vals = [str(ID_BASE + i), q(w['name'], 200), q(w['category']), q(w['sub_category'], 100), q(w['service_type'], 20), q(w['provider_type']),
                q(w['org_name'], 100), q(w['dept_name'], 100), q(w['phone'], 150), q(w['address'], 200), q(w['support_content']),
                q(w['apply_method']), q(w['documents']), q(w['apply_url'], 300), sv(w['age_min']), sv(w['age_max']),
                q(w['dong_codes'], 200), q(w['household_types'], 100), sv(w['income_rank']), q(w['income_uncertain']),
                q(w['disability']), q(w['nationality']), q(w['edu_work'], 50), q(w['uncertain_note'], 300), q(w['eligibility_raw']),
                q(w['decision_period'], 200), q(w['service_cycle'], 200), q(w['applicant'], 200), q(w['cost_flag']), q(w['cost_amount']),
                q(SOURCE_NAME), 'NULL', q(DATA_BASE_DATE), "'A'"]
        chunk.append('(' + ','.join(vals) + ')')
        if len(chunk) == 40 or i == len(rows):
            lines.append('INSERT INTO resource (' + ','.join(cols) + ') VALUES\n' + ',\n'.join(chunk) + ';'); chunk = []
    lines += ['', '-- RESOURCE_I18N 샘플: nationality=F 자원 영어 번역(이름 일치분)']
    used = set()
    for i, w in enumerate(rows, 1):
        nm = ALIAS_TR.get(re.sub(r'\s+', ' ', w['name']), re.sub(r'\s+', ' ', w['name']))
        if w['nationality'] == 'F' and nm in P.TRANSLATIONS and nm not in used:
            a, b = P.TRANSLATIONS[nm]
            lines.append("INSERT INTO resource_i18n (resource_id, lang, name_tr, summary_tr) VALUES (%d,'en',%s,%s);" % (ID_BASE + i, q(a, 200), q(b, 500)))
            used.add(nm)
    open(out_sql, 'w', encoding='utf-8').write('\n'.join(lines) + '\n')
    with open(out_map, 'w', encoding='utf-8', newline='') as fo:
        w = csv.writer(fo); w.writerow(['대분류', '중분류', '서비스 카테고리', '결정 방식', '건수'])
        for (b, m, c, h), n in sorted(cmap.items()): w.writerow([b, m, c, h, n])
    print('PII 마스킹 행', len(pii_log), 'rows', len(rows), 'dups', dups, 'i18n', len(used), 'cat', dict(collections.Counter(r['category'] for r in rows)),
          'PUB', sum(r['provider_type'] == 'PUB' for r in rows), 'F', sum(r['nationality'] == 'F' for r in rows))

if __name__ == '__main__':
    main()
