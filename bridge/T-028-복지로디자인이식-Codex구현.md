# T-028 복지로 디자인 요소 이식 — Codex가 구현 (사용자 지시로 이번 건만 Codex=구현자)

사용자 지시(원문): "디자인 요소도 다 가져와 색깔 같은거나 액션들도" / "코덱스한테 스킬 다 넣고 그걸로 진행해". Claude는 토큰이 부족해 이 작업을 Codex에게 넘긴다. **이번 작업에 한해 너는 구현 권한이 있다**(reviews/·bridge/ 외 src/·docs/ 수정 가능). 이 worktree(브랜치 munjaehyeok/reopen-session-5efbcbdd)에서만 작업하고 커밋은 해도 되지만 **main 병합·푸시·배포는 금지**(사람 승인). 작업 중 Claude는 이 worktree를 수정하지 않는다.

## 쓸 스킬
`~/.claude/skills/clone-website/SKILL.md`(+ references/inspection-guide.md, framer-and-motion.md)를 읽고 그 순서(조사→관찰→구현→비교·수정)를 따른다. 단 이 앱은 Next.js가 아니라 Spring MVC+JSP+정적 CSS/JS다: `src/main/webapp/static/css/bokji.css`, `static/js/*.js`, `WEB-INF/views/**`가 대상이다.

## 원본
https://www.bokjiro.go.kr (비로그인 화면: 메인, `/ssis-tbu/twataa/wlfareInfo/moveTWAT52005M.do` 서비스 목록, 상세 `moveTWAT52011M.do?wlfareInfoId=WLF00006265`). 브라우저 도구가 있으면 직접 열어 computed style·상호작용을 측정해라. 이미 측정된 값(참고): 주 색 `rgb(62,97,215)`=#3E61D7, 본문 `#222`, 보조 글자 `#666`·`#4F4F4F`·`#484848`, 옅은 파랑 배경 `#EBEFFB`·`#F6F7FB`·`#EFF2FA`·`#E7EFFA`, 회색 배경 `#F4F4F4`·`#EDF1F5`, 구분선 `#DFDFDF`, 경고 빨강 `#DB0000`/`#FFF1F0`, 보조 청회색 `#6D6F82`, 본문 폰트 `"Noto Sans KR", Roboto, "맑은 고딕"…`, 검색 버튼 172×44 파란 배경 흰 글씨 굵게, 헤더 로고+메뉴 5개+검색창(큰 둥근 입력 + 파란 돋보기 원형 버튼), 우하단 플로팅 버튼(위/아래 이동 등), 필터 패널(생애주기/가구상황/관심주제 3열 체크박스 표), 카드 목록, 페이지네이션, 찜 버튼. 상호작용: 메뉴 hover/active, 체크박스·버튼 hover/focus, 탭 전환, 스크롤 이동 버튼, 모달·툴팁 등 직접 관찰한 것만 구현.

## 이식 범위와 금지
- 이식: **색 팔레트·타이포(크기/굵기/자간)·간격/라운드/그림자·헤더 구조·버튼/체크박스/탭/카드/페이지네이션 스타일·hover/focus/active/전환 모션·플로팅 위/아래 이동 버튼·검색창 스타일**을 복지이음 전 화면(홈, 입력 7단계, 결과, 상세, 둘러보기)에 일관되게 적용. 기존 "종이색+청록" 디자인은 엎어도 된다(사용자 허락). 토큰은 `:root` CSS 변수로.
- **금지(법·오인 방지)**: 복지로 로고·캐릭터·사진·아이콘 파일 그대로 복제 금지(우리 SVG 스프라이트 사용), "이 누리집은 대한민국 공식 전자정부 누리집입니다" 같은 공식 고지·정부 마크 금지, 복지로 문구 복사 금지. 브랜드명 '복지이음'과 "시범 서비스·참고용" 고지 유지.
- 유지: 접근성(포커스 표시, 대비 AA, label/aria), `prefers-reduced-motion`, 인쇄 스타일, 모바일 390px 가로 넘침 없음, 글자 크게 토글, 4개 언어 줄바꿈, 기존 기능·SQL·URL 변경 금지(순수 프런트).
- 시크릿: config.properties·serviceKey 건드리지 않음. 파일 삭제는 이번 변경 범위 밖 금지.

## 검증(AGENTS.md web-app 게이트)
- 빌드 `./mvnw -q package -DskipTests`, `./mvnw -q test`.
- 서버: 검증 서버가 이미 `http://127.0.0.1:8099` 에서 떠 있다(`pom-verify.xml` cargo, DB 컨테이너 bokji-verify). CSS/JSP 변경은 war 재빌드+서버 재시작 필요: `pkill -f pom-verify.xml; ./mvnw -q package -DskipTests; BOKJI_ADMIN_INITIAL_PASSWORD='임의값' nohup ./mvnw -q -f pom-verify.xml cargo:run > /tmp/verify-run.log 2>&1 &`.
- 회귀: `python3 -I docs/검증/resource-search-regression.py http://127.0.0.1:8099`(ALL PASS), `python3 docs/검증/match-regression.py http://127.0.0.1:8099 792 15`, `python3 docs/검증/age-hint-regression.py http://127.0.0.1:8099`, `docs/검증/compare-regression.py`, `link-regression.py`.
- 브라우저 스모크(가능하면): 데스크톱+390px, 콘솔 에러 0, 4xx/5xx 0, 핵심 흐름(홈→입력→결과→상세, 둘러보기→필터→찜→상세). 캡처 `reviews/screens/design-bokjiro-*.png`, 기록 `reviews/design-bokjiro-smoke-028.md`(원본↔로컬 비교, 이식한 것/의도적으로 안 한 것/남은 차이 구분).
- 끝나면 `reviews/design-bokjiro-028.md`에 변경 파일·토큰표·남은 차이를 적고, 이 탭에는 3줄 요약. 커밋 메시지 끝에 `Co-Authored-By: Codex <noreply@openai.com>`.
