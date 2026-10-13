<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="pageTitle" value="자원 관리"/>
<%@ include file="../common/admin-top.jspf" %>

<div class="d-flex flex-wrap align-items-center gap-2 mb-3">
    <h1 class="fs-4 fw-bold mb-0">자원 관리 <span class="text-secondary fs-6">(총 <c:out value="${total}"/>건)</span></h1>
    <a class="btn btn-bk ms-auto" href="${ctx}/admin/resources/new">+ 신규 등록</a>
</div>

<form method="get" action="${ctx}/admin/resources" class="row g-2 align-items-end mb-3">
    <div class="col-auto">
        <label class="form-label" for="q">검색 (이름·기관)</label>
        <input type="text" class="form-control" id="q" name="q" value="<c:out value='${p.q}'/>">
    </div>
    <div class="col-auto">
        <label class="form-label" for="status">상태</label>
        <select class="form-select" id="status" name="status">
            <option value="">전체</option>
            <option value="A" ${p.status == 'A' ? 'selected' : ''}>A 노출</option>
            <option value="H" ${p.status == 'H' ? 'selected' : ''}>H 숨김</option>
            <option value="E" ${p.status == 'E' ? 'selected' : ''}>E 종료</option>
        </select>
    </div>
    <div class="col-auto">
        <div class="form-check">
            <input type="checkbox" class="form-check-input" id="expired" name="expired" value="true" ${p.expired ? 'checked' : ''}>
            <label class="form-check-label" for="expired">기준일 12개월 경과만</label>
        </div>
    </div>
    <div class="col-auto">
        <button type="submit" class="btn btn-bk-outline">검색</button>
    </div>
</form>

<div class="table-responsive">
    <table class="table table-hover bk-admin-table align-middle bg-white">
        <thead class="table-light">
        <tr>
            <th scope="col">ID</th><th scope="col">이름</th><th scope="col">기관</th>
            <th scope="col">상태</th><th scope="col">기준일</th><th scope="col">수정</th><th scope="col">상태 전환</th>
        </tr>
        </thead>
        <tbody>
        <c:forEach var="r" items="${rows}">
            <tr>
                <td><c:out value="${r.resourceId}"/></td>
                <td><c:out value="${r.name}"/></td>
                <td><c:out value="${r.orgName}"/></td>
                <td>
                    <c:choose>
                        <c:when test="${r.status == 'A'}"><span class="badge text-bg-success">노출</span></c:when>
                        <c:when test="${r.status == 'H'}"><span class="badge text-bg-secondary">숨김</span></c:when>
                        <c:otherwise><span class="badge text-bg-dark">종료</span></c:otherwise>
                    </c:choose>
                </td>
                <td><c:out value="${r.dataBaseDate}"/></td>
                <td><a class="btn btn-sm btn-bk-outline" href="${ctx}/admin/resources/${r.resourceId}/edit">수정</a></td>
                <td>
                    <form method="post" class="d-flex gap-1"
                          action="${ctx}/admin/resources/${r.resourceId}/status">
                        <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}">
                        <label class="visually-hidden" for="st${r.resourceId}">상태</label>
                        <select class="form-select form-select-sm w-auto" id="st${r.resourceId}" name="status">
                            <option value="A" ${r.status == 'A' ? 'selected' : ''}>A 노출</option>
                            <option value="H" ${r.status == 'H' ? 'selected' : ''}>H 숨김</option>
                            <option value="E" ${r.status == 'E' ? 'selected' : ''}>E 종료</option>
                        </select>
                        <button type="submit" class="btn btn-sm btn-outline-secondary">전환</button>
                    </form>
                </td>
            </tr>
        </c:forEach>
        <c:if test="${empty rows}">
            <tr><td colspan="7" class="text-center text-secondary py-4">검색 결과가 없습니다.</td></tr>
        </c:if>
        </tbody>
    </table>
</div>

<nav aria-label="pagination" class="d-flex align-items-center gap-2">
    <span>페이지 <c:out value="${p.page}"/> / <c:out value="${totalPages}"/></span>
    <c:url var="prevUrl" value="/admin/resources">
        <c:param name="page" value="${p.page - 1}"/>
        <c:if test="${p.q != null}"><c:param name="q" value="${p.q}"/></c:if>
        <c:if test="${p.status != null}"><c:param name="status" value="${p.status}"/></c:if>
        <c:if test="${p.expired}"><c:param name="expired" value="true"/></c:if>
    </c:url>
    <c:url var="nextUrl" value="/admin/resources">
        <c:param name="page" value="${p.page + 1}"/>
        <c:if test="${p.q != null}"><c:param name="q" value="${p.q}"/></c:if>
        <c:if test="${p.status != null}"><c:param name="status" value="${p.status}"/></c:if>
        <c:if test="${p.expired}"><c:param name="expired" value="true"/></c:if>
    </c:url>
    <c:if test="${p.page > 1}"><a class="btn btn-bk-outline btn-sm" href="${prevUrl}">이전</a></c:if>
    <c:if test="${p.page < totalPages}"><a class="btn btn-bk-outline btn-sm" href="${nextUrl}">다음</a></c:if>
</nav>

<%@ include file="../common/admin-foot.jspf" %>
