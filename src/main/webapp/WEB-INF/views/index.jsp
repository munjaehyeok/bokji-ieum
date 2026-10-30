<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<c:set var="pageTitle"><spring:message code="landing.headline"/></c:set>
<c:set var="pageWide" value="true"/>
<%@ include file="common/top.jspf" %>

<div class="bk-hero">
    <svg class="bk-hero-art" aria-hidden="true"><use href="${ctx}/static/img/icons.svg#hero"/></svg>
    <h1><spring:message code="landing.headline"/></h1>
    <p class="bk-sub"><spring:message code="landing.sub" arguments="${resourceCount}"/></p>
    <div class="bk-cta">
        <a class="btn btn-bk bk-start-btn" href="${ctx}/match"><spring:message code="landing.startShort"/></a>
        <a class="btn btn-bk-outline bk-start-btn" href="${ctx}/resources"><spring:message code="landing.browseShort"/></a>
    </div>
    <p class="mt-2"><a class="bk-browse-link" href="${ctx}/match?step=7"><spring:message code="landing.family"/></a></p>
    <p class="mt-2 text-secondary small"><spring:message code="landing.steps"/></p>
    <p class="mt-3 text-secondary"><spring:message code="landing.privacy"/></p>
    <c:if test="${langCode != 'ko'}">
        <p class="mt-2 small text-secondary"><spring:message code="mt.notice"/></p>
    </c:if>
</div>

<section class="bk-how" aria-labelledby="bkHowT">
    <h2 id="bkHowT"><spring:message code="home.how.t"/></h2>
    <p class="bk-how-sub"><spring:message code="home.how.s"/></p>
    <div class="bk-how-grid">
        <article class="bk-how-card">
            <span class="bk-pill"><spring:message code="home.how.ex"/> 1</span>
            <h3><spring:message code="home.how.h1"/></h3>
            <p><spring:message code="home.how.d1"/></p>
            <div class="bk-mock" aria-hidden="true">
                <small><spring:message code="home.how.m1a"/></small>
                <div class="bk-mock-num"><spring:message code="home.how.m1b"/></div>
                <div class="bk-mock-opt"><spring:message code="home.how.m1c"/></div>
            </div>
        </article>
        <article class="bk-how-card">
            <span class="bk-pill"><spring:message code="home.how.ex"/> 2</span>
            <h3><spring:message code="home.how.h2"/></h3>
            <p><spring:message code="home.how.d2"/></p>
            <div class="bk-mock" aria-hidden="true">
                <div class="bk-mock-opt on"><spring:message code="home.how.m2a"/></div>
                <div class="bk-mock-opt"><spring:message code="home.how.m2b"/></div>
                <div class="bk-mock-opt"><spring:message code="home.how.m2c"/></div>
            </div>
        </article>
        <article class="bk-how-card">
            <span class="bk-pill"><spring:message code="home.how.ex"/> 3</span>
            <h3><spring:message code="home.how.h3"/></h3>
            <p><spring:message code="home.how.d3"/></p>
            <div class="bk-mock" aria-hidden="true">
                <div class="bk-mock-tag ok">&#10003; <spring:message code="home.how.m3a"/></div>
                <div class="bk-mock-tag warn">&#9888; <spring:message code="home.how.m3b"/></div>
            </div>
        </article>
    </div>
</section>

<hr>
<section aria-label="<spring:message code='landing.examples'/>" class="text-center">
    <p class="fw-bold mb-2"><spring:message code="landing.examples"/></p>
    <div class="bk-chips">
    <span class="bk-chip"><spring:message code="landing.chip1"/></span>
    <span class="bk-chip"><spring:message code="landing.chip2"/></span>
    <span class="bk-chip"><spring:message code="landing.chip3"/></span>
    </div>
</section>

<%@ include file="common/foot.jspf" %>
