<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title><spring:message code="app.title"/></title>
</head>
<body>
    <h1><spring:message code="app.title"/></h1>
    <p><spring:message code="landing.headline"/></p>
    <p>
        <a href="?lang=ko">한국어</a> |
        <a href="?lang=en">English</a> |
        <a href="?lang=zh">中文</a> |
        <a href="?lang=vi">Tiếng Việt</a>
    </p>
    <p><a href="<c:url value='/match'/>"><spring:message code="landing.start"/></a></p>
    <p><spring:message code="landing.privacy"/></p>
    <!-- 골격 스텁: 실제 랜딩 UI는 프론트 담당이 구현 -->
</body>
</html>
