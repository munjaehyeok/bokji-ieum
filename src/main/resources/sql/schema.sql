-- =====================================================================
-- 복지이음 schema.sql — 설계/02-데이터베이스-설계.md 기준
-- 전 테이블 utf8mb4, 재실행 가능(DROP TABLE IF EXISTS)
-- resource 는 §3.5 원본 22열 매핑의 추가 컬럼 포함:
--   sub_category, service_type, eligibility_raw, decision_period,
--   service_cycle, applicant, cost_flag, cost_amount
-- 테이블명은 전부 소문자(설계 02 표기 확정, 2026-10-13). ADMIN은 예약어 회피로 admin_user.
-- =====================================================================
SET NAMES utf8mb4;

DROP TABLE IF EXISTS favorite;
DROP TABLE IF EXISTS member;
DROP TABLE IF EXISTS news;
DROP TABLE IF EXISTS event_log;
DROP TABLE IF EXISTS match_log;
DROP TABLE IF EXISTS resource_history;
DROP TABLE IF EXISTS report;
DROP TABLE IF EXISTS admin_user;
DROP TABLE IF EXISTS resource_i18n;
DROP TABLE IF EXISTS resource;

-- ---------------------------------------------------------------
-- resource — 복지자원 (핵심, 744건)
-- ---------------------------------------------------------------
CREATE TABLE resource (
    resource_id      INT AUTO_INCREMENT PRIMARY KEY,
    name             VARCHAR(200) NOT NULL COMMENT '자원명(원본 6열 서비스명)',
    category         VARCHAR(20)  NOT NULL COMMENT 'JOB/HOUSE/DAILY/HEALTH/MIND/CARE/EDU/CULTURE/RIGHTS',
    sub_category     VARCHAR(100) NULL     COMMENT '원본 4열 중분류(51종)',
    service_type     VARCHAR(20)  NULL     COMMENT '원본 5열: 현금/현물/바우처/프로그램/기타서비스 등 (필터용)',
    provider_type    CHAR(3)      NOT NULL COMMENT 'PUB(공공)/PRV(민간)',
    org_name         VARCHAR(100) NOT NULL COMMENT '제공 기관명(원본 12열)',
    dept_name        VARCHAR(100) NULL     COMMENT '담당 부서(원본 22열)',
    phone            VARCHAR(150) NULL     COMMENT '연락처(하이픈 포함, 복수 병기 가능)',
    address          VARCHAR(200) NULL     COMMENT '기관 주소',
    support_content  TEXT         NOT NULL COMMENT '지원 내용(원본 7열)',
    apply_method     TEXT         NULL     COMMENT '신청 방법(NULL이면 화면에 담당기관 문의)',
    documents        TEXT         NULL     COMMENT '준비 서류(NULL이면 담당기관 문의)',
    apply_url        VARCHAR(300) NULL     COMMENT '온라인 신청/안내 URL',
    -- ---- 자격조건 태깅 7필드 (NULL = 해당 조건 무관) ----
    age_min          SMALLINT     NULL,
    age_max          SMALLINT     NULL,
    dong_codes       VARCHAR(200) NULL     COMMENT '행정동 코드 CSV, NULL=시 전체',
    household_types  VARCHAR(100) NULL     COMMENT 'ONE/SPAR/MCHD/MCUL/NKOR/PREG CSV',
    income_rank      TINYINT      NULL     COMMENT '1=수급만 2=차상위까지 3=중위100까지 4=중위150까지',
    income_uncertain CHAR(1)      NULL     COMMENT 'Y=세부 소득기준 존재, 일치여도 확인 필요 병기',
    disability       CHAR(1)      NULL     COMMENT 'Y=장애인 대상',
    nationality      CHAR(1)      NULL     COMMENT 'F=외국인 대상/전용, K=주민등록 내국인 한정',
    edu_work         VARCHAR(50)  NULL     COMMENT 'STU/UNIV/SEEK/WORK CSV',
    uncertain_note   VARCHAR(300) NULL     COMMENT '구조화 못 한 서술형 조건 요약 → 항상 확인 필요로 노출',
    -- ---- 원문 보존·상세 표시 (§3.5 추가 컬럼) ----
    eligibility_raw  TEXT         NULL     COMMENT '원본 9열(지원 기준) 원문 그대로',
    decision_period  VARCHAR(200) NULL     COMMENT '원본 10열 선정 소요기간',
    service_cycle    VARCHAR(200) NULL     COMMENT '원본 11열 제공시기(상시/일시 등)',
    applicant        VARCHAR(200) NULL     COMMENT '원본 16열 신청권자',
    cost_flag        CHAR(1)      NULL     COMMENT 'X=무료, O=본인부담, NULL=미기재',
    cost_amount      TEXT         NULL     COMMENT '본인부담금 금액/설명(원본 20열)',
    -- ---- 출처·관리 ----
    source_name      VARCHAR(100) NOT NULL DEFAULT '시흥시 복지자원 종합안내서',
    source_url       VARCHAR(300) NULL,
    data_base_date   DATE         NOT NULL COMMENT '자료 기준일(12개월 경과 시 확인 필요 뱃지)',
    last_verified_date DATE       NULL,
    status           CHAR(1)      NOT NULL DEFAULT 'A' COMMENT 'A=노출 H=숨김 E=종료(물리 삭제 금지)',
    created_at       DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at       DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_status_category (status, category)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------
-- resource_i18n — 다국어 (외국인 대상 자원 우선 번역, en/zh/vi)
-- ---------------------------------------------------------------
CREATE TABLE resource_i18n (
    resource_id INT          NOT NULL,
    lang        CHAR(2)      NOT NULL,
    name_tr     VARCHAR(200) NOT NULL,
    summary_tr  VARCHAR(500) NULL,
    PRIMARY KEY (resource_id, lang),
    CONSTRAINT fk_i18n_resource FOREIGN KEY (resource_id) REFERENCES resource (resource_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------
-- admin_user — 관리자 (초기 계정은 백엔드가 초기화)
-- ---------------------------------------------------------------
CREATE TABLE admin_user (
    admin_id   INT AUTO_INCREMENT PRIMARY KEY,
    login_id   VARCHAR(50) NOT NULL UNIQUE,
    pw_hash    CHAR(60)    NOT NULL COMMENT 'BCrypt',
    name       VARCHAR(50) NOT NULL,
    created_at DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------
-- report — 오류 제보
-- ---------------------------------------------------------------
CREATE TABLE report (
    report_id    INT AUTO_INCREMENT PRIMARY KEY,
    resource_id  INT          NOT NULL,
    content      VARCHAR(500) NOT NULL,
    status       CHAR(1)      NOT NULL DEFAULT 'R' COMMENT 'R접수/C확인/D반영/X반려',
    admin_memo   VARCHAR(500) NULL,
    created_at   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    processed_at DATETIME     NULL,
    CONSTRAINT fk_report_resource FOREIGN KEY (resource_id) REFERENCES resource (resource_id),
    INDEX idx_report_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------
-- resource_history — 변경 이력 (변경 전후 요약 텍스트)
-- ---------------------------------------------------------------
CREATE TABLE resource_history (
    history_id      INT AUTO_INCREMENT PRIMARY KEY,
    resource_id     INT          NOT NULL,
    admin_id        INT          NOT NULL,
    action          CHAR(1)      NOT NULL COMMENT 'C등록/U수정/H숨김/E종료',
    changed_summary VARCHAR(500) NULL,
    created_at      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_history_resource (resource_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------
-- match_log / event_log — 익명 로그 (FK 없음, 집계 전용)
-- ---------------------------------------------------------------
CREATE TABLE match_log (
    log_id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    session_hash    CHAR(32)     NOT NULL,
    age_band        VARCHAR(10)  NULL COMMENT '예: 60s',
    dong            VARCHAR(10)  NULL,
    household_types VARCHAR(100) NULL,
    income_rank     TINYINT      NULL,
    disability      CHAR(1)      NULL,
    nationality     CHAR(1)      NULL,
    edu_work        VARCHAR(50)  NULL,
    result_count    INT          NOT NULL,
    created_at      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_matchlog_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE event_log (
    log_id       BIGINT AUTO_INCREMENT PRIMARY KEY,
    session_hash CHAR(32) NOT NULL,
    event        CHAR(1)  NOT NULL COMMENT 'M매칭/D상세조회/A신청안내확인/R제보',
    resource_id  INT      NULL,
    created_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_eventlog_event (event, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------
-- member / favorite (선택) · news (권장)
-- ---------------------------------------------------------------
CREATE TABLE member (
    member_id  INT AUTO_INCREMENT PRIMARY KEY,
    email      VARCHAR(100) NOT NULL UNIQUE,
    pw_hash    CHAR(60)     NOT NULL,
    lang       CHAR(2)      NOT NULL DEFAULT 'ko',
    created_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE favorite (
    member_id   INT      NOT NULL,
    resource_id INT      NOT NULL,
    created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (member_id, resource_id),
    CONSTRAINT fk_fav_member   FOREIGN KEY (member_id)   REFERENCES member (member_id),
    CONSTRAINT fk_fav_resource FOREIGN KEY (resource_id) REFERENCES resource (resource_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE news (
    news_id      INT AUTO_INCREMENT PRIMARY KEY,
    title        VARCHAR(300) NOT NULL,
    url          VARCHAR(500) NOT NULL,
    source       VARCHAR(100) NULL,
    keyword      VARCHAR(100) NULL,
    published_at DATETIME     NULL,
    collected_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_news_url (url(255))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
