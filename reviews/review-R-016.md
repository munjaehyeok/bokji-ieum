# R-016 신청방법 링크 리뷰

`LinkText.toHtml`은 원문을 먼저 HTML 이스케이프하고 http(s)·`www.` 패턴만 링크화한다. 링크 본문은 이스케이프된 문자열이며 새 탭에는 `rel="noopener"`가 붙는다. 현재 seed의 `apply_url`은 확인한 범위에서 http(s) 또는 `www.` 형태다. 다음 두 항목은 보완이 필요하다.

[P1] reviews/argonaut-smoke.md:51
Axis: Spec
Problem: UI 변경의 필수 모바일 브라우저 스모크가 빠졌다.
Evidence: `AGENTS.md`는 변경 화면의 데스크톱·모바일 스크린샷, 콘솔·네트워크 결과, 핵심 흐름을 요구한다. 이번 기록에는 id=34의 데스크톱 캡처와 해당 요청 200만 있고 모바일 화면은 명시적으로 미확인이다.
Suggested direction: 현재 링크화 버전의 상세 화면을 390px에서도 열어 URL이 포함된 신청방법의 줄바꿈·터치 동작을 확인하고, 같은 흐름의 콘솔·네트워크 결과와 스크린샷 경로를 기록한다.
Verification: NEEDS_EVIDENCE

[P2] src/main/java/com/ieum/bokji/util/LinkText.java:43
Axis: Correctness
Problem: `normalizeUrl`이 http(s)가 아닌 모든 입력 앞에 `https://`를 붙여, URL이 아닌 값이나 다른 스킴을 잘못된 링크로 만든다.
Evidence: 관리자 저장 경로는 `applyUrl`을 빈 값만 정리하고 URL 형식을 검사하지 않는다(`AdminService.java:59`). 예를 들어 `/apply`는 `https:///apply`, `mailto:help@example.org`는 `https://mailto:help@example.org`가 된다. 현재 회귀는 유효한 `www.` 사례만 확인한다.
Suggested direction: 보정 대상을 검증된 스킴 없는 웹 주소로 제한하고, 지원하지 않는 값은 링크를 만들지 않도록 처리한다. 유효·무효 입력을 회귀에 추가한다.
Verification: static

요약: 지적 2건 (P0 0, P1 1, P2 1)
판정: REVISE
