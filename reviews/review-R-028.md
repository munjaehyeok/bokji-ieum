# R-028 디자인 이식 검증·리뷰

- 판정: **REVISE**
- 대상: `http://127.0.0.1:8099` (검증 서버, Chrome 기존 탭)
- 브랜치: `munjaehyeok/reopen-session-5efbcbdd`
- 코드 수정: 없음. 관찰된 UI 결함을 특정하지 못했고 시각/접근성 점검이 완결되지 않아 CSS·JSP·JS를 변경하지 않았다.
- 병합·푸시·배포: 하지 않음.

## 확인한 흐름

- 홈 데스크톱(1440 CSS px) 및 모바일(390 CSS px) 캡처가 이미 생성되어 있다.
- `/match`에서 건너뛰기를 사용해 1~7단계를 진행했고 `/match/result`에 도달했다. 결과 페이지는 `조건에 해당될 수 있는 복지 777개`와 9개 카테고리 필터, 추천순/사업내용 최신순 정렬을 표시했다.
- 390px에서 매칭 1단계 화면을 캡처했다.
- 상세 `/resources/181`, `/resources`의 필터·찜·페이지 이동, 데스크톱 결과/상세 및 언어별 표시를 이번 실행에서 확인하지 못했다.

## 캡처

- `reviews/screens/design-bokjiro-home-desktop-20261024-R028.png` (2880×2084 이미지, 1440 CSS px)
- `reviews/screens/design-bokjiro-home-mobile-20261024-R028.png` (780×1564 이미지, 390 CSS px)
- `reviews/screens/design-bokjiro-match-step1-mobile-20261024-R028.png` (780×1564 이미지, 390 CSS px)
- 결과/상세/둘러보기 화면 캡처는 없음.

## 회귀·빌드 결과

| 게이트 | 결과 |
|---|---|
| `resource-search-regression.py http://127.0.0.1:8099` | **FAIL 1건**: 인기순 표본 부족 시 이름순 대체 및 안내 검증 실패. 나머지 검사 통과. |
| `match-regression.py http://127.0.0.1:8099 792 15` | PASS |
| `age-hint-regression.py http://127.0.0.1:8099` | PASS |
| `compare-regression.py` | PASS |
| `link-regression.py` | PASS |
| `./mvnw -q test` | PASS (관리자 초기 비밀번호 미설정 관련 WARN 로그만 출력) |
| `./mvnw -q package -DskipTests` | PASS |

## 남은 검증

R-028 요구 중 결과 화면 시각 품질과 데스크톱 레이아웃, `/resources/181`, 목록 필터·찜·페이지네이션, 4개 언어, WCAG AA 대비 실측, 키보드 순서·포커스 링, `prefers-reduced-motion`, 인쇄 미리보기, 글자 크게 토글 후 줄바꿈, 브라우저 콘솔·네트워크 에러 확인 및 원본과의 상세 나란히 비교를 완료하지 못했다. 따라서 시각·접근성 승인 근거가 부족하다.

## 다음 조치

1. 검색 회귀의 인기순 실패 원인을 확인하고, 필요하면 허용된 CSS/JSP/JS 범위에서만 수정한다(기능·SQL·URL 변경 금지).
2. 누락된 브라우저 경로와 측정 항목을 완료하고 해당 데스크톱·모바일 캡처를 추가한다.
3. 모든 필수 게이트 통과 후 재리뷰한다.
