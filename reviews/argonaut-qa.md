# T13 시나리오·QA 결과 (검증 DB 792건, 포트 8099, 커밋은 이 파일이 들어간 커밋의 직전 구현 상태)
## 자동
- Maven: `./mvnw -q test` rc 0 (테스트 클래스 0개), `./mvnw -q package -DskipTests` rc 0
- 데이터 게이트 15/15, 매칭 회귀 20/20, AGE_HINT 회귀 99 PASS / 0 FAIL (docs/검증/age-hint-regression.py; 노출 건수 불변 6명, 안정 분할 추천·최신 × 3개 연령, id=309 오탐 사례 포함)
- 최초 렌더·AJAX JSON·상세 날짜/안내문 4개 언어 scope.py (ko/en/zh/vi), 결과 머리글 문구 4개 언어 확인
- scope.py의 '최신순 전체 내림차순' 단언은 안정 분할 도입으로 의도적으로 무효 → 묶음 내 순서는 age-hint-regression 3d가 검증
## 브라우저(Claude in Chrome)
- 입력 마법사 7단계 → 결과(68세 기초수급, 602건) 실제 흐름: 머리글 2개, 연령 대상 확인 카드 109건, 콘솔 에러 0
- 결과 → 카드 클릭 → 상세(출처·기준일·신청방법·신고 버튼) 확인, 가로 스크롤 없음
- 네트워크: 이번 흐름의 자체 호스트 요청(/match POST, /match/result, /match/result/list, static) 모두 200, CDN(bootstrap, pretendard) 200. 4xx/5xx 없음
- 스크린샷: reviews/screens/result-ko-68-수급.jpg, result-en-30-외국인.jpg, detail-en.jpg (뷰포트는 모바일 폭으로 측정됨; 데스크톱 폭 캡처는 못 했다)
## 발견(미수정, 사람 판단 필요)
- en/zh/vi 상세 화면의 분야 하위, 자격 원문, 신청 방법, 서류는 한국어 원문 그대로다(이름·요약만 번역). 번역 데이터 범위 문제이며 이번 변경과 무관.
- 데스크톱 폭(1280)에서의 레이아웃은 확인하지 못했다(창 크기 변경이 뷰포트에 반영되지 않음).
- 실제 신청 전송은 하지 않았다(외부 제출).
