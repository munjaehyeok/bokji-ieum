package com.ieum.bokji.service;

import com.ieum.bokji.dto.MatchCondition;
import com.ieum.bokji.dto.MatchResultRow;
import com.ieum.bokji.util.CsvTagUtil;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.MessageSource;
import org.springframework.stereotype.Component;

/**
 * 상세 판정표용 "내 조건 vs 공고 조건" 행 생성. 판정(일치/확인/불일치)은 SQL이 낸 태그를 그대로 쓰고,
 * 여기서는 같은 항목의 입력값과 자원 필드를 사람이 읽는 문구로 옮기기만 한다(판정 재계산 금지).
 */
@Component
public class JudgeCompare {

    public static final class Line {
        private final String item, mine, theirs, status;
        Line(String item, String mine, String theirs, String status) {
            this.item = item; this.mine = mine; this.theirs = theirs; this.status = status;
        }
        public String getItem() { return item; }
        public String getMine() { return mine; }
        public String getTheirs() { return theirs; }
        /** match | check | miss — JSP에서 태그 색·문구 선택 */
        public String getStatus() { return status; }
    }

    @Autowired
    private MessageSource ms;

    public List<Line> build(MatchResultRow r, MatchCondition c, Locale l) {
        List<Line> out = new ArrayList<>();
        add(out, r.getMatchedCsv(), "match", r, c, l);
        add(out, r.getNeedCheckCsv(), "check", r, c, l);
        add(out, r.getMismatchedCsv(), "miss", r, c, l);
        // rank 없이 소득 기준만 불확실한 자원(건강보험료·재산 등)은 SQL이 소득 태그를 만들지 않으므로 표시 전용 행을 더한다.
        if (r.getIncomeRank() == null && "Y".equals(r.getIncomeUncertain())) {
            out.add(new Line(ms.getMessage("tag.INCOME", null, "INCOME", l), incomeMine(c, l), m("compare.incomeRaw", l), "check"));
        }
        return out;
    }

    private void add(List<Line> out, String csv, String status, MatchResultRow r, MatchCondition c, Locale l) {
        for (String tag : CsvTagUtil.toList(csv)) {
            String mine = "", theirs = "";
            switch (tag) {
                case "AGE":
                    mine = c.getAge() == null ? m("compare.unknown", l) : m("cond.age", l, c.getAge());
                    theirs = ageRange(r, l);
                    break;
                case "AGE_HINT":
                    mine = c.getAge() == null ? m("compare.unknown", l) : m("cond.age", l, c.getAge());
                    theirs = m("compare.ageHint", l);
                    break;
                case "DONG":
                    mine = blank(c.getDong()) ? m("compare.unknown", l) : m("dong." + c.getDong(), l);
                    theirs = join(r.getDongCodes(), "dong.", l);
                    break;
                case "HOUSEHOLD":
                    mine = c.getHouseholdTypes().isEmpty() ? m("compare.unknown", l) : join(c.getHouseholdTypes(), "hh.", l);
                    theirs = join(r.getHouseholdTypes(), "hh.", l);
                    break;
                case "INCOME":
                case "INCOME_DETAIL":
                    mine = incomeMine(c, l);
                    // rank는 태깅 구간일 뿐 공고 원문의 상한과 다를 수 있다(예: 180% → 4구간). 구간임을 밝히고 원문으로 안내.
                    theirs = "INCOME_DETAIL".equals(tag) || r.getIncomeRank() == null
                            ? m("compare.incomeDetail", l) : m("compare.income.tier", l, m("compare.income." + r.getIncomeRank(), l));
                    break;
                case "DISABILITY":
                    mine = m("compare.dis." + c.getDisability(), l);
                    theirs = m("compare.disTarget", l);
                    break;
                case "NATIONALITY":
                    mine = m("nat." + c.getNationality(), l);
                    theirs = m("nat." + r.getNationality(), l);
                    break;
                case "EDUWORK":
                    mine = c.getEduWork().isEmpty() ? m("compare.unknown", l) : join(c.getEduWork(), "ew.", l);
                    theirs = join(r.getEduWork(), "ew.", l);
                    break;
                case "NOTE":
                    mine = "—";
                    theirs = m("compare.note", l);
                    break;
                default:
                    break;
            }
            out.add(new Line(ms.getMessage("tag." + tag, null, tag, l), mine, theirs, status));
        }
    }

    private String incomeMine(MatchCondition c, Locale l) {
        return c.getIncomeRank() == 0 ? m("compare.unknown", l) : m("income." + c.getIncomeRank(), l);
    }

    private String ageRange(MatchResultRow r, Locale l) {
        Integer lo = r.getAgeMin(), hi = r.getAgeMax();
        if (lo != null && hi != null) return m("compare.age.range", l, lo, hi);
        if (lo != null) return m("compare.age.min", l, lo);
        if (hi != null) return m("compare.age.max", l, hi);
        return "—";
    }

    private String join(String csv, String prefix, Locale l) { return join(CsvTagUtil.toList(csv), prefix, l); }

    private String join(Iterable<String> codes, String prefix, Locale l) {
        List<String> names = new ArrayList<>();
        for (String code : codes) names.add(ms.getMessage(prefix + code, null, code, l));
        return names.isEmpty() ? "—" : String.join(", ", names);
    }

    private String m(String key, Locale l, Object... args) { return ms.getMessage(key, args, key, l); }

    private static boolean blank(String s) { return s == null || s.trim().isEmpty(); }
}
