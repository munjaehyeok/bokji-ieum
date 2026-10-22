# T4 저장소 다국어 커버리지 (2026-10-22)

방법: DB 컨테이너를 쓸 수 없는 상태(Docker 데몬 미기동)라 적재 SQL을 정적 집계했다. `seed.sql`의 `INSERT INTO resource_i18n` 10행, 다른 적재 SQL(api-update·facility-refresh·gov24-update)에는 resource_i18n 삽입 없음(`rg -c resource_i18n src/main/resources/sql/*.sql` → schema 3, seed 10).

| 언어 | 자원 본문 번역(resource_i18n) | 필드 | 화면 UI(messages_*.properties) |
|---|---|---|---|
| ko | 원문 792건 | - | 전체 |
| en | **10건** (resource_id 36, 79, 99, 104, 445, 519, 526, 530, 547, 668) | name_tr·summary_tr만 (자격·신청방법·서류 본문은 한국어) | 전체 |
| zh | **0건** | - | 전체(기계번역 초벌) |
| vi | **0건** | - | 전체(기계번역 초벌) |

결론/표현 기준: "화면 문구는 4개 언어, 자원 본문 번역은 en 10건(이름·요약)에 한정, zh/vi 본문은 한국어". 번역 확대는 원문 검수·동의 없이 자동 번역으로 채우지 않는다(데이터 작업 보류, 사람 결정).
