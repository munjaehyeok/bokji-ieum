package com.ieum.bokji.controller;

import com.ieum.bokji.dto.MatchResultRow;
import com.ieum.bokji.dto.ResourceSearch;
import com.ieum.bokji.mapper.ResourceMapper;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Locale;
import java.util.Set;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

/** 탐색 모드 — 조건 입력 없이 시흥 자원을 둘러본다(자격 판정 아님). 계약: docs/설계/07-탐색모드.md */
@Controller
public class ResourceBrowseController {

    /** 인기순을 믿을 만한 최소 표본(상세 조회 이벤트 수). 미만이면 이름순으로 대체. */
    static final int POPULAR_MIN_SAMPLE = 30;
    static final Set<String> DONGS = new HashSet<>(Arrays.asList(
            "GJ", "WG", "BG1", "BG2", "JWB", "JW1", "JW2", "JW3", "JW4", "JG", "EH", "DY", "SC", "SH", "GL", "MG", "MH", "NG", "YS"));

    @Autowired
    private ResourceMapper resourceMapper;

    @GetMapping("/resources")
    public String browse(@RequestParam(required = false) String[] cat,
                         @RequestParam(required = false) String[] life,
                         @RequestParam(required = false) String[] hh,
                         @RequestParam(required = false) String age,
                         @RequestParam(required = false) String strict,
                         @RequestParam(required = false) String incx,
                         @RequestParam(required = false) String dong,
                         @RequestParam(required = false) String q,
                         @RequestParam(required = false) String xq,
                         @RequestParam(required = false) String online,
                         @RequestParam(required = false) String ids,
                         @RequestParam(required = false) String sort,
                         @RequestParam(required = false) String page,
                         Model model, Locale locale) {
        ResourceSearch s = ResourceSearch.of(cat, life, hh, age, strict, incx, dong, q, xq, online, ids, sort, page, DONGS);
        boolean popularFallback = false;
        if ("popular".equals(s.getSort()) && resourceMapper.popularSample() < POPULAR_MIN_SAMPLE) {
            s.setSort("");
            popularFallback = true;
        }
        String lang = locale.getLanguage();
        int total = (s.isIdsMode() && s.getIds().isEmpty()) ? 0 : resourceMapper.browseCount(s, lang);
        s.fitPage(total);
        List<MatchResultRow> rows = total == 0 ? Collections.<MatchResultRow>emptyList() : resourceMapper.browse(s, lang);
        int last = Math.max(1, (total + ResourceSearch.PAGE_SIZE - 1) / ResourceSearch.PAGE_SIZE);
        model.addAttribute("baseQuery", baseQuery(s));
        model.addAttribute("s", s);
        model.addAttribute("rows", rows);
        model.addAttribute("total", total);
        model.addAttribute("lastPage", last);
        model.addAttribute("popularFallback", popularFallback);
        model.addAttribute("lifeCodes", ResourceSearch.LIFE.keySet());
        model.addAttribute("dongCodes", Arrays.asList("GJ", "WG", "BG1", "BG2", "JWB", "JW1", "JW2", "JW3", "JW4", "JG", "EH", "DY", "SC", "SH", "GL", "MG", "MH", "NG", "YS"));
        return "resource/list";
    }

    /** 정렬·쪽 이동 링크용: 검증된 값만 다시 인코딩(sort·page 제외). */
    static String baseQuery(ResourceSearch s) {
        org.springframework.web.util.UriComponentsBuilder b = org.springframework.web.util.UriComponentsBuilder.newInstance();
        for (String v : s.getCat()) b.queryParam("cat", v);
        for (String v : s.getLife()) b.queryParam("life", v);
        for (String v : s.getHh()) b.queryParam("hh", v);
        if (s.getAge() != null) b.queryParam("age", s.getAge());
        if (s.isStrict()) b.queryParam("strict", "1");
        if (s.isIncx()) b.queryParam("incx", "1");
        if (s.getDong() != null) b.queryParam("dong", s.getDong());
        if (!s.getRawWords().isEmpty()) b.queryParam("q", String.join(" ", s.getRawWords()));
        if (!s.getRawExWords().isEmpty()) b.queryParam("xq", String.join(" ", s.getRawExWords()));
        if (s.isOnline()) b.queryParam("online", "1");
        if (s.isIdsMode()) b.queryParam("ids", s.getIds().stream().map(String::valueOf).collect(java.util.stream.Collectors.joining(",")));
        String q = b.build().encode().toUriString();
        return q.startsWith("?") ? q.substring(1) : q;
    }
}
