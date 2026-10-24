<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<c:set var="pageTitle"><spring:message code="result.title"/></c:set>
<%@ include file="../common/top.jspf" %>

<%-- 조건 요약바 --%>
<div class="bk-summary mb-3">
    <strong><spring:message code="result.myCond"/>:</strong>
    <span>
        <c:choose>
            <c:when test="${condition.age != null}"><spring:message code="cond.age" arguments="${condition.age}"/></c:when>
            <c:otherwise><spring:message code="cond.unknown"/></c:otherwise>
        </c:choose>
        <c:if test="${condition.dong != null}"> · <spring:message code="dong.${condition.dong}"/></c:if>
        <c:forEach var="hh" items="${condition.householdTypes}"> · <spring:message code="hh.${hh}"/></c:forEach>
        · <spring:message code="income.${condition.incomeRank}"/>
        <c:if test="${condition.disability == 'Y'}"> · <spring:message code="tag.DISABILITY"/></c:if>
        <c:if test="${condition.nationality == 'F'}"> · <spring:message code="nat.F"/></c:if>
        <c:forEach var="ew" items="${condition.eduWork}"><c:if test="${ew != 'NONE'}"> · <spring:message code="ew.${ew}"/></c:if></c:forEach>
    </span>
    <a class="btn btn-bk-outline btn-sm ms-auto" href="${ctx}/match">[<spring:message code="result.edit"/>]</a>
</div>

<%-- 가구원 탭 (가구원이 있을 때만) --%>
<c:if test="${not empty condition.members}">
    <ul class="nav nav-pills bk-tabs mb-3" id="bkMemberTabs" role="tablist">
        <li class="nav-item" role="presentation">
            <button type="button" class="nav-link active" data-member="0" aria-selected="true" role="tab">
                <spring:message code="result.tab.me"/>
            </button>
        </li>
        <c:forEach var="m" items="${condition.members}" varStatus="st">
            <li class="nav-item" role="presentation">
                <button type="button" class="nav-link" data-member="${st.index + 1}" aria-selected="false" role="tab">
                    <c:choose>
                        <c:when test="${m.relation != null}"><c:out value="${m.relation}"/></c:when>
                        <c:otherwise><spring:message code="member.label"/> ${st.index + 1}</c:otherwise>
                    </c:choose>
                </button>
            </li>
        </c:forEach>
    </ul>
</c:if>

<%-- 분야 필터 --%>
<div class="bk-filter mb-2" id="bkCatFilter" role="group" aria-label="<spring:message code='result.catLabel'/>">
    <button type="button" data-cat="" class="${empty category ? 'active' : ''}"><svg class="bk-ico" aria-hidden="true"><use href="${ctx}/static/img/icons.svg#cat-ALL"/></svg><spring:message code="cat.ALL"/></button>
    <c:forTokens items="JOB,HOUSE,DAILY,HEALTH,MIND,CARE,EDU,CULTURE,RIGHTS" delims="," var="cat">
        <button type="button" data-cat="${cat}" class="${category == cat ? 'active' : ''}"><svg class="bk-ico" aria-hidden="true"><use href="${ctx}/static/img/icons.svg#cat-${cat}"/></svg><spring:message code="cat.${cat}"/></button>
    </c:forTokens>
</div>

<%-- 정렬 --%>
<div class="bk-filter mb-3" id="bkSortToggle" role="group" aria-label="<spring:message code='explore.sortLabel'/>">
    <button type="button" data-sort="" class="${empty sort ? 'active' : ''}"><spring:message code="sort.recommend"/></button>
    <button type="button" data-sort="latest" class="${sort == 'latest' ? 'active' : ''}"><spring:message code="sort.latest"/></button>
</div>
<p class="bk-date mb-3"><spring:message code="result.scopeNote"/></p>

<h1 class="fs-4 fw-bold" id="bkCount" aria-live="polite"></h1>

<%-- 결과 패널 (서버 렌더 초기값, 탭·필터 전환은 AJAX) --%>
<c:forEach var="entry" items="${resultsByMember}" varStatus="st">
    <div class="bk-pane" id="bkPane${st.index}" data-member="${st.index}"
         data-count="${fn:length(entry.value)}" ${st.index > 0 ? 'hidden' : ''}>
        <c:if test="${empty entry.value}">
            <p class="text-secondary py-4"><spring:message code="result.empty"/></p>
        </c:if>
        <c:set var="grp" value="" />
        <c:forEach var="row" items="${entry.value}">
            <c:if test="${not empty entry.value[0].matchedLabels and grp == '' and not empty row.matchedLabels}">
                <h2 class="bk-group"><spring:message code="result.groupMatched"/></h2>
                <c:set var="grp" value="m" />
            </c:if>
            <c:if test="${not empty entry.value[0].matchedLabels and grp == 'm' and empty row.matchedLabels}">
                <h2 class="bk-group"><spring:message code="result.groupOther"/></h2>
                <c:set var="grp" value="o" />
            </c:if>
            <a class="bk-card" href="${ctx}/resources/${row.resourceId}">
                <div class="d-flex justify-content-between align-items-start gap-2">
                    <h3><c:out value="${row.displayName}"/></h3>
                    <span class="bk-badge-provider"><spring:message code="provider.${row.providerType}" text="${row.providerType}" htmlEscape="true"/></span>
                </div>
                <p class="org"><c:out value="${row.orgName}"/><c:if test="${not empty row.deptName}"> <c:out value="${row.deptName}"/></c:if></p>
                <p class="summary1">
                    <c:choose>
                        <c:when test="${not empty row.summaryTr}"><c:out value="${row.summaryTr}"/></c:when>
                        <c:otherwise><c:out value="${row.supportContent}"/></c:otherwise>
                    </c:choose>
                </p>
                <div>
                    <c:if test="${not empty row.matchedLabels}">
                        <span class="bk-tag bk-tag-match"><spring:message code="result.matched"/>:
                            <c:forEach var="t" items="${row.matchedLabels}" varStatus="ts"><c:out value="${t}"/><c:if test="${!ts.last}"> · </c:if></c:forEach>
                        </span>
                    </c:if>
                    <c:if test="${not empty row.needCheckLabels}">
                        <span class="bk-tag bk-tag-check"><spring:message code="result.needCheck"/>:
                            <c:forEach var="t" items="${row.needCheckLabels}" varStatus="ts"><c:out value="${t}"/><c:if test="${!ts.last}"> · </c:if></c:forEach>
                        </span>
                    </c:if>
                </div>
                <div class="bk-date mt-1">
                    <c:if test="${not empty row.dataBaseDate}">
                        <spring:message code="result.baseDate"/> <c:out value="${row.dataBaseDate}"/>
                    </c:if>
                    <c:if test="${not empty row.lastVerifiedDate}">
                        · <spring:message code="detail.verified"/> <c:out value="${row.lastVerifiedDate}"/>
                    </c:if>
                    <c:if test="${row.oldData}">
                        <span class="bk-badge-old"><spring:message code="result.oldData"/></span>
                    </c:if>
                </div>
            </a>
        </c:forEach>
    </div>
</c:forEach>

<script>
window.BK_RESULT = {
    ctx: '${ctx}',
    category: '<c:out value="${category}"/>',
    sort: '<c:out value="${sort}"/>',
    msg: {
        count: '<spring:message code="result.count" arguments="@N@" javaScriptEscape="true"/>',
        matched: '<spring:message code="result.matched" javaScriptEscape="true"/>',
        needCheck: '<spring:message code="result.needCheck" javaScriptEscape="true"/>',
        baseDate: '<spring:message code="result.baseDate" javaScriptEscape="true"/>',
        verified: '<spring:message code="detail.verified" javaScriptEscape="true"/>',
        groupMatched: '<spring:message code="result.groupMatched" javaScriptEscape="true"/>',
        groupOther: '<spring:message code="result.groupOther" javaScriptEscape="true"/>',
        oldData: '<spring:message code="result.oldData" javaScriptEscape="true"/>',
        empty: '<spring:message code="result.empty" javaScriptEscape="true"/>',
        loading: '<spring:message code="result.loading" javaScriptEscape="true"/>',
        fail: '<spring:message code="report.fail" javaScriptEscape="true"/>',
        provider: {
            PUB: '<spring:message code="provider.PUB" javaScriptEscape="true"/>',
            PRV: '<spring:message code="provider.PRV" javaScriptEscape="true"/>'
        }
    }
};
</script>

<%@ include file="../common/foot.jspf" %>
