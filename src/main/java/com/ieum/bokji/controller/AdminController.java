package com.ieum.bokji.controller;

import com.ieum.bokji.dto.AdminUser;
import com.ieum.bokji.dto.PageParam;
import com.ieum.bokji.dto.Resource;
import com.ieum.bokji.interceptor.AdminAuthInterceptor;
import com.ieum.bokji.mapper.AdminMapper;
import com.ieum.bokji.mapper.ReportMapper;
import com.ieum.bokji.mapper.ResourceMapper;
import com.ieum.bokji.service.AdminService;
import com.ieum.bokji.util.TextUtil;
import java.util.UUID;
import javax.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

/**
 * 관리자. 인증·CSRF는 AdminAuthInterceptor가 선검증(/admin/login 제외).
 * 로그인 5회 실패 시 세션 기준 10분 잠금.
 */
@Controller
@RequestMapping("/admin")
public class AdminController {

    private static final int MAX_FAIL = 5;
    private static final long LOCK_MILLIS = 10 * 60 * 1000L;

    private final BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();

    @Autowired
    private AdminMapper adminMapper;
    @Autowired
    private AdminService adminService;
    @Autowired
    private ResourceMapper resourceMapper;
    @Autowired
    private ReportMapper reportMapper;

    /* ---------- 로그인 ---------- */

    @GetMapping("/login")
    public String loginForm() {
        return "admin/login";
    }

    @PostMapping("/login")
    public String login(@RequestParam String loginId, @RequestParam String password,
                        HttpSession session, Model model) {
        Long lockUntil = (Long) session.getAttribute("loginLockUntil");
        if (lockUntil != null && lockUntil > System.currentTimeMillis()) {
            model.addAttribute("error", "로그인 5회 실패로 10분간 잠금되었습니다.");
            return "admin/login";
        }
        AdminUser admin = adminMapper.findByLoginId(loginId);
        if (admin != null && encoder.matches(password, admin.getPwHash())) {
            session.removeAttribute("loginFailCount");
            session.removeAttribute("loginLockUntil");
            session.setAttribute(AdminAuthInterceptor.ADMIN_ID, admin.getAdminId());
            session.setAttribute("adminName", admin.getName());
            session.setAttribute(AdminAuthInterceptor.CSRF_TOKEN, UUID.randomUUID().toString());
            return "redirect:/admin/resources";
        }
        Integer fail = (Integer) session.getAttribute("loginFailCount");
        fail = (fail == null) ? 1 : fail + 1;
        if (fail >= MAX_FAIL) {
            session.setAttribute("loginLockUntil", System.currentTimeMillis() + LOCK_MILLIS);
            session.removeAttribute("loginFailCount");
            model.addAttribute("error", "로그인 5회 실패로 10분간 잠금되었습니다.");
        } else {
            session.setAttribute("loginFailCount", fail);
            model.addAttribute("error", "아이디 또는 비밀번호가 올바르지 않습니다. (" + fail + "/" + MAX_FAIL + ")");
        }
        return "admin/login";
    }

    @GetMapping("/logout")
    public String logout(HttpSession session) {
        session.invalidate();
        return "redirect:/admin/login";
    }

    /* ---------- 자원 관리 ---------- */

    @GetMapping("/resources")
    public String resources(@ModelAttribute("p") PageParam p, Model model) {
        model.addAttribute("rows", resourceMapper.adminList(p));
        int total = resourceMapper.adminCount(p);
        model.addAttribute("total", total);
        model.addAttribute("totalPages", Math.max(1, (total + p.getSize() - 1) / p.getSize()));
        return "admin/resources";
    }

    @GetMapping("/resources/new")
    public String newForm(Model model) {
        model.addAttribute("resource", new Resource());
        model.addAttribute("formAction", "/admin/resources/new");
        return "admin/resource-form";
    }

    @PostMapping("/resources/new")
    public String create(@ModelAttribute Resource resource, HttpSession session) {
        adminService.create(resource, adminId(session));
        return "redirect:/admin/resources";
    }

    @GetMapping("/resources/{id}/edit")
    public String editForm(@PathVariable int id, Model model) {
        model.addAttribute("resource", resourceMapper.findById(id, "ko"));
        model.addAttribute("formAction", "/admin/resources/" + id + "/edit");
        return "admin/resource-form";
    }

    @PostMapping("/resources/{id}/edit")
    public String edit(@PathVariable int id, @ModelAttribute Resource resource, HttpSession session) {
        resource.setResourceId(id);
        adminService.update(resource, adminId(session));
        return "redirect:/admin/resources";
    }

    @PostMapping("/resources/{id}/status")
    public String changeStatus(@PathVariable int id, @RequestParam String status, HttpSession session) {
        if ("A".equals(status) || "H".equals(status) || "E".equals(status)) {
            adminService.changeStatus(id, status, adminId(session));
        }
        return "redirect:/admin/resources";
    }

    /* ---------- 제보 처리 ---------- */

    @GetMapping("/reports")
    public String reports(@ModelAttribute("p") PageParam p, Model model) {
        model.addAttribute("reports", reportMapper.list(p));
        model.addAttribute("total", reportMapper.count(p));
        return "admin/reports";
    }

    @PostMapping("/reports/{id}")
    public String processReport(@PathVariable int id, @RequestParam String status,
                                @RequestParam(required = false) String memo) {
        if ("R".equals(status) || "C".equals(status) || "D".equals(status) || "X".equals(status)) {
            reportMapper.updateStatus(id, status, TextUtil.cleanToNull(memo));
        }
        return "redirect:/admin/reports";
    }

    private static int adminId(HttpSession session) {
        return (Integer) session.getAttribute(AdminAuthInterceptor.ADMIN_ID);
    }
}
