package com.ieum.bokji.controller;

import com.ieum.bokji.dto.Report;
import com.ieum.bokji.mapper.LogMapper;
import com.ieum.bokji.mapper.ReportMapper;
import com.ieum.bokji.util.HashUtil;
import com.ieum.bokji.util.TextUtil;
import java.time.LocalDate;
import java.util.Map;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataAccessException;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

/** 오류 제보 (AJAX JSON). 500자 제한, 세션당 5건/일, Jsoup 정화. */
@Controller
public class ReportController {

    private static final int DAILY_LIMIT = 5;
    private static final String QUOTA_KEY = "reportQuota"; // "yyyy-MM-dd:n"
    public static final String TOKEN_KEY = "reportToken";  // 공개 세션 토큰 (상세 진입 시 발급)

    @Autowired
    private ReportMapper reportMapper;
    @Autowired
    private LogMapper logMapper;

    @PostMapping("/reports")
    @ResponseBody
    public Map<String, Object> create(@RequestParam int resourceId,
                                      @RequestParam String content,
                                      @RequestParam(value = "_token", required = false) String token,
                                      HttpSession session, HttpServletResponse response) {
        String sessionToken = (String) session.getAttribute(TOKEN_KEY);
        if (sessionToken == null || !sessionToken.equals(token)) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            return Map.of("ok", false, "error", "token");
        }
        String clean = TextUtil.clean(content);
        if (clean == null || clean.isEmpty() || clean.length() > 500) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            return Map.of("ok", false, "error", "content");
        }
        int used = quotaUsed(session);
        if (used >= DAILY_LIMIT) {
            response.setStatus(429);
            return Map.of("ok", false, "error", "limit");
        }
        Report report = new Report();
        report.setResourceId(resourceId);
        report.setContent(clean);
        try {
            reportMapper.insert(report);
        } catch (DataAccessException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            return Map.of("ok", false, "error", "resource");
        }
        session.setAttribute(QUOTA_KEY, LocalDate.now() + ":" + (used + 1));
        logMapper.insertEvent(HashUtil.sessionHash(session), "R", resourceId);
        return Map.of("ok", true, "reportId", report.getReportId());
    }

    private static int quotaUsed(HttpSession session) {
        Object v = session.getAttribute(QUOTA_KEY);
        if (v instanceof String) {
            String[] parts = ((String) v).split(":");
            if (parts.length == 2 && LocalDate.now().toString().equals(parts[0])) {
                try {
                    return Integer.parseInt(parts[1]);
                } catch (NumberFormatException ignored) {
                }
            }
        }
        return 0;
    }
}
