# -*- coding: utf-8 -*-
"""2025판 시흥시 복지자원 종합안내서(xlsx) 무결성·교차 검증 — 읽기 전용 (DB/seed 변경 없음).
실행: python3 -I check_2025.py <A.xlsx> <B.xlsx> <old_db.tsv>   (old_db.tsv = resource 테이블 덤프: resource_id,name,org_name,category,provider_type,source_name)
출력: 마크다운 보고서(표준출력). 개인정보 보호: openpyxl 이 시트 XML을 파싱하는 동안 담당자 열(A의 AA–AC)도 라이브러리 내부에서는 해석된다(막을 수 없음).
  이 도구는 허용 열(A: C–Z, B: C–R)만 행으로 돌려받고, 보고서·집계에는 그 값만 쓴다. 합성 표식으로 출력 미노출을 시험했다.
  담당자 값이 라이브러리 내부에서도 해석되면 안 되는 환경이라면 담당자 열을 제거한 사본을 입력으로 쓴다.
"""
import sys, re, csv, collections
import openpyxl

def n(s): return re.sub(r'[\s\W_]+', '', str(s or ''))
def rows(path, last):
    """last = 허용 마지막 열의 0기반 인덱스(A: Z=25, B: R=17). read_only 스트리밍 + max_col 로 허용 밖 열은 행으로 만들지 않는다.
    인덱스는 원본 열 위치(C=2…)를 유지하도록 앞 두 칸을 None 으로 채운다."""
    wb = openpyxl.load_workbook(path, read_only=True, data_only=True)
    out = []
    for r in wb['복지자원'].iter_rows(min_row=7, min_col=3, max_col=last + 1, values_only=True):
        if any(c not in (None, '') for c in r):
            out.append((None, None) + tuple(r))
    wb.close()
    return out

A = rows(sys.argv[1], 25); B = rows(sys.argv[2], 17)
old = list(csv.DictReader(open(sys.argv[3], encoding='utf-8'), delimiter='\t'))
o22 = [r for r in old if r['source_name'].startswith('시흥시 복지자원')]
# 0기반 인덱스(=Excel 열 문자). A: C담당기관(2) D공개(3) E구분(4) F대분류(5) G중분류(6) H유형(7) I서비스명(8) J상세(9) L대상(11) M기준(12) P실제제공기관(15) Q연락처(16) R주소(17) S지역(18) U방법(20) V서류(21) W본인부담(22)
# B: C구분(2) D대분류(3) E중분류(4) F유형(5) G담당기관(6) H연락처(7) I서비스명(8) J상세(9) K대상(10) L기준(11) N제공주체(13) O연락처(14) P지역(15) Q방법(16) R서류(17)
def stats(R, k):
    g = lambda c: [r[c] if c < len(r) else None for r in R]
    return {
        'rows': len(R),
        '서비스명 빈칸': sum(1 for v in g(k['name']) if not n(v)),
        '기관 빈칸': sum(1 for v in g(k['org']) if not n(v)),
        '지원내용 빈칸': sum(1 for v in g(k['det']) if not n(v)),
        '구분이 공공/민간/지역발굴 아님': sum(1 for v in g(k['kind']) if v not in ('공공', '민간', '지역발굴')),
        '대분류 11종 밖': sum(1 for v in g(k['big']) if v not in BIG),
        '유형 목록 밖': sum(1 for v in g(k['typ']) if v not in TYP),
        '허용 열 기준 완전중복행': len(R) - len({tuple(str(x) for x in r) for r in R}),
    }
BIG = {'문화 및 여가', '돌봄(일상생활)', '보육 및 교육', '신체적 건강', '경제(현금중심)', '정신적 건강', '일자리', '주거', '법률 및 권익보장', '관계', '안전'}
TYP = {'프로그램', '기타서비스', '기타 서비스', '현금', '바우처', '현물', '시설입소', '대여/감면', '자원봉사'}
ka = dict(org=2, kind=4, big=5, name=8, det=9, typ=7)
kb = dict(org=6, kind=2, big=3, name=8, det=9, typ=5)
sa, sb = stats(A, ka), stats(B, kb)
print('# 2025판 종합안내서 검증 보고서 (읽기 전용)\n')
print('| 항목 | A(2025 하반기, 수정 2026-03-26) | B(2025, 수정 2025-07-24) |\n|---|---|---|')
for k in sa: print('| %s | %s | %s |' % (k, sa[k], sb[k]))
on = {n(r['name']) for r in o22}
an = {n(r[8]) for r in A} - {''}; bn = {n(r[8]) for r in B} - {''}   # 빈 이름 제외
print('\n## 기존 DB(2022판 %d건)와 서비스명 대조\n' % len(o22))
print('- 기존 2022판 중 A에 이름이 있는 건: %d / %d (%.0f%%)' % (sum(1 for r in o22 if n(r['name']) in an), len(o22), 100 * sum(1 for r in o22 if n(r['name']) in an) / len(o22)))
print('- A 중 기존 2022판에 이름이 있는 건: %d / %d' % (sum(1 for r in A if n(r[8]) in on), len(A)))
print('- A∩B 서비스명 %d, A만 %d, B만 %d' % (len(an & bn), len(an - bn), len(bn - an)))
oth = [r for r in old if not r['source_name'].startswith('시흥시 복지자원')]
print('- API·보조금24 추가분 %d건 중 A와 이름 일치: %s' % (len(oth), [r['name'] for r in oth if n(r['name']) in an]))
print('\n## 분류 체계 교차 (이름이 일치하는 행: 새 대분류 → 기존 category)\n')
m = {n(r['name']): r['category'] for r in o22}
x = collections.Counter((r[5], m[n(r[8])]) for r in A if n(r[8]) in m)
print('| 새 대분류 | 기존 category | 건수 |\n|---|---|---|')
for kk, v in sorted(x.items(), key=lambda t: -t[1]): print('| %s | %s | %d |' % (kk[0], kk[1], v))
