<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>관리자 로그인 — 복지이음</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/variable/pretendardvariable-dynamic-subset.min.css">
    <link rel="stylesheet" href="${ctx}/static/css/bokji.css">
</head>
<body>
<main class="container py-5" style="max-width: 420px">
    <h1 class="fs-3 fw-bold text-center mb-4" style="color: var(--bk-primary)">복지이음 관리자</h1>
    <div class="bk-section">
        <c:if test="${not empty error}">
            <div class="alert alert-danger" role="alert"><c:out value="${error}"/></div>
        </c:if>
        <form method="post" action="${ctx}/admin/login">
            <div class="mb-3">
                <label class="form-label" for="loginId">아이디</label>
                <input type="text" class="form-control" id="loginId" name="loginId" required autofocus>
            </div>
            <div class="mb-3">
                <label class="form-label" for="password">비밀번호</label>
                <input type="password" class="form-control" id="password" name="password" required>
            </div>
            <button type="submit" class="btn btn-bk w-100">로그인</button>
        </form>
    </div>
    <p class="text-center mt-3"><a href="${ctx}/">&larr; 복지이음 홈</a></p>
</main>
</body>
</html>
