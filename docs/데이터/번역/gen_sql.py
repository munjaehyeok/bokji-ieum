import json,glob,os,sys,hashlib
LANGS=['en','zh','vi']
def esc(s): return s.replace('\\','\\\\').replace("'","\\'").replace('\r','').replace('\n','\\n')
src={};tr={}
for bf in sorted(glob.glob('batch/*.json')):
    n=os.path.basename(bf); rf='result/'+n
    if not os.path.exists(rf): continue
    try: res=json.load(open(rf))
    except Exception: continue
    items=json.load(open(bf))
    if not all(x['h'] in res and all(res[x['h']].get(l,'').strip() for l in LANGS) for x in items): continue
    for x in items: src[x['h']]=x['src']; tr[x['h']]=res[x['h']]
out=[]
w=out.append
w("""-- content-i18n-20261125.sql : DB 본문(사업명·기관·지원내용 등) 영/중/베 번역 적재 (멱등)
-- 적재 순서: schema → seed → api-update → facility-refresh → gov24-update → 이 파일
-- 원리: 한국어 원문 TRIM 후 SHA-256 을 키로 하는 번역 사전(content_i18n)을 만들고,
--       resource 각 필드의 SHA2 로 사전을 찾아 resource_i18n 의 *_tr 컬럼을 채운다.
--       번역이 없으면 *_tr 은 NULL → 화면이 한국어 원문으로 폴백. 재실행해도 결과 동일.
SET NAMES utf8mb4;

-- 1) 기존 DB 마이그레이션: resource_i18n 컬럼 확장 (신규 DB 는 schema.sql 이 이미 포함, 이미 있으면 건너뜀)
DROP PROCEDURE IF EXISTS bk_add_col;
DELIMITER //
CREATE PROCEDURE bk_add_col(IN col VARCHAR(64), IN def VARCHAR(100))
BEGIN
  DECLARE c INT;
  SELECT COUNT(*) INTO c FROM information_schema.columns
   WHERE table_schema = DATABASE() AND table_name = 'resource_i18n' AND column_name = col;
  IF c = 0 THEN
    SET @bk_sql = CONCAT('ALTER TABLE resource_i18n ADD COLUMN ', col, ' ', def);
    PREPARE bk_st FROM @bk_sql; EXECUTE bk_st; DEALLOCATE PREPARE bk_st;
  END IF;
END//
DELIMITER ;
CALL bk_add_col('org_name_tr', 'VARCHAR(300) NULL');
CALL bk_add_col('dept_name_tr', 'VARCHAR(300) NULL');
CALL bk_add_col('address_tr', 'VARCHAR(500) NULL');
CALL bk_add_col('apply_method_tr', 'TEXT NULL');
CALL bk_add_col('documents_tr', 'TEXT NULL');
CALL bk_add_col('eligibility_tr', 'TEXT NULL');
CALL bk_add_col('cost_amount_tr', 'TEXT NULL');
CALL bk_add_col('uncertain_note_tr', 'TEXT NULL');
CALL bk_add_col('applicant_tr', 'VARCHAR(500) NULL');
CALL bk_add_col('service_cycle_tr', 'VARCHAR(300) NULL');
CALL bk_add_col('decision_period_tr', 'VARCHAR(300) NULL');
CALL bk_add_col('phone_tr', 'VARCHAR(300) NULL');
DROP PROCEDURE bk_add_col;
-- 번역명은 한국어보다 길어질 수 있어 넓힌다 (멱등)
ALTER TABLE resource_i18n MODIFY name_tr VARCHAR(500) NOT NULL, MODIFY summary_tr TEXT NULL;

-- 2) 번역 사전 (파생 테이블이라 매번 새로 만든다. MySQL 9.6+ 는 MD5() 가 없어 SHA2 를 쓴다)
DROP TABLE IF EXISTS content_i18n;
CREATE TABLE content_i18n (
    src_hash CHAR(64)   NOT NULL COMMENT 'SHA2(TRIM(한국어 원문), 256)',
    lang     CHAR(2)    NOT NULL,
    text_tr  MEDIUMTEXT NOT NULL,
    PRIMARY KEY (src_hash, lang)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
""")
rows=[(hashlib.sha256(src[h].strip().encode()).hexdigest(),l,tr[h][l]) for h in sorted(tr) for l in LANGS]
for i in range(0,len(rows),100):
    part=rows[i:i+100]
    w("INSERT INTO content_i18n (src_hash, lang, text_tr) VALUES\n"+",\n".join(f"('{h}','{l}','{esc(t.strip())}')" for h,l,t in part)+"\nON DUPLICATE KEY UPDATE text_tr = VALUES(text_tr);\n")
w("""
-- 3) resource_i18n 채우기 (이름 번역이 있는 자원만 행 생성. 기존 수기 번역 name_tr/summary_tr 은 보존)
INSERT INTO resource_i18n (resource_id, lang, name_tr, summary_tr, org_name_tr, dept_name_tr, address_tr,
                           apply_method_tr, applicant_tr, service_cycle_tr, decision_period_tr, phone_tr,
                           documents_tr, eligibility_tr, cost_amount_tr, uncertain_note_tr)
SELECT * FROM (
SELECT r.resource_id, l.lang, nm.text_tr AS name_tr, sc.text_tr AS summary_tr, og.text_tr AS org_name_tr,
       dp.text_tr AS dept_name_tr, ad.text_tr AS address_tr, am.text_tr AS apply_method_tr,
       ap.text_tr AS applicant_tr, cy.text_tr AS service_cycle_tr, dpd.text_tr AS decision_period_tr, ph.text_tr AS phone_tr,
       dc.text_tr AS documents_tr, el.text_tr AS eligibility_tr, ca.text_tr AS cost_amount_tr, un.text_tr AS uncertain_note_tr
FROM resource r
JOIN (SELECT 'en' AS lang UNION ALL SELECT 'zh' UNION ALL SELECT 'vi') l
JOIN content_i18n nm ON nm.lang = l.lang AND nm.src_hash = SHA2(TRIM(r.name), 256)
LEFT JOIN content_i18n sc ON sc.lang = l.lang AND sc.src_hash = SHA2(TRIM(r.support_content), 256)
LEFT JOIN content_i18n og ON og.lang = l.lang AND og.src_hash = SHA2(TRIM(r.org_name), 256)
LEFT JOIN content_i18n dp ON dp.lang = l.lang AND dp.src_hash = SHA2(TRIM(r.dept_name), 256)
LEFT JOIN content_i18n ad ON ad.lang = l.lang AND ad.src_hash = SHA2(TRIM(r.address), 256)
LEFT JOIN content_i18n am ON am.lang = l.lang AND am.src_hash = SHA2(TRIM(r.apply_method), 256)
LEFT JOIN content_i18n ap ON ap.lang = l.lang AND ap.src_hash = SHA2(TRIM(r.applicant), 256)
LEFT JOIN content_i18n cy ON cy.lang = l.lang AND cy.src_hash = SHA2(TRIM(r.service_cycle), 256)
LEFT JOIN content_i18n dpd ON dpd.lang = l.lang AND dpd.src_hash = SHA2(TRIM(r.decision_period), 256)
LEFT JOIN content_i18n ph ON ph.lang = l.lang AND ph.src_hash = SHA2(TRIM(r.phone), 256)
LEFT JOIN content_i18n dc ON dc.lang = l.lang AND dc.src_hash = SHA2(TRIM(r.documents), 256)
LEFT JOIN content_i18n el ON el.lang = l.lang AND el.src_hash = SHA2(TRIM(r.eligibility_raw), 256)
LEFT JOIN content_i18n ca ON ca.lang = l.lang AND ca.src_hash = SHA2(TRIM(r.cost_amount), 256)
LEFT JOIN content_i18n un ON un.lang = l.lang AND un.src_hash = SHA2(TRIM(r.uncertain_note), 256)
) AS src
ON DUPLICATE KEY UPDATE
    name_tr = COALESCE(resource_i18n.name_tr, VALUES(name_tr)),
    summary_tr = COALESCE(resource_i18n.summary_tr, VALUES(summary_tr)),
    org_name_tr = VALUES(org_name_tr), dept_name_tr = VALUES(dept_name_tr), address_tr = VALUES(address_tr),
    apply_method_tr = VALUES(apply_method_tr), applicant_tr = VALUES(applicant_tr),
    service_cycle_tr = VALUES(service_cycle_tr), decision_period_tr = VALUES(decision_period_tr), phone_tr = VALUES(phone_tr), documents_tr = VALUES(documents_tr),
    eligibility_tr = VALUES(eligibility_tr), cost_amount_tr = VALUES(cost_amount_tr),
    uncertain_note_tr = VALUES(uncertain_note_tr);
""")
open('/home/claude/bokji-ieum/src/main/resources/sql/content-i18n-20261125.sql','w',encoding='utf-8').write("\n".join(out))
print('dict strings',len(tr),'of',len(json.load(open('dict_src.json'))))
