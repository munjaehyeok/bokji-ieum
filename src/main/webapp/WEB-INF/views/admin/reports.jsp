<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head><meta charset="UTF-8"><title>제보 처리 — 복지이음</title></head>
<body>
<h1>제보 처리 (<c:out value="${total}"/>건)</h1>
<p><a href="${pageContext.request.contextPath}/admin/resources">자원 관리</a></p>
<form method="get" action="${pageContext.request.contextPath}/admin/reports">
    상태 <select name="status">
        <option value="">전체</option>
        <option value="R" ${p.status == 'R' ? 'selected' : ''}>R 접수</option>
        <option value="C" ${p.status == 'C' ? 'selected' : ''}>C 확인</option>
        <option value="D" ${p.status == 'D' ? 'selected' : ''}>D 반영</option>
        <option value="X" ${p.status == 'X' ? 'selected' : ''}>X 반려</option>
    </select>
    <button type="submit">필터</button>
</form>
<table border="1">
    <tr><th>ID</th><th>대상 자원</th><th>내용</th><th>상태</th><th>메모</th><th>접수일</th><th>처리</th></tr>
    <c:forEach var="r" items="${reports}">
        <tr>
            <td><c:out value="${r.reportId}"/></td>
            <td><a href="${pageContext.request.contextPath}/resources/${r.resourceId}">
                <c:out value="${r.resourceName}"/></a></td>
            <td><c:out value="${r.content}"/></td>
            <td><c:out value="${r.status}"/></td>
            <td><c:out value="${r.adminMemo}"/></td>
            <td><c:out value="${r.createdAt}"/></td>
            <td>
                <form method="post" action="${pageContext.request.contextPath}/admin/reports/${r.reportId}">
                    <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}">
                    <select name="status">
                        <option value="R">R 접수</option><option value="C">C 확인</option>
                        <option value="D">D 반영</option><option value="X">X 반려</option>
                    </select>
                    <input type="text" name="memo" maxlength="500" placeholder="메모">
                    <button type="submit">변경</button>
                </form>
            </td>
        </tr>
    </c:forEach>
</table>
</body>
</html>
