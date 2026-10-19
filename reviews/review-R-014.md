# R-014 상세 판정표 리뷰

판정 상태는 기존 SQL 태그를 사용하고, 데스크톱·390px 화면에서 표의 기본 배치는 확인됐다. 다음 세 항목은 병합 전 보정이 필요하다.

[P1] src/main/java/com/ieum/bokji/service/JudgeCompare.java:67
Axis: Correctness
Problem: `공고 조건` 열이 정규화한 소득 rank의 대표 문구를 실제 공고의 상한으로 단정해 표시한다.
Evidence: rank=4·uncertain=Y인 id=269의 원문은 중위소득 **180% 이하**인데 표에는 `compare.income.4`인 **150% 이하**가 나온다(`messages_ko.properties:195`). id=95의 **80% 이하**도 rank=3이므로 **100% 이하**로 나온다. `확인 필요` 태그나 아래 원문이 있더라도 두 문구는 같은 화면에서 서로 모순된다.
Suggested direction: rank 문구를 실제 공고 조건이라고 표시하지 말고, 태깅 구간임을 명시하거나 원문 기준과 불확실성을 함께 보여 준다. 180%·80% 사례를 회귀에 추가한다.
Verification: static

[P1] src/main/java/com/ieum/bokji/service/JudgeCompare.java:66
Axis: Correctness
Problem: rank가 비고 `income_uncertain='Y'`인 자원의 소득 기준은 새 비교표에서 소득 항목으로 나타나지 않는다.
Evidence: `resource-mapper.xml:101-106`은 `INCOME`·`INCOME_DETAIL` 태그를 rank가 있을 때만 만든다. 따라서 `r.getIncomeRank() == null`일 때의 `compare.incomeDetail` 분기는 실제로 실행되지 않는다. 활성 자원에 이 조합이 23건(`docs/검증/발표숫자.md:74`) 있으며 id=182는 건강보험료 기준을 원문에 둔다. 표에는 소득 비교 대신 일반적인 `NOTE`만 나올 수 있다.
Suggested direction: SQL 판정을 재계산하지 않으면서도 rank 없는 별도 소득 기준을 확인이 필요한 공고 정보로 표시하고, 해당 사례를 회귀에 넣는다.
Verification: static

[P1] reviews/argonaut-smoke.md:36
Axis: Spec
Problem: 이번 UI 변경의 필수 네트워크 스모크 결과가 없다.
Evidence: `AGENTS.md`의 브라우저 게이트는 네트워크 4xx/5xx 없음을 요구하지만, 이번 상세 화면 스모크는 이를 `별도 수집`하지 않았다고 기록했다. 콘솔 0건과 데스크톱·모바일 캡처는 기록돼 있다.
Suggested direction: 현재 v=7 화면의 핵심 흐름에서 네트워크 요청과 응답 상태를 확인해 스모크 기록에 남긴다.
Verification: NEEDS_EVIDENCE

요약: 지적 3건 (P0 0, P1 3, P2 0)
판정: REVISE
