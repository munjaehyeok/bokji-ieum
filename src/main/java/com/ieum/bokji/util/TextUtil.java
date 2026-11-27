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

    // 완전한 전화번호: 031)123-4567(여는 괄호 누락 입력 포함) · (031)123-4567 · 031 123 4567 · +82 31 123 4567 · 1588-0000
    private static final String PHONE_RE =
            "(?:\\(?\\s*0\\d{1,2}\\s*\\)?|\\+82[\\s-]*\\d{1,2})[\\s.-]*\\d{3,4}[\\s.-]*\\d{4}|1[5-9]\\d{2}[\\s-]?\\d{4}";
    private static final Pattern PHONE = Pattern.compile(PHONE_RE);
    // 칸 구분: 쉼표·세미콜론·슬래시·줄바꿈 (공백만으로 이어진 여러 번호는 아래에서 번호 단위로 나눈다)
    private static final Pattern SEG_SEP = Pattern.compile("\\s*[,;/\\r\\n]+\\s*");
    private static final Pattern DEAD = Pattern.compile("삭제|폐지|폐기|종료|중단");

    /**
     * 여러 전화번호가 한 칸에 들어 있는 값을 번호별로 나눈다 (JSP 함수 bk:phones). null·빈 값은 빈 목록.
     * 한 칸 안에 완전한 번호가 둘 이상이면 번호 시작 위치에서 다시 나누고,
     * "031-310-5842, 5834" 같은 내선 줄임 표기는 앞 번호에 붙인다. 라벨·메모("(삭제)" 등)는 그대로 둔다.
     */
    public static List<String> splitPhones(String v) {
        List<String> out = new ArrayList<>();
        if (v == null) {
            return out;
        }
        for (String part : SEG_SEP.split(v.trim())) {
            String t = part.trim();
            if (t.isEmpty()) {
                continue;
            }
            if (!out.isEmpty() && t.matches("\\d{1,4}")) {
                out.set(out.size() - 1, out.get(out.size() - 1) + ", " + t);
                continue;
            }
            java.util.regex.Matcher m = PHONE.matcher(t);
            List<Integer> starts = new ArrayList<>();
            while (m.find()) {
                starts.add(m.start());
            }
            if (starts.size() < 2) {
                out.add(t);
                continue;
            }
            int from = 0;
            for (int i = 1; i < starts.size(); i++) {
                out.add(t.substring(from, starts.get(i)).trim());
                from = starts.get(i);
            }
            out.add(t.substring(from).trim());
        }
        return out;
    }

    /** tel: 링크용: 첫 완전한 번호의 숫자(와 선행 +)만. 번호가 없거나 삭제·폐지 표시가 있으면 빈 문자열(링크 대신 글자로 표시). */
    public static String telDigits(String v) {
        if (v == null || DEAD.matcher(v).find()) {
            return "";
        }
        java.util.regex.Matcher m = PHONE.matcher(v);
        return m.find() ? m.group().replaceAll("[^\\d+]", "") : "";
    }
}
