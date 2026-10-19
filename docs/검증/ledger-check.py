#!/usr/bin/env python3
"""본문 검증 대장 독립 검증. usage: ledger-check.py [대장.csv] [reliability-content.sql]   종료코드 = 위반 수. --selftest 로 자체 검출력 확인.
규칙: 필수 열·값, 확인필드 허용값, 전값≠후값, 날짜 형식, 미확인사항 명시(없으면 '없음'), 반영 SQL의 resource_id ↔ 대장 행 1:1.
데이터가 아직 없으면(0행·SQL 없음) 통과하되 '0행'임을 출력한다 — 본문 대조가 수행됐다는 증거가 아니다."""
import csv, re, sys, os, tempfile
COLS = ['resource_id', '자원명', '확인필드', '전값', '후값', '출처', '출처위치', '확인일', '확인자', '미확인사항']
FIELDS = {'지원내용', '자격', '금액', '신청방법', '서류', '기간'}

def check(ledger, sql):
    bad = []
    with open(ledger, encoding='utf-8-sig', newline='') as f:
        rd = csv.DictReader(f)
        if rd.fieldnames != COLS: return [f'열 불일치: {rd.fieldnames}']
        rows = list(rd)
    ids = []
    for n, r in enumerate(rows, 2):
        for c in COLS:
            if not (r[c] or '').strip(): bad.append(f'{n}행 {c} 비어 있음')
        if not (r['resource_id'] or '').isdigit(): bad.append(f'{n}행 resource_id 숫자 아님')
        else: ids.append(int(r['resource_id']))
        if r['확인필드'] and r['확인필드'] not in FIELDS: bad.append(f'{n}행 확인필드 허용값 아님: {r["확인필드"]}')
        if r['전값'] and r['전값'] == r['후값']: bad.append(f'{n}행 전값=후값(변경 없음은 대장에 올리지 않는다)')
        if r['확인일'] and not re.fullmatch(r'\d{4}-\d{2}-\d{2}', r['확인일']): bad.append(f'{n}행 확인일 형식')
    if sql and os.path.exists(sql):
        sql_ids = {int(x) for x in re.findall(r'resource_id\s*=\s*(\d+)', open(sql, encoding='utf-8').read())}
        for i in sorted(sql_ids - set(ids)): bad.append(f'SQL에는 있으나 대장에 없음: {i}')
        for i in sorted(set(ids) - sql_ids): bad.append(f'대장에는 있으나 SQL에 없음: {i}')
    print(f'대장 {len(rows)}행' + (' (0행: 본문 대조 미수행 상태)' if not rows else ''))
    return bad

def selftest():
    d = tempfile.mkdtemp(); L = os.path.join(d, 'l.csv'); S = os.path.join(d, 'c.sql')
    good = ['10', 'A', '금액', '10만원', '20만원', '복지로', 'p.3', '2026-10-19', '검증자', '없음']
    def w(rows, sql=''):
        with open(L, 'w', encoding='utf-8-sig', newline='') as f:
            cw = csv.writer(f); cw.writerow(COLS); cw.writerows(rows)
        open(S, 'w').write(sql)
    w([good], 'UPDATE resource SET x=1 WHERE resource_id=10;'); assert not check(L, S), 'good 통과해야 함'
    w([good], 'UPDATE resource SET x=1 WHERE resource_id=11;'); assert len(check(L, S)) == 2, 'SQL↔대장 불일치 2건'
    bad = list(good); bad[9] = ''; w([bad], 'resource_id=10'); assert check(L, S), '미확인사항 공란 검출'
    bad = list(good); bad[4] = bad[3]; w([bad], 'resource_id=10'); assert check(L, S), '전=후 검출'
    bad = list(good); bad[2] = '아무거나'; w([bad], 'resource_id=10'); assert check(L, S), '확인필드 검출'
    print('selftest OK')

if __name__ == '__main__':
    if '--selftest' in sys.argv: selftest(); sys.exit(0)
    a = [x for x in sys.argv[1:]]
    led = a[0] if a else 'docs/데이터/수집/본문검증대장.csv'; sql = a[1] if len(a) > 1 else 'src/main/resources/sql/reliability-content.sql'
    v = check(led, sql); [print('FAIL', x) for x in v]; print('FAIL' if v else 'PASS'); sys.exit(len(v))
