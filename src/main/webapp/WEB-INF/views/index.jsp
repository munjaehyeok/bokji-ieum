<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<c:set var="pageTitle"><spring:message code="landing.headline"/></c:set>
<%@ include file="common/top.jspf" %>

<div class="bk-hero">
    <svg class="bk-hero-art" aria-hidden="true"><use href="${ctx}/static/img/icons.svg#hero"/></svg>
    <h1><spring:message code="landing.headline"/></h1>
    <p class="bk-sub"><spring:message code="landing.sub" arguments="${resourceCount}"/></p>
    <a class="btn btn-bk bk-start-btn" href="${ctx}/match">
        <spring:message code="landing.start"/> &rarr;
    </a>
    <p class="mt-3 text-secondary"><spring:message code="landing.privacy"/></p>
    <c:if test="${langCode != 'ko'}">
        <p class="mt-2 small text-secondary"><spring:message code="mt.notice"/></p>
    </c:if>
</div>

<hr>
<section aria-label="examples" class="text-center">
    <p class="fw-bold mb-2"><spring:message code="landing.examples"/></p>
    <span class="bk-chip"><spring:message code="landing.chip1"/></span>
    <span class="bk-chip"><spring:message code="landing.chip2"/></span>
    <span class="bk-chip"><spring:message code="landing.chip3"/></span>
</section>

<%@ include file="common/foot.jspf" %>
