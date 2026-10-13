package com.ieum.bokji.controller;

import com.ieum.bokji.mapper.ResourceMapper;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

/** 랜딩 페이지. */
@Controller
public class HomeController {

    private final ResourceMapper resourceMapper;

    public HomeController(ResourceMapper resourceMapper) {
        this.resourceMapper = resourceMapper;
    }

    @GetMapping("/")
    public String index(Model model) {
        model.addAttribute("resourceCount", resourceMapper.activeCount());
        return "index";
    }
}
