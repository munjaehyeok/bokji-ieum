package com.ieum.bokji.util;

import org.jsoup.Jsoup;
import org.jsoup.parser.Parser;
import org.jsoup.safety.Safelist;

/** 입력 정화 공용 유틸 (제보·관리자 입력). */
public final class TextUtil {

    private TextUtil() {
    }

    /** HTML 태그 전부 제거한 순수 텍스트 반환 (엔티티 재이스케이프 없이 저장 — 출력은 c:out 담당). */
    public static String clean(String v) {
        if (v == null) {
            return null;
        }
        String stripped = Jsoup.clean(v, Safelist.none());
        return Parser.unescapeEntities(stripped, false).trim();
    }

    /** 정화 + 빈 문자열은 null로 (NULL=무관 규약 유지). */
    public static String cleanToNull(String v) {
        String c = clean(v);
        return (c == null || c.isEmpty()) ? null : c;
    }
}
