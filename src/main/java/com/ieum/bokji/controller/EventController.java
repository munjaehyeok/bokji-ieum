package com.ieum.bokji.controller;

import com.ieum.bokji.mapper.LogMapper;
import com.ieum.bokji.util.HashUtil;
import java.util.Map;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

/** AJAX 비콘: 신청 안내 확인(A) → event_log. M/D는 FunnelLogInterceptor, R은 제보 시 기록. */
@Controller
public class EventController {

    @Autowired
    private LogMapper logMapper;

    @PostMapping("/events")
    @ResponseBody
    public Map<String, Object> event(@RequestParam String event,
                                     @RequestParam(required = false) Integer resourceId,
                                     HttpSession session, HttpServletResponse response) {
        if (!"A".equals(event)) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            return Map.of("ok", false, "error", "event");
        }
        logMapper.insertEvent(HashUtil.sessionHash(session), "A", resourceId);
        return Map.of("ok", true);
    }
}
