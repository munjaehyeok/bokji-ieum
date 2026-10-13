package com.ieum.bokji.interceptor;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.springframework.web.servlet.HandlerInterceptor;

/**
 * 퍼널 익명 로그 인터셉터 — 뼈대.
 * 다음 단계: 결과(M)/상세(D)/신청안내(A) 조회를 익명 기록 (연령 10세 밴드, 동 단위, IP 미저장).
 */
public class FunnelLogInterceptor implements HandlerInterceptor {

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response,
                             Object handler) {
        // TODO(M7): LogMapper로 익명 퍼널 기록. 골격 단계에서는 통과만 시킨다.
        return true;
    }
}
