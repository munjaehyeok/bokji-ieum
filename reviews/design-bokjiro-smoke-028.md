# T-028 브라우저 스모크 기록

## 결과

부분 완료 — 대체 포트의 서버와 HTTP/회귀 검증은 통과했다. 다만 이번 변경의 브라우저 화면 스모크(데스크톱·390px), 콘솔/네트워크 확인 및 캡처는 수행하지 못했다. 원본 복지로와 변경 후 로컬 UI를 브라우저에서 나란히 비교하지 않았다.

## 시도 및 근거

- 요청서의 검증 서버 `http://127.0.0.1:8099`는 JSP/CSS 재빌드 반영을 위해 재기동할 때 Cargo가 RMI 포트 `8299` 충돌을 보고했다. 추가 RMI 포트도 기존 프로세스와 충돌했다.
- 저장소의 검증 POM은 수정하지 않고, 생성물 디렉터리에 임시 POM을 두어 HTTP/RMI/AJP를 `28099/28199/28209`로 변경했다. 검증 WAR를 배포한 Cargo Tomcat이 `28099`에서 정상 시작됐고 `GET /resources`가 HTTP 200을 반환했다.
- 대체 포트에서 `resource-search-regression.py`, `match-regression.py`, `age-hint-regression.py`, `compare-regression.py`, `link-regression.py`를 실행해 모두 통과했다.
- CUA surface inventory에 사용 가능한 브라우저 앱/탭이 없었고, 새 in-app browser 생성도 사용할 수 없었다. 원본 직접 관찰은 기존 이미지 `reviews/screens/competitor-bokjiro-list-20261023.jpg` 수준만 가능했다.
- 따라서 브라우저 콘솔 0건, 네트워크 4xx/5xx 0건, 모바일 가로 넘침 없음, 홈→입력→결과→상세 및 둘러보기→필터→찜→상세 성공은 확인하지 않았다. 임시 검증 서버는 이 기록 시점에 `http://127.0.0.1:28099`에서 실행 중이다.

## 수행된 비브라우저 검증

- `./mvnw -q package -DskipTests`: 통과.
- `./mvnw -q test`: 통과.
- `git diff --check`: 통과.
- 지정 포트의 첫 회귀 시도는 sandbox의 localhost 제한 때문에 실패했으나, 대체 포트에서 위 다섯 회귀 스크립트를 다시 실행해 모두 통과.

## 다음 검증에 필요한 조건

검증 Tomcat의 8299 RMI 포트를 점유한 기존 프로세스 상태를 정리한 뒤 CSS/JSP 변경이 반영된 검증 서버를 띄우고, 데스크톱과 390px 브라우저에서 지정 흐름·콘솔·네트워크를 확인해야 한다. 접근 가능한 브라우저 세션에서 캡처를 얻은 경우에만 `reviews/screens/design-bokjiro-*.png`를 추가한다.

## 2026-10-24 Claude 보완 검증(Codex 세션 종료 후, 검증 서버 8099 재빌드)
- Codex 구현물(CSS 토큰·헤더 검색·위/아래 버튼·전 화면 스타일) 그대로 빌드·기동 성공. 캡처: `reviews/screens/design-bokjiro-home-desktop-20261024.jpg`, `design-bokjiro-home-mobile-20261024.jpg`, `design-bokjiro-explore-desktop-20261024.jpg`.
- 발견·수정 2건: ① 영어 화면(`/resources?lang=en&hh=DIS`)에서 필터 라벨이 390px 2열 그리드를 넘쳐 scrollWidth 408 → `minmax(0,1fr)`·`overflow-wrap`으로 수정 후 390. ② 홈 히어로 제목 데스크톱에서 "안/에" 한 글자 줄바꿈 → `word-break: keep-all; text-wrap: balance`.
- 390px 가로 넘침 재측정(iframe, scrollWidth): `/`, `/match`, `/resources`, `/resources/181`, `?lang=en&hh=DIS`, `?lang=vi&cat=EDU`, `?lang=zh` 전부 390.
- 콘솔 에러 0. 헤더 검색(`q`) → `/resources?q=…` 동작(80건), 스크롤 시 위/아래 버튼 표시.
- 회귀(재빌드 후): resource-search ALL PASS, match 20/20, age-hint FAIL 0, compare 10, link 4.
- 미검증: 결과(`/match/result`) 화면 시각 비교, 입력 7단계 완주 캡처, 대비 AA 수치 측정, 키보드·스크린리더, 원본 대비 픽셀 비교. Codex 리뷰는 세션 종료로 받지 못함(R-028 미실시).
