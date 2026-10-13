package com.ieum.bokji.controller;

import com.ieum.bokji.dto.MatchCondition;
import com.ieum.bokji.dto.MatchResultRow;
import com.ieum.bokji.service.MatchService;
import java.util.Locale;
import javax.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.server.ResponseStatusException;

/** 자원 상세 — 세션 조건이 있으면 자격 판정표 포함, 없으면 상세만. */
@Controller
public class ResourceController {

    @Autowired
    private MatchService matchService;

    @GetMapping("/resources/{id}")
    public String detail(@PathVariable int id, HttpSession session, Model model, Locale locale) {
        MatchCondition cond = (MatchCondition) session.getAttribute(MatchController.SESSION_KEY);
        MatchResultRow row = (cond != null)
                ? matchService.judgeOne(id, cond, locale)
                : matchService.findOne(id, locale);
        if (row == null || !"A".equals(row.getStatus())) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "resource not found");
        }
        model.addAttribute("resource", row);
        model.addAttribute("judged", cond != null);
        return "resource/detail";
    }
}
