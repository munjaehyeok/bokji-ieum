<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<c:set var="pageTitle"><spring:message code="explore.title"/></c:set>
<c:set var="pageWide" value="true"/>
<%@ include file="../common/top.jspf" %>

<h1 class="bk-explore-h1"><spring:message code="explore.title"/></h1>
<p class="bk-explore-intro">
    <spring:message code="explore.intro"/>
    <a class="btn btn-bk btn-sm ms-1" href="${ctx}/match"><spring:message code="explore.cta"/> <span class="bk-arrow">&rarr;</span></a>
</p>

<c:set var="catCodes" value="JOB,HOUSE,DAILY,HEALTH,MIND,CARE,EDU,CULTURE,RIGHTS"/>
<c:set var="hhCodes" value="LOW,DIS,SPAR,MCHD,MCUL,NKOR,ONE,PREG,FOR"/>

<form class="bk-explore-form" id="bkExploreForm" method="get" action="${ctx}/resources">
    <div class="bk-axes">
        <fieldset class="bk-axis">
            <legend><spring:message code="explore.lifecycle"/></legend>
            <c:forEach var="lc" items="${lifeCodes}">
                <label class="bk-check"><input type="checkbox" name="life" value="${lc}" ${fn:contains(fn:join(s.life.toArray(), ','), lc) ? 'checked' : ''}> <spring:message code="life.${lc}"/></label>
            </c:forEach>
        </fieldset>
        <fieldset class="bk-axis">
            <legend><spring:message code="explore.household"/></legend>
            <c:forTokens items="${hhCodes}" delims="," var="h">
                <label class="bk-check"><input type="checkbox" name="hh" value="${h}" ${fn:contains(fn:join(s.hh.toArray(), ','), h) ? 'checked' : ''}> <spring:message code="hhx.${h}"/></label>
            </c:forTokens>
        </fieldset>
        <fieldset class="bk-axis">
            <legend><spring:message code="explore.topic"/></legend>
            <c:forTokens items="${catCodes}" delims="," var="ct">
                <label class="bk-check"><input type="checkbox" name="cat" value="${ct}" ${fn:contains(fn:join(s.cat.toArray(), ','), ct) ? 'checked' : ''}> <svg class="bk-ico" aria-hidden="true"><use href="${ctx}/static/img/icons.svg#cat-${ct}"/></svg><spring:message code="cat.${ct}"/></label>
            </c:forTokens>
        </fieldset>
    </div>

    <div class="bk-fields">
        <label class="bk-field"><span><spring:message code="explore.age"/></span>
            <span class="bk-inline"><input type="number" name="age" min="0" max="120" inputmode="numeric" value="${s.age}"> <spring:message code="explore.ageUnit"/></span></label>
        <label class="bk-field"><span><spring:message code="explore.dong"/></span>
            <select name="dong">
                <option value=""><spring:message code="explore.dongAll"/></option>
                <c:forEach var="d" items="${dongCodes}"><option value="${d}" ${s.dong == d ? 'selected' : ''}><spring:message code="dong.${d}"/></option></c:forEach>
            </select></label>
        <label class="bk-field bk-field-grow"><span><spring:message code="explore.q"/></span>
            <input type="search" name="q" maxlength="170" placeholder="<spring:message code='explore.qph'/>" value="<c:out value='${fn:join(s.rawWords.toArray(), " ")}'/>"></label>
        <label class="bk-field bk-field-grow"><span><spring:message code="explore.xq"/></span>
            <input type="search" name="xq" maxlength="170" placeholder="<spring:message code='explore.xqph'/>" value="<c:out value='${fn:join(s.rawExWords.toArray(), " ")}'/>"></label>
    </div>
    <div class="bk-opts">
        <label class="bk-check"><input type="checkbox" name="strict" value="1" ${s.strict ? 'checked' : ''}> <spring:message code="explore.strict"/></label>
        <label class="bk-check"><input type="checkbox" name="incx" value="1" ${s.incx ? 'checked' : ''}> <spring:message code="explore.incx"/></label>
        <label class="bk-check"><input type="checkbox" name="online" value="1" ${s.online ? 'checked' : ''}> <spring:message code="explore.online"/></label>
        <span class="bk-opts-btns">
            <a class="btn btn-bk-outline btn-sm" href="${ctx}/resources"><spring:message code="explore.reset"/></a>
            <button type="submit" class="btn btn-bk btn-sm"><spring:message code="explore.search"/></button>
        </span>
    </div>
    <c:if test="${s.sort != ''}"><input type="hidden" name="sort" value="${s.sort}"></c:if>
</form>

<p class="bk-date mb-2"><spring:message code="explore.note"/></p>

<div class="bk-explore-bar">
    <h2 class="bk-explore-count" id="bkExploreCount" aria-live="polite"><spring:message code="explore.count" arguments="${total}"/></h2>
    <div class="bk-filter" role="group" aria-label="<spring:message code='explore.sortLabel'/>">
        <a class="${s.sort == '' ? 'active' : ''}" href="${ctx}/resources?${baseQuery}"><spring:message code="explore.sort.name"/></a>
        <a class="${s.sort == 'latest' ? 'active' : ''}" href="${ctx}/resources?${baseQuery}${empty baseQuery ? '' : '&'}sort=latest"><spring:message code="sort.latest"/></a>
        <a class="${s.sort == 'popular' ? 'active' : ''}" href="${ctx}/resources?${baseQuery}${empty baseQuery ? '' : '&'}sort=popular"><spring:message code="explore.sort.popular"/></a>
        <a href="#" id="bkFavToggle" data-all="<spring:message code='explore.favAll'/>" data-fav="<spring:message code='explore.favList'/>" data-base="${ctx}/resources" hidden><spring:message code="explore.favList"/> <span id="bkFavCount"></span></a>
    </div>
</div>
<c:if test="${popularFallback}"><p class="bk-date mb-2" role="status"><spring:message code="explore.popularFallback"/></p></c:if>
<c:if test="${s.idsMode}"><p class="bk-date mb-2"><spring:message code="explore.favNote"/> <a href="${ctx}/resources"><spring:message code="explore.favAll"/></a></p></c:if>

<div class="bk-explore-list" id="bkExploreList">
<c:forEach var="row" items="${rows}">
    <article class="bk-xcard">
        <div class="bk-xcard-top">
            <span class="bk-xcat"><svg class="bk-ico" aria-hidden="true"><use href="${ctx}/static/img/icons.svg#cat-${row.category}"/></svg><spring:message code="cat.${row.category}" text="${row.category}" htmlEscape="true"/></span>
            <span class="bk-badge-provider"><spring:message code="provider.${row.providerType}" text="${row.providerType}" htmlEscape="true"/></span>
            <button type="button" class="bk-fav" data-id="${row.resourceId}" aria-pressed="false"
                    data-on="<spring:message code='explore.favOn'/>" data-off="<spring:message code='explore.fav'/>" aria-label="<spring:message code='explore.fav'/>" hidden>
                <svg aria-hidden="true"><use href="${ctx}/static/img/icons.svg#fav"/></svg>
            </button>
        </div>
        <h3><a href="${ctx}/resources/${row.resourceId}"><c:out value="${row.displayName}"/></a></h3>
        <p class="bk-xorg"><c:out value="${row.orgName}"/><c:if test="${not empty row.deptName}"> · <c:out value="${row.deptName}"/></c:if></p>
        <p class="bk-xsum"><c:choose><c:when test="${not empty row.summaryTr}"><c:out value="${row.summaryTr}"/></c:when><c:otherwise><c:out value="${row.supportContent}"/></c:otherwise></c:choose></p>
        <div class="bk-xtags">
            <c:forTokens items="${row.householdTypes}" delims="," var="ht"><span class="bk-xtag"><spring:message code="hh.${ht}" text="${ht}" htmlEscape="true"/></span></c:forTokens>
            <c:if test="${row.disability == 'Y'}"><span class="bk-xtag"><spring:message code="tag.DISABILITY"/></span></c:if>
            <c:if test="${row.nationality == 'F'}"><span class="bk-xtag"><spring:message code="nat.F"/></span></c:if>
        </div>
        <dl class="bk-xmeta">
            <c:if test="${not empty row.serviceCycle and fn:length(row.serviceCycle) <= 8}"><div><dt><spring:message code="card.cycle"/></dt><dd><spring:message code="val.${fn:trim(row.serviceCycle)}" text="${fn:trim(row.serviceCycle)}" htmlEscape="true"/></dd></div></c:if>
            <c:if test="${not empty row.serviceType}"><div><dt><spring:message code="card.type"/></dt><dd><c:out value="${row.serviceType}"/></dd></div></c:if>
            <c:if test="${not empty row.phone}"><div><dt><spring:message code="card.phone"/></dt><dd><c:out value="${fn:trim(fn:split(row.phone, ',')[0])}"/></dd></div></c:if>
        </dl>
        <p class="bk-date mb-0">
            <c:if test="${not empty row.dataBaseDate}"><spring:message code="result.baseDate"/> <c:out value="${row.dataBaseDate}"/></c:if>
            <c:if test="${row.oldData}"><span class="bk-badge-old"><spring:message code="result.oldData"/></span></c:if>
            <a class="bk-xmore" href="${ctx}/resources/${row.resourceId}"><spring:message code="card.detail"/> &rarr;</a>
        </p>
    </article>
</c:forEach>
</div>
<c:if test="${total == 0}">
    <p class="text-secondary py-4" id="bkExploreEmpty"><c:choose><c:when test="${s.idsMode}"><spring:message code="explore.favEmpty"/></c:when><c:otherwise><spring:message code="explore.empty"/></c:otherwise></c:choose></p>
</c:if>

<c:if test="${lastPage > 1}">
    <nav class="bk-pager" aria-label="<spring:message code='explore.pagerLabel'/>">
        <c:if test="${s.page > 1}"><a href="${ctx}/resources?${baseQuery}${empty baseQuery ? '' : '&'}${s.sort != '' ? 'sort='.concat(s.sort).concat('&') : ''}page=${s.page - 1}" rel="prev">&larr; <spring:message code="explore.prev"/></a></c:if>
        <span aria-current="page">${s.page} / ${lastPage}</span>
        <c:if test="${s.page < lastPage}"><a href="${ctx}/resources?${baseQuery}${empty baseQuery ? '' : '&'}${s.sort != '' ? 'sort='.concat(s.sort).concat('&') : ''}page=${s.page + 1}" rel="next"><spring:message code="explore.next"/> &rarr;</a></c:if>
    </nav>
</c:if>
<p class="bk-date" id="bkFavMsg" hidden><spring:message code="explore.favUnavailable"/></p>

<%@ include file="../common/foot.jspf" %>
