# T3/T4 표시 스모크 (검증 DB 792건, 포트 8099, 2026-10-19)
- 최초 렌더·AJAX JSON·상세: ko/en/zh/vi 모두 `사업내용 기준 … · 연락처 등 확인 …` + 안내문 표시, '최신순' 정렬은 기준일 내림차순 (scratchpad scope.py, PASS)
- 브라우저(데스크톱·390px 모바일): 결과 → 정렬 토글(AJAX) 카드 갱신 → 두 날짜 표시, 가로 스크롤 없음, 콘솔 에러 0
- 한계: 스크린샷은 대화에서만 확인(파일 미저장), 상세→신청 흐름은 이번 변경 범위 밖이라 재확인 안 함

## 디자인 정리 스모크 (2026-10-19, 구현 커밋은 `git log -1 -- src/main/webapp/static/css/bokji.css`)
- 변경: bokji.css 재작성(종이색·룰선·4px, 이모지 제거, v=3), result.jsp·detail.jsp·bokji.js 이모지 제거. 판정 로직·SQL 불변.
- 데스크톱(실제 viewport 1440): 랜딩, 결과(80세 1인 기초수급, 482건) — `reviews/screens/result-ko-restyle.jpg`.
- 모바일 390(iframe 방식): 결과·상세·랜딩, 가로 스크롤 없음 — `reviews/screens/restyle-mobile390-result-detail-landing.jpg`.
- 흐름: 랜딩 → 조건 POST → 결과 → 상세 열림. 미확인: 입력 7단계 화면·en/zh/vi 화면의 새 스타일, 관리자 화면(스타일 공유, 확인 안 함). 콘솔·네트워크는 이번에 별도 수집하지 않음.
- 알려진 한계: 상세의 전화 버튼이 데이터 원문(번호 여러 개)을 그대로 보여 길다(디자인 이전부터 있던 데이터 문제).
