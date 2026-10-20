# R-020 모션 리뷰

[P1] reviews/argonaut-smoke.md:70
Axis: Correctness
Problem: UI 변경에 필수인 브라우저 스모크 근거가 아직 완결되지 않았다.
Evidence: `AGENTS.md`의 web-app 게이트는 변경 화면의 데스크톱·모바일 스크린샷, 콘솔 에러 0건, 네트워크 4xx/5xx 없음, 핵심 사용자 흐름 1개 완료를 요구한다. 이번 모션 절은 결과 화면 최종 상태 캡처 1장과 390px 폭·문서 응답 200, 콘솔 0건만 기록했다. 랜딩·입력·상세의 변경 후 캡처 경로, 모바일 캡처 경로, 전체 앱 요청의 4xx/5xx 점검 및 핵심 흐름 완료 기록이 없다. `prefers-reduced-motion: reduce`도 실제 브라우저에서 확인하지 못했다고 명시되어 있다. 이전 정적 캡처는 이번 모션 변경 후 화면의 근거가 될 수 없다.
Suggested direction: 변경된 랜딩·입력·결과·상세 화면을 데스크톱과 모바일에서 캡처하고, 시작→입력→결과→상세 흐름과 콘솔·네트워크 상태를 기록한다. 움직임 줄이기 모드에서 애니메이션이 꺼지는지도 브라우저 계산 스타일로 확인한다.
Verification: NEEDS_EVIDENCE

정적 검토에서는 모션이 `prefers-reduced-motion: no-preference` 안에 한정되고, 카드 13번째 자식부터 애니메이션을 끄며, 등장 효과가 opacity·transform만 사용해 레이아웃 크기를 바꾸지 않는 것을 확인했다. 판정표 모바일 쌓기 규칙과 `aria-live` 건수 표시에 직접적인 충돌은 보이지 않는다.

요약: 지적 1건 (P0 0, P1 1, P2 0)
판정: REVISE
