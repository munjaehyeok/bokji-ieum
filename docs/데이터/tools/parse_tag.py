# -*- coding: utf-8 -*-
"""
복지이음 — 시흥시 복지자원 종합안내서.xlsx 파싱 + 규칙 기반 자동 태깅 → seed.sql / 태깅-미결.md
실행: python3 -I parse_tag.py <종합안내서.xlsx> <출력디렉터리(데이터/)>
설계 근거: 설계/02-데이터베이스-설계.md §3.5(22열 매핑)·§4(변환 규칙), 설계/03(판정 의미).
원칙: 확신 없는 패턴은 필드를 비우고 uncertain_note에 요약 — 임의 해석 금지, 애매하면 '확인 필요'.
"""
import sys, re, json, datetime

import openpyxl

SOURCE_NAME = '시흥시 복지자원 종합안내서(2022 하반기)'
DATA_BASE_DATE = '2022-12-31'

CATEGORY = {
    '일자리': 'JOB', '주거': 'HOUSE', '일상생활': 'DAILY',
    '신체건강 및 보건의료': 'HEALTH', '정신건강 및 심리정서': 'MIND',
    '보호 및 돌봄·요양': 'CARE', '보육 및 교육': 'EDU',
    '문화 및 여가': 'CULTURE', '안전 및 권익보장': 'RIGHTS',
}

# 행정동 코드 (설계 02 §3)
SIMPLE_DONG = [('대야', 'DY'), ('신천', 'SC'), ('신현', 'SH'), ('은행', 'EH'),
               ('매화', 'MH'), ('목감', 'MG'), ('군자', 'GJ'), ('월곶', 'WG'),
               ('과림', 'GL'), ('연성', 'YS'), ('장곡', 'JG'), ('능곡', 'NG')]
DONG_ORDER = ['DY', 'SC', 'SH', 'EH', 'MH', 'MG', 'GJ', 'WG', 'GL', 'YS', 'JG', 'NG',
              'BG1', 'BG2', 'JWB', 'JW1', 'JW2', 'JW3', 'JW4']
ALL_JW = ['JWB', 'JW1', 'JW2', 'JW3', 'JW4']


def norm(s):
    return re.sub(r'\s+', '', s or '')


def cell(ws, r, c):
    v = ws.cell(r, c).value
    if v is None:
        return ''
    return str(v).strip()


# ---------------- 지역 (15열) → dong_codes ----------------
UNKNOWN_AREA = re.compile(r'장현|거모|죽율|은계|오이도|[Ll][Hh]|단지|북부권')

def dong_tokens(t):
    """정규화 문자열에서 행정동 코드 목록 추출 (법정동 정왕동→행정동 전체 확장 포함)"""
    codes = []

    def add(c):
        if c not in codes:
            codes.append(c)

    if '신천권역' in t:
        for c in ('SC', 'EH', 'SH'):
            add(c)
    # 정왕·배곧 (숫자 분동: '정왕1~4동', '정왕2동,3동,4동', '배곧동1동,2동' 등)
    for m in re.finditer(r'(정왕본|정왕|배곧)동?((?:[,~·및]?\d(?:동)?)*)', t):
        stem, tail = m.group(1), m.group(2)
        nums = []
        for rm in re.finditer(r'(\d)(?:동)?~(\d)', tail):
            nums.extend(range(int(rm.group(1)), int(rm.group(2)) + 1))
        tail2 = re.sub(r'\d(?:동)?~\d동?', '', tail)
        nums.extend(int(d) for d in re.findall(r'\d', tail2))
        if stem == '정왕본':
            add('JWB')
            for n in sorted(set(nums)):
                if 1 <= n <= 4:
                    add('JW%d' % n)
        elif stem == '정왕':
            if nums:
                for n in sorted(set(nums)):
                    if 1 <= n <= 4:
                        add('JW%d' % n)
            else:  # 법정동 '정왕동' → 행정동 전체
                for c in ALL_JW:
                    add(c)
        else:  # 배곧
            if nums:
                for n in sorted(set(nums)):
                    if 1 <= n <= 2:
                        add('BG%d' % n)
            else:
                add('BG1'); add('BG2')
    for name, code in SIMPLE_DONG:
        if name in t:
            add(code)
    codes.sort(key=DONG_ORDER.index)
    return codes


def parse_dong(raw):
    """15열(제공 가능 지역) → (codes_csv or None, notes list)"""
    notes = []
    t = norm(raw)
    if not t:
        return None, notes
    if '제외' in t:
        notes.append('지역조건 확인: ' + raw.replace('\n', ' ')[:70])
        return None, notes
    codes = []
    if not re.search(r'전역|전지역|전국|경기도|모집지역|인근지역|관내초', t):
        codes = dong_tokens(t)
    if UNKNOWN_AREA.search(t):
        notes.append('지역 세부조건 확인: ' + raw.replace('\n', ' ')[:70])
    if not codes:
        if not re.search(r'전역|전지역|전국|경기도|모집지역|인근지역|관내초', t) and not notes:
            notes.append('지역 확인: ' + raw.replace('\n', ' ')[:70])
        return None, notes
    return ','.join(codes), notes


# ---------------- 연령 ----------------
# [D1] "N세 자녀를 둔 / N세 이하 자녀 양육가정" — 자녀 연령이지 신청자 연령이 아님 → age 태깅 금지
CHILD_AGE = re.compile(r'(?:생후)?만?\d{1,3}(?:[~\-]만?\d{1,3})?(?:세|개월)(?:이상|이하|미만)?\)?의?(?:인)?(?:자녀|손자녀)')

def parse_age(text):
    """return (age_min, age_max, notes)"""
    t = norm(text)
    notes = []
    if CHILD_AGE.search(t):
        t = CHILD_AGE.sub('', t)
        notes.append('자녀 연령 기준(신청자 연령 아님) — 확인 필요')
    mins, maxes = [], []
    # 개월 표기
    for m in re.finditer(r'(?<!\d)(\d{1,3})개월(미만|이하)', t):
        mm, kind = int(m.group(1)), m.group(2)
        maxes.append((mm - 1) // 12 if kind == '미만' else mm // 12)
    # A~B세
    for m in re.finditer(r'(?<!\d)만?(\d{1,2})(?:세)?(?:이상)?~만?(\d{1,2})세(미만|이하)?', t):
        a, b, kind = int(m.group(1)), int(m.group(2)), m.group(3)
        mins.append(a)
        maxes.append(b - 1 if kind == '미만' else b)
    t2 = re.sub(r'만?\d{1,2}(?:세)?(?:이상)?~만?\d{1,2}세(?:미만|이하)?', '', t)
    for m in re.finditer(r'(?<!\d)만?(\d{1,2})세이상', t2):
        mins.append(int(m.group(1)))
    for m in re.finditer(r'(?<!\d)만?(\d{1,2})세(미만|이하)', t2):
        n, kind = int(m.group(1)), m.group(2)
        maxes.append(n - 1 if kind == '미만' else n)
    amin = min(mins) if mins else None   # 복수 기준이면 가장 넓은 범위(틀리게 제외하지 않기)
    amax = max(maxes) if maxes else None
    if (len(set(mins)) > 1) or (len(set(maxes)) > 1):
        notes.append('연령 기준 복수(대상별 상이) — 원문 확인')
    if amin is not None and amax is not None and amin > amax:
        notes.append('연령 기준 해석 불가 — 원문 확인')
        return None, None, notes
    return amin, amax, notes


# ---------------- 공통: 우선/감면 문맥 가드 ----------------
GUARD = re.compile(r'우선|감면|면제|가점|순위|우대')

def guarded(t, pos, span=25, after=12):
    lo = max(0, pos - span)
    seg = t[lo:pos + after]
    return bool(GUARD.search(seg))


def find_tokens(t, pattern):
    """pattern 매치를 (매치문자열, 가드여부) 목록으로"""
    out = []
    for m in re.finditer(pattern, t):
        out.append((m.group(0), guarded(t, m.start())))
    return out


# ---------------- 소득 ----------------
def parse_income(text):
    """return (rank, uncertain('Y'|None), notes)"""
    t = norm(text)
    notes = []
    if re.search(r'소득수준무관|소득기준없음|소득무관|소득수준과무관|소득기준:없음|소득수준에관계없이|소득기준없이', t):
        if re.search(r'수급|차상위|중위소득|저소득', t):
            notes.append('소득 무관 명시(일부 조건에 소득기준 병존) — 원문 확인')
        return None, None, notes
    if re.search(r'및지역주민|지역주민누구나', t):
        # [D3 확장] "수급자/차상위 … 및 지역주민" 병기 = 전체 개방 → 소득 한정 아님
        if re.search(r'수급|차상위|중위소득|저소득|취약계층', t):
            notes.append('소득기준·지역주민 병기(전체 개방) — 확인 필요')
        return None, None, notes
    cands = []   # (rank, uncertain)
    pcts = []
    for m in re.finditer(r'중위(?:소득)?(\d{2,3})%', t):
        if not guarded(t, m.start()):
            pcts.append(int(m.group(1)))
        else:
            notes.append('소득기준은 우선/감면 조건(중위%s%%)' % m.group(1))
    if pcts:
        p = max(pcts)
        if p < 100:
            cands.append((3, 'Y'))
        elif p == 100:
            cands.append((3, None))
        elif p <= 150:
            cands.append((4, 'Y' if p != 150 else None))
        else:
            cands.append((4, 'Y'))
            notes.append('소득 상한 중위 %d%%(랭크 범위 초과) — 확인 필요' % p)
        if len(set(pcts)) > 1:
            notes.append('소득 기준 복수(%s%%) — 세부기준 확인' % ','.join(map(str, sorted(set(pcts)))))
    toks = find_tokens(t, r'수급')
    if any(not g for _, g in toks):
        cands.append((1, None))
    elif toks:
        notes.append('수급자는 우선/감면 대상 — 원문 확인')
    toks = find_tokens(t, r'차상위')
    if any(not g for _, g in toks):
        cands.append((2, None))
    toks = find_tokens(t, r'저소득|취약계층')
    if any(not g for _, g in toks):
        cands.append((3, 'Y'))
        notes.append('소득기준 상세 문의(저소득/취약계층 서술)')
    if re.search(r'기초연금|건강?보험료', t):
        # [D4] 기초연금·보험료 하위 기준은 수급/차상위보다 넓은 택일 기준 → 랭크로 조이면 틀리게 제외
        notes.append('기초연금/건강보험료 기준 — 소득랭크 미적용, 확인 필요')
        return None, 'Y', notes
    if not cands:
        return None, None, notes
    # 랭크는 누적 상한(1⊂2⊂3⊂4)이므로 복수 랭크는 모순이 아님 — 가장 느슨한 상한 채택
    rank = max(c for c, _ in cands)
    unc = 'Y' if any(u == 'Y' for c, u in cands if c == rank) else None
    return rank, unc, notes


# ---------------- 가구형태 ----------------
HH_PATTERNS = [
    ('SPAR', r'한부모|조손|조부모가정|부자가정|모자가정|소년소녀'),
    ('MCHD', r'다자녀'),
    ('MCUL', r'다문화'),
    ('NKOR', r'북한이탈'),
    ('PREG', r'임산부|임신|산모|난임|출산(?!장려)'),
    ('ONE',  r'1인가구|1인남성가구|독거|홀몸'),
]

def parse_household(text):
    t = norm(text)
    codes, notes = [], []
    for code, pat in HH_PATTERNS:
        toks = find_tokens(t, pat)
        if not toks:
            continue
        if any(not g for _, g in toks):
            if code not in codes:
                codes.append(code)
        else:
            notes.append('%s 계열은 우선/감면 조건 — 원문 확인' % toks[0][0])
    return (','.join(codes) if codes else None), notes


# ---------------- 장애 ----------------
DIS_PAT = r'등록장애인|장애인복지법|심한장애|중증장애|장애아동|장애인|발달장애|지적장애|자폐성?장애|뇌병변|장애정도|장애청소년|장애청년'

def parse_disability(c8, c9):
    notes = []
    t8, t9 = norm(c8), norm(c9)
    both = t8 + '|' + t9
    if re.search(r'장애.{0,6}(가족|부모및|자녀를둔)', both):
        notes.append('장애인 가족 대상 — 원문 확인')
        return None, notes
    if re.search(r'및지역주민|지역주민누구나', both):
        # [D3] "등록장애인 및 지역주민" 병기 = 전체 개방 → 장애 한정 아님
        if '장애' in both:
            notes.append('장애인·지역주민 병기(전체 개방) — 확인 필요')
        return None, notes
    if '비장애' in both:   # 장애·비장애 모두 대상 → 제한 없음
        return None, notes
    if '장애' in re.sub('비장애', '', t8):
        return 'Y', notes
    toks = find_tokens(t9, DIS_PAT)
    if any(not g for _, g in toks):
        return 'Y', notes
    if toks:
        notes.append('장애 관련은 우선/감면 조건 — 원문 확인')
    return None, notes


# ---------------- 국적 ----------------
def parse_nationality(text):
    t = norm(text)
    notes = []
    toks = find_tokens(t, r'외국인|결혼이민자|결혼이주|중도입국|이주배경|난민')
    if any(not g for _, g in toks):
        return 'F', notes
    if toks:
        notes.append('외국인 관련은 우선/가점 조건 — 원문 확인')
    if '주민등록을둔' in t:
        return 'K', notes
    return None, notes


# ---------------- 학업/취업 ----------------
def parse_edu_work(text):
    t = norm(text)
    codes, notes = [], []
    if not re.search(r'미취학', t):
        if re.search(r'초등학생|초·?중학생|중학생|고등학생|초중고|재학중|재학생|\d학년|취학', t):
            codes.append('STU')
    if re.search(r'대학생|대학재학|대학입학|대학진학|전공과', t):
        codes.append('UNIV')
    if re.search(r'구직|취업희망|취업을희망|미취업|취업취약계층|예비창업|초기창업|취업상담|구인·?구직', t):
        codes.append('SEEK')
    if re.search(r'재직|일하는|워킹맘|워킹대디|근무자|근로자(?!수)', t):
        codes.append('WORK')
    return (','.join(codes) if codes else None), notes


# ---------------- 그 외 '판단 불가/세부기준' 키워드 → note ----------------
AMBIG = [
    (r'국가유공자|유공자', '국가유공자 관련 기준'),
    (r'장기요양', '장기요양등급 기준'),
    (r'질병코드|진단', '질환/진단 기준'),
    (r'위탁가정|가정위탁', '가정위탁 보호대상'),
    (r'입양', '입양가정 기준'),
    (r'노숙인', '노숙인 등 대상'),
    (r'자활', '자활참여자 기준'),
    (r'등록회원|센터등록', '기관 등록회원 한정'),
    (r'사례관리|지역보호', '기관 사례관리 대상 선정'),
    (r'상담후|선정|심의|추천', '상담/심의로 대상 선정'),
    (r'무주택|전세|월세|보증금', '주택/임차 기준'),
    (r'재산|자산', '재산 기준 별도'),
    (r'학교밖', '학교 밖 청소년 대상'),
    (r'가정밖', '가정 밖 청소년 대상'),
    (r'위기|긴급', '위기/긴급 상황 요건'),
    (r'경계선', '경계선 지능 기준'),
    (r'비문해', '비문해 학습자 대상'),
    (r'치매|만성질환|재가암', '건강 상태 기준'),
    (r'자살', '자살 고위험군 등 대상'),
    (r'정신질환|정신장애|고위험군', '정신건강 기준'),
    (r'결식', '결식 우려 요건'),
    (r'양육공백|맞벌이', '양육공백(맞벌이 등) 요건'),
    (r'거동', '거동 불편 요건'),
    (r'모집공고|공고문', '모집 공고별 상이'),
    (r'상이\b|별도', '세부기준 별도/상이'),
    (r'의사상자', '의사상자 유족 기준'),
    (r'여성(?!새일|청소년)', '여성 대상(가구형태 코드 없음)'),
]

def ambig_notes(text):
    t = norm(text)
    out = []
    for pat, msg in AMBIG:
        if re.search(pat, t):
            out.append(msg)
    return out


NO_CONDITION = re.compile(r'^(해당사항없음|해당없음|무관|없음|-|제한없음|시흥시민|지역주민|누구나|시흥시주민|지역내거주하는지역주민|지역주민누구나)')


# ---------------- 행 태깅 ----------------
def tag_row(c8, c9, c15, c21):
    f = {'age_min': None, 'age_max': None, 'dong_codes': None, 'household_types': None,
         'income_rank': None, 'income_uncertain': None, 'disability': None,
         'nationality': None, 'edu_work': None, 'uncertain_note': None}
    notes = []
    f['dong_codes'], n = parse_dong(c15); notes += n
    # 15열이 시 전체(또는 미파싱)인데 9열에 '○○동 거주/주민' 요건이 있으면 9열에서 추출 (설계 02 §4)
    if f['dong_codes'] is None and re.search(r'거주|주민', norm(c9)):
        c9codes = dong_tokens(norm(c9))
        if c9codes:
            f['dong_codes'] = ','.join(c9codes)
    body = (c8 + '\n' + c9)
    # [D2] 번호 열거(3개 이상) + 법령 신분 2개 이상 인용 = 이질 요건 택일 목록 → AND 태깅 금지
    enum_alt = (len(re.findall(r'\d\)', c9)) >= 3
                and len(re.findall(r'법[\]』」\s]{0,4}(?:상|에\s*따른|에\s*따라)', c9)) >= 2)
    if enum_alt:
        notes.append('대상 요건 복수(택일) — 원문 확인')
    if (NO_CONDITION.match(norm(c9)) and not norm(c8)) or enum_alt:
        pass
    else:
        f['age_min'], f['age_max'], n = parse_age(body); notes += n
        f['income_rank'], f['income_uncertain'], n = parse_income(body); notes += n
        f['household_types'], n = parse_household(body); notes += n
        f['disability'], n = parse_disability(c8, c9); notes += n
        f['nationality'], n = parse_nationality(body); notes += n
        f['edu_work'], n = parse_edu_work(body); notes += n
        notes += ambig_notes(body)
    if norm(c21):
        notes.append('비고: ' + c21.replace('\n', ' ')[:60])
    if notes:
        seen, uniq = set(), []
        for x in notes:
            if x not in seen:
                seen.add(x); uniq.append(x)
        f['uncertain_note'] = '; '.join(uniq)[:300]
    return f


# ---------------- 기타 열 변환 ----------------
def map_provider(v):
    v = norm(v)
    if v == '공공' or v == '공공/민간':
        return 'PUB'
    return 'PRV'   # 민간, 지역발굴(민간 발굴자원으로 취급)


def map_cost(v):
    v = norm(v).upper()
    if v.startswith('X'):
        return 'X'
    if v.startswith('O'):
        return 'O'
    return None


URL_RE = re.compile(r'(https?://[^\s,)\u3001]+|www\.[^\s,)\u3001]+)')


def sql_str(s, maxlen=None):
    if s is None or s == '':
        return 'NULL'
    if maxlen and len(s) > maxlen:
        s = s[:maxlen - 1] + '…'   # 절단 표시 (M1)
    return "'" + s.replace('\\', '\\\\').replace("'", "''").replace('\n', '\\n').replace('\r', '') + "'"


def sql_val(v):
    return 'NULL' if v is None else str(v)


# nationality='F' 자원 영어 번역 샘플 (name 기준 매칭, 10건)
TRANSLATIONS = {
    '결혼이민자 취업교육': ('Employment Training for Marriage Immigrants',
        'Job training for marriage immigrants, including certificate courses and job placement support.'),
    '외국인근로자 단기쉼터': ('Short-term Shelter for Foreign Workers',
        'Temporary room and board for foreign workers who need short-term housing due to workplace changes or preparing to return home.'),
    '외국인주민 긴급지원(생계비)': ('Emergency Support for Foreign Residents (Living Expenses)',
        'Emergency support (living, medical and childbirth expenses) for low-income foreign residents in crisis due to illness, accident or disaster.'),
    '다문화가정 통번역서비스': ('Interpretation and Translation Service for Multicultural Families',
        'Multilingual interpretation and translation services for multicultural and foreign families in the community.'),
    '중도입국자녀 한국사회 적응지원': ('Adaptation Support for Immigrant Youth',
        'Support for teenagers who immigrated to Korea mid-childhood to help them adapt to Korean society.'),
    '결혼이민자 한국어교육': ('Korean Language Education for Marriage Immigrants',
        'Korean language classes by proficiency level for marriage immigrants.'),
    '결혼이민자 역량강화지원 한국어교육': ('Korean Language Education for Empowerment of Marriage Immigrants',
        'Korean language education to help marriage immigrants and foreign residents adapt to Korean society.'),
    '다문화교육지원': ('Education Support for Multicultural Families',
        'Basic learning (Korean, math), school adaptation education and parent education for multicultural families.'),
    '외국인주민 문화동아리': ('Culture Clubs for Foreign Residents',
        'Guitar, yoga, taekwondo, English and photography clubs for foreign residents.'),
    '다문화가족캠프': ('Multicultural Family Camp',
        'Camp program providing cultural activities for multicultural families.'),
}


def main():
    xlsx, outdir = sys.argv[1], sys.argv[2].rstrip('/')
    wb = openpyxl.load_workbook(xlsx, data_only=True)
    rows = []
    unresolved = []   # 태깅-미결 — 조건 서술이 있는데 7필드 전부 비고(지역 제외)인 경우
    for ws in wb.worksheets:
        if ws.title not in CATEGORY:
            continue
        cat = CATEGORY[ws.title]
        for r in range(4, ws.max_row + 1):
            vals = [cell(ws, r, c) for c in range(1, 23)]
            if all(v == '' for v in vals):
                continue
            (seq, ptype, big, mid, stype, name, content, c8, c9, period, cycle,
             org, phone, addr, area, applicant, method, docs, costf, costa,
             note21, dept) = vals
            f = tag_row(c8, c9, area, note21)
            # [M1] phone/address 컬럼 상한 초과 시 절단 발생 — note 로 알림 ('…' 표시는 sql_str)
            trunc_msgs = []
            if phone and len(phone) > 150:
                trunc_msgs.append('연락처 일부 절단(동별 연락처는 원문/신청방법 참조)')
            if addr and len(addr) > 200:
                trunc_msgs.append('주소 일부 절단(동별 주소는 담당기관 문의)')
            if trunc_msgs:
                f['uncertain_note'] = '; '.join(([f['uncertain_note']] if f['uncertain_note'] else []) + trunc_msgs)[:300]
            apply_url = None
            m = URL_RE.search(method or '')
            if m:
                apply_url = m.group(1)
            row = {
                'name': name or '(서비스명 미기재)',
                'category': cat, 'sub_category': mid or None,
                'service_type': stype or None,
                'provider_type': map_provider(ptype), 'provider_raw': norm(ptype),
                'org_name': org or dept or '(기재 없음)',
                'dept_name': dept or None, 'phone': phone or None,
                'address': addr or None,
                'support_content': content or name or '(내용 미기재)',
                'apply_method': method or None, 'documents': docs or None,
                'apply_url': apply_url, 'applicant': applicant or None,
                'decision_period': period or None, 'service_cycle': cycle or None,
                'cost_flag': map_cost(costf), 'cost_amount': costa or None,
                'eligibility_raw': c9 or None,
                'c8': c8, 'area': area,
                **f,
            }
            rows.append(row)
            tagged = any(f[k] is not None for k in
                         ('age_min', 'age_max', 'household_types', 'income_rank',
                          'disability', 'nationality', 'edu_work'))
            has_cond = bool(norm(c9)) and not NO_CONDITION.match(norm(c9))
            if has_cond and not tagged:
                unresolved.append((cat, name, c9))

    assert len(rows) == 744, 'expected 744 rows, got %d' % len(rows)

    # ---------- seed.sql ----------
    cols = ['resource_id', 'name', 'category', 'sub_category', 'service_type',
            'provider_type', 'org_name', 'dept_name', 'phone', 'address',
            'support_content', 'apply_method', 'documents', 'apply_url',
            'age_min', 'age_max', 'dong_codes', 'household_types', 'income_rank',
            'income_uncertain', 'disability', 'nationality', 'edu_work',
            'uncertain_note', 'eligibility_raw', 'decision_period', 'service_cycle',
            'applicant', 'cost_flag', 'cost_amount',
            'source_name', 'source_url', 'data_base_date', 'status']
    lines = ["-- 복지이음 seed.sql — parse_tag.py 자동 생성 (%s)" % datetime.date.today(),
             "-- 원본: 시흥시 복지자원 종합안내서.xlsx (744건)",
             "SET NAMES utf8mb4;", ""]
    chunk = []
    for i, row in enumerate(rows, 1):
        v = [str(i),
             sql_str(row['name'], 200), sql_str(row['category']), sql_str(row['sub_category'], 100),
             sql_str(row['service_type'], 20), sql_str(row['provider_type']),
             sql_str(row['org_name'], 100), sql_str(row['dept_name'], 100),
             sql_str(row['phone'], 150), sql_str(row['address'], 200),
             sql_str(row['support_content']), sql_str(row['apply_method']),
             sql_str(row['documents']), sql_str(row['apply_url'], 300),
             sql_val(row['age_min']), sql_val(row['age_max']),
             sql_str(row['dong_codes'], 200), sql_str(row['household_types'], 100),
             sql_val(row['income_rank']), sql_str(row['income_uncertain']),
             sql_str(row['disability']), sql_str(row['nationality']),
             sql_str(row['edu_work'], 50), sql_str(row['uncertain_note'], 300),
             sql_str(row['eligibility_raw']), sql_str(row['decision_period'], 200),
             sql_str(row['service_cycle'], 200), sql_str(row['applicant'], 200),
             sql_str(row['cost_flag']), sql_str(row['cost_amount']),
             sql_str(SOURCE_NAME), 'NULL', sql_str(DATA_BASE_DATE), "'A'"]
        chunk.append('(' + ','.join(v) + ')')
        if len(chunk) == 40 or i == len(rows):
            lines.append('INSERT INTO resource (' + ','.join(cols) + ') VALUES\n'
                         + ',\n'.join(chunk) + ';')
            chunk = []

    # RESOURCE_I18N 샘플 (nationality='F' 자원 10건, 영어)
    lines.append('')
    lines.append('-- RESOURCE_I18N 샘플: nationality=F 자원 10건 영어 번역')
    used = set()
    i18n = 0
    for i, row in enumerate(rows, 1):
        if row['nationality'] == 'F' and row['name'] in TRANSLATIONS and row['name'] not in used:
            name_tr, summary_tr = TRANSLATIONS[row['name']]
            lines.append("INSERT INTO resource_i18n (resource_id, lang, name_tr, summary_tr) "
                         "VALUES (%d,'en',%s,%s);" % (i, sql_str(name_tr, 200), sql_str(summary_tr, 500)))
            used.add(row['name']); i18n += 1
    with open(outdir + '/seed.sql', 'w', encoding='utf-8') as fo:
        fo.write('\n'.join(lines) + '\n')

    # ---------- 태깅-미결.md ----------
    with open(outdir + '/태깅-미결.md', 'w', encoding='utf-8') as fo:
        fo.write('# 태깅 미결 사례 — 규칙으로 7필드를 하나도 채우지 못한 조건 서술\n\n')
        fo.write('기준: 9열(지원 기준)에 실질 조건이 있으나 자동 규칙이 연령·가구·소득·장애·국적·학업취업 '
                 '어느 필드도 채우지 못한 행. 전부 uncertain_note 로 "확인 필요" 처리됨.\n\n')
        fo.write('총 %d건 / 744건\n\n| 분야 | 자원명 | 지원 기준 원문 |\n|---|---|---|\n' % len(unresolved))
        for cat, name, c9 in unresolved:
            fo.write('| %s | %s | %s |\n' % (cat, name.replace('\n', ' '),
                                             c9.replace('\n', ' ').replace('|', '／')[:160]))

    # ---------- 통계 ----------
    def fill(k):
        return sum(1 for r in rows if r[k] is not None)
    stats = {
        'total': len(rows),
        'by_category': {},
        'provider': {},
        'cost_flag': {},
        'fill': {k: fill(k) for k in ('age_min', 'age_max', 'dong_codes', 'household_types',
                                      'income_rank', 'income_uncertain', 'disability',
                                      'nationality', 'edu_work', 'uncertain_note')},
        'age_any': sum(1 for r in rows if r['age_min'] is not None or r['age_max'] is not None),
        'nationality_F': sum(1 for r in rows if r['nationality'] == 'F'),
        'unresolved': len(unresolved),
        'i18n': i18n,
        'provider_raw': {},
    }
    for r in rows:
        stats['by_category'][r['category']] = stats['by_category'].get(r['category'], 0) + 1
        stats['provider'][r['provider_type']] = stats['provider'].get(r['provider_type'], 0) + 1
        stats['provider_raw'][r['provider_raw']] = stats['provider_raw'].get(r['provider_raw'], 0) + 1
        k = r['cost_flag'] or 'NULL'
        stats['cost_flag'][k] = stats['cost_flag'].get(k, 0) + 1
    print(json.dumps(stats, ensure_ascii=False, indent=1))

    # 대표 예시 후보 출력 (원문 → 태깅)
    print('--- EXAMPLES ---')
    shown = 0
    wanted = ['구인·구직', '발달재활', '한국어', '학교밖', '정왕동 거주 60', '중위소득 120',
              '기초수급자이며 75세', '수급, 법청차상위', '만 9세~24세', '채권추심']
    for i, r in enumerate(rows, 1):
        key = (r['c8'] + r['eligibility_raw'] if r['eligibility_raw'] else r['c8'])
        if any(w in (r['eligibility_raw'] or '') + r['c8'] + r['name'] for w in wanted) and shown < 14:
            print(json.dumps({'id': i, 'name': r['name'], 'c9': (r['eligibility_raw'] or '')[:90],
                              'area': r['area'][:40],
                              'tags': {k: r[k] for k in ('age_min', 'age_max', 'dong_codes',
                                                         'household_types', 'income_rank', 'income_uncertain',
                                                         'disability', 'nationality', 'edu_work', 'uncertain_note')}},
                             ensure_ascii=False))
            shown += 1


if __name__ == '__main__':
    main()
