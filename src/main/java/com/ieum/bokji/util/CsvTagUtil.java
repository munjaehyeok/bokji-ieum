package com.ieum.bokji.util;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/** 태그 CSV("A,B,C") ↔ 리스트 변환. DB CSV 태깅 7필드 공용. */
public final class CsvTagUtil {

    private CsvTagUtil() {
    }

    public static List<String> toList(String csv) {
        if (csv == null || csv.isBlank()) {
            return Collections.emptyList();
        }
        List<String> result = new ArrayList<>();
        for (String token : csv.split(",")) {
            String trimmed = token.trim();
            if (!trimmed.isEmpty()) {
                result.add(trimmed);
            }
        }
        return result;
    }

    public static String toCsv(List<String> tags) {
        if (tags == null || tags.isEmpty()) {
            return "";
        }
        return String.join(",", tags);
    }
}
