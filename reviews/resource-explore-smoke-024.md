# 탐색 모드(/resources) 스모크 (검증 DB 792건, 포트 8099, 2026-10-23)

구현: `GET /resources`(ResourceBrowseController·ResourceSearch·resource-mapper `browse`), list.jsp, resource-favorites.js, 상세 한눈에 보기·목록으로 링크, nav '둘러보기', 홈 링크. 계약 `docs/설계/07-탐색모드.md`.

## 자동 검증
- `python3 -I docs/검증/resource-search-regression.py http://127.0.0.1:8099` → ALL PASS (기대값은 계약에서 DB로 따로 계산: 기본 792·쪽 순회 중복/누락 없음, 주제 OR/AND, 생애주기 6구간 strict/기본, 나이 경계 0/5/6/12/13/18/19/39/40/64/65(±1 없음), 가구 9코드·FOR≠MCUL·LOW/incx, 동, 검색(AND·제외 우선·% _ 리터럴·위험 입력), 온라인, 최신순, 인기순 표본부족 대체, 잘못된 입력·쪽 초과, ids 검증·50개 제한, 비활성 제외(복원), 쪽/정렬 링크 필터 보존).
- 기존 회귀: compare 10 PASS, link 4 PASS, match-regression 20/20(792 15), age-hint FAIL 0, data-gate 전 항목 PASS.
- 빌드 `./mvnw -q package -DskipTests` rc 0, `./mvnw -q test` 통과(AdminInitializerTest 3).

## 브라우저(Claude in Chrome)
- 데스크톱 1502px: `reviews/screens/explore-desktop-20261023.jpg` — 3축 필터·나이·동·검색·제외·옵션·정렬·카드. 총 792건.
- 찜: 하트 2개 클릭 → localStorage `[757,665]`, 버튼 aria-pressed·라벨 전환, '찜한 목록 (2)' → `/resources?ids=757%2C665` 2건 표시(`explore-favorites-20261023.jpg`).
- 필터 URL(`life=SENIOR&hh=DIS&q=돌봄&sort=latest`): 체크·검색어·정렬 상태 유지, 16건.
- 모바일 390px(동일 출처 iframe): 목록·상세·영어(`?lang=en&hh=DIS&life=SENIOR` 100건) 모두 scrollWidth=390(가로 넘침 없음). 모바일 필터는 2열 체크박스로 압축(`explore-mobile-*.jpg`).
- 상세 `/resources/181`: 한눈에 보기(담당·주기·유형·문의) + 찜 버튼 + 목록으로 링크, 기존 섹션 유지(`explore-detail-20261023.jpg`).
- 콘솔 에러 0, 네트워크 4xx/5xx 0(127.0.0.1:8099 요청 40건 전부 200/304).

## 한계(미검증)
- 키보드 전용 조작·스크린리더는 구조(label·fieldset·legend·aria-live·aria-pressed)만 확인, 실사용 보조기술 미검증. zh/vi 화면은 키 존재만 확인하고 직접 캡처하지 않음. 저장소 차단 환경(찜 불가 안내)은 코드 경로만 있고 재현하지 않음.
- 복지로 시흥 필터 결과·시흥 민간 포함 여부는 미확인(`reviews/bokjiro-benchmark-024.md`). 지도·위기알림·신고는 범위 제외.
