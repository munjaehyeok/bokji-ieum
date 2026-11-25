package com.ieum.bokji.service;

import com.ieum.bokji.dto.StatsDailyRow;
import com.ieum.bokji.dto.StatsDimRow;
import com.ieum.bokji.dto.StatsResourceRow;
import com.ieum.bokji.dto.StatsSummary;
import com.ieum.bokji.mapper.StatsMapper;
import java.time.LocalDate;
import java.time.ZoneId;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.function.BiFunction;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.MessageSource;
import org.springframework.stereotype.Service;

/**
 * 관리자 이용 통계 (/admin/stats). match_log·event_log를 읽기만 한다.
 * 기간: 한국 날짜 기준 '오늘 포함 최근 N일'(7·30·90) 또는 전체(0).
 */
@Service
public class AdminStatsService {

    public static final ZoneId KST = ZoneId.of("Asia/Seoul");
    public static final int DEFAULT_DAYS = 30;
    private static final List<Integer> ALLOWED_DAYS = List.of(7, 30, 90, 0);

    /** 조건 분포 카드 순서와 제목 (관리자 화면은 한국어 고정) */
    public static final Map<String, String> DIM_TITLES;
    static {
        Map<String, String> m = new LinkedHashMap<>();
        m.put("AGE", "연령대");
        m.put("DONG", "거주 동");
        m.put("HH", "가구 상황 (복수 선택)");
        m.put("INCOME", "소득 구간");
        m.put("DIS", "장애 여부");
        m.put("NAT", "국적·체류");
        m.put("EDU", "학업·취업 (복수 선택)");
        DIM_TITLES = Collections.unmodifiableMap(m);
    }

    private static final String UNKNOWN = "";
    private static final String UNKNOWN_LABEL = "모름·건너뜀";

    @Autowired
    private StatsMapper statsMapper;
    @Autowired
    private MessageSource messageSource;

    public StatsSummary summary(int days) {
        StatsSummary s = statsMapper.summary(days);
        s.setViewedPct(pct(s.getViewedSessions(), s.getMatchedSessions()));
        s.setAppliedPct(pct(s.getAppliedSessions(), s.getMatchedSessions()));
        return s;
    }

    public List<StatsResourceRow> popularResources(int days) {
        List<StatsResourceRow> rows = statsMapper.popularResources(days);
        long top = rows.isEmpty() ? 0 : rows.get(0).getViews();
        for (StatsResourceRow r : rows) {
            r.setCategoryLabel(r.getCategory() == null ? "-" : msg("cat." + r.getCategory()));
            r.setBarPct(pct(r.getViews(), top));
        }
        return rows;
    }

    /** 분류별 막대 목록. 순서는 DIM_TITLES 순서. */
    public Map<String, List<StatsDimRow>> conditionBars(int days) {
        Map<String, List<StatsDimRow>> byDim = new LinkedHashMap<>();
        for (String dim : DIM_TITLES.keySet()) {
            byDim.put(dim, new ArrayList<>());
        }
        for (StatsDimRow row : statsMapper.conditionCounts(days)) {
            byDim.computeIfAbsent(row.getDim(), k -> new ArrayList<>()).add(row);
        }
        Map<String, List<StatsDimRow>> bars = new LinkedHashMap<>();
        byDim.forEach((dim, rows) -> bars.put(dim, toBars(dim, rows, this::label)));
        return bars;
    }

    public List<StatsDailyRow> daily(int days) {
        return statsMapper.daily(days);
    }

    /* ---------- 아래는 DB 없이 단위 테스트하는 순수 함수 ---------- */

    /** 허용 값(7·30·90·0=전체)만 받고 나머지는 기본 30일. */
    public static int normalizeDays(String raw) {
        if (raw != null) {
            try {
                int d = Integer.parseInt(raw.trim());
                if (ALLOWED_DAYS.contains(d)) {
                    return d;
                }
            } catch (NumberFormatException ignored) {
                // 숫자가 아니면 기본값
            }
        }
        return DEFAULT_DAYS;
    }

    /** 반올림한 백분율. 분모가 0이면 0. */
    public static int pct(long part, long whole) {
        return whole <= 0 ? 0 : (int) Math.round(part * 100.0 / whole);
    }

    public static String periodLabel(int days, LocalDate today) {
        if (days == 0) {
            return "전체 기간";
        }
        return "최근 " + days + "일 (" + today.minusDays(days - 1) + " ~ " + today + ", 한국 시간)";
    }

    /** match_log.age_band("60s") → "60대". 0s는 10세 미만, 100s 이상은 100세 이상. */
    public static String ageLabel(String band) {
        int n = ageOrder(band);
        if (n == Integer.MAX_VALUE) {
            return UNKNOWN_LABEL;
        }
        if (n == 0) {
            return "10세 미만";
        }
        if (n >= 100) {
            return "100세 이상";
        }
        return n + "대";
    }

    /** 연령대 정렬 순서. 모름·이상한 값은 맨 뒤. */
    static int ageOrder(String band) {
        if (band == null || !band.matches("\\d+s")) {
            return Integer.MAX_VALUE;
        }
        return Integer.parseInt(band.substring(0, band.length() - 1));
    }

    /**
     * SQL 집계(분류·값·건수)를 화면 막대로 바꾼다.
     * 복수 선택(가구 상황·학업/취업)은 "ONE,SPAR"처럼 쉼표로 저장돼 있어서 값마다 나눠 더한다.
     * 비율의 분모는 검색 수라서 복수 선택 항목은 합이 100%를 넘을 수 있다.
     */
    static List<StatsDimRow> toBars(String dim, List<StatsDimRow> rows,
                                    BiFunction<String, String, String> labeler) {
        boolean multi = "HH".equals(dim) || "EDU".equals(dim);
        long base = 0;
        Map<String, Long> counts = new LinkedHashMap<>();
        for (StatsDimRow r : rows) {
            base += r.getCnt();
            String code = r.getCode() == null ? UNKNOWN : r.getCode().trim();
            if (multi && !code.isEmpty()) {
                for (String one : code.split(",")) {
                    counts.merge(one.trim(), r.getCnt(), Long::sum);
                }
            } else {
                counts.merge(code, r.getCnt(), Long::sum);
            }
        }
        List<StatsDimRow> bars = new ArrayList<>();
        for (Map.Entry<String, Long> c : counts.entrySet()) {
            StatsDimRow b = new StatsDimRow();
            b.setDim(dim);
            b.setCode(c.getKey());
            b.setCnt(c.getValue());
            b.setLabel(labeler.apply(dim, c.getKey()));
            b.setPct(pct(c.getValue(), base));
            bars.add(b);
        }
        if ("AGE".equals(dim)) {
            bars.sort(Comparator.comparingInt(b -> ageOrder(b.getCode())));
        } else {
            bars.sort(Comparator.comparingLong(StatsDimRow::getCnt).reversed()
                    .thenComparing(StatsDimRow::getLabel));
        }
        return bars;
    }

    /** 코드 → 화면 이름. 기존 messages_ko.properties 라벨을 그대로 쓴다. */
    private String label(String dim, String code) {
        if (code == null || code.isEmpty()) {
            return "INCOME".equals(dim) ? msg("income.0") : UNKNOWN_LABEL;
        }
        switch (dim) {
            case "AGE":    return ageLabel(code);
            case "DONG":   return msg("dong." + code);
            case "HH":     return msg("hh." + code);
            case "INCOME": return msg("income." + code);
            case "DIS":    return msg("dis." + code);
            case "NAT":    return msg("nat." + code);
            case "EDU":    return msg("ew." + code);
            default:       return code;
        }
    }

    private String msg(String key) {
        return messageSource.getMessage(key, null, key, Locale.KOREAN);
    }
}