# 복지이음 (bokji-ieum)

> 시흥시 복지자원 **792건**(공공 246·민간 546)을 로그인 없이 **1분 조건 입력 → 규칙 기반 자격 판정 → 추천 이유와 신청 안내**로 이어 주는 웹 서비스.
> 웹서비스프로그래밍 팀 프로젝트 — 팀 **이음** (김재민·문재혁·이병화·이윤재) · CE 경진대회 출품작.

시흥시 복지자원을 조건별로 탐색하고, **매칭 근거(일치/확인필요)와 신청 안내**를 확인하는 시범 서비스다. 명시 조건에 맞는 항목을 먼저 정렬하고 불확실한 항목도 '확인 필요'로 함께 보여 주므로, 대표 입력에서도 결과가 수백 건 남을 수 있다. 생성형 AI 없이 결정표 기반 규칙 매칭만 사용해 같은 입력이면 같은 결과가 재현된다. 복지온은 질문에 답하는 챗봇(2026-10-23 직접 확인, `reviews/competitor-evidence-023.md`)이고, 복지로와의 직접 비교·시 차원의 연계는 미확인·협의 필요다.

## 주요 기능

- **7스텝 조건 입력**: 출생연도·거주 동·가구 유형·소득 구분·장애·국적·학업. 모든 스텝 [모름/건너뛰기] 가능, 가구원 추가 매칭 지원
- **매칭 결과**: 점수순 카드 + 추천 이유 태그(✅일치/⚠️확인 필요), 분야 필터, '오래된 자료' 뱃지. 원칙은 *"애매하면 확인 필요, 틀리게 제외 금지"* — 전 필드 '모름'이어도 777건(=792−외국인 전용 15)이 노출된다
- **상세**: 항목별 자격 판정표, 신청 방법·서류·연락처(tel: 링크), 출처·기준일, 인쇄, 오류 제보
- **다국어 4종**: 한국어·English·中文·Tiếng Việt (외국인 선택 시 외국인 대상 자원 우선 정렬)
- **관리자**: 자원 CRUD(변경 이력 자동 기록)·제보 처리·기준일 경과 필터 — 수정 즉시 매칭에 반영
- **익명 퍼널 로그**: 매칭→상세→전화/신청→제보, 식별자 미저장(10세 연령 밴드, 세션 해시)

## 기술 스택

JSP/JSTL · Spring MVC 5.3 (**비-Boot**, web.xml) · MyBatis 3.5 · MySQL 8 (Docker) · Tomcat 9 (cargo 플러그인) · Bootstrap 5.3 — 수업 표준 스택 그대로. 매칭 로직은 `resource-mapper.xml`의 SQL 한 곳에 모여 있다(진실의 원천은 [docs/설계/03](docs/설계/03-매칭-엔진-설계.md)의 결정표).

## 빠른 시작 (JDK 17 + Docker만 있으면 됨, Maven 설치 불필요)

```bash
git clone <repo-url> && cd bokji-ieum
docker compose up -d                                   # MySQL 8 기동
cp src/main/resources/config.properties.example src/main/resources/config.properties
docker exec -i bokji-mysql mysql --default-character-set=utf8mb4 -ubokji -pbokji11 bokji < src/main/resources/sql/schema.sql
docker exec -i bokji-mysql mysql --default-character-set=utf8mb4 -ubokji -pbokji11 bokji < src/main/resources/sql/seed.sql
docker exec -i bokji-mysql mysql --default-character-set=utf8mb4 -ubokji -pbokji11 bokji < src/main/resources/sql/api-update-20261014.sql
docker exec -i bokji-mysql mysql --default-character-set=utf8mb4 -ubokji -pbokji11 bokji < src/main/resources/sql/facility-refresh-20261014.sql
docker exec -i bokji-mysql mysql --default-character-set=utf8mb4 -ubokji -pbokji11 bokji < src/main/resources/sql/gov24-update-20261014.sql
docker exec -i bokji-mysql mysql --default-character-set=utf8mb4 -ubokji -pbokji11 bokji < src/main/resources/sql/reliability-tagging.sql
docker exec -i bokji-mysql mysql --default-character-set=utf8mb4 -ubokji -pbokji11 bokji < src/main/resources/sql/reliability-provenance.sql
./mvnw cargo:run                                       # http://localhost:8080
```

- 관리자: `/admin/login` — 첫 기동 시 환경변수 `BOKJI_ADMIN_INITIAL_PASSWORD`가 있으면 `admin` 계정을 그 값으로 생성한다(값이 없으면 계정을 만들지 않음, 기존 계정은 변경하지 않음). 예: `BOKJI_ADMIN_INITIAL_PASSWORD=<임의값> ./mvnw cargo:run`
- 상세 절차·문제 해결: [SETUP.md](SETUP.md) · 발표 시연 순서: [docs/데모.md](docs/데모.md)

## 검증 결과

| 항목 | 결과 |
|---|---|
| 데이터 | 활성 시흥 자원 **792건**(공공 246·민간 546, 2026-10-19 스냅샷) = 종합안내서 744 + 복지로 API 24 + 보조금24 24. 본문 기준일은 2022년 744·2025년 1·2026년 47건 — **최신성은 자원별 기준일로 확인**해야 하며 본문 대조 완료는 0건 |
| 최신화 | 복지로 API·보조금24·시설현황 공공데이터 3종 대조(2026-10-14) — 신규 48건 추가, 연락처 59건 수정. 연락처·존속 확인일은 본문 확인이 아니다 |
| 규칙 구현 회귀 | 결정표 단위 케이스 **40/40 통과**(2026-10-13) — 규칙 구현 확인이며 실제 자격 정확도·792건 전체 정답률 측정이 아니다 |
| 시나리오 | S1~S6 6/6 통과(설계 문언 기준; 엄격 보조 기준 4/6) |
| 통합·보안 | XSS 제거·CSRF 403·제보 토큰+429·비로그인 차단 — 전 항목 PASS |

증거 로그 전체: [docs/검증/](docs/검증/) · 발표용 숫자 정리: [docs/검증/발표숫자.md](docs/검증/발표숫자.md)

## 문서 구성

| 경로 | 내용 |
|---|---|
| [docs/설계/](docs/설계/) | 설계서 00~06 (개요·아키텍처·DB·매칭 엔진·URL/화면·검증 운영·팀 운영) |
| [docs/데이터/](docs/데이터/) | 태깅 현황·미결, 수집 근거 인용 20건, 공공데이터 API 명세, 태깅 스크립트(`parse_tag.py`) |
| [docs/검증/](docs/검증/) | 단위 케이스 40건·fixtures·시나리오/통합 스모크 raw 로그 |
| [docs/데모.md](docs/데모.md) | 발표 데모 7단계 시연 경로 + 알려진 한계 |

## 알려진 한계 (정직하게)

- 종합안내서 분(744건)의 '오래된 자료' 뱃지 = 원본이 2022 하반기 기준이라 **정상 동작**. 설계된 갱신 경로인 **복지로 지자체복지서비스 API 대조를 실제 수행**(2026-10-14)해 신규 24건 추가·기존 3건 기준일을 갱신했고(본문 기준일 2026인 자원은 총 47건)(`src/main/resources/sql/api-update-20261014.sql`), 민간 546건은 종합안내서 개정판이 나와야 갱신 가능
- 화면 문구는 4개 언어(기계번역 초벌, 화면에 고지)이나 **자원 본문 번역은 en 10건뿐, zh/vi 본문은 한국어**. 성별 전용 조건은 '확인 필요'로만 표시
- 사용성 효과(탐색 시간 단축·퍼널 도달률·설문)는 **미측정**(목표값만 있음), 시 부서의 운영 수락·최신본 제공은 **미확인**, 복지로 API 대조는 일회성(자동 주간 동기화 미구현)
- 미구현(설계상 권장/선택): 회원·즐겨찾기, 뉴스 수집, 관리자 통계

## 남은 일정

EC2 배포(11/19) → 사용성 테스트 9명(11/20~22) → 최종 제출(11/29)

**데이터 후속 과제**: ① 시흥시 복지정책과에 **종합안내서 2026년판(2022판 양식 그대로) 공문 요청** — 수령 시 `docs/데이터/tools/parse_tag.py` 재실행으로 전량 교체 가능. ~~② 보조금24~~ (완료: 2026-10-14 시흥시 소관 42건 반영)
