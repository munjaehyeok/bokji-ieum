package com.ieum.bokji.util;

import java.time.LocalDate;

/** 출생연도 → 나이(연 나이 = 올해 - 출생연도). */
public final class AgeUtil {

    private AgeUtil() {
    }

    public static int toAge(int birthYear) {
        return toAge(birthYear, LocalDate.now().getYear());
    }

    public static int toAge(int birthYear, int currentYear) {
        if (birthYear <= 0 || birthYear > currentYear) {
            throw new IllegalArgumentException("invalid birthYear: " + birthYear);
        }
        return currentYear - birthYear;
    }
}
