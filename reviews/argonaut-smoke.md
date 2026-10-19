# T3/T4 표시 스모크 (검증 DB 792건, 포트 8099, 2026-10-19)
- 최초 렌더·AJAX JSON·상세: ko/en/zh/vi 모두 `사업내용 기준 … · 연락처 등 확인 …` + 안내문 표시, '최신순' 정렬은 기준일 내림차순 (scratchpad scope.py, PASS)
- 브라우저(데스크톱·390px 모바일): 결과 → 정렬 토글(AJAX) 카드 갱신 → 두 날짜 표시, 가로 스크롤 없음, 콘솔 에러 0
- 한계: 스크린샷은 대화에서만 확인(파일 미저장), 상세→신청 흐름은 이번 변경 범위 밖이라 재확인 안 함

## 디자인 정리 스모크 (2026-10-19, 구현 커밋은 `git log -1 -- src/main/webapp/static/css/bokji.css`)
- 변경: bokji.css 재작성(종이색·룰선·4px, 이모지 제거, v=3), result.jsp·detail.jsp·bokji.js 이모지 제거. 판정 로직·SQL 불변.
- 데스크톱(실제 viewport 1440): 랜딩, 결과(80세 1인 기초수급, 482건) — (구 캡처는 삭제, 현행: `reviews/screens/restyle-result-ko-final.jpg`).
- 모바일 390(iframe 방식): 결과·상세·랜딩, 가로 스크롤 없음 — `reviews/screens/restyle-mobile390-result-detail-landing.jpg`.
- 흐름: 랜딩 → 조건 POST → 결과 → 상세 열림. 미확인: 입력 7단계 화면·en/zh/vi 화면의 새 스타일, 관리자 화면(스타일 공유, 확인 안 함). 콘솔·네트워크는 이번에 별도 수집하지 않음.
- 알려진 한계: 상세의 전화 버튼이 데이터 원문(번호 여러 개)을 그대로 보여 길다(디자인 이전부터 있던 데이터 문제).

### 보완 실행 (R-010 P1 대응, 2026-10-20, css v=4 서버 재기동 후)
- 흐름(실제 클릭): /match 1/7 → 2/7 → … → POST /match 200 → /match/result(80세) 604건 표시. 스크린샷: restyle-form-step1.jpg, restyle-result-ko-final.jpg.
- 4개 언어: ko·vi·zh 결과 화면 확인(restyle-result-vi.jpg, restyle-result-zh-bigfont125.jpg). en은 구스타일 캡처를 삭제해 현재 증거가 없고 새 스타일은 vi·zh와 같은 CSS를 공유해 별도 캡처 안 함.
- 글자 크게 125%(루트 20px): 레이아웃 유지, 가로 스크롤 없음(scrollWidth = 1440 = viewport).
- 콘솔: 이 실행에서 메시지 0건(입력→결과 전 구간, zh 화면 포함). 네트워크: 이 실행의 앱 요청(HTML·css v=4·js·POST /match)과 CDN(bootstrap·pretendard) 모두 200, 4xx/5xx 없음.
- 모바일 390(iframe): 결과·상세·랜딩 위 절 참조(v=3). v=4 변경은 색 1개와 예시 접두어 제거뿐이라 재촬영 안 함.
- R-010 P2 반영: 예시 앞 "예)" CSS 제거(언어 고정 문구 제거), .bk-date 색 #525c60 (배경 #F6F3EC 대비 약 6:1).
- 미확인: 입력 단계 3~7의 새 스타일 개별 캡처, 관리자 화면.

## 아이콘·일러스트 추가 스모크 (2026-10-20, css v=6)
- 변경: static/img/icons.svg(직접 그린 SVG 스프라이트: 로고, 분야 10종, 랜딩 일러스트), top.jspf 로고, result.jsp 분야 필터, index.jsp 히어로. 문화·여가 아이콘은 음표로 교체(점선 티켓 폐기). 장식용이라 aria-hidden, 의미는 글자가 전달. SQL·로직 불변.
- 확인: 한국어 랜딩(데스크톱 1440), 결과 화면 필터 줄(icons-filter-ko.png), icons.svg 200 image/svg+xml, POST /match → 결과 정상.
- 미확인: 모바일 390·글자 125%·en/zh/vi에서의 새 아이콘 배치, 콘솔·네트워크 재수집(이번엔 하지 않음).

### 보완 실행 (R-012 P1 대응, css v=6)
- 모바일 390(iframe) + 글자 125%(루트 폰트 20px): 랜딩·결과 2개 화면 — `reviews/screens/icons-mobile390-bigfont125.jpg`. 세 프레임 모두 innerWidth/scrollWidth/clientWidth = 390/390/390(가로 스크롤 없음). 분야 필터 칩은 줄바꿈되며 아이콘·글자 정렬 유지. 세 번째 프레임은 `?lang=vi`로 열었으나 화면은 한국어로 표시(세션 언어가 이미 ko로 돌아가 있었음) — 이번 증거에 vi 새 아이콘 배치는 없다.
- 콘솔: 이 실행 구간 메시지 0건. 네트워크(127.0.0.1): GET/POST 모두 200(또는 304), icons.svg 200, css v=6·js 200. 4xx/5xx 없음. 핵심 흐름: 랜딩 → POST /match 200 → 결과 표시.
- 미확인: en/zh/vi에서의 새 아이콘 배치(문구가 길어 줄바꿈이 달라질 수 있음), 관리자 화면.

## 상세 판정표: 내 조건 vs 공고 조건 (2026-10-20, css v=7)
- 변경: JudgeCompare.java(신규, 표시 전용 — 판정은 SQL 태그 그대로), ResourceController(model "compare"), detail.jsp 판정표를 항목/내 조건/공고 조건/판정 4열로, messages 4개 언어 compare.* 키, bokji.css(좁은 폭에서 항목별 쌓기). SQL·매칭 로직 불변.
- 회귀: docs/검증/compare-regression.py 6/6 PASS(일치·불일치·확인필요·모름 입력·en), match-regression 전부 PASS(792/23), age-hint-regression 전부 PASS.
- 화면: 데스크톱 reviews/screens/compare-detail-desktop.jpg, 모바일 390(iframe, scrollWidth 390=390) compare-detail-mobile390.jpg. 콘솔 메시지 0건(모바일 구간).
- 미확인: en/zh/vi 상세 화면 캡처(문구는 회귀로 en만 검사), 큰 글자 125%, 가구원 여러 명일 때(상세는 세션의 본인 조건만 사용 — 기존 동작), 네트워크 4xx/5xx 별도 수집.
- 알려진 표시 한계: '소득' 일치 행의 공고 조건은 DB의 income_rank를 문구로 옮긴 것(예: rank 3 = 중위소득 100% 이하)이며 원문 기준은 아래 '지원 기준(원문)'이 정본.

### 보완 실행 (R-014 P1 3건 대응, css v=8)
- P1-1: 공고 조건의 소득 문구를 "분류 구간: … (원문 기준은 아래 '지원 기준(원문)' 참고)"로 바꿔 rank를 공고 상한으로 단정하지 않음. id=269(원문 180%)는 "중위소득 150% 이하 구간"으로 분류됨과 원문 안내를 함께 표시 — `reviews/screens/compare-detail-269-tier.jpg`. id=95(80%)도 같은 처리.
- P1-2: rank NULL + income_uncertain='Y'(23건) 자원은 SQL이 소득 태그를 만들지 않으므로 JudgeCompare가 표시 전용 '소득' 행(확인 필요, 원문 확인 안내)을 더함. 판정 재계산은 아님(SQL 불변).
- 회귀: compare-regression.py 9/9 PASS (269·95·182 사례 추가), match-regression PASS.
- P1-3 네트워크: 이 실행(입력 POST → 상세 /resources/269, css v=8)의 127.0.0.1 요청 모두 200(결과 페이지 요청 1건은 수집 시점 pending 표시), 4xx/5xx 없음. 콘솔 0건.
- 미확인: en/zh/vi 상세 캡처, 글자 125%.

## 신청 방법 링크화 (2026-10-20)
- 원인 확인: 원래 plain text 출력(c:out)이었음. 신청방법 본문에 URL이 든 행 89건, apply_url 버튼은 136건뿐이고, apply_url 중 스킴 없는 값("www.bokjiro.go.kr", 예 id=94)은 상대경로 링크가 되는 결함도 있었음.
- 변경: util/LinkText.java(전체 HTML 이스케이프 후 http/https·www 주소만 `<a target=_blank rel=noopener>`로, "www. bokjiro. go. kr"처럼 점 뒤 공백도 한 주소로 정규화, 문장 끝 구두점 제외), ResourceController(applyMethodHtml, apply_url 스킴 없으면 https:// 보정), detail.jsp 신청방법 출력. SQL·판정 불변.
- 회귀: docs/검증/link-regression.py 3/3 PASS, compare-regression 9/9 유지.
- 화면: reviews/screens/apply-link-34.jpg (id=34 '복지로(www. bokjiro. go. kr)'가 링크로 표시). 콘솔 0건, 해당 요청 200.
- 미확인: 모바일·en/zh/vi 화면(링크 마크업은 언어 공통), 실제 외부 사이트 클릭 이동, 관리자 입력 폼에서 스킴 없는 URL 저장 방지(표시 단계에서만 보정).
