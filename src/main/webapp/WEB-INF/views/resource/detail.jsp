<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%-- 기능 검증용 최소 뷰 — 디자인 금지(프론트 교체 예정). --%>
<!DOCTYPE html>
<html lang="ko">
<head><meta charset="UTF-8"><title>자원 상세 — 복지이음</title></head>
<body>
<h1><c:out value="${resource.displayName}"/> [<c:out value="${resource.providerType}"/>]</h1>
<p>분야: <c:out value="${resource.category}"/> / <c:out value="${resource.subCategory}"/>
    · 유형: <c:out value="${resource.serviceType}"/></p>

<h2>지원 내용</h2>
<p><c:out value="${resource.supportContent}"/></p>

<c:if test="${judged}">
    <h2>나의 자격 판정</h2>
    <ul>
        <c:forEach var="t" items="${resource.matchedLabels}">
            <li>일치: <c:out value="${t}"/></li>
        </c:forEach>
        <c:forEach var="t" items="${resource.needCheckLabels}">
            <li>확인 필요: <c:out value="${t}"/></li>
        </c:forEach>
        <c:forEach var="t" items="${resource.mismatchedLabels}">
            <li>불일치: <c:out value="${t}"/></li>
        </c:forEach>
        <c:if test="${empty resource.matchedLabels and empty resource.needCheckLabels and empty resource.mismatchedLabels}">
            <li>이 자원은 별도 자격 제한이 없습니다.</li>
        </c:if>
    </ul>
    <p>판정 점수: <c:out value="${resource.score}"/></p>
    <c:if test="${not empty resource.uncertainNote}">
        <p>추가 조건: <c:out value="${resource.uncertainNote}"/></p>
    </c:if>
</c:if>

<h2>지원 기준(원문)</h2>
<p><c:out value="${resource.eligibilityRaw}"/></p>

<h2>신청 방법</h2>
<p><c:choose><c:when test="${not empty resource.applyMethod}"><c:out value="${resource.applyMethod}"/></c:when>
    <c:otherwise>담당기관 문의</c:otherwise></c:choose></p>
<p>준비 서류: <c:choose><c:when test="${not empty resource.documents}"><c:out value="${resource.documents}"/></c:when>
    <c:otherwise>담당기관 문의</c:otherwise></c:choose></p>
<p>신청권자: <c:out value="${resource.applicant}"/> · 선정 기간: <c:out value="${resource.decisionPeriod}"/>
    · 제공 시기: <c:out value="${resource.serviceCycle}"/></p>
<p>비용: <c:out value="${resource.costFlag}"/> <c:out value="${resource.costAmount}"/></p>
<c:if test="${not empty resource.applyUrl}">
    <p><a href="<c:out value='${resource.applyUrl}'/>" target="_blank" rel="noopener"
          onclick="beaconA()">온라인 신청/안내 바로가기</a></p>
</c:if>
<p><button type="button" onclick="beaconA()">신청 안내 확인(이벤트 A 비콘 테스트)</button></p>

<h2>담당 기관</h2>
<p><c:out value="${resource.orgName}"/> <c:out value="${resource.deptName}"/>
    <c:if test="${not empty resource.phone}">
        · <a href="tel:<c:out value='${resource.phone}'/>"><c:out value="${resource.phone}"/></a>
    </c:if><br>
    <c:out value="${resource.address}"/></p>

<p>출처: <c:out value="${resource.sourceName}"/> · 기준일 <c:out value="${resource.dataBaseDate}"/>
    <c:if test="${resource.oldData}"> — 자료 기준일 확인(12개월 경과)</c:if>
    <c:if test="${not empty resource.lastVerifiedDate}"> · 최근 확인 <c:out value="${resource.lastVerifiedDate}"/></c:if>
</p>

<h2>정보가 다르면 알려주기 (개인정보 입력란 없음)</h2>
<form method="post" action="${pageContext.request.contextPath}/reports">
    <input type="hidden" name="resourceId" value="${resource.resourceId}">
    <textarea name="content" maxlength="500" rows="3" cols="50" required></textarea>
    <button type="submit">보내기</button>
</form>

<p>※ 참고용 안내입니다. 최종 자격은 담당기관 확인이 필요합니다.</p>
<p><a href="${pageContext.request.contextPath}/match/result">결과 목록으로</a></p>

<script>
function beaconA() {
    try {
        fetch('${pageContext.request.contextPath}/events', {
            method: 'POST',
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: 'event=A&resourceId=${resource.resourceId}'
        });
    } catch (e) { /* 비콘 실패 무시 */ }
}
</script>
</body>
</html>
