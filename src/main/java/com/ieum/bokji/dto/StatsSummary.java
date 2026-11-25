package com.ieum.bokji.dto;

import java.io.Serializable;

/** 관리자 이용 통계 — 선택한 기간의 요약 숫자 (stats-mapper.xml summary). */
public class StatsSummary implements Serializable {

    private static final long serialVersionUID = 1L;

    private long searches;            // 조건 검색 수 (같은 세션에서 같은 조건을 다시 본 건 1건)
    private long matchedSessions;     // 결과 화면까지 본 세션
    private long viewedSessions;      // 그중 상세 화면을 본 세션
    private long appliedSessions;     // 그중 신청 안내(전화·신청 링크·인쇄)까지 누른 세션
    private long browseOnlySessions;  // 조건 검색 없이 둘러보기에서 상세만 본 세션
    private long detailViews;         // 상세 조회 수
    private long applyClicks;         // 신청 안내 확인 수
    private long reports;             // 오류 제보 수
    private Long avgResults;          // 결과 수 평균 (기록이 없으면 null)
    private Integer minResults;
    private Integer maxResults;
    private int viewedPct;            // viewedSessions / matchedSessions (%) — 서비스에서 계산
    private int appliedPct;           // appliedSessions / matchedSessions (%)

    public long getSearches() { return searches; }
    public void setSearches(long searches) { this.searches = searches; }
    public long getMatchedSessions() { return matchedSessions; }
    public void setMatchedSessions(long matchedSessions) { this.matchedSessions = matchedSessions; }
    public long getViewedSessions() { return viewedSessions; }
    public void setViewedSessions(long viewedSessions) { this.viewedSessions = viewedSessions; }
    public long getAppliedSessions() { return appliedSessions; }
    public void setAppliedSessions(long appliedSessions) { this.appliedSessions = appliedSessions; }
    public long getBrowseOnlySessions() { return browseOnlySessions; }
    public void setBrowseOnlySessions(long browseOnlySessions) { this.browseOnlySessions = browseOnlySessions; }
    public long getDetailViews() { return detailViews; }
    public void setDetailViews(long detailViews) { this.detailViews = detailViews; }
    public long getApplyClicks() { return applyClicks; }
    public void setApplyClicks(long applyClicks) { this.applyClicks = applyClicks; }
    public long getReports() { return reports; }
    public void setReports(long reports) { this.reports = reports; }
    public Long getAvgResults() { return avgResults; }
    public void setAvgResults(Long avgResults) { this.avgResults = avgResults; }
    public Integer getMinResults() { return minResults; }
    public void setMinResults(Integer minResults) { this.minResults = minResults; }
    public Integer getMaxResults() { return maxResults; }
    public void setMaxResults(Integer maxResults) { this.maxResults = maxResults; }
    public int getViewedPct() { return viewedPct; }
    public void setViewedPct(int viewedPct) { this.viewedPct = viewedPct; }
    public int getAppliedPct() { return appliedPct; }
    public void setAppliedPct(int appliedPct) { this.appliedPct = appliedPct; }
}