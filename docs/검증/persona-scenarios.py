import urllib.request,urllib.parse,http.cookiejar,json
B='http://127.0.0.1:8099'
def run(**c):
    cj=http.cookiejar.CookieJar(); op=urllib.request.build_opener(urllib.request.HTTPCookieProcessor(cj))
    d=[(k,v) for k,v in c.items() if not isinstance(v,list)]+[(k,x) for k,v in c.items() if isinstance(v,list) for x in v]
    op.open(B+'/match',urllib.parse.urlencode(d).encode()).read()
    return json.load(op.open(B+'/match/result/list?member=0'))
P={
'무조건(전부 모름)':dict(birthYear=1990,incomeRank=0,disability='U',nationality='K'),
'80세 기초수급 독거':dict(birthYear=1946,incomeRank=1,disability='N',nationality='K',householdTypes=['ONE']),
'35세 차상위 한부모':dict(birthYear=1991,incomeRank=2,disability='N',nationality='K',householdTypes=['SPAR']),
'8세 아동(소득 중위100)':dict(birthYear=2018,incomeRank=3,disability='N',nationality='K'),
'45세 중증장애 기초수급':dict(birthYear=1981,incomeRank=1,disability='Y',nationality='K'),
'30세 외국인 근로자 소득모름':dict(birthYear=1996,incomeRank=0,disability='N',nationality='F'),
'40세 일반 중위150초과':dict(birthYear=1986,incomeRank=4,disability='N',nationality='K'),
}
for n,c in P.items():
    r=run(**c); t=len(r)
    full=sum(1 for x in r if x['matchedLabels'] and not x['needCheckLabels'])
    m=sum(1 for x in r if x['matchedLabels']); nc=sum(1 for x in r if x['needCheckLabels'])
    zero=sum(1 for x in r if not x['matchedLabels'])
    print(f"{n:22s} 노출 {t:4d} | 일치있음 {m:4d} | 일치없음(자격 불문 노출) {zero:4d} | 확인필요 {nc:4d} | 확인필요 없고 일치 {full:4d}")
    print('    상위3:',[ (x['displayName'][:18],x['matchedLabels'],x['needCheckLabels']) for x in r[:3]])
