# API명세요약 — 한국사회보장정보원_지자체복지서비스

> 수집일: 2026-10-13 / 수집자: data-collector
> 출처: 공공데이터포털 상세페이지 https://www.data.go.kr/data/15108347/openapi.do (페이지 내장 Swagger 2.0 JSON 및 오퍼레이션 정의를 직접 파싱해 확인)
> 참고: 과제 지시문의 "한국사회**장**정보원"은 오기 — 정확한 기관명은 **한국사회보장정보원**이다.

## 1. 데이터셋 개요

| 항목 | 내용 |
|---|---|
| 정확한 서비스명 | **한국사회보장정보원_지자체복지서비스** |
| 데이터셋 ID | 15108347 |
| 제공기관 / 관리부서 | 한국사회보장정보원 / 포털운영부 |
| 원천 | 대국민 복지포털 복지로(bokjiro.go.kr) 제공 API |
| API 유형 / 응답 포맷 | REST(GET) / **XML** (produces: application/xml) |
| 갱신주기 | 실시간 |
| 라이선스 | 무료, 이용허락범위 제한 없음 |
| 등록일 / 수정일 | 2022-11-23 / 2026-04-13 (활용신청 1,946건) |
| 참고문서 | `지자체복지서비스_코드표(v1.0).doc` (상세페이지에서 다운로드 — 생애주기·가구상황·관심주제 코드값 수록) |

## 2. 활용신청 절차

1. data.go.kr 로그인 → 위 상세페이지에서 [활용신청]
2. **개발단계·운영단계 모두 자동승인** — 신청 즉시 인증키(serviceKey) 발급, 담당자 심사 대기 없음
3. 호출 제한(트래픽): **개발계정 일 1,000건** / 운영계정은 고정치 없음(활용사례 등록 후 신청 시 증량 가능)
4. 발급 직후 키 활성화까지 통상 수 분~1시간 소요될 수 있음(포털 일반 안내)

→ 설계서 00의 "4주차 내 신청" 일정에 리스크 없음. 일 1,000건이면 시흥시 전수 대조 배치(목록 1~2콜 + 상세 수백 콜)도 개발계정으로 충분.

## 3. 엔드포인트

베이스: `https://apis.data.go.kr/B554287/LocalGovernmentWelfareInformations` (http도 허용)

| 오퍼레이션 | 메서드/경로 | 용도 |
|---|---|---|
| 목록조회 | `GET /LcgvWelfarelist` | 조건별 지자체 복지서비스 목록 |
| 상세조회 | `GET /LcgvWelfaredetailed` | servId 1건의 지원대상·선정기준·신청방법 전문 |

## 4. 요청 파라미터

### 4.1 목록조회 (LcgvWelfarelist)

| 파라미터 | 필수 | 설명 |
|---|---|---|
| serviceKey | 필수 | 인증키 |
| pageNo | 옵션 | 페이지 시작 위치 |
| numOfRows | 옵션 | 출력 건수 |
| lifeArray | 옵션 | 생애주기 (코드표 참조) |
| trgterIndvdlArray | 옵션 | 가구상황 (코드표 참조) |
| intrsThemaArray | 옵션 | 관심주제 (코드표 참조) |
| age | 옵션 | 나이 |
| **ctpvNm** | 옵션 | **시도명** — 시흥시 필터 시 `경기도` |
| **sggNm** | 옵션 | **시군구명** — 시흥시 필터 시 `시흥시` |
| srchKeyCode | 옵션 | 검색분류 |
| searchWrd | 옵션 | 검색어 |
| arrgOrd | 옵션 | 정렬순서 |

**시흥시 필터 호출 예시** (설계서 00의 `ctpvNm=경기도, sggNm=시흥시` 그대로 유효함을 명세에서 확인):

```
https://apis.data.go.kr/B554287/LocalGovernmentWelfareInformations/LcgvWelfarelist?serviceKey=인증키&pageNo=1&numOfRows=100&ctpvNm=%EA%B2%BD%EA%B8%B0%EB%8F%84&sggNm=%EC%8B%9C%ED%9D%A5%EC%8B%9C
```

### 4.2 상세조회 (LcgvWelfaredetailed)

| 파라미터 | 필수 | 설명 |
|---|---|---|
| serviceKey | 필수 | 인증키 |
| servId | 필수 | 서비스ID (목록조회 응답의 servId; 포털 예시값 `WLF00001138`) |

```
https://apis.data.go.kr/B554287/LocalGovernmentWelfareInformations/LcgvWelfaredetailed?serviceKey=인증키&servId=WLF00001138
```

## 5. 응답 필드 (XML)

### 5.1 목록조회 응답

공통: `resultCode`(결과코드), `resultMessage`(결과메시지), `numOfRows`, `pageNo`, `totalCount`
`servList` 반복 항목:

| 필드 | 설명 |
|---|---|
| servId | 서비스ID (상세조회 키) |
| servNm | 서비스명 |
| servDgst | 서비스 요약 |
| servDtlLink | 서비스상세링크(복지로) |
| ctpvNm / sggNm | 시도명 / 시군구명 |
| bizChrDeptNm | 사업담당부서명 |
| lifeNmArray | 생애주기명 |
| trgterIndvdlNmArray | 가구상황명 |
| intrsThemaNmArray | 관심주제명 |
| sprtCycNm | 지원주기명 |
| srvPvsnNm | 제공유형명 |
| aplyMtdNm | 신청방법명 |
| inqNum | 조회수 |
| lastModYmd | 최종수정일자 |

### 5.2 상세조회 응답

목록 필드 전부 + 아래 추가:

| 필드 | 설명 |
|---|---|
| enfcBgngYmd / enfcEndYmd | 시행시작일자 / 시행종료일자 |
| sprtTrgtCn | **지원대상 내용** (자격 태깅 원문) |
| slctCritCn | **선정기준 내용** |
| alwServCn | 급여(지원)서비스 내용 |
| aplyMtdCn | 신청방법 내용 |
| inqplCtadrList | 문의처 목록 (wlfareInfoReldNm/Cn/DtlCd 반복) |
| inqplHmpgReldList | 관련 웹사이트 목록 (동일 구조) |
| baslawList | 근거법령 목록 (동일 구조) |
| basfrmList | 서식/자료 목록 (동일 구조) |

## 6. 복지이음 활용 포인트

- **최신성 대조 배치**: 목록조회(경기도/시흥시) → `lastModYmd`·`servNm`·`bizChrDeptNm`을 종합안내서(2022) 공공 200건과 대조. 종료 사업은 목록에서 빠지므로 "목록 부재 = 종료 후보" 플래그.
- `sprtTrgtCn`/`slctCritCn` 원문은 RESOURCE 테이블 `원문자격` 보존용으로 그대로 저장 가능.
- 민간 544건은 이 API에 없음(지자체 공공사업만) — 민간분은 종합안내서+시 누리집 수동 대조 유지.

## 미확인 항목

- **운영계정 트래픽 상한 수치**: 포털에 "활용사례 등록 후 증량 가능"으로만 표기, 구체 수치 미공개 → 미확인
- **코드표 상세 값**(lifeArray 등 코드↔명칭 매핑): 첨부 doc 미다운로드 상태 → 활용신청 시 상세페이지에서 `지자체복지서비스_코드표(v1.0).doc` 수령 필요
- JSON 응답 지원 여부: 명세상 XML만 명시(`_type=json` 지원 여부 미확인)
