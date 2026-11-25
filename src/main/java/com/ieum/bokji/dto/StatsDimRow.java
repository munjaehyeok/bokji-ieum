package com.ieum.bokji.dto;

import java.io.Serializable;

/**
 * 관리자 이용 통계 — 조건 분포 한 칸.
 * SQL은 dim(분류)·code(값)·cnt(건수)만 채우고, label·pct는 서비스에서 채운다.
 */
public class StatsDimRow implements Serializable {

    private static final long serialVersionUID = 1L;

    private String dim;     // AGE, DONG, HH, INCOME, DIS, NAT, EDU
    private String code;    // 예: 60s, JWB, ONE,SPAR (모름이면 null)
    private long cnt;
    private String label;   // 화면 표시 이름 (예: 60대, 정왕본동)
    private int pct;        // 검색 수 대비 비율(%)

    public String getDim() { return dim; }
    public void setDim(String dim) { this.dim = dim; }
    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }
    public long getCnt() { return cnt; }
    public void setCnt(long cnt) { this.cnt = cnt; }
    public String getLabel() { return label; }
    public void setLabel(String label) { this.label = label; }
    public int getPct() { return pct; }
    public void setPct(int pct) { this.pct = pct; }
}