<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<c:set var="pageTitle"><c:out value="${resource.displayName}"/></c:set>
<%@ include file="../common/top.jspf" %>

<div class="d-flex justify-content-between align-items-start gap-2 mb-1">
    <h1 class="fs-3 fw-bold" style="color: var(--bk-primary)"><c:out value="${resource.displayName}"/></h1>
    <span class="bk-badge-provider fs-6"><spring:message code="provider.${resource.providerType}" text="${resource.providerType}" htmlEscape="true"/></span>
</div>
<p class="text-secondary mb-3">
    <spring:message code="cat.${resource.category}" text="${resource.category}" htmlEscape="true"/>
    <c:if test="${not empty resource.subCategory}"> · <c:out value="${resource.subCategory}"/></c:if>
</p>

<%-- 한눈에 보기: 담당·주기·제공유형·문의 (값이 없으면 칸 자체를 만들지 않는다 — 추정해 채우지 않음) --%>
<div class="bk-facts d-flex flex-wrap align-items-start gap-3 mb-3">
    <dl class="bk-xmeta mb-0" aria-label="<spring:message code='detail.facts'/>">
        <c:if test="${not empty resource.deptName}"><div><dt><spring:message code="card.dept"/></dt><dd><c:out value="${resource.deptName}"/></dd></div></c:if>
        <c:if test="${not empty resource.serviceCycle and fn:length(resource.serviceCycle) <= 8}"><div><dt><spring:message code="card.cycle"/></dt><dd><spring:message code="val.${fn:trim(resource.serviceCycle)}" text="${fn:trim(resource.serviceCycle)}" htmlEscape="true"/></dd></div></c:if>
        <c:if test="${not empty resource.serviceType}"><div><dt><spring:message code="card.type"/></dt><dd><c:out value="${resource.serviceType}"/></dd></div></c:if>
        <c:if test="${not empty resource.phone}"><div><dt><spring:message code="card.phone"/></dt><dd><c:out value="${fn:trim(fn:split(resource.phone, ',')[0])}"/></dd></div></c:if>
    </dl>
    <button type="button" class="bk-fav ms-auto bk-noprint" data-id="${resource.resourceId}" aria-pressed="false"
            data-on="<spring:message code='explore.favOn'/>" data-off="<spring:message code='explore.fav'/>" aria-label="<spring:message code='explore.fav'/>" hidden>
        <svg aria-hidden="true"><use href="${ctx}/static/img/icons.svg#fav"/></svg>
    </button>
</div>
<p class="bk-date" id="bkFavMsg" hidden><spring:message code="explore.favUnavailable"/></p>

<%-- 지원 내용 --%>
<section class="bk-section">
    <h2>&#9670; <spring:message code="detail.support"/></h2>
    <p class="bk-ws mb-0"><c:choose><c:when test="${not empty resource.summaryTr}"><c:out value="${resource.summaryTr}"/></c:when><c:otherwise><c:out value="${fn:trim(resource.supportContent)}"/></c:otherwise></c:choose></p>
</section>

<%-- 자격 판정표 (조건 입력 후에만) --%>
<c:if test="${judged}">
    <section class="bk-section">
        <h2>&#9670; <spring:message code="detail.judge"/></h2>
        <table class="table bk-judge-table mb-0">
            <thead>
            <tr>
                <th scope="col"><spring:message code="detail.judge.item"/></th>
                <th scope="col"><spring:message code="compare.mine"/></th>
                <th scope="col"><spring:message code="compare.theirs"/></th>
                <th scope="col"><spring:message code="detail.judge.result"/></th>
            </tr>
            </thead>
            <tbody>
            <c:forEach var="ln" items="${compare}">
                <tr>
                    <th scope="row"><c:out value="${ln.item}"/></th>
                    <td data-label="<spring:message code="compare.mine"/>"><c:out value="${ln.mine}"/></td>
                    <td data-label="<spring:message code="compare.theirs"/>"><c:out value="${ln.theirs}"/></td>
                    <td data-label="<spring:message code="detail.judge.result"/>">
                        <c:choose>
                            <c:when test="${ln.status == 'match'}"><span class="bk-tag bk-tag-match"><spring:message code="judge.match"/></span></c:when>
                            <c:when test="${ln.status == 'check'}"><span class="bk-tag bk-tag-check"><spring:message code="judge.check"/></span></c:when>
                            <c:otherwise><span class="bk-tag bk-tag-miss"><spring:message code="judge.mismatch"/></span></c:otherwise>
                        </c:choose>
                    </td>
                </tr>
            </c:forEach>
            <c:if test="${empty compare}">
                <tr><td colspan="4"><spring:message code="detail.judge.none"/></td></tr>
            </c:if>
            </tbody>
        </table>
        <c:if test="${not empty resource.uncertainNote}">
            <p class="mt-2 mb-0"><strong><spring:message code="detail.note"/>:</strong> <c:out value="${resource.uncertainNote}"/></p>
        </c:if>
    </section>
</c:if>

<%-- 지원 기준 원문 --%>
<c:if test="${not empty resource.eligibilityRaw}">
    <section class="bk-section">
        <h2>&#9670; <spring:message code="detail.eligibility"/></h2>
        <p class="bk-ws mb-0"><c:out value="${resource.eligibilityRaw}"/></p>
    </section>
</c:if>

<%-- 신청 방법·서류 --%>
<section class="bk-section">
    <h2>&#9670; <spring:message code="detail.apply"/></h2>
    <p class="bk-ws"><c:choose><c:when test="${not empty resource.applyMethod}">${applyMethodHtml}</c:when><c:otherwise><spring:message code="detail.askOrg"/></c:otherwise></c:choose></p>
    <p><strong><spring:message code="detail.docs"/>:</strong>
        <c:choose>
            <c:when test="${not empty resource.documents}"><c:out value="${resource.documents}"/></c:when>
            <c:otherwise><spring:message code="detail.askOrg"/></c:otherwise>
        </c:choose>
    </p>
    <p class="mb-1 text-secondary">
        <c:if test="${not empty resource.applicant}"><spring:message code="detail.applicant"/>: <spring:message code="val.${fn:trim(resource.applicant)}" text="${fn:trim(resource.applicant)}" htmlEscape="true"/> · </c:if>
        <c:if test="${not empty resource.decisionPeriod}"><spring:message code="detail.decision"/>: <c:out value="${resource.decisionPeriod}"/> · </c:if>
        <c:if test="${not empty resource.serviceCycle}"><spring:message code="detail.cycle"/>: <spring:message code="val.${fn:trim(resource.serviceCycle)}" text="${fn:trim(resource.serviceCycle)}" htmlEscape="true"/></c:if>
    </p>
    <c:if test="${not empty resource.costFlag}">
        <p class="mb-1 text-secondary"><spring:message code="detail.cost"/>:
            <spring:message code="cost.${resource.costFlag}" text="${resource.costFlag}" htmlEscape="true"/>
            <c:if test="${not empty resource.costAmount and not (fn:trim(resource.costAmount) eq '-' or fn:trim(resource.costAmount) eq '무료' or fn:trim(resource.costAmount) eq '해당없음' or fn:trim(resource.costAmount) eq '0')}"> — <c:out value="${resource.costAmount}"/></c:if>
        </p>
    </c:if>
    <c:if test="${not empty resource.applyUrl}">
        <a class="btn btn-bk mt-2" href="<c:out value='${resource.applyUrl}'/>"
           target="_blank" rel="noopener" data-beacon="A">
            <spring:message code="detail.applyUrl"/> &rarr;
        </a>
    </c:if>
</section>

<%-- 담당 기관 --%>
<section class="bk-section">
    <h2>&#9670; <spring:message code="detail.org"/></h2>
    <p class="mb-1">
        <c:out value="${resource.orgName}"/>
        <c:if test="${not empty resource.deptName}"> <c:out value="${resource.deptName}"/></c:if>
    </p>
    <c:if test="${not empty resource.address}">
        <p class="mb-1 text-secondary"><c:out value="${resource.address}"/></p>
    </c:if>
    <c:if test="${not empty resource.phone}">
        <c:set var="firstPhone" value="${fn:trim(fn:split(resource.phone, ',')[0])}"/>
        <p class="mb-1"><c:out value="${resource.phone}"/></p>
        <a class="btn btn-bk bk-tel-btn bk-noprint" href="tel:${fn:replace(firstPhone, ' ', '')}" data-beacon="A">
            &#128222; <spring:message code="detail.call"/> <c:out value="${firstPhone}"/>
        </a>
    </c:if>
</section>

<%-- 출처·기준일 --%>
<section class="bk-section">
    <h2>&#9670; <spring:message code="detail.source"/></h2>
    <p class="mb-0">
        <c:if test="${not empty resource.sourceName}"><spring:message code="src.${fn:substring(resource.sourceName,0,3)}" text="${resource.sourceName}" htmlEscape="true"/> · </c:if>
        <c:if test="${not empty resource.dataBaseDate}">
            <spring:message code="result.baseDate"/> <c:out value="${resource.dataBaseDate}"/>
        </c:if>
        <c:if test="${resource.oldData}">
            <span class="bk-badge-old"><spring:message code="result.oldData"/></span>
        </c:if>
        <c:if test="${not empty resource.lastVerifiedDate}">
            · <spring:message code="detail.verified"/> <c:out value="${resource.lastVerifiedDate}"/>
        </c:if>
    </p>
    <p class="bk-date mt-2 mb-0"><spring:message code="result.scopeNote"/></p>
</section>

<%-- 액션 --%>
<div class="d-flex flex-wrap gap-2 my-3 bk-noprint">
    <button type="button" class="btn btn-bk-outline" id="bkPrint">&#128424; <spring:message code="detail.print"/></button>
    <button type="button" class="btn btn-bk-outline" data-bs-toggle="modal" data-bs-target="#bkReportModal">
        <spring:message code="detail.report"/>
    </button>
    <a class="btn btn-outline-secondary ms-auto" href="${ctx}/resources"><spring:message code="detail.backList"/></a>
    <c:if test="${judged}"><a class="btn btn-outline-secondary" href="${ctx}/match/result"><spring:message code="detail.back"/></a></c:if>
</div>

<div class="bk-disclaimer">&#8251; <spring:message code="footer.disclaimer"/></div>

<%-- 제보 모달 --%>
<div class="modal fade" id="bkReportModal" tabindex="-1" aria-labelledby="bkReportTitle" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <form id="bkReportForm">
                <div class="modal-header">
                    <h2 class="modal-title fs-5" id="bkReportTitle"><spring:message code="report.title"/></h2>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="close"></button>
                </div>
                <div class="modal-body">
                    <p class="hint"><spring:message code="report.desc"/></p>
                    <label for="bkReportContent" class="visually-hidden"><spring:message code="report.title"/></label>
                    <textarea class="form-control" id="bkReportContent" name="content" rows="4"
                              maxlength="500" required placeholder="<spring:message code='report.ph'/>"></textarea>
                    <p class="mt-2 mb-0" id="bkReportMsg" role="status"></p>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">
                        <spring:message code="report.cancel"/>
                    </button>
                    <button type="submit" class="btn btn-bk" id="bkReportSend"><spring:message code="report.send"/></button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
window.BK_DETAIL = {
    ctx: '${ctx}',
    resourceId: ${resource.resourceId},
    token: '<c:out value="${sessionScope.reportToken}"/>',
    msg: {
        ok: '<spring:message code="report.ok" javaScriptEscape="true"/>',
        fail: '<spring:message code="report.fail" javaScriptEscape="true"/>',
        limit: '<spring:message code="report.limit" javaScriptEscape="true"/>'
    }
};
</script>

<%@ include file="../common/foot.jspf" %>
