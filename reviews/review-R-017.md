# R-017 재검토

R-016의 P2는 해소됐다. `LinkText.normalizeUrl`은 http(s) 주소를 유지하고 스킴 없는 도메인 형태에만 `https://`를 붙이며, 상대경로·`mailto:`·`javascript:`·문장은 `null`로 거부한다. 상세의 기존 조건문은 `null`일 때 신청 URL 버튼을 숨긴다. `LinkTextCheck.java`의 유효·무효 URL 및 이스케이프 사례 12건이 통과한 것으로 기록됐다.

R-016의 P1도 해소됐다. `reviews/argonaut-smoke.md:53-56`과 `reviews/screens/apply-link-34-mobile390.jpg`에 390px 상세 화면, 링크 줄바꿈과 목적지, 가로 스크롤 없음, 콘솔 0건 및 관찰된 앱 요청의 4xx/5xx 없음이 기록됐다. 인라인 본문 링크의 터치 영역 한계는 스모크에 명시돼 있다.

요약: 지적 없음
판정: APPROVE
