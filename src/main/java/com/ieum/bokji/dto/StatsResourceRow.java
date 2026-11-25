package com.ieum.bokji.dto;

import java.io.Serializable;

/** 관리자 이용 통계 — 많이 본 자원 한 줄. categoryLabel·barPct는 서비스에서 채운다. */
public class StatsResourceRow implements Serializable {

    private static final long serialVersionUID = 1L;

    private Integer resourceId;
    private String name;
    private String orgName;
    private String category;
    private String status;         // A노출/H숨김/E종료
    private long views;            // 상세 조회 수
    private long applies;          // 신청 안내 확인 수
    private String categoryLabel;
    private int barPct;            // 1위 대비 막대 길이(%)

    public Integer getResourceId() { return resourceId; }
    public void setResourceId(Integer resourceId) { this.resourceId = resourceId; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getOrgName() { return orgName; }
    public void setOrgName(String orgName) { this.orgName = orgName; }
    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public long getViews() { return views; }
    public void setViews(long views) { this.views = views; }
    public long getApplies() { return applies; }
    public void setApplies(long applies) { this.applies = applies; }
    public String getCategoryLabel() { return categoryLabel; }
    public void setCategoryLabel(String categoryLabel) { this.categoryLabel = categoryLabel; }
    public int getBarPct() { return barPct; }
    public void setBarPct(int barPct) { this.barPct = barPct; }
}