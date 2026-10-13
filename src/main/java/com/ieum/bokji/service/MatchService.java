package com.ieum.bokji.service;

import com.ieum.bokji.dto.MatchCondition;
import com.ieum.bokji.dto.MatchResultRow;
import com.ieum.bokji.mapper.LogMapper;
import com.ieum.bokji.mapper.ResourceMapper;
import com.ieum.bokji.util.CsvTagUtil;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.MessageSource;
import org.springframework.stereotype.Service;

/**
 * 매칭 서비스 — 판정은 전부 resource-mapper.xml SQL에서 수행.
 * 여기서는 태그 CSV→다국어 라벨 변환과 익명 로그 기록만 한다 (판정 로직 Java 복제 금지).
 */
@Service
public class MatchService {

    private static final Logger log = LoggerFactory.getLogger(MatchService.class);

    @Autowired
    private ResourceMapper resourceMapper;
    @Autowired
    private LogMapper logMapper;
    @Autowired
    private MessageSource messageSource;

    public List<MatchResultRow> match(MatchCondition cond, String category, Locale locale) {
        List<MatchResultRow> rows = resourceMapper.findMatches(cond, category, locale.getLanguage());
        for (MatchResultRow row : rows) {
            applyLabels(row, locale);
        }
        return rows;
    }

    public MatchResultRow judgeOne(int id, MatchCondition cond, Locale locale) {
        MatchResultRow row = resourceMapper.findOneWithJudge(id, cond, locale.getLanguage());
        if (row != null) {
            applyLabels(row, locale);
        }
        return row;
    }

    public MatchResultRow findOne(int id, Locale locale) {
        return resourceMapper.findById(id, locale.getLanguage());
    }

    /** match_log 익명 기록 — 연령은 10세 밴드로만 저장. 실패해도 화면은 막지 않는다. */
    public void logMatch(MatchCondition cond, int resultCount, String sessionHash) {
        try {
            Integer age = cond.getAge();
            String ageBand = (age == null) ? null : (age / 10 * 10) + "s";
            logMapper.insertMatch(sessionHash, ageBand, cond.getDong(),
                    csvOrNull(cond.getHouseholdTypes()),
                    cond.getIncomeRank() == 0 ? null : cond.getIncomeRank(),
                    cond.getDisability(), cond.getNationality(),
                    csvOrNull(cond.getEduWork()), resultCount);
        } catch (Exception e) {
            log.warn("match_log insert failed: {}", e.getMessage());
        }
    }

    private static String csvOrNull(java.util.Set<String> set) {
        return (set == null || set.isEmpty()) ? null : String.join(",", set);
    }

    private void applyLabels(MatchResultRow row, Locale locale) {
        row.setMatchedLabels(labels(row.getMatchedCsv(), locale));
        row.setNeedCheckLabels(labels(row.getNeedCheckCsv(), locale));
        row.setMismatchedLabels(labels(row.getMismatchedCsv(), locale));
    }

    private List<String> labels(String csv, Locale locale) {
        List<String> out = new ArrayList<>();
        for (String tag : CsvTagUtil.toList(csv)) {
            out.add(messageSource.getMessage("tag." + tag, null, tag, locale));
        }
        return out;
    }
}
