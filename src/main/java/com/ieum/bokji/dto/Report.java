package com.ieum.bokji.dto;

import java.io.Serializable;

/** report 테이블 DTO (+ 관리자 목록용 resourceName 조인 컬럼). */
public class Report implements Serializable {

    private static final long serialVersionUID = 1L;

    private Integer reportId;
    private Integer resourceId;
    private String content;
    private String status;       // R접수/C확인/D반영/X반려
    private String adminMemo;
    private String createdAt;
    private String processedAt;
    private String resourceName; // join 전용

    public Integer getReportId() { return reportId; }
    public void setReportId(Integer reportId) { this.reportId = reportId; }
    public Integer getResourceId() { return resourceId; }
    public void setResourceId(Integer resourceId) { this.resourceId = resourceId; }
    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getAdminMemo() { return adminMemo; }
    public void setAdminMemo(String adminMemo) { this.adminMemo = adminMemo; }
    public String getCreatedAt() { return createdAt; }
    public void setCreatedAt(String createdAt) { this.createdAt = createdAt; }
    public String getProcessedAt() { return processedAt; }
    public void setProcessedAt(String processedAt) { this.processedAt = processedAt; }
    public String getResourceName() { return resourceName; }
    public void setResourceName(String resourceName) { this.resourceName = resourceName; }
}
