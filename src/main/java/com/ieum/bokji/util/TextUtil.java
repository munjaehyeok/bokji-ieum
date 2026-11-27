package com.ieum.bokji.util;

import org.jsoup.Jsoup;
import org.jsoup.parser.Parser;
import org.jsoup.safety.Safelist;

import java.util.ArrayList;
import java.util.List;
import java.util.regex.Pattern;

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

    // 구분자: 쉼표·세미콜론·슬래시·줄바꿈, 공백 2칸 이상, 숫자 뒤 공백 + 지역번호(0xx-)로 시작하는 다음 번호
    private static final Pattern PHONE_SEP =
            Pattern.compile("\\s*[,;/\\r\\n]+\\s*|\\s{2,}|(?<=\\d)\\s+(?=0\\d{1,2}-\\d)");

    /** 여러 전화번호가 한 칸에 들어 있는 값을 번호별로 나눈다 (JSP 함수 bk:phones). null·빈 값은 빈 목록. */
    public static List<String> splitPhones(String v) {
        List<String> out = new ArrayList<>();
        if (v == null) {
            return out;
        }
        for (String part : PHONE_SEP.split(v.trim())) {
            String t = part.trim();
            if (t.isEmpty()) {
                continue;
            }
            // "031-310-5842, 5834" 같은 내선 줄임 표기는 별도 번호가 아니라 앞 번호에 붙인다
            if (!out.isEmpty() && t.matches("\\d{1,4}")) {
                out.set(out.size() - 1, out.get(out.size() - 1) + ", " + t);
            } else {
                out.add(t);
            }
        }
        return out;
    }

    /** tel: 링크용: 숫자와 선행 +만 남긴다. 숫자가 없으면 빈 문자열(링크 대신 글자로 표시). */
    public static String telDigits(String v) {
        if (v == null) {
            return "";
        }
        // 괄호 앞 기관명 등은 버리고 첫 번호 덩어리만 쓴다 ("031-310-5842, 5834" → 031-310-5842)
        java.util.regex.Matcher m = Pattern.compile("\\+?\\d[\\d\\- ]{4,}\\d").matcher(v);
        return m.find() ? m.group().replaceAll("[^\\d+]", "") : "";
    }
}
