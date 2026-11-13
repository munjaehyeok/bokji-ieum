# 다른 컴퓨터에서 실행하기 (처음부터 10분)

이 저장소만 받으면 **소스·DB 스키마·시흥시 복지자원 데이터(792건)** 가 모두 들어 있어, 아래 순서대로 하면 그대로 실행된다.
저장소에 없는 것은 DB 접속 설정 파일(`config.properties`, 예시 파일에서 복사)과 공공데이터포털 인증키(서버 재수집에만 필요, 실행에는 불필요)뿐이다.

## 0. 필요한 것

| 도구 | 버전 | 비고 |
|---|---|---|
| JDK | 17 | `java -version`으로 확인 |
| Docker | Docker Desktop(Windows·Mac) / Docker Engine(Linux) / OrbStack(Mac) | MySQL 8 컨테이너용. 로컬에 MySQL을 직접 쓸 수도 있다(아래 "Docker 없이") |
| git | 아무 버전 | |
| Maven | 설치 불필요 | 저장소의 `mvnw`(Maven Wrapper)가 받아 온다 |

## 1. 받기
```bash
git clone <저장소 주소>
cd bokji-ieum
```

## 2. DB 기동 + 데이터 자동 적재
```bash
docker compose up -d
docker logs -f bokji-mysql      # "[bokji] 적재 완료: 활성 자원 792건"이 보이면 끝 (Ctrl+C로 로그만 닫기, 1~2분)
```
- 컨테이너가 **빈 볼륨으로 처음 뜰 때 한 번만** `docker/initdb/01-load-data.sh`가 `src/main/resources/sql/`의 SQL 7개를 정해진 순서로 적재한다.
  순서: `schema → seed → api-update-20261014 → facility-refresh-20261014 → gov24-update-20261014 → reliability-tagging → reliability-provenance`
- 접속 정보: `127.0.0.1:3306`, DB `bokji`, 계정 `bokji` / `bokji11` (로컬 개발용, 외부에 열지 말 것)
- 다시 처음부터 적재하려면: `docker compose down -v && docker compose up -d` (**볼륨 삭제 = DB 초기화**)

## 3. 접속 설정 파일
```bash
cp src/main/resources/config.properties.example src/main/resources/config.properties      # Windows: copy 로 같은 이름 복사
```
기본값 그대로면 수정할 것이 없다. `config.properties`는 `.gitignore`에 있어 올라가지 않는다. 본인 DB·포트를 쓰면 `db.url`·`db.username`·`db.password`를 거기서 바꾼다.

## 4. 서버 기동
```bash
# macOS / Linux — 관리자 화면까지 쓰려면 로컬용 임의 비밀번호를 환경변수로 준다
BOKJI_ADMIN_INITIAL_PASSWORD='<직접 정한 값>' ./mvnw cargo:run
```
```powershell
# Windows PowerShell
$env:BOKJI_ADMIN_INITIAL_PASSWORD='<직접 정한 값>'; .\mvnw.cmd cargo:run
```
- 환경변수가 없으면 관리자 계정을 만들지 않는다(일반 화면은 정상). 이미 admin이 있는 DB는 바뀌지 않는다. **저장소에는 고정 비밀번호가 없다.**
- 첫 실행은 의존성·Tomcat 9 다운로드로 수 분 걸린다. 끝나면 http://localhost:8080/ 접속. 종료는 Ctrl+C.

## 5. 잘 떴는지 확인
| 확인 | 기대 결과 |
|---|---|
| http://localhost:8080/ | "나에게 맞는 시흥시 복지, 1분 안에" 홈 |
| http://localhost:8080/resources | 둘러보기 목록, 792건(공공 246·민간 546) |
| `docker exec bokji-mysql mysql -ubokji -pbokji11 bokji -e "select count(*) from resource where status='A'"` | 792 |
| `/match` → 출생연도만 입력 후 "지금 조건으로 결과 보기" | 결과 화면에 "어긋나는 점이 없는 자원 N건 · 추가 확인이 필요한 자원 K건" |
| `./mvnw -q test` | 통과 |

## 저장소에 없는 것 (따로 받아야 하는 것)

| 항목 | 실행에 필요? | 설명 |
|---|---|---|
| `src/main/resources/config.properties` | 예 | 위 3단계에서 예시 파일을 복사해 만든다(비밀 아님, 기본값 동작) |
| 공공데이터포털 `serviceKey` | **아니오** | 복지로 API를 다시 수집할 때만. 이미 수집한 결과는 `sql/api-update-*.sql`에 들어 있다. 필요하면 data.go.kr에서 본인 키를 받아 `config.properties`에만 쓴다(커밋 금지) |
| 시 종합안내서 원본(xlsx/pdf) 등 참고자료 | 아니오 | 원본 파일은 저장소에 없다. 정제 결과가 `seed.sql`과 `docs/데이터/수집/`의 근거 CSV·로그에 있다 |
| 발표자료(PPT)·영상 | 아니오 | 별도 전달 |

## Docker 없이 로컬 MySQL을 쓰는 경우
MySQL 8에 DB `bokji`(utf8mb4)와 계정 `bokji`/`bokji11`을 만든 뒤, 아래 순서로 SQL을 적재한다. **`--default-character-set=utf8mb4` 필수**(빼면 한글이 깨진다).
```bash
cd src/main/resources/sql
for f in schema seed api-update-20261014 facility-refresh-20261014 gov24-update-20261014 reliability-tagging reliability-provenance; do
  mysql --default-character-set=utf8mb4 -ubokji -pbokji11 bokji < $f.sql
done
```
Windows PowerShell은 `<` 입력 리다이렉트가 안 되므로 Git Bash를 쓰거나 `mysql ... -e "source schema.sql"` 형태로 한 파일씩 실행한다.

## 문제 해결
- **한글이 `???`로 보임**: 적재할 때 `--default-character-set=utf8mb4`가 빠졌다. `docker compose down -v` 후 다시 `up -d`.
- **적재 로그가 안 보이고 792건이 아님**: 기존 볼륨이 있으면 초기화 스크립트가 다시 돌지 않는다. `docker compose down -v && docker compose up -d`.
- **포트 3306 충돌**: 로컬 MySQL을 끄거나 `docker-compose.yml`의 `"3306:3306"`을 `"3307:3306"` 등으로 바꾸고 `config.properties`의 `db.url` 포트도 같이 바꾼다.
- **포트 8080 충돌**: 사용 중 프로세스를 종료하고 다시 실행.
- **`./mvnw` 권한 오류(Mac/Linux)**: `chmod +x mvnw`.
- 빌드만 확인: `./mvnw -q package -DskipTests`

## 더 읽을 것
[README](README.md) · 설계서 [docs/설계/](docs/설계/) · 검증 스크립트 [docs/검증/](docs/검증/)(`data-gate.sh`는 빈 DB 적재 → 792/246/546/15 수치 점검) · 발표 시연 순서 [docs/데모.md](docs/데모.md)
