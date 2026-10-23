/* 찜(탐색 모드) — localStorage 전용. 서버에 보내는 것은 찜 목록 보기의 ids 쿼리뿐(최대 50, 서버가 활성 ID만 통과시킴). */
(function () {
    'use strict';
    var KEY = 'bkFavs', MAX = 50;
    var ok = true;
    function read() {
        try {
            var raw = JSON.parse(localStorage.getItem(KEY) || '[]');
            if (!Array.isArray(raw)) return [];
            var seen = {}, out = [];
            raw.forEach(function (v) {
                var n = parseInt(v, 10);
                if (n > 0 && !seen[n] && out.length < MAX) { seen[n] = 1; out.push(n); }
            });
            return out;
        } catch (e) { ok = false; return []; }
    }
    function write(list) { try { localStorage.setItem(KEY, JSON.stringify(list.slice(0, MAX))); } catch (e) { ok = false; } }

    var buttons = document.querySelectorAll('.bk-fav');
    var toggle = document.getElementById('bkFavToggle');
    var msg = document.getElementById('bkFavMsg');
    if (!buttons.length && !toggle) return;
    var favs = read();
    if (!ok) { if (msg) msg.hidden = false; return; }   // 저장소 불가: 찜 UI를 숨긴 채 안내

    function paint() {
        buttons.forEach(function (b) {
            var on = favs.indexOf(parseInt(b.dataset.id, 10)) >= 0;
            b.hidden = false;
            b.setAttribute('aria-pressed', on ? 'true' : 'false');
            b.setAttribute('aria-label', on ? b.dataset.on : b.dataset.off);
            b.classList.toggle('on', on);
        });
        if (toggle) {
            toggle.hidden = false;
            var cnt = document.getElementById('bkFavCount');
            if (cnt) cnt.textContent = '(' + favs.length + ')';
        }
    }
    buttons.forEach(function (b) {
        b.addEventListener('click', function (e) {
            e.preventDefault();
            var id = parseInt(b.dataset.id, 10), i = favs.indexOf(id);
            if (i >= 0) favs.splice(i, 1); else if (favs.length < MAX) favs.push(id);
            write(favs); paint();
        });
    });
    if (toggle) {
        toggle.addEventListener('click', function (e) {
            e.preventDefault();
            location.href = toggle.dataset.base + '?ids=' + encodeURIComponent(favs.join(','));
        });
        if (new URLSearchParams(location.search).has('ids')) toggle.classList.add('active');
    }
    paint();
})();
