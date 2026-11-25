/* 상세 페이지 담당 기관 위치 지도 (네이버 지도 Web Dynamic Map + Geocoder 서브모듈)
 * - 주소 → 좌표 변환은 브라우저에서 한다(DB에 좌표를 저장하지 않음).
 * - 키 인증 실패·변환 실패·스크립트 로드 실패 시 지도 영역 전체를 숨긴다(빈 박스를 남기지 않음).
 */
(function () {
    'use strict';
    // ---- 주소 문자열 → 지오코딩 후보 목록 -------------------------------------
    // 원본 데이터에는 여러 줄 주소("정왕점 ) …\n은행점 ) …"), 라벨("북부 - …"),
    // 괄호("마유로 416(정왕동)307호"), 시/도 생략("거북섬5길 16") 같은 변형이 섞여 있다.
    var CITY_RE = /시흥시|(^|\s)[가-힣]{1,6}(시|군|구)\s/;
    function looksLikeAddress(t) { return /\d/.test(t) && /(로|길|동|리|읍|면)/.test(t); }
    function buildCandidates(raw) {
        var out = [];
        String(raw || '').split(/[\r\n]+/).forEach(function (line) {
            var inParens = [];
            line.replace(/\(([^)]*)\)/g, function (m, t) { inParens.push(t); return m; });
            line = line.replace(/\([^)]*\)/g, ' ');
            // 앞쪽 라벨 제거: "대야본소 :", "북부 -", "정왕점 )", "1호:"
            line = line.replace(/^\s*[^\s:)\-]{1,10}\s*[:)\-]\s+/, '');
            line = line.split(',')[0].replace(/\s+/g, ' ').trim();
            if (!looksLikeAddress(line)) {
                // 괄호 안에 실제 주소가 있는 경우: "시흥시청(시청로 20), 4층"
                var inner = null;
                inParens.forEach(function (t) { if (!inner && looksLikeAddress(t)) inner = t.split(',')[0].replace(/\s+/g, ' ').trim(); });
                if (!inner) return;                            // "-", "명단 참조", "시흥시청" 등은 제외
                line = inner;
            }
            if (!CITY_RE.test(line)) line = '경기도 시흥시 ' + line; // 시/군/구가 없으면 시흥시 안에서 찾는다
            if (out.indexOf(line) < 0) out.push(line);
        });
        return out;
    }

    var box = document.getElementById('bkOrgMap');
    var wrap = document.getElementById('bkOrgMapWrap');
    if (!box || !wrap) return;

    var clientId = box.getAttribute('data-client-id');
    var address = (box.getAttribute('data-address') || '').trim();
    var orgName = box.getAttribute('data-name') || '';
    if (!clientId || !address) return;

    // 주소를 지도에서 못 찾았을 때: 빈 박스 대신 안내 문구와 검색 링크를 보여 준다
    function notFound() {
        var msg = box.getAttribute('data-notfound') || '';
        wrap.hidden = false;
        box.removeAttribute('role');
        box.style.height = 'auto';
        box.style.padding = '1rem';
        box.textContent = msg;
        var link = document.getElementById('bkOrgMapLink');
        if (link) link.href = 'https://map.naver.com/p/search/' + encodeURIComponent(orgName ? orgName + ' ' + candidates[0] : candidates[0]);
    }

    function giveUp() { wrap.hidden = true; wrap.parentNode && wrap.parentNode.removeChild(wrap); }

    // 인증 실패(Client ID 오류, 허용 URL 미등록 등)
    window.navermap_authFailure = giveUp;

    var candidates = buildCandidates(address);
    if (!candidates.length) { giveUp(); return; } // 주소가 아닌 값이면 지도 영역을 만들지 않는다

    function geocode(list, done) {
        if (!list.length) { done(null); return; }
        naver.maps.Service.geocode({ query: list[0] }, function (status, res) {
            var ok = status === naver.maps.Service.Status.OK && res && res.v2 &&
                     res.v2.addresses && res.v2.addresses.length > 0;
            if (ok) {
                var a = res.v2.addresses[0];
                done({ lat: parseFloat(a.y), lng: parseFloat(a.x) });
            } else {
                geocode(list.slice(1), done);
            }
        });
    }

    function draw() {
        geocode(candidates, function (pos) {
            if (!pos || isNaN(pos.lat) || isNaN(pos.lng)) { notFound(); return; }
            wrap.hidden = false; // 지도 크기 계산을 위해 먼저 보이게 한다
            var center = new naver.maps.LatLng(pos.lat, pos.lng);
            var map = new naver.maps.Map(box, { center: center, zoom: 16, zoomControl: true,
                zoomControlOptions: { position: naver.maps.Position.TOP_RIGHT } });
            var marker = new naver.maps.Marker({ position: center, map: map, title: orgName });
            if (orgName) {
                var iw = new naver.maps.InfoWindow({ content: '' });
                iw.setContent((function () {
                    var d = document.createElement('div');
                    d.style.cssText = 'padding:6px 10px;font-size:13px;font-weight:600;white-space:nowrap;';
                    d.textContent = orgName;
                    return d;
                })());
                iw.open(map, marker);
            }
            var link = document.getElementById('bkOrgMapLink');
            if (link) link.href = 'https://map.naver.com/p/search/' + encodeURIComponent(candidates[0]);
        });
    }

    var s = document.createElement('script');
    s.src = 'https://oapi.map.naver.com/openapi/v3/maps.js?ncpKeyId=' +
            encodeURIComponent(clientId) + '&submodules=geocoder';
    s.async = true;
    s.onload = function () {
        // 지도 본체 스크립트가 로드된 뒤에도 Geocoder 서브모듈은 따로 늦게 로드된다.
        // 준비될 때까지 최대 10초 기다린 뒤에도 없으면 포기한다.
        var tries = 0;
        (function waitGeocoder() {
            if (window.naver && naver.maps && naver.maps.Service && naver.maps.Service.geocode) {
                draw();
            } else if (++tries > 100) {
                giveUp();
            } else {
                setTimeout(waitGeocoder, 100);
            }
        })();
    };
    s.onerror = giveUp;
    document.head.appendChild(s);
})();
