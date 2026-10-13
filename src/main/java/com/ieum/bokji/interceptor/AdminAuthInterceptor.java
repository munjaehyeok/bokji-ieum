package com.ieum.bokji.interceptor;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import org.springframework.web.servlet.HandlerInterceptor;

/**
 * /admin/** 접근 차단 (/admin/login 제외 — servlet-context 매핑).
 * 로그인 확인 + 관리자 변경(POST) 요청의 세션 CSRF 토큰(_csrf) 검증.
 */
public class AdminAuthInterceptor implements HandlerInterceptor {

    public static final String ADMIN_ID = "adminId";
    public static final String CSRF_TOKEN = "csrfToken";

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response,
                             Object handler) throws Exception {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute(ADMIN_ID) == null) {
            response.sendRedirect(request.getContextPath() + "/admin/login");
            return false;
        }
        if ("POST".equalsIgnoreCase(request.getMethod())) {
            String token = (String) session.getAttribute(CSRF_TOKEN);
            if (token == null || !token.equals(request.getParameter("_csrf"))) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "CSRF token mismatch");
                return false;
            }
        }
        return true;
    }
}
