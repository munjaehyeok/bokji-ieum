# R-010 디자인 정리 리뷰

결과·상세의 일치/확인필요 태그는 문구와 세로선으로 구분된다. R-007의 결과 그룹·AGE_HINT 표시 경로와 R-009의 소득 규칙·집계 파일은 이번 변경에서 수정되지 않았다. 기존 스모크의 결과→정렬 흐름만으로는 새 스타일의 전체 게이트를 대신할 수 없다.

[P1] reviews/argonaut-smoke.md:10
Axis: Spec
Problem: UI 변경의 필수 브라우저 스모크 게이트가 완료되지 않았다.
Evidence: `AGENTS.md`는 변경 화면의 데스크톱·모바일 스크린샷, 콘솔 에러 0건, 네트워크 4xx/5xx 없음, 핵심 흐름 확인을 요구한다. 새 디자인 스모크는 콘솔·네트워크를 별도로 수집하지 않았다고 명시하고, 입력 7단계와 en/zh/vi 새 스타일도 미확인으로 남겼다.
Suggested direction: 변경된 입력·결과·상세 화면과 4개 언어에서 큰 글자·모바일 배치를 확인하고, 같은 실행의 콘솔·네트워크 결과와 핵심 흐름을 스모크 기록에 남긴다.
Verification: NEEDS_EVIDENCE

[P2] src/main/webapp/static/css/bokji.css:60
Axis: Correctness
Problem: 랜딩 예시 앞의 `예)`가 CSS에 한국어로 고정돼 en/zh/vi 화면에도 그대로 표시된다.
Evidence: `index.jsp:20-24`는 예시 본문에 `spring:message`를 쓰지만, `bk-chip::before`의 문구는 언어별 메시지를 거치지 않는다.
Suggested direction: 예시 접두어를 언어별 메시지로 제공하거나 언어 중립적인 표기로 바꾼다.
Verification: static

[P2] src/main/webapp/static/css/bokji.css:109
Axis: Correctness
Problem: 결과의 기준일·확인 범위 안내에 쓰이는 작은 본문 글자 대비가 일반 텍스트 기준에 미달한다.
Evidence: `.bk-date`의 `#6b7377`과 배경 `#F6F3EC` 대비는 약 4.36:1로, 4.5:1보다 낮다. 같은 클래스가 `result.jsp:105`의 날짜와 `result.jsp:60`의 안내에 적용된다.
Suggested direction: 날짜·안내 글자색을 조금 더 어둡게 해 4.5:1 이상을 확보하고 큰 글자 모드에서도 확인한다.
Verification: static

요약: 지적 3건 (P0 0, P1 1, P2 2)
판정: REVISE
