<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%-- 기능 검증용 최소 뷰 — 디자인 금지(프론트 교체 예정). --%>
<!DOCTYPE html>
<html lang="ko">
<head><meta charset="UTF-8"><title>매칭 결과 — 복지이음</title></head>
<body>
<h1>매칭 결과</h1>
<p>내 조건:
    <c:if test="${condition.age != null}"><c:out value="${condition.age}"/>세 · </c:if>
    <c:if test="${condition.dong != null}"><c:out value="${condition.dong}"/> · </c:if>
    <c:if test="${not empty condition.householdTypes}"><c:out value="${condition.householdTypes}"/> · </c:if>
    소득 <c:out value="${condition.incomeRank}"/> ·
    장애 <c:out value="${condition.disability}"/> ·
    국적 <c:out value="${condition.nationality}"/>
    <c:if test="${not empty condition.eduWork}"> · <c:out value="${condition.eduWork}"/></c:if>
    [<a href="${pageContext.request.contextPath}/match">조건 수정</a>]
</p>
<p>분야:
    <a href="${pageContext.request.contextPath}/match/result">전체</a>
    <c:forTokens items="JOB,HOUSE,DAILY,HEALTH,MIND,CARE,EDU,CULTURE,RIGHTS" delims="," var="cat">
        <a href="${pageContext.request.contextPath}/match/result?category=${cat}">${cat}</a>
    </c:forTokens>
    <c:if test="${not empty category}">(현재: <c:out value="${category}"/>)</c:if>
</p>
<c:forEach var="entry" items="${resultsByMember}">
    <h2><c:out value="${entry.key}"/> — <c:out value="${fn:length(entry.value)}"/>개의 복지가 조건과 맞습니다</h2>
    <c:forEach var="row" items="${entry.value}">
        <div style="border:1px solid #ccc; margin:4px; padding:4px">
            <a href="${pageContext.request.contextPath}/resources/${row.resourceId}">
                <c:out value="${row.displayName}"/></a>
            [<c:out value="${row.providerType}"/>]
            <c:out value="${row.orgName}"/> · 점수 <c:out value="${row.score}"/><br>
            <c:if test="${not empty row.summaryTr}"><c:out value="${row.summaryTr}"/><br></c:if>
            <c:if test="${not empty row.matchedLabels}">
                일치:
                <c:forEach var="t" items="${row.matchedLabels}"><c:out value="${t}"/> </c:forEach><br>
            </c:if>
            <c:if test="${not empty row.needCheckLabels}">
                확인 필요:
                <c:forEach var="t" items="${row.needCheckLabels}"><c:out value="${t}"/> </c:forEach><br>
            </c:if>
            기준일 <c:out value="${row.dataBaseDate}"/>
            <c:if test="${row.oldData}"> — 자료 기준일 확인(12개월 경과)</c:if>
        </div>
    </c:forEach>
</c:forEach>
<p>참고용 안내이며 최종 자격은 담당기관 확인이 필요합니다.</p>
</body>
</html>
