package com.ieum.bokji.controller;

import com.ieum.bokji.dto.MatchCondition;
import com.ieum.bokji.dto.MatchResultRow;
import com.ieum.bokji.service.MatchService;
import com.ieum.bokji.util.HashUtil;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import javax.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

/** 조건 입력(PRG) → 매칭 결과. 세션 키 matchCondition (조건은 DB 미저장). */
@Controller
public class MatchController {

    public static final String SESSION_KEY = "matchCondition";

    @Autowired
    private MatchService matchService;

    @GetMapping("/match")
    public String form(HttpSession session, Model model) {
        MatchCondition cond = (MatchCondition) session.getAttribute(SESSION_KEY);
        model.addAttribute("condition", cond != null ? cond : new MatchCondition());
        return "match/form";
    }

    @PostMapping("/match")
    public String submit(@ModelAttribute MatchCondition cond, HttpSession session) {
        int thisYear = LocalDate.now().getYear();
        if (invalidBirthYear(cond.getBirthYear(), thisYear)) {
            return "redirect:/match?error=birthYear";
        }
        // 가구원: 빈 행 제거 + 가구 공통 조건(동·소득·가구형태) 본인 값 복사
        List<MatchCondition> members = new ArrayList<>();
        for (MatchCondition m : cond.getMembers()) {
            if (m == null || isBlankMember(m)) {
                continue;
            }
            if (invalidBirthYear(m.getBirthYear(), thisYear)) {
                return "redirect:/match?error=memberBirthYear";
            }
            m.setDong(cond.getDong());
            m.setIncomeRank(cond.getIncomeRank());
            m.setHouseholdTypes(cond.getHouseholdTypes());
            m.setMembers(Collections.emptyList());
            members.add(m);
        }
        cond.setMembers(members);
        session.setAttribute(SESSION_KEY, cond);
        return "redirect:/match/result";
    }

    @GetMapping("/match/result")
    public String result(@RequestParam(required = false) String category,
                         @RequestParam(required = false) String sort,
                         HttpSession session, Model model, Locale locale) {
        MatchCondition cond = (MatchCondition) session.getAttribute(SESSION_KEY);
        if (cond == null) {
            return "redirect:/match";
        }
        Map<String, List<MatchResultRow>> resultsByMember = new LinkedHashMap<>();
        List<MatchResultRow> mine = matchService.match(cond, category, locale, sort);
        resultsByMember.put("나", mine);
        int i = 1;
        for (MatchCondition m : cond.getMembers()) {
            String key = m.getRelation() != null ? m.getRelation() : "가구원" + i;
            resultsByMember.put(key, matchService.match(m, category, locale, sort));
            i++;
        }
        matchService.logMatch(cond, mine.size(), HashUtil.sessionHash(session));
        model.addAttribute("condition", cond);
        model.addAttribute("resultsByMember", resultsByMember);
        model.addAttribute("category", category);
        model.addAttribute("sort", sort);
        return "match/result";
    }

    /** AJAX: 분야 필터·가구원 탭 전환. member=0 본인, 1부터 가구원 순번. */
    @GetMapping("/match/result/list")
    @ResponseBody
    public List<MatchResultRow> list(@RequestParam(required = false) String category,
                                     @RequestParam(required = false) String sort,
                                     @RequestParam(defaultValue = "0") int member,
                                     HttpSession session, Locale locale) {
        MatchCondition cond = (MatchCondition) session.getAttribute(SESSION_KEY);
        if (cond == null) {
            return Collections.emptyList();
        }
        MatchCondition target = cond;
        if (member >= 1 && member <= cond.getMembers().size()) {
            target = cond.getMembers().get(member - 1);
        }
        return matchService.match(target, category, locale, sort);
    }

    private static boolean invalidBirthYear(Integer y, int thisYear) {
        return y != null && (y < 1900 || y > thisYear);
    }

    private static boolean isBlankMember(MatchCondition m) {
        return m.getBirthYear() == null && m.getRelation() == null
                && "U".equals(m.getDisability()) && m.isEwUnknown();
    }
}
