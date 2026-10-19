package com.ieum.bokji.util;

import java.util.regex.Matcher;
import java.util.regex.Pattern;
import org.springframework.web.util.HtmlUtils;

/**
 * 자유 텍스트(신청 방법 등)를 HTML로 바꾸며 URL만 링크로 만든다. 먼저 전체를 이스케이프하므로 다른 태그는 생기지 않고,
 * 링크는 http/https만 허용한다. 원문에 "www. bokjiro. go. kr"처럼 점 뒤에 공백이 낀 표기가 있어 그것도 한 주소로 본다.
 */
public final class LinkText {

    private static final Pattern URL = Pattern.compile(
            "(https?://[^\\s<>\"'()]+|www\\.\\s?[A-Za-z0-9-]+(?:\\.\\s?[A-Za-z0-9-]+)+(?:/[^\\s<>\"'()]*)?)");

    private LinkText() {}

    public static String toHtml(String text) {
        if (text == null) return "";
        String esc = HtmlUtils.htmlEscape(text.trim());
        Matcher m = URL.matcher(esc);
        StringBuffer sb = new StringBuffer();
        while (m.find()) {
            String shown = m.group(1);
            String tail = "";
            while (!shown.isEmpty() && ".,;:".indexOf(shown.charAt(shown.length() - 1)) >= 0) {
                tail = shown.charAt(shown.length() - 1) + tail;
                shown = shown.substring(0, shown.length() - 1);
            }
            String href = normalizeUrl(shown.replaceAll("\\s+", ""));
            m.appendReplacement(sb, Matcher.quoteReplacement(
                    "<a href=\"" + href + "\" target=\"_blank\" rel=\"noopener\">" + shown + "</a>" + tail));
        }
        m.appendTail(sb);
        return sb.toString();
    }

    private static final Pattern BARE_HOST = Pattern.compile("^(?:www\\.)?[A-Za-z0-9-]+(?:\\.[A-Za-z0-9-]+)+(?::\\d+)?(?:[/?#]\\S*)?$");

    /** http(s)는 그대로, 스킴 없는 웹 주소(도메인 형태)는 https:// 를 붙인다. 그 밖의 값(상대경로·mailto 등)은 null — 링크를 만들지 않는다. */
    public static String normalizeUrl(String url) {
        if (url == null) return null;
        String u = url.trim();
        if (u.isEmpty()) return null;
        if (u.matches("(?i)^https?://\\S+$")) return u;
        return BARE_HOST.matcher(u).matches() ? "https://" + u : null;
    }
}
