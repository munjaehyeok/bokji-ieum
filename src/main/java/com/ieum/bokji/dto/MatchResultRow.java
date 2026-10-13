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
    public List<String> getMatchedLabels() { return matchedLabels; }
    public void setMatchedLabels(List<String> matchedLabels) { this.matchedLabels = matchedLabels; }
    public List<String> getNeedCheckLabels() { return needCheckLabels; }
    public void setNeedCheckLabels(List<String> needCheckLabels) { this.needCheckLabels = needCheckLabels; }
    public List<String> getMismatchedLabels() { return mismatchedLabels; }
    public void setMismatchedLabels(List<String> mismatchedLabels) { this.mismatchedLabels = mismatchedLabels; }
}
