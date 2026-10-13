package com.ieum.bokji.dto;

/** admin_user 테이블 DTO. */
public class AdminUser {

    private Integer adminId;
    private String loginId;
    private String pwHash;
    private String name;

    public Integer getAdminId() { return adminId; }
    public void setAdminId(Integer adminId) { this.adminId = adminId; }
    public String getLoginId() { return loginId; }
    public void setLoginId(String loginId) { this.loginId = loginId; }
    public String getPwHash() { return pwHash; }
    public void setPwHash(String pwHash) { this.pwHash = pwHash; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
}
