package com.ieum.bokji.dto;

/** 관리자 목록 공용 페이징·필터 파라미터 (페이지 크기 20 고정). */
public class PageParam {

    private int page = 1;
    private int size = 20;
    private String q;        // 이름·기관 검색어
    private String status;   // A/H/E (report: R/C/D/X)
    private boolean expired; // 기준일 12개월 경과만

    public int getPage() { return page; }
    public void setPage(int page) { this.page = Math.max(page, 1); }
    public int getSize() { return size; }
    public void setSize(int size) { if (size > 0 && size <= 100) this.size = size; }
    public int getOffset() { return (page - 1) * size; }
    public String getQ() { return q; }
    public void setQ(String q) { this.q = (q == null || q.isBlank()) ? null : q.trim(); }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = (status == null || status.isBlank()) ? null : status; }
    public boolean isExpired() { return expired; }
    public void setExpired(boolean expired) { this.expired = expired; }
}
