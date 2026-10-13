<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head><meta charset="UTF-8"><title>관리자 로그인 — 복지이음</title></head>
<body>
<h1>관리자 로그인</h1>
<c:if test="${not empty error}"><p style="color:red"><c:out value="${error}"/></p></c:if>
<form method="post" action="${pageContext.request.contextPath}/admin/login">
    <p>아이디 <input type="text" name="loginId" required></p>
    <p>비밀번호 <input type="password" name="password" required></p>
    <p><button type="submit">로그인</button></p>
</form>
</body>
</html>
