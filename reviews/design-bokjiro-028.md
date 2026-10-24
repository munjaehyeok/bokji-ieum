# T-028 복지로 디자인 요소 이식 결과

## 범위

복지로의 공개 화면에서 확인된 시각 언어를 참고해 복지이음의 홈, 7단계 입력, 결과, 상세, 자원 둘러보기 화면에 공통 스타일을 적용했다. 이번 변경은 프런트엔드 표현만 다루며 SQL, 컨트롤러, 검색 조건, 기존 URL 계약은 변경하지 않았다. 복지로 로고·캐릭터·사진·아이콘 파일, 공식 정부 고지·마크, 복지로 문구는 가져오지 않았다. 로고 및 검색 아이콘은 기존 복지이음 SVG 스프라이트/자체 CSS 도형을 사용했고 서비스명·시범 서비스 고지를 유지했다.

## 변경 파일

- `src/main/webapp/WEB-INF/views/common/top.jspf`: Noto Sans KR/Roboto, 건너뛰기 링크, 검색창, 언어·글자 크기 도구, 주요 메뉴, main 랜드마크 식별자 및 접근성 속성.
- `src/main/webapp/WEB-INF/views/common/foot.jspf`: 위/아래 이동 컨트롤 추가, JS 캐시 버전 갱신.
- `src/main/webapp/static/css/bokji.css`: 전역 토큰과 공통 헤더·검색·버튼·입력·탭·카드·히어로·상세·탐색 UI, 반응형·포커스·모션·인쇄 스타일.
- `src/main/webapp/static/js/bokji.js`: 스크롤 위치에 따른 위/아래 버튼 노출 및 동작, reduced-motion 설정 존중.
- `src/main/resources/messages/messages_{ko,en,zh,vi}.properties`: 새 공통 내비게이션·검색·접근성·스크롤 컨트롤 문자열을 네 언어에 추가.

## 주요 CSS 토큰

| 토큰 | 값 | 용도 |
|---|---|---|
| `--bk-primary` | `#3E61D7` | 주요 링크·버튼·활성 표시 |
| `--bk-primary-dark` | `#2D4DBB` | hover/강조 상태 |
| `--bk-primary-soft` | `#EBEFFB` | 옅은 파랑 강조 배경 |
| `--bk-primary-pale` / `--bk-bg` | `#F6F7FB` | 페이지 배경 |
| `--bk-text` / `--bk-muted` | `#222222` / `#4F4F4F` | 본문·보조 글자 |
| `--bk-line` / `--bk-surface` | `#DFDFDF` / `#FFFFFF` | 구분선·카드 표면 |
| `--bk-radius` | `14px` | 공통 라운드 기준 |
| `--bk-shadow` | `0 8px 28px rgba(35, 54, 112, .08)` | 부드러운 표면 그림자 |

## 구현 판단 및 차이

- 새 헤더 검색 폼은 기존 `/resources?q=...` 계약을 사용하는 GET 폼이다. 언어 전환, 홈·매칭·둘러보기·처음부터 링크도 기존 경로를 사용한다.
- 헤더 검색창은 48px 높이의 둥근 입력과 CSS로 만든 원형 검색 아이콘을 사용한다. 별도 아이콘 파일을 복제하지 않았다.
- 공통 라운드·파란색·밝은 표면·활성 밑줄·hover/focus 전환을 화면 전반에 적용하고, 기존 기능 동작은 유지했다. 상단/하단 플로팅 컨트롤은 작은 화면에서도 페이지 가로폭을 늘리지 않도록 고정 배치했다.
- 복지로의 실제 세부 모달·툴팁·탭 동작은 이번 브라우저 관찰 환경에서 확인할 수 없어 새로 흉내 내지 않았다. 기존 서비스의 정보구조와 복지이음 고유 문구를 유지한 점도 원본과의 의도된 차이다.
- 브라우저 화면에서의 최종 시각 비교, 390px 가로 넘침 및 대비의 실측은 로컬 서버 기동/브라우저 접근 문제로 완료하지 못했다. 상세 상황은 `reviews/design-bokjiro-smoke-028.md`에 기록했다. 따라서 픽셀 단위 일치나 런타임 접근성 통과를 주장하지 않는다.

## 검증

- `./mvnw -q package -DskipTests`: 통과.
- `./mvnw -q test`: 통과(테스트 출력은 초기 관리자 계정 초기화 관련 정상 로그).
- `git diff --check`: 통과.
- 최초 지정 포트의 서버 재기동은 RMI 포트 충돌로 막혔으나, 임시 POM을 생성물 디렉터리에 두고 HTTP/RMI/AJP를 각각 `28099/28199/28209`로 옮겨 서버 기동에 성공했다. 임시 POM은 저장소 추적 파일이 아니다.
- `http://127.0.0.1:28099/resources`: HTTP 200.
- `resource-search-regression.py`, `match-regression.py`, `age-hint-regression.py`, `compare-regression.py`, `link-regression.py`: 대체 포트를 사용해 모두 통과(자원 검색 결과 `ALL PASS`).
- 브라우저 데스크톱/모바일 스모크 및 캡처: 실행 불가. 대체 포트 서버는 동작하지만 CUA 세션에서 사용할 브라우저가 제공되지 않았다. 화면 캡처를 생성한 것처럼 기록하지 않았다.

## 작업 경계

main 병합, push, 배포를 하지 않았다. 기존에 있던 미추적 `pom-verify.xml`은 수정하거나 삭제하지 않았다.
