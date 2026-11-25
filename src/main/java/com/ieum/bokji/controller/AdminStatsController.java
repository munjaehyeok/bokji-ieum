package com.ieum.bokji.controller;

import com.ieum.bokji.service.AdminStatsService;
import java.time.LocalDate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

/**
 * 관리자 이용 통계 화면 (읽기 전용 GET).
 * /admin/** 경로라서 AdminAuthInterceptor가 로그인 여부를 먼저 확인한다.
 */
@Controller
@RequestMapping("/admin/stats")
public class AdminStatsController {

    @Autowired
    private AdminStatsService statsService;

    @GetMapping
    public String stats(@RequestParam(required = false) String days, Model model) {
        int d = AdminStatsService.normalizeDays(days);
        model.addAttribute("days", d);
        model.addAttribute("periodLabel",
                AdminStatsService.periodLabel(d, LocalDate.now(AdminStatsService.KST)));
        model.addAttribute("summary", statsService.summary(d));
        model.addAttribute("popular", statsService.popularResources(d));
        model.addAttribute("bars", statsService.conditionBars(d));
        model.addAttribute("dimTitles", AdminStatsService.DIM_TITLES);
        model.addAttribute("daily", statsService.daily(d));
        return "admin/stats";
    }
}