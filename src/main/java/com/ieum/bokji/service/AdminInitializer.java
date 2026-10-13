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

/** 기동 시 admin_user가 비어 있으면 admin / ieum2026! (BCrypt) 초기 계정 생성. */
@Component
public class AdminInitializer implements ApplicationListener<ContextRefreshedEvent> {

    private static final Logger log = LoggerFactory.getLogger(AdminInitializer.class);
    private final AtomicBoolean done = new AtomicBoolean(false);

    @Autowired
    private AdminMapper adminMapper;

    @Override
    public void onApplicationEvent(ContextRefreshedEvent event) {
        if (!done.compareAndSet(false, true)) {
            return;
        }
        try {
            if (adminMapper.count() == 0) {
                String hash = new BCryptPasswordEncoder().encode("ieum2026!");
                adminMapper.insert("admin", hash, "관리자");
                log.info("초기 관리자 계정 생성: admin");
            }
        } catch (Exception e) {
            log.warn("admin_user 초기화 건너뜀 (DB 미기동 또는 테이블 없음): {}", e.getMessage());
        }
    }
}
