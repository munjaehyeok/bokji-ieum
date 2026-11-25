#!/usr/bin/env python3
"""상세 '신청 방법' 링크화 회귀 (서버 :8099). 텍스트 속 URL은 링크, 다른 HTML은 이스케이프, 스킴 없는 apply_url은 https로."""
import urllib.request, re, sys, subprocess
def rid_of(name):  # id 하드코딩 금지: 이름으로 활성 행 조회
    r = subprocess.run(['docker', 'exec', 'bokji-verify', 'mysql', '-uroot', '-pverify', '--default-character-set=utf8mb4', 'bokji', '-N', '-e',
                        "select resource_id from resource where status='A' and name='%s' order by resource_id limit 1" % name], capture_output=True, text=True)
    return int(r.stdout.split()[0])
B = 'http://127.0.0.1:8099'; bad = 0
def page(rid): return urllib.request.urlopen('%s/resources/%d' % (B, rid)).read().decode()
def check(n, c):
    global bad; print(('PASS ' if c else 'FAIL ') + n); bad += (not c)
A, Bn = rid_of('청년내일저축계좌 차상위이하'), rid_of('에너지바우처')  # A: 신청방법에 'www. bokjiro. go. kr' / Bn: 스킴 없는 apply_url
h = page(A)
check('청년내일저축계좌 신청방법 속 "www. bokjiro. go. kr" 가 https://www.bokjiro.go.kr 링크', 'href="https://www.bokjiro.go.kr"' in h)
check('청년내일저축계좌 링크는 새 탭·noopener', 'target="_blank" rel="noopener">www. bokjiro. go. kr</a>' in h)
h = page(Bn)
check('에너지바우처 스킴 없는 apply_url 버튼이 https:// 로 시작(상대경로 아님)', re.search(r'<a class="btn btn-bk mt-2" href="https://www\.bokjiro\.go\.kr', h) is not None)
print('FAIL %d' % bad if bad else 'ALL PASS'); sys.exit(1 if bad else 0)
