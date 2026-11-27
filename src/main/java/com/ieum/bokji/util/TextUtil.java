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
    // 숫자열 일부·하이픈 뒤 조각은 번호로 보지 않는다(lookbehind/lookahead). 국번 생략 형식(310-2756)도 번호로 인정.
    private static final String PHONE_RE =
            "(?<![\\d-])(?:(?:\\(?\\s*0\\d{1,2}\\s*\\)?|\\+82[\\s-]*\\d{1,2})[\\s.-]*\\d{3,4}[\\s.-]*\\d{4}"
                    + "|1[5-9]\\d{2}[\\s-]?\\d{4}|\\d{3,4}-\\d{4})(?!\\d)";
    private static final Pattern PHONE = Pattern.compile(PHONE_RE);
    // 칸 구분: 쉼표·세미콜론·슬래시·줄바꿈 (공백만으로 이어진 여러 번호는 아래에서 번호 단위로 나눈다)
    private static final Pattern SEG_SEP = Pattern.compile("\\s*[,;/\\r\\n]+\\s*");
    private static final Pattern DEAD = Pattern.compile("삭제|폐지|폐기|종료|중단|deleted|discontinued|closed|已删除|删除|废止|đã xóa|ngừng");

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
        String pending = "";
        for (String part : SEG_SEP.split(v.trim())) {
            String t = part.trim();
            if (t.isEmpty()) {
                continue;
            }
            // "폐기 번호:\n031-…" — 번호 없는 상태 라벨은 이어지는 번호에 붙여 상태를 잃지 않게 한다
            if (!PHONE.matcher(t).find() && !t.matches("\\d{1,4}") && (DEAD.matcher(t).find() || t.endsWith(":"))) {
                pending = pending.isEmpty() ? t : pending + " " + t;
                continue;
            }
            if (!pending.isEmpty()) {
                t = pending + " " + t;
                pending = "";
            }
            if (!out.isEmpty() && t.matches("\\d{1,4}")) {
                out.set(out.size() - 1, out.get(out.size() - 1) + ", " + t);
                continue;
            }
            java.util.regex.Matcher m = PHONE.matcher(t);
            List<Integer> starts = new ArrayList<>();
            List<Integer> ends = new ArrayList<>();
            while (m.find()) {
                starts.add(m.start());
                ends.add(m.end());
            }
            // 번호 사이가 공백·구두점뿐일 때만 번호 단위로 나눈다. 사이에 글자(지점명·상태)가 있으면
            // 어느 번호에 붙는 말인지 알 수 없으므로 원문 그대로 한 항목으로 둔다(telDigits도 링크를 만들지 않음).
            boolean pure = starts.size() >= 2;
            for (int i = 1; pure && i < starts.size(); i++) {
                if (!t.substring(ends.get(i - 1), starts.get(i)).matches("[\\s.,;·]*")) {
                    pure = false;
                }
            }
            if (!pure) {
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
        if (!pending.isEmpty()) {
            out.add(pending);
        }
        return out;
    }

    /** tel: 링크용: 첫 완전한 번호의 숫자(와 선행 +)만. 번호가 없거나 삭제·폐지 표시가 있으면 빈 문자열(링크 대신 글자로 표시). */
    public static String telDigits(String v) {
        if (v == null || DEAD.matcher(v).find()) {
            return "";
        }
        if (v.trim().matches("1\\d{2}")) {
            return v.trim(); // 112·119·123 같은 단독 단축번호
        }
        java.util.regex.Matcher m = PHONE.matcher(v);
        if (!m.find()) {
            return "";
        }
        String first = m.group().replaceAll("[^\\d+]", "");
        return m.find() ? "" : first;
    }

    private static List<String> numbers(String v) {
        List<String> r = new ArrayList<>();
        if (v != null) {
            java.util.regex.Matcher m = PHONE.matcher(v);
            while (m.find()) {
                r.add(m.group().replaceAll("[^\\d+]", ""));
            }
        }
        return r;
    }

    /** 원문·번역 조각이 같은 수이고 번호별 통화 대상이 모두 같을 때만 true (라벨을 번호별로 대응해도 안전). */
    public static boolean phonesAligned(String phone, String phoneTr) {
        List<String> a = splitPhones(phone);
        List<String> b = splitPhones(phoneTr);
        if (b.isEmpty() || a.size() != b.size()) {
            return false;
        }
        for (int i = 0; i < a.size(); i++) {
            if (!pieceMatches(a.get(i), b.get(i))) {
                return false;
            }
        }
        return true;
    }

    private static boolean pieceMatches(String a, String b) {
        return telDigits(a).equals(telDigits(b)) && numbers(a).equals(numbers(b))
                && DEAD.matcher(a).find() == DEAD.matcher(b).find();
    }

    /** 번역 문구를 통째로 보여줘도 되는지: 원문과 같은 번호 집합(순서 무관)일 때만 true. 관리자가 원문만 고친 오래된 번역을 거른다. */
    public static boolean sameNumbers(String phone, String phoneTr) {
        List<String> a = numbers(phone);
        List<String> b = numbers(phoneTr);
        java.util.Collections.sort(a);
        java.util.Collections.sort(b);
        return a.equals(b) && DEAD.matcher(phone == null ? "" : phone).find() == DEAD.matcher(phoneTr == null ? "" : phoneTr).find();
    }

    /** 카드용 대표 번호: 번역의 첫 조각이 원문 첫 조각과 같은 번호일 때만 번역을 쓴다. */
    public static String firstPhone(String phone, String phoneTr) {
        List<String> a = splitPhones(phone);
        if (a.isEmpty()) {
            return "";
        }
        List<String> b = splitPhones(phoneTr);
        return (!b.isEmpty() && pieceMatches(a.get(0), b.get(0))) ? b.get(0) : a.get(0);
    }
}
