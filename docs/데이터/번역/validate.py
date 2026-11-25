import json,glob,os,re,collections
H=re.compile('[가-힣]')
ok=[];bad={}
for bf in sorted(glob.glob('batch/*.json')):
    n=os.path.basename(bf)
    src=json.load(open(bf))
    rf='result/'+n
    if not os.path.exists(rf): bad[n]='missing';continue
    try: res=json.load(open(rf))
    except Exception as e: bad[n]='badjson';continue
    miss=[x['h'] for x in src if x['h'] not in res or not all(res[x['h']].get(l,'').strip() for l in('en','zh','vi'))]
    hang=sum(1 for x in src if x['h'] in res for l in('en','zh','vi') if H.search(res[x['h']].get(l,'')))
    numbad=0
    for x in src:
        r=res.get(x['h'])
        if not r: continue
        dn=collections.Counter(re.findall(r'\d+',x['src']))
        for l in('en','zh','vi'):
            tn=collections.Counter(re.findall(r'\d+',r.get(l,'')))
            if any(tn[k]<v for k,v in dn.items()): numbad+=1
    if miss: bad[n]=f'incomplete {len(miss)}/{len(src)} missing'
    else: ok.append(n); print(n,'OK items',len(src),'hangul',hang,'numdiff',numbad)
print('BAD',bad)
