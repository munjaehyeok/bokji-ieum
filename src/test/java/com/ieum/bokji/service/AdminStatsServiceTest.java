package com.ieum.bokji.service;

import static org.junit.Assert.assertEquals;

import com.ieum.bokji.dto.StatsDimRow;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import org.junit.Test;

public class AdminStatsServiceTest {

    private static StatsDimRow row(String dim, String code, long cnt) {
        StatsDimRow r = new StatsDimRow();
        r.setDim(dim);
        r.setCode(code);
        r.setCnt(cnt);
        return r;
    }

    @Test
    public void daysParamAcceptsOnlyAllowedValues() {
        assertEquals(7, AdminStatsService.normalizeDays("7"));
        assertEquals(90, AdminStatsService.normalizeDays(" 90 "));
        assertEquals(0, AdminStatsService.normalizeDays("0"));
        assertEquals(30, AdminStatsService.normalizeDays(null));
        assertEquals(30, AdminStatsService.normalizeDays("365"));
        assertEquals(30, AdminStatsService.normalizeDays("abc"));
    }

    @Test
    public void percentRoundsAndHandlesZero() {
        assertEquals(0, AdminStatsService.pct(3, 0));
        assertEquals(33, AdminStatsService.pct(1, 3));
        assertEquals(67, AdminStatsService.pct(2, 3));
        assertEquals(100, AdminStatsService.pct(5, 5));
    }

    @Test
    public void ageBandLabels() {
        assertEquals("10세 미만", AdminStatsService.ageLabel("0s"));
        assertEquals("60대", AdminStatsService.ageLabel("60s"));
        assertEquals("100세 이상", AdminStatsService.ageLabel("100s"));
        assertEquals("모름·건너뜀", AdminStatsService.ageLabel(null));
    }

    @Test
    public void periodLabelIncludesToday() {
        assertEquals("최근 7일 (2026-11-20 ~ 2026-11-26, 한국 시간)",
                AdminStatsService.periodLabel(7, LocalDate.of(2026, 11, 26)));
        assertEquals("전체 기간", AdminStatsService.periodLabel(0, LocalDate.of(2026, 11, 26)));
    }

    @Test
    public void multiSelectValuesAreSplitAndUseSearchCountAsBase() {
        List<StatsDimRow> rows = new ArrayList<>();
        rows.add(row("HH", "ONE,SPAR", 3));
        rows.add(row("HH", "ONE", 2));
        rows.add(row("HH", null, 1));

        List<StatsDimRow> bars = AdminStatsService.toBars("HH", rows,
                (dim, code) -> code.isEmpty() ? "모름" : code);

        assertEquals(3, bars.size());
        assertEquals("ONE", bars.get(0).getCode());
        assertEquals(5, bars.get(0).getCnt());
        assertEquals(83, bars.get(0).getPct());   // 5 / 검색 6건
        assertEquals("SPAR", bars.get(1).getCode());
        assertEquals(50, bars.get(1).getPct());   // 3 / 6
        assertEquals("모름", bars.get(2).getLabel());
        assertEquals(17, bars.get(2).getPct());   // 1 / 6
    }

    @Test
    public void ageBarsKeepAgeOrderWithUnknownLast() {
        List<StatsDimRow> rows = new ArrayList<>();
        rows.add(row("AGE", "60s", 1));
        rows.add(row("AGE", null, 5));
        rows.add(row("AGE", "10s", 2));

        List<StatsDimRow> bars = AdminStatsService.toBars("AGE", rows, (dim, code) -> code);

        assertEquals("10s", bars.get(0).getCode());
        assertEquals("60s", bars.get(1).getCode());
        assertEquals("", bars.get(2).getCode());
    }
}