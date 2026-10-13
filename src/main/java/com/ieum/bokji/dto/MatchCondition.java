package com.ieum.bokji.dto;

import java.io.Serializable;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

/**
 * 매칭 조건 (세션 키 "matchCondition").
 * 3상태 규약(설계03 보충 Q2): 빈 Set=모름(확인필요) / 'NONE' 포함=해당없음(제약 자원 제외) / 그 외=선택값.
 * incomeRank 0=모름. disability Y/N/U. nationality K/F(모름 없음, 기본 K — 보충 Q4).
 */
public class MatchCondition implements Serializable {

    private static final long serialVersionUID = 1L;
    public static final String NONE = "NONE";

    private Integer birthYear;
    private String dong;                                        // null/blank = 모름
    private Set<String> householdTypes = new LinkedHashSet<>(); // 'NONE' 특수값
    private int incomeRank;                                     // 0=모름, 1~4
    private String disability = "U";
    private String nationality = "K";
    private Set<String> eduWork = new LinkedHashSet<>();        // 'NONE' 특수값
    private String relation;                                    // 가구원 관계(본인은 null)
    private List<MatchCondition> members = new ArrayList<>();

    public Integer getBirthYear() { return birthYear; }
    public void setBirthYear(Integer birthYear) { this.birthYear = birthYear; }

    public String getDong() { return dong; }
    public void setDong(String dong) {
        this.dong = (dong == null || dong.isBlank()) ? null : dong.trim();
    }

    public Set<String> getHouseholdTypes() { return householdTypes; }
    public void setHouseholdTypes(Set<String> householdTypes) {
        this.householdTypes = householdTypes == null ? new LinkedHashSet<>() : householdTypes;
    }

    public int getIncomeRank() { return incomeRank; }
    public void setIncomeRank(int incomeRank) {
        this.incomeRank = (incomeRank < 0 || incomeRank > 4) ? 0 : incomeRank;
    }

    public String getDisability() { return disability; }
    public void setDisability(String disability) {
        this.disability = ("Y".equals(disability) || "N".equals(disability)) ? disability : "U";
    }

    public String getNationality() { return nationality; }
    public void setNationality(String nationality) {
        this.nationality = "F".equals(nationality) ? "F" : "K"; // 보충 Q4: 모름 없음, 기본 K
    }

    public Set<String> getEduWork() { return eduWork; }
    public void setEduWork(Set<String> eduWork) {
        this.eduWork = eduWork == null ? new LinkedHashSet<>() : eduWork;
    }

    public String getRelation() { return relation; }
    public void setRelation(String relation) {
        this.relation = (relation == null || relation.isBlank()) ? null : relation.trim();
    }

    public List<MatchCondition> getMembers() { return members; }
    public void setMembers(List<MatchCondition> members) {
        this.members = members == null ? new ArrayList<>() : members;
    }

    /* ---------- SQL 파라미터용 파생 getter (매퍼 XML에서 사용) ---------- */

    /** 연 나이 = 당해연도 - 출생연도. 미입력/비정상 입력은 null(=모름). */
    public Integer getAge() {
        int now = LocalDate.now().getYear();
        if (birthYear == null || birthYear < 1900 || birthYear > now) {
            return null;
        }
        return now - birthYear;
    }

    public boolean isHhUnknown() { return householdTypes == null || householdTypes.isEmpty(); }
    public boolean isHhNone() { return householdTypes != null && householdTypes.contains(NONE); }
    public List<String> getHhSelected() { return selected(householdTypes); }

    public boolean isEwUnknown() { return eduWork == null || eduWork.isEmpty(); }
    public boolean isEwNone() { return eduWork != null && eduWork.contains(NONE); }
    public List<String> getEwSelected() { return selected(eduWork); }

    private static List<String> selected(Set<String> set) {
        if (set == null || set.contains(NONE)) {
            return new ArrayList<>();
        }
        return new ArrayList<>(set);
    }
}
