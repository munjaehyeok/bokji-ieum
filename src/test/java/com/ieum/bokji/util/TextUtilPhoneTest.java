package com.ieum.bokji.util;

import static org.junit.Assert.assertEquals;

import java.util.Arrays;
import java.util.Collections;
import org.junit.Test;

public class TextUtilPhoneTest {

    @Test
    public void splitsNewlineCommaSlashAndSpaces() {
        assertEquals(Arrays.asList("031-431-5680", "031-404-5683", "070-7725-5534"),
                TextUtil.splitPhones("031-431-5680\n031-404-5683\n070-7725-5534"));
        assertEquals(Arrays.asList("031-314-6395", "070-4204-5853"),
                TextUtil.splitPhones("031-314-6395/\n070-4204-5853"));
        assertEquals(Arrays.asList("070-7008-8894", "031-432-3549"),
                TextUtil.splitPhones("070-7008-8894,\n031-432-3549"));
        assertEquals(Arrays.asList("031-310-5850", "031-310-6803"),
                TextUtil.splitPhones("031-310-5850                  031-310-6803"));
        assertEquals(Arrays.asList("031-411-0999", "070-8821-8004"),
                TextUtil.splitPhones("031-411-0999, 070-8821-8004"));
    }

    @Test
    public void extensionShorthandStaysWithPreviousNumber() {
        assertEquals(Collections.singletonList("031-310-5842, 5834"), TextUtil.splitPhones("031-310-5842,5834"));
        assertEquals(Collections.singletonList("031-310-3692, 2059"), TextUtil.splitPhones("031-310-3692/2059"));
    }

    @Test
    public void emptyAndNull() {
        assertEquals(Collections.emptyList(), TextUtil.splitPhones(null));
        assertEquals(Collections.emptyList(), TextUtil.splitPhones("  "));
    }

    @Test
    public void telDigits() {
        assertEquals("0314315680", TextUtil.telDigits("031-431-5680"));
        assertEquals("0313166661", TextUtil.telDigits("031-316-6661, 3"));
        assertEquals("16660420", TextUtil.telDigits("(광역센터)1666-0420"));
        assertEquals("", TextUtil.telDigits("각 시군 노인복지과"));
        assertEquals("", TextUtil.telDigits(null));
    }

    @Test
    public void formatsReportedByReview() {
        assertEquals("0311234567", TextUtil.telDigits("(031)123-4567"));
        assertEquals("0314319114", TextUtil.telDigits("031)431-9114"));
        assertEquals(Arrays.asList("031  123 4567"), TextUtil.splitPhones("031  123 4567"));
        assertEquals(Arrays.asList("031 123 4567", "032 234 5678"), TextUtil.splitPhones("031 123 4567 032 234 5678"));
        assertEquals(Arrays.asList("031-123-4567", "1588-0000"), TextUtil.splitPhones("031-123-4567 1588-0000"));
        assertEquals("0311234567", TextUtil.telDigits("(2026-11-27 기준)031-123-4567"));
        assertEquals("+82311234567", TextUtil.telDigits("+82 31 123 4567"));
    }

    @Test
    public void deletedNumberHasNoLink() {
        assertEquals("", TextUtil.telDigits("031-310-0724(삭제)"));
        assertEquals("0313105833", TextUtil.telDigits("031-310-5833"));
    }

    @Test
    public void localNumberWithoutAreaCodeStillLinks() {
        assertEquals("3102756", TextUtil.telDigits("310-2756"));
        assertEquals("4352351", TextUtil.telDigits("435-2351"));
        // 실제 ID 1001: 일반 번호는 링크, 폐기 번호는 글자만
        assertEquals("3105935", TextUtil.telDigits("310-5935"));
        assertEquals("", TextUtil.telDigits("310-0724(삭제)"));
    }

    @Test
    public void rejectsPartOfLongerDigitRun() {
        assertEquals("", TextUtil.telDigits("031-123-45678"));
        assertEquals("0312345678", TextUtil.telDigits("참조번호 003112345678999, 031-234-5678"));
    }

    @Test
    public void labelledNumbersAreNotSplitOrLinked() {
        assertEquals(Collections.singletonList("대야점 031-123-4567 정왕점 032-234-5678"),
                TextUtil.splitPhones("대야점 031-123-4567 정왕점 032-234-5678"));
        assertEquals("", TextUtil.telDigits("대야점 031-123-4567 정왕점 032-234-5678"));
        assertEquals("", TextUtil.telDigits("대야점 031-123-4567 폐기 번호: 032-234-5678"));
    }

    @Test
    public void translationUsedOnlyWhenNumbersMatch() {
        String ko = "대야점 031-123-4567, 정왕점 032-234-5678";
        assertEquals(false, TextUtil.phonesAligned(ko, "Jeongwang 032-234-5678, Daeya 031-123-4567"));
        assertEquals(true, TextUtil.phonesAligned(ko, "Daeya 031-123-4567, Jeongwang 032-234-5678"));
        // 관리자가 원문만 고친 경우: 오래된 번역은 쓰지 않는다
        assertEquals(false, TextUtil.sameNumbers("031-123-4567, 032-999-9999", "031-123-4567, 032-234-5678"));
        assertEquals(true, TextUtil.sameNumbers(ko, "Jeongwang 032-234-5678, Daeya 031-123-4567"));
        assertEquals("031-123-4567", TextUtil.firstPhone("031-123-4567, 032-234-5678", "032-234-5678, 031-123-4567").equals("032-234-5678")
                ? "bad" : "031-123-4567");
        // ID 1061: 번역 라벨 안 구분자로 조각 수가 달라도 번호는 같다
        String k = "(광역센터)1666-0420\n(시군센터)1522-3650";
        String e = "(Provincial center)1666-0420\n(City/county center)1522-3650";
        assertEquals(true, TextUtil.sameNumbers(k, e));
        assertEquals("(Provincial center)1666-0420", TextUtil.firstPhone(k, e));
    }
}
