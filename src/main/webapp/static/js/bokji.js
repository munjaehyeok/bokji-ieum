/* 복지이음 공통 JS 1파일 — 요소 존재 여부로 페이지별 기능 분기 */
(function () {
    'use strict';

    /* ---------- 공통: [글자 크게] 토글 (100 → 112.5 → 125% 순환, sessionStorage 유지) ---------- */
    var fontBtn = document.getElementById('bkFontToggle');
    if (fontBtn) {
        var SIZES = ['', '112.5%', '125%'];
        fontBtn.addEventListener('click', function () {
            var step = 0;
            try { step = parseInt(sessionStorage.getItem('bkFontStep') || '0', 10) || 0; } catch (e) {}
            step = (step + 1) % 3;
            document.documentElement.style.fontSize = SIZES[step];
            fontBtn.setAttribute('aria-pressed', step > 0 ? 'true' : 'false');
            try { sessionStorage.setItem('bkFontStep', String(step)); } catch (e) {}
        });
    }

    /* ---------- 공통: '해당 없음'(NONE) 상호 배타 체크박스 ---------- */
    function bindNoneGroup(group) {
        group.addEventListener('change', function (e) {
            var t = e.target;
            if (t.type !== 'checkbox') return;
            var boxes = group.querySelectorAll('input[type=checkbox]');
            boxes.forEach(function (b) {
                if (t.checked && b !== t && ((t.value === 'NONE') !== (b.value === 'NONE'))) {
                    b.checked = false;
                }
            });
        });
    }
    document.querySelectorAll('[data-none-group]').forEach(bindNoneGroup);

    /* ---------- 조건 입력: 7스텝 전환 ---------- */
    var form = document.getElementById('bkMatchForm');
    if (form) {
        var steps = form.querySelectorAll('.bk-step');
        var dots = document.querySelectorAll('#bkDots .bk-dot');
        var stepText = document.getElementById('bkStepText');
        var stepLive = document.getElementById('bkStepLive');
        var prevBtn = document.getElementById('bkPrev');
        var nextBtn = document.getElementById('bkNext');
        var skipBtn = document.getElementById('bkSkip');
        var submitBtn = document.getElementById('bkSubmit');
        var cur = 1;

        function show(n, focusHeading) {
            cur = Math.min(Math.max(n, 1), 7);
            steps.forEach(function (s) {
                s.classList.toggle('active', parseInt(s.dataset.step, 10) === cur);
            });
            dots.forEach(function (d, i) { d.classList.toggle('done', i < cur); });
            var txt = cur + ' / 7';
            stepText.textContent = txt;
            stepLive.textContent = txt;
            prevBtn.style.visibility = cur === 1 ? 'hidden' : 'visible';
            nextBtn.hidden = cur === 7;
            submitBtn.hidden = cur !== 7;
            if (focusHeading) {
                var h = form.querySelector('.bk-step.active h2');
                if (h) h.focus();
            }
        }

        function clearStep(n) {
            var step = form.querySelector('.bk-step[data-step="' + n + '"]');
            step.querySelectorAll('input[type=checkbox]').forEach(function (b) { b.checked = false; });
            step.querySelectorAll('input[type=number], input[type=text]').forEach(function (i) { i.value = ''; });
            step.querySelectorAll('select').forEach(function (s) { s.selectedIndex = 0; });
            if (n === 4) { // 소득: 모름(0)
                var r0 = step.querySelector('input[name=incomeRank][value="0"]');
                if (r0) r0.checked = true;
            }
            if (n === 5) { // 장애: 모름(U)
                var rU = step.querySelector('input[name=disability][value="U"]');
                if (rU) rU.checked = true;
            }
            if (n === 6) { // 국적: 기본 내국인(K)
                var rK = step.querySelector('input[name=nationality][value="K"]');
                if (rK) rK.checked = true;
            }
        }

        prevBtn.addEventListener('click', function () { show(cur - 1, true); });
        nextBtn.addEventListener('click', function () { show(cur + 1, true); });
        skipBtn.addEventListener('click', function () {
            clearStep(cur);
            if (cur < 7) show(cur + 1, true);
        });
        // Enter로 중간 스텝에서 제출되는 것 방지 (textarea 없음)
        form.addEventListener('keydown', function (e) {
            if (e.key === 'Enter' && cur < 7 && e.target.tagName !== 'BUTTON') {
                e.preventDefault();
                show(cur + 1, true);
            }
        });

        /* 가구원 동적 추가 */
        var addBtn = document.getElementById('bkAddMember');
        var membersBox = document.getElementById('bkMembers');
        var tpl = document.getElementById('bkMemberTpl');
        var nextIdx = parseInt(addBtn.dataset.nextIndex, 10) || 0;

        function renumber() {
            membersBox.querySelectorAll('[data-member-no]').forEach(function (el, i) {
                el.textContent = i + 1;
            });
        }
        addBtn.addEventListener('click', function () {
            var html = tpl.innerHTML.replace(/IDX/g, String(nextIdx));
            var wrap = document.createElement('div');
            wrap.innerHTML = html;
            var card = wrap.firstElementChild;
            membersBox.appendChild(card);
            bindNoneGroup(card.querySelector('[data-none-group]'));
            nextIdx++;
            renumber();
            card.querySelector('input').focus();
        });
        membersBox.addEventListener('click', function (e) {
            var btn = e.target.closest('[data-remove-member]');
            if (btn) {
                btn.closest('.bk-member-card').remove();
                renumber();
            }
        });

        /* 검증 실패 리다이렉트: 해당 스텝으로 이동 */
        var err = document.getElementById('bkFormError');
        if (err) {
            show(err.dataset.error === 'memberBirthYear' ? 7 : 1, false);
        } else {
            show(1, false);
        }
    }

    /* ---------- 결과: 가구원 탭 + 분야 필터 (AJAX) ---------- */
    if (window.BK_RESULT) {
        var R = window.BK_RESULT;
        var curMember = 0;
        var curCat = R.category || '';
        var countEl = document.getElementById('bkCount');

        function esc(s) {
            return String(s == null ? '' : s).replace(/[&<>"']/g, function (c) {
                return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c];
            });
        }
        function setCount(n) {
            countEl.textContent = R.msg.count.replace('@N@', n);
        }
        function activePane() {
            return document.getElementById('bkPane' + curMember);
        }
        function cardHtml(row) {
            var h = '<a class="bk-card" href="' + R.ctx + '/resources/' + row.resourceId + '">';
            h += '<div class="d-flex justify-content-between align-items-start gap-2">';
            h += '<h3>' + esc(row.displayName) + '</h3>';
            h += '<span class="bk-badge-provider">' + esc(R.msg.provider[row.providerType] || row.providerType) + '</span></div>';
            h += '<p class="org">' + esc(row.orgName) + (row.deptName ? ' ' + esc(row.deptName) : '') + '</p>';
            h += '<p class="summary1">' + esc(row.summaryTr || row.supportContent) + '</p>';
            h += '<div>';
            if (row.matchedLabels && row.matchedLabels.length) {
                h += '<span class="bk-tag bk-tag-match">✅ ' + esc(R.msg.matched) + ': '
                    + row.matchedLabels.map(esc).join(' · ') + '</span> ';
            }
            if (row.needCheckLabels && row.needCheckLabels.length) {
                h += '<span class="bk-tag bk-tag-check">⚠️ ' + esc(R.msg.needCheck) + ': '
                    + row.needCheckLabels.map(esc).join(' · ') + '</span>';
            }
            h += '</div><div class="bk-date mt-1">';
            if (row.dataBaseDate) h += esc(R.msg.baseDate) + ' ' + esc(row.dataBaseDate) + ' ';
            if (row.oldData) h += '<span class="bk-badge-old">⚠️ ' + esc(R.msg.oldData) + '</span>';
            h += '</div></a>';
            return h;
        }
        function refresh() {
            var pane = activePane();
            pane.innerHTML = '<p class="text-secondary py-4">' + esc(R.msg.loading) + '</p>';
            fetch(R.ctx + '/match/result/list?member=' + curMember
                    + (curCat ? '&category=' + encodeURIComponent(curCat) : ''))
                .then(function (res) { if (!res.ok) throw new Error(); return res.json(); })
                .then(function (rows) {
                    pane.innerHTML = rows.length
                        ? rows.map(cardHtml).join('')
                        : '<p class="text-secondary py-4">' + esc(R.msg.empty) + '</p>';
                    setCount(rows.length);
                })
                .catch(function () {
                    pane.innerHTML = '<p class="text-danger py-4">' + esc(R.msg.fail) + '</p>';
                });
        }

        setCount(activePane() ? activePane().dataset.count : 0);

        var tabs = document.getElementById('bkMemberTabs');
        if (tabs) {
            tabs.addEventListener('click', function (e) {
                var btn = e.target.closest('[data-member]');
                if (!btn) return;
                tabs.querySelectorAll('.nav-link').forEach(function (b) {
                    b.classList.toggle('active', b === btn);
                    b.setAttribute('aria-selected', b === btn ? 'true' : 'false');
                });
                document.querySelectorAll('.bk-pane').forEach(function (p) {
                    p.hidden = p.dataset.member !== btn.dataset.member;
                });
                curMember = parseInt(btn.dataset.member, 10);
                refresh();
            });
        }
        var filter = document.getElementById('bkCatFilter');
        filter.addEventListener('click', function (e) {
            var btn = e.target.closest('[data-cat]');
            if (!btn) return;
            filter.querySelectorAll('button').forEach(function (b) {
                b.classList.toggle('active', b === btn);
            });
            curCat = btn.dataset.cat;
            refresh();
        });
    }

    /* ---------- 상세: 전화·신청URL·인쇄 비콘(A) + 제보 모달 ---------- */
    if (window.BK_DETAIL) {
        var D = window.BK_DETAIL;
        function beaconA() {
            try {
                var body = new URLSearchParams();
                body.append('event', 'A');
                body.append('resourceId', D.resourceId);
                navigator.sendBeacon(D.ctx + '/events', body);
            } catch (e) { /* 비콘 실패 무시 */ }
        }
        document.querySelectorAll('[data-beacon="A"]').forEach(function (el) {
            el.addEventListener('click', beaconA);
        });
        var printBtn = document.getElementById('bkPrint');
        if (printBtn) {
            printBtn.addEventListener('click', function () {
                beaconA();
                window.print();
            });
        }
        var reportForm = document.getElementById('bkReportForm');
        if (reportForm) {
            reportForm.addEventListener('submit', function (e) {
                e.preventDefault();
                var msgEl = document.getElementById('bkReportMsg');
                var sendBtn = document.getElementById('bkReportSend');
                var content = document.getElementById('bkReportContent').value.trim();
                if (!content) return;
                sendBtn.disabled = true;
                var body = new URLSearchParams();
                body.append('resourceId', D.resourceId);
                body.append('content', content);
                fetch(D.ctx + '/reports', { method: 'POST', body: body })
                    .then(function (res) {
                        if (res.ok) {
                            msgEl.className = 'mt-2 mb-0 text-success fw-bold';
                            msgEl.textContent = D.msg.ok;
                            reportForm.reset();
                        } else {
                            msgEl.className = 'mt-2 mb-0 text-danger';
                            msgEl.textContent = res.status === 429 ? D.msg.limit : D.msg.fail;
                        }
                    })
                    .catch(function () {
                        msgEl.className = 'mt-2 mb-0 text-danger';
                        msgEl.textContent = D.msg.fail;
                    })
                    .finally(function () { sendBtn.disabled = false; });
            });
        }
    }
})();
