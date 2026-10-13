package com.ieum.bokji.service;

import com.ieum.bokji.dto.Resource;
import com.ieum.bokji.mapper.AdminMapper;
import com.ieum.bokji.mapper.ResourceMapper;
import com.ieum.bokji.util.TextUtil;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/** 관리자 자원 CRUD + resource_history 기록. 저장 전 Jsoup 정화. */
@Service
public class AdminService {

    @Autowired
    private ResourceMapper resourceMapper;
    @Autowired
    private AdminMapper adminMapper;

    @Transactional
    public int create(Resource r, int adminId) {
        sanitize(r);
        resourceMapper.insert(r);
        adminMapper.insertHistory(r.getResourceId(), adminId, "C", trunc("등록: " + r.getName()));
        return r.getResourceId();
    }

    @Transactional
    public void update(Resource r, int adminId) {
        Resource old = resourceMapper.findById(r.getResourceId(), "ko");
        sanitize(r);
        resourceMapper.update(r);
        adminMapper.insertHistory(r.getResourceId(), adminId, "U", trunc(diffSummary(old, r)));
    }

    @Transactional
    public void changeStatus(int resourceId, String status, int adminId) {
        resourceMapper.updateStatus(resourceId, status);
        String action = "H".equals(status) ? "H" : "E".equals(status) ? "E" : "U";
        adminMapper.insertHistory(resourceId, adminId, action, "상태변경: " + status);
    }

    /** 자유 텍스트 전 필드 Jsoup 정화 + 빈 문자열→NULL(무관 규약), 필수 기본값 보정. */
    private void sanitize(Resource r) {
        r.setName(TextUtil.clean(r.getName()));
        r.setSubCategory(TextUtil.cleanToNull(r.getSubCategory()));
        r.setServiceType(TextUtil.cleanToNull(r.getServiceType()));
        r.setOrgName(TextUtil.clean(r.getOrgName()));
        r.setDeptName(TextUtil.cleanToNull(r.getDeptName()));
        r.setPhone(TextUtil.cleanToNull(r.getPhone()));
        r.setAddress(TextUtil.cleanToNull(r.getAddress()));
        r.setSupportContent(TextUtil.clean(r.getSupportContent()));
        r.setApplyMethod(TextUtil.cleanToNull(r.getApplyMethod()));
        r.setDocuments(TextUtil.cleanToNull(r.getDocuments()));
        r.setApplyUrl(blankToNull(r.getApplyUrl()));
        r.setDongCodes(blankToNull(r.getDongCodes()));
        r.setHouseholdTypes(blankToNull(r.getHouseholdTypes()));
        r.setIncomeUncertain(blankToNull(r.getIncomeUncertain()));
        r.setDisability(blankToNull(r.getDisability()));
        r.setNationality(blankToNull(r.getNationality()));
        r.setEduWork(blankToNull(r.getEduWork()));
        r.setUncertainNote(TextUtil.cleanToNull(r.getUncertainNote()));
        r.setEligibilityRaw(TextUtil.cleanToNull(r.getEligibilityRaw()));
        r.setDecisionPeriod(TextUtil.cleanToNull(r.getDecisionPeriod()));
        r.setServiceCycle(TextUtil.cleanToNull(r.getServiceCycle()));
        r.setApplicant(TextUtil.cleanToNull(r.getApplicant()));
        r.setCostFlag(blankToNull(r.getCostFlag()));
        r.setCostAmount(TextUtil.cleanToNull(r.getCostAmount()));
        r.setSourceUrl(blankToNull(r.getSourceUrl()));
        r.setLastVerifiedDate(blankToNull(r.getLastVerifiedDate()));
        if (r.getSourceName() == null || r.getSourceName().isBlank()) {
            r.setSourceName("시흥시 복지자원 종합안내서");
        } else {
            r.setSourceName(TextUtil.clean(r.getSourceName()));
        }
        if (r.getDataBaseDate() == null || r.getDataBaseDate().isBlank()) {
            r.setDataBaseDate(LocalDate.now().toString());
        }
        if (r.getStatus() == null || !"AHE".contains(r.getStatus())) {
            r.setStatus("A");
        }
    }

    /** 변경 전후 요약 텍스트 (매칭에 영향 주는 필드 중심). */
    private String diffSummary(Resource o, Resource n) {
        if (o == null) {
            return "수정: " + n.getName();
        }
        List<String> diffs = new ArrayList<>();
        addDiff(diffs, "name", o.getName(), n.getName());
        addDiff(diffs, "category", o.getCategory(), n.getCategory());
        addDiff(diffs, "age", o.getAgeMin() + "~" + o.getAgeMax(), n.getAgeMin() + "~" + n.getAgeMax());
        addDiff(diffs, "dong", o.getDongCodes(), n.getDongCodes());
        addDiff(diffs, "household", o.getHouseholdTypes(), n.getHouseholdTypes());
        addDiff(diffs, "income", str(o.getIncomeRank()), str(n.getIncomeRank()));
        addDiff(diffs, "disability", o.getDisability(), n.getDisability());
        addDiff(diffs, "nationality", o.getNationality(), n.getNationality());
        addDiff(diffs, "eduWork", o.getEduWork(), n.getEduWork());
        addDiff(diffs, "status", o.getStatus(), n.getStatus());
        addDiff(diffs, "dataBaseDate", o.getDataBaseDate(), n.getDataBaseDate());
        return diffs.isEmpty() ? "수정(태깅 외 필드): " + n.getName() : "수정: " + String.join("; ", diffs);
    }

    private static void addDiff(List<String> diffs, String field, String before, String after) {
        if (!Objects.equals(before, after)) {
            diffs.add(field + " [" + before + "] → [" + after + "]");
        }
    }

    private static String str(Object o) {
        return o == null ? null : String.valueOf(o);
    }

    private static String blankToNull(String v) {
        return (v == null || v.isBlank()) ? null : v.trim();
    }

    private static String trunc(String v) {
        return (v != null && v.length() > 500) ? v.substring(0, 500) : v;
    }
}
