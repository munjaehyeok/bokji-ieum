package com.ieum.bokji.dto;

import java.io.Serializable;

/** resource 테이블 전 컬럼 DTO (날짜는 String — JSON/폼 왕복 단순화). */
public class Resource implements Serializable {

    private static final long serialVersionUID = 1L;

    private Integer resourceId;
    private String name;
    private String category;
    private String subCategory;
    private String serviceType;
    private String providerType;
    private String orgName;
    private String deptName;
    private String phone;
    private String address;
    private String supportContent;
    private String applyMethod;
    private String documents;
    private String applyUrl;
    // ---- 자격조건 태깅 7필드 (NULL = 무관) ----
    private Integer ageMin;
    private Integer ageMax;
    private String dongCodes;
    private String householdTypes;
    private Integer incomeRank;
    private String incomeUncertain;
    private String disability;
    private String nationality;
    private String eduWork;
    private String uncertainNote;
    // ---- 원문 보존·상세 표시 ----
    private String eligibilityRaw;
    private String decisionPeriod;
    private String serviceCycle;
    private String applicant;
    private String costFlag;
    private String costAmount;
    // ---- 출처·관리 ----
    private String sourceName;
    private String sourceUrl;
    private String dataBaseDate;
    private String lastVerifiedDate;
    private String status;
    private String createdAt;
    private String updatedAt;

    public Integer getResourceId() { return resourceId; }
    public void setResourceId(Integer resourceId) { this.resourceId = resourceId; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }
    public String getSubCategory() { return subCategory; }
    public void setSubCategory(String subCategory) { this.subCategory = subCategory; }
    public String getServiceType() { return serviceType; }
    public void setServiceType(String serviceType) { this.serviceType = serviceType; }
    public String getProviderType() { return providerType; }
    public void setProviderType(String providerType) { this.providerType = providerType; }
    public String getOrgName() { return orgName; }
    public void setOrgName(String orgName) { this.orgName = orgName; }
    public String getDeptName() { return deptName; }
    public void setDeptName(String deptName) { this.deptName = deptName; }
    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }
    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }
    public String getSupportContent() { return supportContent; }
    public void setSupportContent(String supportContent) { this.supportContent = supportContent; }
    public String getApplyMethod() { return applyMethod; }
    public void setApplyMethod(String applyMethod) { this.applyMethod = applyMethod; }
    public String getDocuments() { return documents; }
    public void setDocuments(String documents) { this.documents = documents; }
    public String getApplyUrl() { return applyUrl; }
    public void setApplyUrl(String applyUrl) { this.applyUrl = applyUrl; }
    public Integer getAgeMin() { return ageMin; }
    public void setAgeMin(Integer ageMin) { this.ageMin = ageMin; }
    public Integer getAgeMax() { return ageMax; }
    public void setAgeMax(Integer ageMax) { this.ageMax = ageMax; }
    public String getDongCodes() { return dongCodes; }
    public void setDongCodes(String dongCodes) { this.dongCodes = dongCodes; }
    public String getHouseholdTypes() { return householdTypes; }
    public void setHouseholdTypes(String householdTypes) { this.householdTypes = householdTypes; }
    public Integer getIncomeRank() { return incomeRank; }
    public void setIncomeRank(Integer incomeRank) { this.incomeRank = incomeRank; }
    public String getIncomeUncertain() { return incomeUncertain; }
    public void setIncomeUncertain(String incomeUncertain) { this.incomeUncertain = incomeUncertain; }
    public String getDisability() { return disability; }
    public void setDisability(String disability) { this.disability = disability; }
    public String getNationality() { return nationality; }
    public void setNationality(String nationality) { this.nationality = nationality; }
    public String getEduWork() { return eduWork; }
    public void setEduWork(String eduWork) { this.eduWork = eduWork; }
    public String getUncertainNote() { return uncertainNote; }
    public void setUncertainNote(String uncertainNote) { this.uncertainNote = uncertainNote; }
    public String getEligibilityRaw() { return eligibilityRaw; }
    public void setEligibilityRaw(String eligibilityRaw) { this.eligibilityRaw = eligibilityRaw; }
    public String getDecisionPeriod() { return decisionPeriod; }
    public void setDecisionPeriod(String decisionPeriod) { this.decisionPeriod = decisionPeriod; }
    public String getServiceCycle() { return serviceCycle; }
    public void setServiceCycle(String serviceCycle) { this.serviceCycle = serviceCycle; }
    public String getApplicant() { return applicant; }
    public void setApplicant(String applicant) { this.applicant = applicant; }
    public String getCostFlag() { return costFlag; }
    public void setCostFlag(String costFlag) { this.costFlag = costFlag; }
    public String getCostAmount() { return costAmount; }
    public void setCostAmount(String costAmount) { this.costAmount = costAmount; }
    public String getSourceName() { return sourceName; }
    public void setSourceName(String sourceName) { this.sourceName = sourceName; }
    public String getSourceUrl() { return sourceUrl; }
    public void setSourceUrl(String sourceUrl) { this.sourceUrl = sourceUrl; }
    public String getDataBaseDate() { return dataBaseDate; }
    public void setDataBaseDate(String dataBaseDate) { this.dataBaseDate = dataBaseDate; }
    public String getLastVerifiedDate() { return lastVerifiedDate; }
    public void setLastVerifiedDate(String lastVerifiedDate) { this.lastVerifiedDate = lastVerifiedDate; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getCreatedAt() { return createdAt; }
    public void setCreatedAt(String createdAt) { this.createdAt = createdAt; }
    public String getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(String updatedAt) { this.updatedAt = updatedAt; }
}
