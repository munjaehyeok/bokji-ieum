import com.ieum.bokji.util.LinkText;
/** LinkText 단위 점검. 실행: javac -cp target/classes:<spring-web.jar>:<spring-core.jar>:<spring-jcl.jar> -d /tmp/lt docs/검증/LinkTextCheck.java && java -cp /tmp/lt:<같은 cp> LinkTextCheck */
public class LinkTextCheck {
    static int bad = 0;
    static void eq(String n, Object got, Object want) { boolean ok = want == null ? got == null : want.equals(got); System.out.println((ok ? "PASS " : "FAIL ") + n + (ok ? "" : " got=" + got)); if (!ok) bad++; }
    public static void main(String[] a) {
        eq("https 그대로", LinkText.normalizeUrl("https://a.kr/x"), "https://a.kr/x");
        eq("www 보정", LinkText.normalizeUrl("www.bokjiro.go.kr"), "https://www.bokjiro.go.kr");
        eq("도메인 보정", LinkText.normalizeUrl("bokjiro.go.kr/a?b=1"), "https://bokjiro.go.kr/a?b=1");
        eq("상대경로 거부", LinkText.normalizeUrl("/apply"), null);
        eq("mailto 거부", LinkText.normalizeUrl("mailto:help@example.org"), null);
        eq("javascript 거부", LinkText.normalizeUrl("javascript:alert(1)"), null);
        eq("빈값", LinkText.normalizeUrl("  "), null);
        eq("공백 낀 문장 거부", LinkText.normalizeUrl("전화 문의"), null);
        eq("태그는 이스케이프", LinkText.toHtml("<script>x</script>"), "&lt;script&gt;x&lt;/script&gt;");
        eq("점 뒤 공백 주소 링크", LinkText.toHtml("복지로(www. bokjiro. go. kr)"), "복지로(<a href=\"https://www.bokjiro.go.kr\" target=\"_blank\" rel=\"noopener\">www. bokjiro. go. kr</a>)");
        eq("문장부호 제외", LinkText.toHtml("https://a.kr/x."), "<a href=\"https://a.kr/x\" target=\"_blank\" rel=\"noopener\">https://a.kr/x</a>.");
        String atk = LinkText.toHtml("https://a.kr/\"onmouseover=\"x");
        eq("속성 탈출 불가(따옴표는 &quot;로 유지, 속성 하나뿐)", atk.indexOf("\"onmouseover") < 0 && atk.split("href=").length == 2 && atk.contains("&quot;onmouseover=&quot;"), true);
        System.out.println(bad == 0 ? "ALL PASS" : "FAIL " + bad); System.exit(bad == 0 ? 0 : 1);
    }
}
