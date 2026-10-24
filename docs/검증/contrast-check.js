// 대비(WCAG AA) 측정 — 검증 서버가 뜬 상태에서 같은 출처의 아무 페이지 콘솔(또는 Claude in Chrome javascript_tool)에 붙여넣어 실행.
// 각 화면을 1280·390px iframe에 넣고 글자색/배경/크기 조합이 기준(일반 4.5, 큰 글씨 3)에 못 미치는 것과 가로 넘침을 보고한다.
(async () => {
  const lum = c => { const [r, g, b] = c.match(/[\d.]+/g).slice(0, 3).map(Number).map(v => { v /= 255; return v <= .03928 ? v / 12.92 : Math.pow((v + .055) / 1.055, 2.4); }); return .2126 * r + .7152 * g + .0722 * b; };
  const ratio = (a, b) => { const [x, y] = [lum(a), lum(b)].sort((p, q) => q - p); return +(((x + .05) / (y + .05)).toFixed(2)); };
  const wrap = document.createElement('div'); wrap.style.cssText = 'position:fixed;left:-9999px;top:0'; document.body.appendChild(wrap);
  const URLS = ['/', '/match', '/match/result', '/resources', '/resources/181', '/resources?lang=en&hh=DIS', '/resources?lang=zh', '/resources?lang=vi&cat=EDU'];
  let total = 0, failsAll = 0; const problems = {};
  for (const u of URLS) for (const W of [1280, 390]) {
    const f = document.createElement('iframe'); f.style.cssText = `width:${W}px;height:800px;border:0`; f.src = u; wrap.appendChild(f);
    await new Promise(r => f.onload = r); await new Promise(r => setTimeout(r, 350));
    const d = f.contentDocument, w = f.contentWindow;
    const bgOf = e => { while (e) { const b = w.getComputedStyle(e).backgroundColor; if (b && !/rgba?\(0, 0, 0, 0\)/.test(b)) return b; e = e.parentElement; } return 'rgb(255,255,255)'; };
    const seen = new Set(), fails = [];
    d.querySelectorAll('a,button,h1,h2,h3,p,span,label,li,dt,dd,legend,small,th,td').forEach(e => {
      if (![...e.childNodes].some(x => x.nodeType === 3 && x.textContent.trim())) return;
      const s = w.getComputedStyle(e); if (s.display === 'none' || s.visibility === 'hidden' || e.closest('[hidden]')) return;
      const fg = s.color, bg = bgOf(e), k = fg + bg + s.fontSize; if (seen.has(k)) return; seen.add(k); total++;
      const px = parseFloat(s.fontSize), bold = parseInt(s.fontWeight) >= 700, need = (px >= 24 || (px >= 18.66 && bold)) ? 3 : 4.5, r = ratio(fg, bg);
      if (r < need) { fails.push({ r, need, fg, bg, t: e.textContent.trim().slice(0, 14) }); failsAll++; }
    });
    if (fails.length || d.documentElement.scrollWidth !== W) problems[`${u}@${W}`] = { sw: d.documentElement.scrollWidth, fails };
  }
  console.log(JSON.stringify({ pairsChecked: total, failsAll, problems }));
  return { pairsChecked: total, failsAll, problems };
})();
