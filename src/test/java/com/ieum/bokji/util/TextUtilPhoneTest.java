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
}
