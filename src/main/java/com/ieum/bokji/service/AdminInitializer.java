package com.ieum.bokji.service;

import com.ieum.bokji.mapper.AdminMapper;
import java.util.concurrent.atomic.AtomicBoolean;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationListener;
import org.springframework.context.event.ContextRefreshedEvent;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Component;

/**
 * 기동 시 admin_user가 비어 있고 환경변수 BOKJI_ADMIN_INITIAL_PASSWORD가 있으면 admin 초기 계정(BCrypt)을 만든다.
 * 값이 없으면 계정을 만들지 않는다(공개된 고정 비밀번호 없음). 이미 계정이 있으면 건드리지 않는다.
 */
@Component
public class AdminInitializer implements ApplicationListener<ContextRefreshedEvent> {

    private static final Logger log = LoggerFactory.getLogger(AdminInitializer.class);
    static final String ENV = "BOKJI_ADMIN_INITIAL_PASSWORD";
    private final AtomicBoolean done = new AtomicBoolean(false);

    @Autowired
    private AdminMapper adminMapper;

    @Override
    public void onApplicationEvent(ContextRefreshedEvent event) {
        if (!done.compareAndSet(false, true)) {
            return;
        }
        try {
            createIfEmpty(System.getenv(ENV));
        } catch (Exception e) {
            log.warn("admin_user 초기화 건너뜀 (DB 미기동 또는 테이블 없음): {}", e.getMessage());
        }
    }

    /** @return 계정을 만들었으면 true. 비밀번호 없음 또는 기존 계정 있음이면 false. */
    boolean createIfEmpty(String pw) {
        if (adminMapper.count() != 0) {
            return false;
        }
        if (pw == null || pw.trim().isEmpty()) {
            log.warn("admin_user가 비어 있으나 {} 가 없어 초기 관리자 계정을 만들지 않았습니다", ENV);
            return false;
        }
        adminMapper.insert("admin", new BCryptPasswordEncoder().encode(pw), "관리자");
        log.info("초기 관리자 계정 생성: admin");
        return true;
    }
}
