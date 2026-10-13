package com.ieum.bokji.interceptor;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.springframework.web.servlet.HandlerInterceptor;

/**
 * /admin/** 접근 차단 인터셉터 — 뼈대.
 * 다음 단계: 세션 adminId 확인, 없으면 /admin/login 리다이렉트 (BCrypt + 5회 실패 10분 잠금).
 */
public class AdminAuthInterceptor implements HandlerInterceptor {

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response,
                             Object handler) {
        // TODO(M6): 세션 인증 검사. 골격 단계에서는 통과만 시킨다.
        return true;
    }
}
