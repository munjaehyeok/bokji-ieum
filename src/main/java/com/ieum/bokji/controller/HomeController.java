package com.ieum.bokji.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

/** 랜딩 페이지. 기능 구현은 다음 단계(MatchController 등)에서. */
@Controller
public class HomeController {

    @GetMapping("/")
    public String index() {
        return "index";
    }
}
