#!/usr/bin/env python3
"""PLAN.md 표 검사: 알 수 없는 의존, 순환, 소유 경로 겹침(서로 의존 없는 작업끼리), 병렬 폭. usage: python3 plan-check.py PLAN.md"""
import re, sys
rows = {}
for line in open(sys.argv[1], encoding="utf8"):
    c = [x.strip() for x in line.strip().strip("|").split("|")]
    if len(c) >= 6 and re.fullmatch(r"T\d+", c[0]):
        paths = [p.strip().rstrip("/") for p in c[3].split(",") if p.strip()]
        deps = [d.strip() for d in re.split(r"[,\s]+", c[4]) if re.fullmatch(r"T\d+", d.strip())]
        rows[c[0]] = (c[1], paths, deps, c[2], c[6] if len(c) > 6 else "")
errs = []
for t, (_, _, deps, _, _) in rows.items():
    errs += [f"알 수 없는 의존: {t} -> {d}" for d in deps if d not in rows]
def anc(t, seen=()):
    out = set()
    for d in rows[t][2]:
        if d in rows:
            out.add(d)
            if d not in seen and d != t:
                out |= anc(d, seen + (t,))
    return out
for t in rows:
    if t in anc(t): errs.append(f"순환 의존: {t}")
if not errs:
    ids = sorted(rows)
    for i, a in enumerate(ids):
        for b in ids[i + 1:]:
            if a in anc(b) or b in anc(a): continue
            for pa in rows[a][1]:
                for pb in rows[b][1]:
                    if pa == pb or pa.startswith(pb + "/") or pb.startswith(pa + "/"):
                        errs.append(f"소유 경로 겹침(병렬 불가, 의존을 추가해 직렬화): {a} {pa} <-> {b} {pb}")
if errs: print("\n".join(errs)); sys.exit(1)
waves, done = [], set()
while len(done) < len(rows):
    w = [t for t in sorted(rows) if t not in done and all(d in done for d in rows[t][2])]
    waves.append(w); done |= set(w)
for i, w in enumerate(waves, 1): print(f"wave {i}: {', '.join(w)}  ({len(w)}개 병렬)")
if max(len(w) for w in waves) > 5: print("경고: 병렬 폭이 5를 넘는다. 비용·조정 부담이 커지니 묶거나 나눠서 실행.")
slices = {}
for t, (_, _, _, kind, sl) in rows.items():
    if sl and sl not in ("-", "통합"): slices.setdefault(sl, set()).add(kind)
for sl, kinds in sorted(slices.items()):
    if not {"구현", "테스트"} <= kinds: print(f"경고: 슬라이스 '{sl}'에 구현과 테스트 작업이 한 쌍으로 없다 ({'/'.join(sorted(kinds))}만 있음)")
print("OK")
