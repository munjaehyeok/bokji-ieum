# R-009 재검토

R-008의 P1은 해소됐다. `bridge/BRIEF.md:26`과 `docs/데이터/태깅-현황.md:63`의 중위소득 180% 처리 방식은 `AGENTS.md:58`의 결정표와 일치하며, id=269는 rank=4·income_uncertain='Y'로 기록됐다. 새 교차표의 합계도 소득 rank 보유 182건, 확인필요 139건 및 rank=4·Y 43건과 일치한다.

[P2] docs/검증/발표숫자.md:61
Axis: Correctness
Problem: 활성 자원 792건의 분포라고 명시했지만, 재현 SQL에는 `status='A'` 조건이 없다.
Evidence: 같은 문서 50행의 집계 기준은 활성 자원이다. 현재 표의 합계는 맞지만, 이 SQL은 비활성 자원이 생기면 다른 분포를 반환한다.
Suggested direction: `status='A' AND (income_rank IS NOT NULL OR income_uncertain='Y')`로 집계 범위를 명시한다.
Verification: static

[P2] docs/검증/발표숫자.md:59
Axis: Correctness
Problem: 소득 분포 절이 기존 집계 표의 중간에 삽입돼, 76–78행의 분야·비용·번역 행이 표에서 분리됐다.
Evidence: 기존 표의 헤더와 구분선은 50–51행에 있고, 그 사이에 새 제목·SQL·별도 표·목록이 들어갔다.
Suggested direction: 기존 집계 표의 세 행 뒤에 소득 분포 절을 배치한다.
Verification: static

요약: 지적 2건 (P0 0, P1 0, P2 2)
판정: APPROVE
