# DB 본문 다국어(en/zh/vi) 번역 — 근거와 재생성

- 적용 SQL: `src/main/resources/sql/content-i18n-20261125.sql` (멱등 — 여러 번 실행해도 결과 동일)
- 적재 순서: schema → seed → api-update → facility-refresh → gov24-update → **content-i18n-20261125**
- 원리: 한국어 원문을 `TRIM` 한 뒤 SHA-256(SHA2) 를 키로 번역 사전(`content_i18n`)을 만들고, `resource_i18n` 의 `*_tr` 컬럼에 채운다. 번역이 없으면 `NULL` → 화면은 한국어 원문으로 폴백.
- 번역 대상: 사업명·지원 내용·기관·부서·주소·신청 방법·구비서류·지원 기준·본인부담·추가 조건·신청권자·제공시기·선정기간·연락처 메모 (고유 문장 3,771개 × 3개 언어)
- 파일: `원문사전.json`(1~25번 묶음 원문), `번역결과/NN.json`(묶음별 번역, 26·27번은 짧은 값), `번역규칙.md`(용어집·규칙), `gen_sql.py`(결과 JSON → SQL), `validate.py`(누락·한글 잔존·숫자 검사)
- 번역은 AI 가 작성함 — 공식 번역이 아니므로 화면 하단 "참고용" 문구 유지. 기존 수기 번역(seed.sql 의 resource 1594 영어)은 보존됨.
- 데이터 변경 시: 새 원문은 번역 사전에 없으면 한국어로 폴백되므로, 묶음 JSON 을 추가 번역 후 `gen_sql.py` 로 SQL 을 다시 만든다.

- MySQL 9.6 이상은 `MD5()` 함수가 제거되어 `SHA2(x, 256)` 을 사용한다. `content_i18n` 은 파생 테이블이라 SQL 실행 때마다 새로 만든다.
