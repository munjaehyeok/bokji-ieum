package com.ieum.bokji.dto;

import java.util.Collections;
import java.util.List;

/**
 * 매칭 결과 1행 = resource 전 컬럼 + 판정 산출물.
 * 판정은 전부 SQL(resource-mapper.xml)에서 산출 — Java는 CSV→라벨 변환만.
 */
public class MatchResultRow extends Resource {

    private static final long serialVersionUID = 1L;

    private int score;
    private String matchedCsv;      // 일치 태그 CSV (AGE,DONG,...)
    private String needCheckCsv;    // 확인필요 태그 CSV
    private String mismatchedCsv;   // 불일치 태그 CSV (findOneWithJudge만)
    private boolean oldData;        // data_base_date 12개월 경과(표시용)
    private String displayName;     // i18n 번역명, 없으면 한국어 name
    private String summaryTr;       // i18n 번역 요약 (없으면 null)
    // i18n 상세 필드 번역 (없으면 null → 화면에서 한국어 원문 폴백)
    private String orgNameTr;
    private String phoneTr;
    private String applicantTr;
    private String serviceCycleTr;
    private String decisionPeriodTr;
    private String deptNameTr;
    private String addressTr;
    private String applyMethodTr;
    private String documentsTr;
    private String eligibilityTr;
    private String costAmountTr;
    private String uncertainNoteTr;

    private List<String> matchedLabels = Collections.emptyList();
    private List<String> needCheckLabels = Collections.emptyList();
    private List<String> mismatchedLabels = Collections.emptyList();

    public int getScore() { return score; }
    public void setScore(int score) { this.score = score; }
    public String getMatchedCsv() { return matchedCsv; }
    public void setMatchedCsv(String matchedCsv) { this.matchedCsv = matchedCsv; }
    public String getNeedCheckCsv() { return needCheckCsv; }
    public void setNeedCheckCsv(String needCheckCsv) { this.needCheckCsv = needCheckCsv; }
    public String getMismatchedCsv() { return mismatchedCsv; }
    public void setMismatchedCsv(String mismatchedCsv) { this.mismatchedCsv = mismatchedCsv; }
    public boolean isOldData() { return oldData; }
    public void setOldData(boolean oldData) { this.oldData = oldData; }
    public String getDisplayName() { return displayName; }
    public void setDisplayName(String displayName) { this.displayName = displayName; }
    public String getSummaryTr() { return summaryTr; }
    public void setSummaryTr(String summaryTr) { this.summaryTr = summaryTr; }
    public String getOrgNameTr() { return orgNameTr; }
    public void setOrgNameTr(String orgNameTr) { this.orgNameTr = orgNameTr; }
    public String getDeptNameTr() { return deptNameTr; }
    public void setDeptNameTr(String deptNameTr) { this.deptNameTr = deptNameTr; }
    public String getAddressTr() { return addressTr; }
    public void setAddressTr(String addressTr) { this.addressTr = addressTr; }
    public String getApplyMethodTr() { return applyMethodTr; }
    public void setApplyMethodTr(String applyMethodTr) { this.applyMethodTr = applyMethodTr; }
    public String getDocumentsTr() { return documentsTr; }
    public void setDocumentsTr(String documentsTr) { this.documentsTr = documentsTr; }
    public String getEligibilityTr() { return eligibilityTr; }
    public void setEligibilityTr(String eligibilityTr) { this.eligibilityTr = eligibilityTr; }
    public String getCostAmountTr() { return costAmountTr; }
    public void setCostAmountTr(String costAmountTr) { this.costAmountTr = costAmountTr; }
    public String getUncertainNoteTr() { return uncertainNoteTr; }
    public void setUncertainNoteTr(String uncertainNoteTr) { this.uncertainNoteTr = uncertainNoteTr; }
    public String getApplicantTr() { return applicantTr; }
    public void setApplicantTr(String applicantTr) { this.applicantTr = applicantTr; }
    public String getServiceCycleTr() { return serviceCycleTr; }
    public void setServiceCycleTr(String serviceCycleTr) { this.serviceCycleTr = serviceCycleTr; }
    public String getDecisionPeriodTr() { return decisionPeriodTr; }
    public void setDecisionPeriodTr(String decisionPeriodTr) { this.decisionPeriodTr = decisionPeriodTr; }
    public String getPhoneTr() { return phoneTr; }
    public void setPhoneTr(String phoneTr) { this.phoneTr = phoneTr; }
    public List<String> getMatchedLabels() { return matchedLabels; }
    public void setMatchedLabels(List<String> matchedLabels) { this.matchedLabels = matchedLabels; }
    public List<String> getNeedCheckLabels() { return needCheckLabels; }
    public void setNeedCheckLabels(List<String> needCheckLabels) { this.needCheckLabels = needCheckLabels; }
    public List<String> getMismatchedLabels() { return mismatchedLabels; }
    public void setMismatchedLabels(List<String> mismatchedLabels) { this.mismatchedLabels = mismatchedLabels; }
}
