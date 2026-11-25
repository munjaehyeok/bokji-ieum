package com.ieum.bokji.dto;

import java.io.Serializable;

/** 관리자 이용 통계 — 날짜별(한국 시간) 건수 한 줄. */
public class StatsDailyRow implements Serializable {

    private static final long serialVersionUID = 1L;

    private String logDay;     // yyyy-MM-dd
    private long searches;     // 조건 검색
    private long views;        // 상세 조회
    private long applies;      // 신청 안내 확인
    private long reports;      // 오류 제보

    public String getLogDay() { return logDay; }
    public void setLogDay(String logDay) { this.logDay = logDay; }
    public long getSearches() { return searches; }
    public void setSearches(long searches) { this.searches = searches; }
    public long getViews() { return views; }
    public void setViews(long views) { this.views = views; }
    public long getApplies() { return applies; }
    public void setApplies(long applies) { this.applies = applies; }
    public long getReports() { return reports; }
    public void setReports(long reports) { this.reports = reports; }
}