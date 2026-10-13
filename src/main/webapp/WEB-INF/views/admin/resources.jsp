<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head><meta charset="UTF-8"><title>자원 관리 — 복지이음</title></head>
<body>
<h1>자원 관리 (<c:out value="${total}"/>건)</h1>
<p><c:out value="${sessionScope.adminName}"/> 님
    [<a href="${pageContext.request.contextPath}/admin/reports">제보 처리</a>]
    [<a href="${pageContext.request.contextPath}/admin/logout">로그아웃</a>]</p>
<form method="get" action="${pageContext.request.contextPath}/admin/resources">
    검색(이름·기관) <input type="text" name="q" value="<c:out value='${p.q}'/>">
    상태 <select name="status">
        <option value="">전체</option>
        <option value="A" ${p.status == 'A' ? 'selected' : ''}>A 노출</option>
        <option value="H" ${p.status == 'H' ? 'selected' : ''}>H 숨김</option>
        <option value="E" ${p.status == 'E' ? 'selected' : ''}>E 종료</option>
    </select>
    <label><input type="checkbox" name="expired" value="true" ${p.expired ? 'checked' : ''}> 기준일 12개월 경과만</label>
    <button type="submit">검색</button>
</form>
<p><a href="${pageContext.request.contextPath}/admin/resources/new">[신규 등록]</a></p>
<table border="1">
    <tr><th>ID</th><th>이름</th><th>기관</th><th>상태</th><th>기준일</th><th>수정</th><th>상태 전환</th></tr>
    <c:forEach var="r" items="${rows}">
        <tr>
            <td><c:out value="${r.resourceId}"/></td>
            <td><c:out value="${r.name}"/></td>
            <td><c:out value="${r.orgName}"/></td>
            <td><c:out value="${r.status}"/></td>
            <td><c:out value="${r.dataBaseDate}"/></td>
            <td><a href="${pageContext.request.contextPath}/admin/resources/${r.resourceId}/edit">수정</a></td>
            <td>
                <form method="post" style="display:inline"
                      action="${pageContext.request.contextPath}/admin/resources/${r.resourceId}/status">
                    <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}">
                    <select name="status">
                        <option value="A">A 노출</option><option value="H">H 숨김</option><option value="E">E 종료</option>
                    </select>
                    <button type="submit">전환</button>
                </form>
            </td>
        </tr>
    </c:forEach>
</table>
<p>페이지 <c:out value="${p.page}"/> / <c:out value="${totalPages}"/>
    <c:if test="${p.page > 1}">
        <a href="?page=${p.page - 1}&q=${p.q}&status=${p.status}&expired=${p.expired}">이전</a>
    </c:if>
    <c:if test="${p.page < totalPages}">
        <a href="?page=${p.page + 1}&q=${p.q}&status=${p.status}&expired=${p.expired}">다음</a>
    </c:if>
</p>
</body>
</html>
