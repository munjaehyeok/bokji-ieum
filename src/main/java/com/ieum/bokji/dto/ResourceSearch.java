package com.ieum.bokji.dto;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

/** 탐색 모드 쿼리 (docs/설계/07-탐색모드.md). 허용값 밖의 입력은 조용히 버린다. */
public class ResourceSearch {

    /** 생애주기 연령 구간(MyBatis에서 lo/hi로 접근). */
    public static final class Range {
        private final int lo, hi;
        Range(int lo, int hi) { this.lo = lo; this.hi = hi; }
        public int getLo() { return lo; }
        public int getHi() { return hi; }
    }

    public static final int PAGE_SIZE = 12;
    private static final Set<String> CATS = new java.util.HashSet<>(Arrays.asList(
            "JOB", "HOUSE", "DAILY", "HEALTH", "MIND", "CARE", "EDU", "CULTURE", "RIGHTS"));
    private static final Set<String> HH = new java.util.HashSet<>(Arrays.asList(
            "LOW", "DIS", "SPAR", "MCHD", "MCUL", "NKOR", "ONE", "PREG", "FOR"));
    /** 생애주기 코드 → {하한, 상한}. */
    public static final Map<String, Range> LIFE = new LinkedHashMap<>();
    static {
        LIFE.put("INF", new Range(0, 5));
        LIFE.put("CHD", new Range(6, 12));
        LIFE.put("TEEN", new Range(13, 18));
        LIFE.put("YOUTH", new Range(19, 39));
        LIFE.put("MID", new Range(40, 64));
        LIFE.put("SENIOR", new Range(65, 200));
    }

    private List<String> cat = new ArrayList<>();
    private List<String> life = new ArrayList<>();
    private List<Range> lifeRanges = new ArrayList<>();
    private List<String> hh = new ArrayList<>();
    private Integer age;
    private boolean strict;
    private boolean incx;
    private String dong;
    private List<String> words = new ArrayList<>();      // 이스케이프된 LIKE 패턴 조각
    private List<String> exWords = new ArrayList<>();
    private List<String> rawWords = new ArrayList<>();   // 화면 재표시용 원문
    private List<String> rawExWords = new ArrayList<>();
    private boolean online;
    private List<Integer> ids = new ArrayList<>();
    private boolean idsMode;
    private String sort = "";
    private int page = 1;
    private int offset;
    private int limit = PAGE_SIZE;

    /** 요청 파라미터 → 검증된 검색 객체. 모든 값은 허용 집합/범위로 걸러진다. */
    public static ResourceSearch of(String[] cat, String[] life, String[] hh, String age, String strict, String incx,
                                    String dong, String q, String xq, String online, String ids, String sort, String page,
                                    Set<String> dongCodes) {
        ResourceSearch s = new ResourceSearch();
        s.cat = pick(cat, CATS);
        s.life = pick(life, LIFE.keySet());
        for (String l : s.life) s.lifeRanges.add(LIFE.get(l));
        s.hh = pick(hh, HH);
        if (age != null && age.matches("\\d{1,3}") && Integer.parseInt(age) <= 120) s.age = Integer.valueOf(age);
        s.strict = "1".equals(strict);
        s.incx = "1".equals(incx);
        if (dong != null && dongCodes.contains(dong)) s.dong = dong;
        s.rawWords = split(q);
        s.rawExWords = split(xq);
        for (String w : s.rawWords) s.words.add(escapeLike(w));
        for (String w : s.rawExWords) s.exWords.add(escapeLike(w));
        s.online = "1".equals(online);
        if (ids != null) {
            s.idsMode = true;
            for (String t : ids.split(",")) {
                if (s.ids.size() >= 50) break;
                t = t.trim();
                if (t.matches("\\d{1,9}") && !s.ids.contains(Integer.valueOf(t))) s.ids.add(Integer.valueOf(t));
            }
        }
        s.sort = ("latest".equals(sort) || "popular".equals(sort)) ? sort : "";
        s.page = (page != null && page.matches("\\d{1,6}")) ? Math.max(1, Integer.parseInt(page)) : 1;
        return s;
    }

    private static List<String> pick(String[] raw, Set<String> allowed) {
        List<String> out = new ArrayList<>();
        if (raw == null) return out;
        for (String r : raw) {
            for (String t : r.split(",")) {
                t = t.trim();
                if (allowed.contains(t) && !out.contains(t)) out.add(t);
            }
        }
        return out;
    }

    /** 공백 구분, 최대 5단어, 단어당 30자. */
    private static List<String> split(String q) {
        List<String> out = new ArrayList<>();
        if (q == null) return out;
        for (String t : q.trim().split("\\s+")) {
            if (t.isEmpty() || out.size() >= 5) continue;
            out.add(t.length() > 30 ? t.substring(0, 30) : t);
        }
        return out;
    }

    static String escapeLike(String w) {
        return w.replace("\\", "\\\\").replace("%", "\\%").replace("_", "\\_");
    }

    /** 총 건수가 정해진 뒤 페이지를 보정하고 offset 계산. */
    public void fitPage(int total) {
        int last = Math.max(1, (total + PAGE_SIZE - 1) / PAGE_SIZE);
        page = Math.min(page, last);
        offset = (page - 1) * PAGE_SIZE;
    }

    public List<String> getCat() { return cat; }
    public List<String> getLife() { return life; }
    public List<Range> getLifeRanges() { return lifeRanges; }
    public List<String> getHh() { return hh; }
    public Integer getAge() { return age; }
    public boolean isStrict() { return strict; }
    public boolean isIncx() { return incx; }
    public String getDong() { return dong; }
    public List<String> getWords() { return words; }
    public List<String> getExWords() { return exWords; }
    public List<String> getRawWords() { return rawWords; }
    public List<String> getRawExWords() { return rawExWords; }
    public boolean isOnline() { return online; }
    public List<Integer> getIds() { return ids; }
    public boolean isIdsMode() { return idsMode; }
    public String getSort() { return sort; }
    public void setSort(String s) { sort = s; }
    public int getPage() { return page; }
    public int getOffset() { return offset; }
    public int getLimit() { return limit; }
}
