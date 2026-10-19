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
