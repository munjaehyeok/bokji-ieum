# 팀원 셋업 가이드 (10분)

필요한 것: **JDK 17**, **Docker Desktop**, git. (Maven 설치 불필요 — mvnw 포함)

## 1. 클론
```bash
git clone <repo-url>
cd bokji-ieum
```

## 2. DB 기동 (MySQL 8, utf8mb4)
```bash
docker compose up -d
```
- 접속 정보: `127.0.0.1:3306`, DB `bokji`, 계정 `bokji` / `bokji11`

## 3. DB 설정 파일
```bash
cp src/main/resources/config.properties.example src/main/resources/config.properties
```
(기본값 그대로면 수정 불필요. `config.properties`는 git에 올라가지 않는다.)

## 4. 스키마·시드 적재
`src/main/resources/sql/`에 schema.sql, seed-codes.sql이 들어오면:
```bash
docker exec -i bokji-mysql mysql -ubokji -pbokji11 bokji < src/main/resources/sql/schema.sql
docker exec -i bokji-mysql mysql -ubokji -pbokji11 bokji < src/main/resources/sql/seed-codes.sql
```
(아직 없으면 건너뛴다 — 데이터 엔지니어 산출물 대기 중. DB 없이도 WAS는 뜬다.)

## 5. 서버 기동
```bash
./mvnw cargo:run        # Windows: mvnw.cmd cargo:run
```
첫 실행은 의존성·Tomcat 9 다운로드로 수 분 걸린다. 이후 http://localhost:8080/ 접속.
종료: Ctrl+C

## 문제 해결
- 포트 8080 충돌: 사용 중 프로세스 종료 후 재시도
- 포트 3306 충돌: 로컬 MySQL 중지 또는 docker-compose.yml 포트 변경(+ config.properties 동기화)
- 빌드만 확인: `./mvnw package`
