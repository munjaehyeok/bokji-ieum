# 복지이음 (bokji-ieum)

> 시흥시 복지자원 **768건**(공공 222·민간 546)을 로그인 없이 **1분 조건 입력 → 규칙 기반 자격 판정 → 추천 이유와 신청 안내**로 이어 주는 웹 서비스.
> 웹서비스프로그래밍 팀 프로젝트 — 팀 **이음** (김재민·문재혁·이병화·이윤재) · CE 경진대회 출품작.

기존 시흥시 복지 앱(복지온)이 "목록 검색"에 그치는 것을 보완해, **내 조건에 맞는 것만 골라 주고 왜 맞는지(✅일치/⚠️확인필요)까지 보여 주는 것**이 핵심이다. 생성형 AI 없이 결정표 기반 규칙 매칭만 사용한다 — 판정 근거를 100% 설명·재현할 수 있다.

## 주요 기능

- **7스텝 조건 입력**: 출생연도·거주 동·가구 유형·소득 구분·장애·국적·학업. 모든 스텝 [모름/건너뛰기] 가능, 가구원 추가 매칭 지원
- **매칭 결과**: 점수순 카드 + 추천 이유 태그(✅일치/⚠️확인 필요), 분야 필터, '오래된 자료' 뱃지. 원칙은 *"애매하면 확인 필요, 틀리게 제외 금지"* — 전 필드 '모름'이어도 723건(=744−외국인 전용 21)이 노출된다
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
./mvnw cargo:run                                       # http://localhost:8080
```

- 관리자: `/admin/login` — **admin / ieum2026!** (첫 기동 시 자동 생성 · 로컬 데모용)
- 상세 절차·문제 해결: [SETUP.md](SETUP.md) · 발표 시연 순서: [docs/데모.md](docs/데모.md)

## 검증 결과

| 항목 | 결과 |
|---|---|
| 데이터 | 시흥시 종합안내서 744건 **전량** 적재 (규칙 기반 자동 태깅 + 리뷰 게이트 2회) + 복지로 API 27건 반영(신규 24·갱신 3) = **768건** |
| 최신화 | 복지로 API(2026-09 기준) + 시설현황 공공데이터(2026-08 기준) 대조 — **연락처 59건 수정·주소 4건 보충, 누적 310건 2026-10-14자 검증 완료** |
| 판정 정확도 | 결정표 단위 테스트 **40/40 PASS** |
| 시나리오 | S1~S6 **6/6 통과** |
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

- 종합안내서 분(744건)의 '오래된 자료' 뱃지 = 원본이 2022 하반기 기준이라 **정상 동작**. 설계된 갱신 경로인 **복지로 지자체복지서비스 API 대조를 실제 수행**(2026-10-14)해 공공 27건을 2026년 기준으로 반영했고(`src/main/resources/sql/api-update-20261014.sql`), 민간 546건은 종합안내서 개정판이 나와야 갱신 가능
- en/zh/vi 번역은 기계번역 초벌(화면에 고지), 성별 전용 조건은 '확인 필요'로만 표시
- 미구현(설계상 권장/선택): 회원·즐겨찾기, 뉴스 수집, 관리자 통계

## 남은 일정

EC2 배포(11/19) → 사용성 테스트 9명(11/20~22) → 최종 제출(11/29)

**데이터 후속 과제**: ① 시흥시 복지정책과에 **종합안내서 2026년판(2022판 양식 그대로) 공문 요청** — 수령 시 `docs/데이터/tools/parse_tag.py` 재실행으로 전량 교체 가능. ② 보조금24 API(공공데이터 15113968) 활용신청 후 시흥시 등록 혜택 추출·대조
