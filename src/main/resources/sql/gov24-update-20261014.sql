-- 보조금24(대한민국 공공서비스 정보, 행안부) 시흥시 소관 42건 반영 (2026-10-14) — 매칭 18(검증) + 신규 24
-- 근거: 데이터/수집/보조금24대조-20261014.csv
UPDATE resource SET data_base_date=GREATEST(IFNULL(data_base_date,'1970-01-01'),'2026-09-22'), last_verified_date='2026-10-14', updated_at=NOW() WHERE resource_id=758;
UPDATE resource SET data_base_date=GREATEST(IFNULL(data_base_date,'1970-01-01'),'2026-09-21'), last_verified_date='2026-10-14', updated_at=NOW() WHERE resource_id=15;
UPDATE resource SET data_base_date=GREATEST(IFNULL(data_base_date,'1970-01-01'),'2026-09-21'), last_verified_date='2026-10-14', updated_at=NOW() WHERE resource_id=65;
UPDATE resource SET data_base_date=GREATEST(IFNULL(data_base_date,'1970-01-01'),'2026-08-28'), last_verified_date='2026-10-14', updated_at=NOW() WHERE resource_id=200;
UPDATE resource SET data_base_date=GREATEST(IFNULL(data_base_date,'1970-01-01'),'2026-09-21'), last_verified_date='2026-10-14', updated_at=NOW() WHERE resource_id=750;
UPDATE resource SET data_base_date=GREATEST(IFNULL(data_base_date,'1970-01-01'),'2026-09-26'), last_verified_date='2026-10-14', updated_at=NOW() WHERE resource_id=66;
INSERT INTO resource (name, category, service_type, provider_type, org_name, dept_name, phone, support_content, apply_method, apply_url, age_min, age_max, income_uncertain, disability, nationality, uncertain_note, eligibility_raw, source_name, source_url, data_base_date, last_verified_date, status) VALUES ('외국인아동보육료 지원', 'EDU', '바우처', 'PUB', '시흥시청', '성평등정책과', '031-310-6890', '○ 관내 어린이집에 재원 중인 시흥시 체류지 등록 외국인아동에게 월 13~25만원 보육료(바우처) 차등지원
   - 만 0~2세  : 202,000원
   - 만 3~5세  : 130,000원 (국공립/법인/직장/공공형 어린이집) 
                         235,000원~250,000원 (민간/가정 어린이집)

○ 관내 어린이집에 재원 중인 시흥시 체류지등록 외국인아동에게 연장보육 이용시간에 따라 연장보육료 지원', '방문신청', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/401000000110', NULL, NULL, NULL, NULL, 'F', '보조금24 수집분(2026) — 대상: ○ 관내 어린이집에 재원중인 만0~5세 외국인아동(관내 체류지 등록 즉시 지원)', '○ 관내 어린이집에 재원중인 만0~5세 외국인아동(관내 체류지 등록 즉시 지원)', '보조금24(대한민국 공공서비스 정보)', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/401000000110', '2026-09-21', '2026-10-14', 'A');
INSERT INTO resource (name, category, service_type, provider_type, org_name, dept_name, phone, support_content, apply_method, apply_url, age_min, age_max, income_uncertain, disability, nationality, uncertain_note, eligibility_raw, source_name, source_url, data_base_date, last_verified_date, status) VALUES ('시흥시 국가유공자 생활보조수당', 'DAILY', '현금', 'PUB', '시흥시청', '복지정책과', '031-310-3553', '○ 기준중위소득 50%이하인 국가유공자에게 월 3만원의 생활보조수당 지원', '정부24온라인신청||방문신청', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/401000000111', NULL, NULL, 'Y', NULL, NULL, '보조금24 수집분(2026) — 대상: ○ 차상위계층(기준중위소득 50%)이하인 국가유공자', '○ 차상위계층(기준중위소득 50%)이하인 국가유공자', '보조금24(대한민국 공공서비스 정보)', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/401000000111', '2026-09-22', '2026-10-14', 'A');
INSERT INTO resource (name, category, service_type, provider_type, org_name, dept_name, phone, support_content, apply_method, apply_url, age_min, age_max, income_uncertain, disability, nationality, uncertain_note, eligibility_raw, source_name, source_url, data_base_date, last_verified_date, status) VALUES ('대안교육기관 등 신입생 교복비 지원', 'DAILY', '현금', 'PUB', '시흥시청', '교육자치과', '031-310-3496', '○ 경기도 대안교육기관  및 타 시·도 중·고등학교 신입생 교복(학칙에 규정된 단체복)지원
- 입학일 기준 시흥시에 주소를 둔 1학년 신입생
- 2025년 기준 최대 40만원(신청기간: 2025. 3.~)
- 학교 소재지 지자체, 교육청에서 지원을 받을 수 있는 경우 해당 기관 <교복/입학지원금 상한액의 차액> 내에서 지원하며
 해당 교육청 지원 우선 신청 원칙,  해당 지원청 배제하고 경기도에 전액 신청 불가
   (예시) 서울시 소재 학교 학생 : 입학지원금 상한액 30만원 → 차액 10만원 내에서 지원
   (예시) 강원도 소재 학교 학생 : 교복지원금 상한액 33.6만원 → 차액 6.4만원내에서 지원
   (예시) 강원도 일반고에서 28만원 받음 → 교복지원금 상한액 33.6만원을 제하여 최대 6.4만원 내 지원', '기타 온라인신청', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/401000000112', NULL, NULL, NULL, NULL, NULL, '보조금24 수집분(2026) — 대상: ○ 경기도 대안교육기관 및 타 시·도 중·고등학교 신입생 교복(학칙에 규정된 단체복)지원 - 입학일 기준 시흥시에 주소를 둔 1학년 신입생 - 2025년 기준 최대 40만원 - 학교 소재지 지자체 교육청에서 지원을 받을 수 있는 경우 해당 지자체 교복·입학 <지원금 상한액의 차액> 내에서 지원하며 해당 교육청 지원 우선 신청 원칙, 해당 지원청 배제하고 경기도에 전액 신청 불가 (예시) 서울시 소재 학교 학생 : 입학지원금 상한액 30만원 → 차액 10만원 내에서 지원 (예시', '○ 경기도 대안교육기관 및 타 시·도 중·고등학교 신입생 교복(학칙에 규정된 단체복)지원 - 입학일 기준 시흥시에 주소를 둔 1학년 신입생 - 2025년 기준 최대 40만원 - 학교 소재지 지자체 교육청에서 지원을 받을 수 있는 경우 해당 지자체 교복·입학 <지원금 상한액의 차액> 내에서 지원하며 해당 교육청 지원 우선 신청 원칙, 해당 지원청 배제하고 경기도에 전액 신청 불가 (예시) 서울시 소재 학교 학생 : 입학지원금 상한액 30만원 → 차액 10만원 내에서 지원 (예시) 강원도 소재 학교 학생 : 교복지원금 상한액 33.6만원 → 차액 6.4만원내에서 지원 (예시) 강원도 일반고에서 28만원 받음 → 교복지원금 상한액 33.6만원을 제하여 최대 6.4만원 내 지원 ※ 해당연도 예산 소진 시, 지원 불가', '보조금24(대한민국 공공서비스 정보)', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/401000000112', '2026-09-23', '2026-10-14', 'A');
UPDATE resource SET data_base_date=GREATEST(IFNULL(data_base_date,'1970-01-01'),'2026-09-23'), last_verified_date='2026-10-14', updated_at=NOW() WHERE resource_id=764;
INSERT INTO resource (name, category, service_type, provider_type, org_name, dept_name, phone, support_content, apply_method, apply_url, age_min, age_max, income_uncertain, disability, nationality, uncertain_note, eligibility_raw, source_name, source_url, data_base_date, last_verified_date, status) VALUES ('농기계 구입비 지원', 'JOB', '현물', 'PUB', '시흥시청', '농업정책과', '031-310-6204', '○ 농기계 구입비 지원
 - 정부지원 농업기계 목록집 수록 농기계 구입비 지원
 - 구입비의 35%이내 보조(조정 가능)
 - 상한가 존재  ※ 상한액 : 7백만원(50백만원 미만), 10백만원(50백만원 이상)', '정부24온라인신청||방문신청', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/401000000114', NULL, NULL, NULL, NULL, NULL, '보조금24 수집분(2026) — 대상: ○ 농업경영정보 등록 농업인 - 관내 거주 및 관내 농지 영농 1년이상(직전년도 1월1일 기준) - 최소 경작면적 1,000제곱미터 이상', '○ 농업경영정보 등록 농업인 - 관내 거주 및 관내 농지 영농 1년이상(직전년도 1월1일 기준) - 최소 경작면적 1,000제곱미터 이상', '보조금24(대한민국 공공서비스 정보)', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/401000000114', '2026-09-23', '2026-10-14', 'A');
UPDATE resource SET data_base_date=GREATEST(IFNULL(data_base_date,'1970-01-01'),'2026-08-25'), last_verified_date='2026-10-14', updated_at=NOW() WHERE resource_id=765;
UPDATE resource SET data_base_date=GREATEST(IFNULL(data_base_date,'1970-01-01'),'2026-08-26'), last_verified_date='2026-10-14', updated_at=NOW() WHERE resource_id=315;
INSERT INTO resource (name, category, service_type, provider_type, org_name, dept_name, phone, support_content, apply_method, apply_url, age_min, age_max, income_uncertain, disability, nationality, uncertain_note, eligibility_raw, source_name, source_url, data_base_date, last_verified_date, status) VALUES ('시흥형 기본교통비 지원 확대(시흥패스+(플러스))', 'EDU', '현금', 'PUB', '시흥시청', '대중교통과', '1577-8459, 031-310-2759, 031-310-2756', '경기도 어린이청소년 교통비  지원은 물론, 11~18세 시흥시민은 추가 지원
○ 수도권 대중교통(버스 및 지하철), 공유자전거(똑타 앱) 이용 시 교통비 실 사용액을 분기별 지역화폐로 지급
○ 카드 한장으로 (경기도+시흥시)분기 최대18만원 지급
 - 6~18세 분기 6만원(경기도 지원금)
 - 11~18세 분기 12만원(시흥시 추가지원금)', '기타 온라인신청', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/401000000120', NULL, NULL, NULL, NULL, NULL, '보조금24 수집분(2026) — 대상: 시흥시에 주민등록이 되어있는 6세~18세', '시흥시에 주민등록이 되어있는 6세~18세', '보조금24(대한민국 공공서비스 정보)', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/401000000120', '2026-09-21', '2026-10-14', 'A');
INSERT INTO resource (name, category, service_type, provider_type, org_name, dept_name, phone, support_content, apply_method, apply_url, age_min, age_max, income_uncertain, disability, nationality, uncertain_note, eligibility_raw, source_name, source_url, data_base_date, last_verified_date, status) VALUES ('시흥돌봄SOS센터(누구나돌봄) 돌봄 서비스 지원', 'DAILY', '프로그램', 'PUB', '시흥시청', '통합돌봄과', '031-310-3568, 031-310-3569', '시흥돌봄SOS센터
 ○ 갑작스럽고 일시적인 위기상황 발생 시 돌봄서비스 신속 지원
 ○ 지원내용
  - 8대 돌봄서비스(단기/수가체계): 생활돌봄, 동행돌봄, 주거안전, 식사지원, 일시보호, 재활돌봄, 심리상담, 방문의료(시범운영)
   · 생활돌봄: 돌봄대상자 가정방문을 통한 수발
   · 동행지원: 필수적 외출 활동지원
   · 주거편의: 간단한 수리보수, 청소, 방역, 세탁
   · 식사지원: 기본적 식생활 유지 위한 식사배달
   · 일시보호: 단기시설 입소
   · 재활돌봄: 맞춤형 운동재활
   · 심리상담: 심리상담 제공
   · 방문의료: 진찰, 처방, 질환관리
 ○ 서비스 비용
  - 8대 돌봄서비스(단기/수가체계): 국민기초생활보장수급자, 차상위, 중위소득120%이하, 국가유공자 본인 및 선순위 유족 무료, 그 외 자부담', '정부24온라인신청||기타 온라인신청||방문신청', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/401000000123', NULL, NULL, NULL, NULL, NULL, '보조금24 수집분(2026) — 대상: ○ 이용대상 - 돌봄이 필요한 시흥시민 ※ 그 외 대상자는 시 심의를 통해 지원 ○ 자격기준 - 아래의 세가지 조건에 모두 해당되는 경우 · 혼자 거동하기 어렵거나 독립적인 일상생활 수행이 어려운 경우 · 수발할 수 있는 가족 등이 부재하거나 수발할 수 없는 경우 · 공적 돌봄서비스를 이용하지 않거나, 서비스 이용 중 불가피한 공백이 발생한 경우', '○ 이용대상 - 돌봄이 필요한 시흥시민 ※ 그 외 대상자는 시 심의를 통해 지원 ○ 자격기준 - 아래의 세가지 조건에 모두 해당되는 경우 · 혼자 거동하기 어렵거나 독립적인 일상생활 수행이 어려운 경우 · 수발할 수 있는 가족 등이 부재하거나 수발할 수 없는 경우 · 공적 돌봄서비스를 이용하지 않거나, 서비스 이용 중 불가피한 공백이 발생한 경우', '보조금24(대한민국 공공서비스 정보)', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/401000000123', '2026-09-21', '2026-10-14', 'A');
INSERT INTO resource (name, category, service_type, provider_type, org_name, dept_name, phone, support_content, apply_method, apply_url, age_min, age_max, income_uncertain, disability, nationality, uncertain_note, eligibility_raw, source_name, source_url, data_base_date, last_verified_date, status) VALUES ('출생 미등록 아동 발굴 및 지원 사업', 'CARE', '기타서비스', 'PUB', '시흥시청', '아동돌봄과', '031-310-2704', '○ 시흥아동확인증 발급
○ 가구별 맞춤형 사례관리 지원', '정부24온라인신청||방문신청', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/401000000484', NULL, NULL, NULL, NULL, NULL, '보조금24 수집분(2026) — 대상: ○ 대한민국에서 태어났지만 여타의 사정으로 출생 등록을 하지 못하고, 시흥시에 살고 있는 18세 미만 아동', '○ 대한민국에서 태어났지만 여타의 사정으로 출생 등록을 하지 못하고, 시흥시에 살고 있는 18세 미만 아동', '보조금24(대한민국 공공서비스 정보)', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/401000000484', '2026-08-25', '2026-10-14', 'A');
INSERT INTO resource (name, category, service_type, provider_type, org_name, dept_name, phone, support_content, apply_method, apply_url, age_min, age_max, income_uncertain, disability, nationality, uncertain_note, eligibility_raw, source_name, source_url, data_base_date, last_verified_date, status) VALUES ('시흥시 구직 청년 면접정장 대여사업「면접 흥하시흥」 운영', 'JOB', '기타서비스', 'PUB', '시흥시청', '청년청소년과', '031-310-2520', '1. 신청개요
  ○ 신청기간 : 2026년 2월 중 ~ 12. 31.(예산 소진 시까지)
  ○ 신청자격 : 신청일 현재 주민등록 상 시흥시에 거주 중인 19~39세 청년 구직자
                       [관내 고등학교 졸업생, 관내 대학교 재(휴)학생 및 졸업생 포함)] 
                   
  ○ 신청방법 : 온라인 신청 
  ○ 제출서류  
     - 시흥시 거주 청년 : 신청서(온라인 작성), 개인정보동의서(온라인 작성), 주민등록초본(신청일로부터 30일 이내 발급서류에 한함), 면접증빙서류(회사명, 면접일시와 장소, 담당자 연락처가 기재된 면접일정 알림 문자, 이메일 캡처본, 수험표 사본 등) 업로드
     - 관내 소재 고등학교, 대학교 졸업생 및 재(휴)학생 : 신청서(온라인작성), 개인정보동의서(온라인작성), 졸업증명서 및 재(휴)학증명서(신청일로부터 30일이내 발급서류에 한함) 및 면접증빙서류(회사명, 면접일시와 장소, 담당자 연락처 기재된 면접일정 알림 문자 혹은 이메일 캡처본, 수험표 사본 등) 업로드

 2. 서비스 이용절차
  ○ 서비스 이용 신청
     - 일자리지원사업 통합접수시스템 접속 후(https://apply.jobaba.net) 본인인증 및 신청서 작성, 개인정보 동의 후 제출서류 업로드
  ○ 신청 승인(시흥시 청년청소년과 청년창업팀)
     - 자격요건 확인 후 승인 통보 
  ○ 업체방문 및 정장 대여·반납
     - 이용자 업체 방문 예약
     - 대여업체 방문대여(신분증 지참) : 첫 대여 시 방문 필수(치수 측정 등)
     - 대여기간(4박5일) 내 반납 : 방문 또는 택배 
        ※ 반납 택배비만 무료(대여 시 택배비는 자부담)

3. 대여품목 등
  ○ 대여물품(면접정장)
     - 남자 : 재킷, 바지, 셔츠, 구두, 넥타이, 벨트 등
     - 여자 : 재킷, 스커트(바지), 블라우스, 구두 등
  ○ 기간/횟수: 4박5일, 1인 연 3회 한정', '기타 온라인신청', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/401000000485', NULL, NULL, NULL, NULL, NULL, '보조금24 수집분(2026) — 대상: 신청일 현재 주민등록 상 시흥시에 거주 중인 19~39세 청년 구직자 [관내 고등학교 졸업생, 관내 대학교 재(휴)학생 및 졸업생 포함]', '신청일 현재 주민등록 상 시흥시에 거주 중인 19~39세 청년 구직자 [관내 고등학교 졸업생, 관내 대학교 재(휴)학생 및 졸업생 포함]', '보조금24(대한민국 공공서비스 정보)', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/401000000485', '2026-10-01', '2026-10-14', 'A');
INSERT INTO resource (name, category, service_type, provider_type, org_name, dept_name, phone, support_content, apply_method, apply_url, age_min, age_max, income_uncertain, disability, nationality, uncertain_note, eligibility_raw, source_name, source_url, data_base_date, last_verified_date, status) VALUES ('시흥시 시민안전보험', 'DAILY', '현금', 'PUB', '시흥시청', '시민안전과', '1644-9666', '※ 만 15세 미만의 경우 사망담보 제외(상법 제732조 의거)
- 시흥시민이 자연재해(일사병, 열사병 포함)로 인해 사망한 경우 1,000만원
- 시흥시민이 폭발, 화재, 붕괴, 산사태 사고로 상해 사망한 경우 1,000만원
- 시흥시민이 폭발, 화재, 붕괴, 산사태 사고로 3~100%의 상해 후유장해가 발생한 경우 1,000만원 한도
- 시흥시민이 대중교통 이용중 상해 사망한 경우 1,000만원
- 시흥시민이 대중교통 이용 중 3~100%의 상해 후유장해가 발생한 경우 1,000만원 한도
- 시흥시민이 상해로 화상을 입고 병원 또는 의원 등에서 수술을 받은 경우 50만원
- 시흥시민이 가스사고로 발생한 상해의 직접결과로써 사망한 경우 1,000만원
- 시흥시민이 가스사고로 발생한 상해의 직접결과로써 3~100%의 상해 후유장해가 발생한 경우 1,000만원 한도
- 시흥시민이 강도에 의해 발생한 사고로 직접 적인 결과 사망한 경우 1,000만원
- 시흥시민이 강도에 의해 발생한 사고로 직접 적인 결과 3~100%의 상해후유장해가 발생한 경우 1,000만원 한도
- 시흥시민이 재난 및 안전관리 기본법 시행규칙 제5조에서 정한 사회재난의 직접적인 결과로 사망한 경우 1,000만원 한도
- 시흥시민이 물놀이사고로 사망한 경우 300만원
- 만 12세 이하 시흥시민이 보험기간 중에 어린이보호구역으로 지정 한 지역에서 교통사고로 상해를 입은 경우(부상등급 1~14급) 1,000만원 한도', '직접입력', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/401000000487', NULL, NULL, NULL, NULL, NULL, '보조금24 수집분(2026) — 대상: 시흥시에 주민등록을 둔 모든 시민(등록외국인 포함)', '시흥시에 주민등록을 둔 모든 시민(등록외국인 포함)', '보조금24(대한민국 공공서비스 정보)', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/401000000487', '2026-07-29', '2026-10-14', 'A');
UPDATE resource SET data_base_date=GREATEST(IFNULL(data_base_date,'1970-01-01'),'2026-09-23'), last_verified_date='2026-10-14', updated_at=NOW() WHERE resource_id=766;
INSERT INTO resource (name, category, service_type, provider_type, org_name, dept_name, phone, support_content, apply_method, apply_url, age_min, age_max, income_uncertain, disability, nationality, uncertain_note, eligibility_raw, source_name, source_url, data_base_date, last_verified_date, status) VALUES ('유축기 대여 서비스', 'HEALTH', '현물', 'PUB', '시흥시청', '보건정책과', '031-310-5887, 031-310-5941, 031-310-0714', '○ 대상: 관내 출산가정
  - 부부 중 한 명만 시흥시민이어도 대여 가능(혼인관계 확인 필요)
○ 대여 기간: 2개월(연장불가)
○ 대여 모델 : 스펙트라 S2+
  - 본품 및 어댑터만 대여
  - 소모품(깔때기, 호스 등)은 직접 구매', '방문신청||직접입력', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/401000000493', NULL, NULL, NULL, NULL, NULL, '보조금24 수집분(2026) — 대상: ○ 대상: 관내 출산가정 - 부부 중 한 명만 시흥시민이어도 대여 가능(혼인관계 확인 필요)', '○ 대상: 관내 출산가정 - 부부 중 한 명만 시흥시민이어도 대여 가능(혼인관계 확인 필요)', '보조금24(대한민국 공공서비스 정보)', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/401000000493', '2026-09-21', '2026-10-14', 'A');
UPDATE resource SET data_base_date=GREATEST(IFNULL(data_base_date,'1970-01-01'),'2026-08-25'), last_verified_date='2026-10-14', updated_at=NOW() WHERE resource_id=747;
INSERT INTO resource (name, category, service_type, provider_type, org_name, dept_name, phone, support_content, apply_method, apply_url, age_min, age_max, income_uncertain, disability, nationality, uncertain_note, eligibility_raw, source_name, source_url, data_base_date, last_verified_date, status) VALUES ('소규모 점포 경영개선 지원', 'DAILY', '현금', 'PUB', '시흥시청', '소상공인과', '070-4122-9590, 031-310-2609', '간판, 인테리어 등 점포 시설개선 최대 300만원 지원(자부담 10% 이상)', '기타 온라인신청||방문신청', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/401000000496', NULL, NULL, NULL, NULL, NULL, '보조금24 수집분(2026) — 대상: 관내 6개월 이상 영업 중인 소상인', '관내 6개월 이상 영업 중인 소상인', '보조금24(대한민국 공공서비스 정보)', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/401000000496', '2026-09-25', '2026-10-14', 'A');
INSERT INTO resource (name, category, service_type, provider_type, org_name, dept_name, phone, support_content, apply_method, apply_url, age_min, age_max, income_uncertain, disability, nationality, uncertain_note, eligibility_raw, source_name, source_url, data_base_date, last_verified_date, status) VALUES ('시흥맞춤 명품점포 지원', 'DAILY', '현금', 'PUB', '시흥시청', '소상공인과', '031-310-2609', '○ 간판, 인테리어 등 점포 시설개선 최대 300만원 지원(자부담 10% 이상)
○ 시흥맞춤 명품점포 인증현판 제작 및 수여', '방문신청', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/401000000497', NULL, NULL, NULL, NULL, NULL, '보조금24 수집분(2026) — 대상: 시루 가맹점이면서 관내 5년 이상 영업 중인 모범 소상공인', '시루 가맹점이면서 관내 5년 이상 영업 중인 모범 소상공인', '보조금24(대한민국 공공서비스 정보)', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/401000000497', '2026-09-25', '2026-10-14', 'A');
INSERT INTO resource (name, category, service_type, provider_type, org_name, dept_name, phone, support_content, apply_method, apply_url, age_min, age_max, income_uncertain, disability, nationality, uncertain_note, eligibility_raw, source_name, source_url, data_base_date, last_verified_date, status) VALUES ('동네관리소 간단 집수리 지원', 'HOUSE', '현물', 'PUB', '시흥시청', '주민자치과', '031-411-0999, 070-8821-8004, 031-311-8209, 031-310-4508, 070-4044-7355, 031-311-4778, 031-311-0633, 031-312-5254', '가정내 경보수 지원', '방문신청||직접입력', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/401000000498', 65, NULL, 'Y', NULL, NULL, '보조금24 수집분(2026) — 대상: 무료 : 국민기초 생활수급자, 독거노인(만65세이상), 차상위계층(한부모포함), 긴급지원, 무한돌봄, 재난적의료대상자 등 유료 : 장애인(3만원 초과 자부담)', '무료 : 국민기초 생활수급자, 독거노인(만65세이상), 차상위계층(한부모포함), 긴급지원, 무한돌봄, 재난적의료대상자 등 유료 : 장애인(3만원 초과 자부담)', '보조금24(대한민국 공공서비스 정보)', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/401000000498', '2026-09-21', '2026-10-14', 'A');
INSERT INTO resource (name, category, service_type, provider_type, org_name, dept_name, phone, support_content, apply_method, apply_url, age_min, age_max, income_uncertain, disability, nationality, uncertain_note, eligibility_raw, source_name, source_url, data_base_date, last_verified_date, status) VALUES ('동네관리소 공구 대여 지원', 'DAILY', '현물', 'PUB', '시흥시청', '주민자치과', '031-411-0999, 070-8821-8004, 031-311-8209, 031-310-4508, 070-4044-7355, 031-311-4778, 031-311-0633, 031-312-5254', '일상 생활에 필요한 공구 무료 대여', '직접입력', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/401000000499', NULL, NULL, NULL, NULL, NULL, '보조금24 수집분(2026) — 대상: 시흥시민 누구나', '시흥시민 누구나', '보조금24(대한민국 공공서비스 정보)', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/401000000499', '2026-09-21', '2026-10-14', 'A');
INSERT INTO resource (name, category, service_type, provider_type, org_name, dept_name, phone, support_content, apply_method, apply_url, age_min, age_max, income_uncertain, disability, nationality, uncertain_note, eligibility_raw, source_name, source_url, data_base_date, last_verified_date, status) VALUES ('시흥시 소상공인 특례보증 및 이차보전 지원', 'DAILY', '현금', 'PUB', '시흥시청', '소상공인과', '031-310-2609', '○ 일반 소상공인 특례보증
  - 특례보증 최대 5천만원 지원
  - 이차보전 1년차 2%, 2~5년차 1% 지원
○ 화재피해 소상공인 특례보증
  - 특례보증 최대 1억원 지원
  - 이차보전 5년간 2% 지원
○ 공통사항
  - 보증기간 5년(1년 거치, 4년 균등 분할상환) 또는 5년 이내', '방문신청', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/401000000500', NULL, NULL, NULL, NULL, NULL, '보조금24 수집분(2026) — 대상: ○ 일반 소상공인 특례보증 : 관내 2개월 이상 운영 중인 소상공인 ○ 화재피해 소상공인 특례보증 : 관내 2개월 이상 운영하였다가 화재증명원 기준 영업장 전체 면적의 1/3이상 화재로 소실되어 조업을 중단하였으나 영업재개를 위한 실질적 절차를 착수한 소상공인', '○ 일반 소상공인 특례보증 : 관내 2개월 이상 운영 중인 소상공인 ○ 화재피해 소상공인 특례보증 : 관내 2개월 이상 운영하였다가 화재증명원 기준 영업장 전체 면적의 1/3이상 화재로 소실되어 조업을 중단하였으나 영업재개를 위한 실질적 절차를 착수한 소상공인', '보조금24(대한민국 공공서비스 정보)', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/401000000500', '2026-09-23', '2026-10-14', 'A');
INSERT INTO resource (name, category, service_type, provider_type, org_name, dept_name, phone, support_content, apply_method, apply_url, age_min, age_max, income_uncertain, disability, nationality, uncertain_note, eligibility_raw, source_name, source_url, data_base_date, last_verified_date, status) VALUES ('1~3호 숨쉬는놀이터(대야동, 정왕동, 하중동) 운영 지원', 'CULTURE', '기타서비스', 'PUB', '시흥시청', '아동돌봄과', '031-310-2736', '권역별 공공형 실내 놀이터(1~3호 숨쉬는놀이터, 대야동/정왕동/하중동)', '기타 온라인신청||직접입력', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/401000000502', NULL, NULL, NULL, NULL, NULL, '보조금24 수집분(2026) — 대상: 5~13세 아동 및 부모', '5~13세 아동 및 부모', '보조금24(대한민국 공공서비스 정보)', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/401000000502', '2026-08-25', '2026-10-14', 'A');
UPDATE resource SET data_base_date=GREATEST(IFNULL(data_base_date,'1970-01-01'),'2026-09-21'), last_verified_date='2026-10-14', updated_at=NOW() WHERE resource_id=234;
INSERT INTO resource (name, category, service_type, provider_type, org_name, dept_name, phone, support_content, apply_method, apply_url, age_min, age_max, income_uncertain, disability, nationality, uncertain_note, eligibility_raw, source_name, source_url, data_base_date, last_verified_date, status) VALUES ('재활보조기구 대여 지원', 'HEALTH', '현물', 'PUB', '시흥시청', '건강증진과', '031-310-0729', '휠체어, 워커, 네발지팡이 (2개월간 대여)', '직접입력', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/401000000504', NULL, NULL, NULL, NULL, NULL, '보조금24 수집분(2026) — 대상: 시흥시 거주 주민', '시흥시 거주 주민', '보조금24(대한민국 공공서비스 정보)', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/401000000504', '2026-08-07', '2026-10-14', 'A');
UPDATE resource SET data_base_date=GREATEST(IFNULL(data_base_date,'1970-01-01'),'2026-08-25'), last_verified_date='2026-10-14', updated_at=NOW() WHERE resource_id=761;
INSERT INTO resource (name, category, service_type, provider_type, org_name, dept_name, phone, support_content, apply_method, apply_url, age_min, age_max, income_uncertain, disability, nationality, uncertain_note, eligibility_raw, source_name, source_url, data_base_date, last_verified_date, status) VALUES ('시흥시 관내 대학생 지원금', 'EDU', '기타서비스', 'PUB', '시흥시청', '미래전략담당관', '031-310-3098', '대학생 지원금 20만원(모바일 시루 최초 1회 지급(중복 지급 불가))', '정부24온라인신청', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/401000000507', NULL, NULL, NULL, NULL, NULL, '보조금24 수집분(2026) — 대상: 아래의 조건을 모두 충족하는 자 ① 시흥시 소재 대학교(대학원)에 재학 중인 자(휴학 중인 학생 제외) ②「주민등록법」에 따라 시흥에 3개월 이상 계속 거주하고 있는 자 ③ 시흥시 취·창업 역량 강화 프로그램 수료자 ※ 프로그램 목록(미정)', '아래의 조건을 모두 충족하는 자 ① 시흥시 소재 대학교(대학원)에 재학 중인 자(휴학 중인 학생 제외) ②「주민등록법」에 따라 시흥에 3개월 이상 계속 거주하고 있는 자 ③ 시흥시 취·창업 역량 강화 프로그램 수료자 ※ 프로그램 목록(미정)', '보조금24(대한민국 공공서비스 정보)', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/401000000507', '2026-09-29', '2026-10-14', 'A');
UPDATE resource SET data_base_date=GREATEST(IFNULL(data_base_date,'1970-01-01'),'2026-08-25'), last_verified_date='2026-10-14', updated_at=NOW() WHERE resource_id=748;
INSERT INTO resource (name, category, service_type, provider_type, org_name, dept_name, phone, support_content, apply_method, apply_url, age_min, age_max, income_uncertain, disability, nationality, uncertain_note, eligibility_raw, source_name, source_url, data_base_date, last_verified_date, status) VALUES ('장애인 전동보장구 배상책임보험', 'RIGHTS', '기타서비스', 'PUB', '시흥시청', '장애인복지과', '02-2038-0828', '○ 전동보장구 운행 시 발생한 사고 중 제3자에 대한 피해보상금 지원
 - (사고당 2,000만원 한도 / 자부담 5만원) ※ 본인 피해는 보상 제외', '기타 온라인신청||직접입력', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/401000000509', 65, NULL, NULL, 'Y', NULL, '보조금24 수집분(2026) — 대상: ○ 전동보장구(전동휠체어 및 스쿠터)를 이용하는 관내 등록 장애인 또는 만 65세 이상 어르신', '○ 전동보장구(전동휠체어 및 스쿠터)를 이용하는 관내 등록 장애인 또는 만 65세 이상 어르신', '보조금24(대한민국 공공서비스 정보)', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/401000000509', '2026-08-25', '2026-10-14', 'A');
INSERT INTO resource (name, category, service_type, provider_type, org_name, dept_name, phone, support_content, apply_method, apply_url, age_min, age_max, income_uncertain, disability, nationality, uncertain_note, eligibility_raw, source_name, source_url, data_base_date, last_verified_date, status) VALUES ('종량제 봉투 무료 지원(차상위)', 'DAILY', '현금', 'PUB', '시흥시청', '자원순환과', '031-310-2254', '○ 「시흥시 폐기물 관리 조례」 제23조(수수료의 감면) 제1항 제1호, 제2호에 따라  차상위계층에게 가구당 매월120ℓ이내에서 공급한다. 

○ 1인 가구에 대해서는월60ℓ 범위 내에서 지급한다.', '정부24온라인신청||방문신청', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/401000000510', NULL, NULL, 'Y', NULL, NULL, '보조금24 수집분(2026) — 대상: 차상위계층 따른 지원대상자', '차상위계층 따른 지원대상자', '보조금24(대한민국 공공서비스 정보)', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/401000000510', '2026-09-22', '2026-10-14', 'A');
INSERT INTO resource (name, category, service_type, provider_type, org_name, dept_name, phone, support_content, apply_method, apply_url, age_min, age_max, income_uncertain, disability, nationality, uncertain_note, eligibility_raw, source_name, source_url, data_base_date, last_verified_date, status) VALUES ('종량제 봉투 무료 지원(한부모)', 'DAILY', '현금', 'PUB', '시흥시청', '자원순환과', '031-310-2254', '○ 「시흥시 폐기물 관리 조례」 제23조(수수료의 감면) 제1항 제1호, 제2호에 따라「한부모가족지원법」에 따른 지원대상자에게 가구당 매월120ℓ이내에서 공급한다. 

○ 1인 가구에 대해서는월60ℓ 범위 내에서 지급한다.', '정부24온라인신청||방문신청', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/401000000511', NULL, NULL, NULL, NULL, NULL, '보조금24 수집분(2026) — 대상: 한부모가족지원법에 따른 지원대상자', '한부모가족지원법에 따른 지원대상자', '보조금24(대한민국 공공서비스 정보)', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/401000000511', '2026-09-22', '2026-10-14', 'A');
UPDATE resource SET data_base_date=GREATEST(IFNULL(data_base_date,'1970-01-01'),'2026-09-21'), last_verified_date='2026-10-14', updated_at=NOW() WHERE resource_id=768;
INSERT INTO resource (name, category, service_type, provider_type, org_name, dept_name, phone, support_content, apply_method, apply_url, age_min, age_max, income_uncertain, disability, nationality, uncertain_note, eligibility_raw, source_name, source_url, data_base_date, last_verified_date, status) VALUES ('시흥시 초·중·고 입학준비금 지원', 'EDU', '기타서비스', 'PUB', '시흥시청', '교육자치과', '031-310-3494', '○ 지원금액 : 초·중·고등학교 1학년에 입학하는 신입생 1인당 100,000원
○ 지급방법 : 시흥 지역화폐 \'시루\' 정책포인트 지급
  ※ 지역상품권 chak(시루 앱) 회원가입(지역선택 ‘시흥시’) 필수
○ 신청기간 : 2026. 3. 3.(화) ~ 10. 30.(금)
○ 신청자격: 지원대상자(학생)의 보호자(부모, 후견인 등)
○ 사용기간 및 사용처
   - 사용기간 : 2026. 11. 30.(월)까지
   - 사 용 처 : 체육복, 각종 학원, 독서실, 문구용품점, 서적, 문구, 학습용 태블릿 등
    ※ 사용 제한 업종 : 병원, 약국, 음식점, 레저, 숙박 등
○ 문의 : 시흥시 교육자치과(☎031-310-3497)', '정부24온라인신청||직접입력', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/401000000513', NULL, NULL, NULL, NULL, NULL, '보조금24 수집분(2026) — 대상: 입학일 기준 시흥시에 주민등록(외국인은 체류지 등록)이 되어있는 2026년 초·중·고등학교 1학년에 입학하는 신입생 ※ 초·중등교육법 제2조에 따른 학교 및 등록 대안교육기관 신입생 포함 ※ 입학일 이후 전입 신입생 불가', '입학일 기준 시흥시에 주민등록(외국인은 체류지 등록)이 되어있는 2026년 초·중·고등학교 1학년에 입학하는 신입생 ※ 초·중등교육법 제2조에 따른 학교 및 등록 대안교육기관 신입생 포함 ※ 입학일 이후 전입 신입생 불가', '보조금24(대한민국 공공서비스 정보)', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/401000000513', '2026-09-21', '2026-10-14', 'A');
UPDATE resource SET data_base_date=GREATEST(IFNULL(data_base_date,'1970-01-01'),'2026-09-21'), last_verified_date='2026-10-14', updated_at=NOW() WHERE resource_id=67;
INSERT INTO resource (name, category, service_type, provider_type, org_name, dept_name, phone, support_content, apply_method, apply_url, age_min, age_max, income_uncertain, disability, nationality, uncertain_note, eligibility_raw, source_name, source_url, data_base_date, last_verified_date, status) VALUES ('종량제 봉투 무료 지원(수급자)', 'DAILY', '현금', 'PUB', '시흥시청', '자원순환과', '031-310-2254', '○ 「시흥시 폐기물 관리 조례」 제23조(수수료의 감면) 제1항 제1호, 제2호에 따라 「국민기초생활보장법」에 따른 생계·의료·주거·교육급여 수급자 에게 가구당 매월120ℓ이내에서 공급한다. 

○ 1인 가구에 대해서는월60ℓ 범위 내에서 지급한다.', '정부24온라인신청||방문신청', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/O00007100004', NULL, NULL, 'Y', NULL, NULL, '보조금24 수집분(2026) — 대상: 생계·의료·주거·교육급여 수급자에 따른 지원대상자', '생계·의료·주거·교육급여 수급자에 따른 지원대상자', '보조금24(대한민국 공공서비스 정보)', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/O00007100004', '2026-09-22', '2026-10-14', 'A');
INSERT INTO resource (name, category, service_type, provider_type, org_name, dept_name, phone, support_content, apply_method, apply_url, age_min, age_max, income_uncertain, disability, nationality, uncertain_note, eligibility_raw, source_name, source_url, data_base_date, last_verified_date, status) VALUES ('상하수도요금 감면', 'DAILY', '현금', 'PUB', '시흥시청', '수도행정과', '031-310-6114', '○ 가정용 상하수도요금 감면(최대 월10톤에 해당하는 요금)
  - 「국민기초생활 보장법」에 따른 생계급여수급자
  - 「장애인복지법」에 따른 장애의 정도가 심한 장애인
  - 「시흥시 다자녀가정 우대 및 지원에 관한 조례」 제2조제2호에 따른 다자녀가정', '방문신청', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/O00007300001', NULL, NULL, 'Y', NULL, NULL, '보조금24 수집분(2026) — 대상: ○ 「국민기초생활 보장법」에 따른 생계급여 수급자 ○ 「장애인복지법」에 따른 장애의 정도가 심한 장애인 ○ 「시흥시다자녀우대및지원에관한조례」에 따른 다자녀가정', '○ 「국민기초생활 보장법」에 따른 생계급여 수급자 ○ 「장애인복지법」에 따른 장애의 정도가 심한 장애인 ○ 「시흥시다자녀우대및지원에관한조례」에 따른 다자녀가정', '보조금24(대한민국 공공서비스 정보)', 'https://www.gov.kr/portal/rcvfvrSvc/dtlEx/O00007300001', '2026-09-22', '2026-10-14', 'A');
