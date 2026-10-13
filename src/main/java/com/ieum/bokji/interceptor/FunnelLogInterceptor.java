package com.ieum.bokji.interceptor;

import com.ieum.bokji.mapper.LogMapper;
import com.ieum.bokji.util.HashUtil;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.servlet.HandlerInterceptor;

/**
 * 퍼널 익명 로그: M=/match/result(결과 조회), D=/resources/{id}(상세 조회) → event_log.
 * session_hash = 세션ID SHA-256 앞 32자. IP·식별자 미저장. 로그 실패가 화면을 막지 않는다.
 */
public class FunnelLogInterceptor implements HandlerInterceptor {

    private static final Logger log = LoggerFactory.getLogger(FunnelLogInterceptor.class);

    @Autowired
    private LogMapper logMapper;

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response,
                             Object handler) {
        try {
            String uri = request.getRequestURI().substring(request.getContextPath().length());
            String hash = HashUtil.sessionHash(request.getSession());
            if ("/match/result".equals(uri)) {
                logMapper.insertEvent(hash, "M", null);
            } else if (uri.startsWith("/resources/")) {
                Integer id = parseId(uri.substring("/resources/".length()));
                logMapper.insertEvent(hash, "D", id);
            }
        } catch (Exception e) {
            log.warn("funnel log failed: {}", e.getMessage());
        }
        return true;
    }

    private static Integer parseId(String s) {
        try {
            return Integer.valueOf(s);
        } catch (NumberFormatException e) {
            return null;
        }
    }
}
