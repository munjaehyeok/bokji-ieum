<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="pageTitle" value="제보 처리"/>
<%@ include file="../common/admin-top.jspf" %>

<div class="d-flex flex-wrap align-items-center gap-2 mb-3">
    <h1 class="fs-4 fw-bold mb-0">제보 처리 <span class="text-secondary fs-6">(총 <c:out value="${total}"/>건)</span></h1>
</div>

<form method="get" action="${ctx}/admin/reports" class="row g-2 align-items-end mb-3">
    <div class="col-auto">
        <label class="form-label" for="status">상태</label>
        <select class="form-select" id="status" name="status">
            <option value="">전체</option>
            <option value="R" ${p.status == 'R' ? 'selected' : ''}>R 접수</option>
            <option value="C" ${p.status == 'C' ? 'selected' : ''}>C 확인</option>
            <option value="D" ${p.status == 'D' ? 'selected' : ''}>D 반영</option>
            <option value="X" ${p.status == 'X' ? 'selected' : ''}>X 반려</option>
        </select>
    </div>
    <div class="col-auto">
        <button type="submit" class="btn btn-bk-outline">필터</button>
    </div>
</form>

<div class="table-responsive">
    <table class="table table-hover bk-admin-table align-middle bg-white">
        <thead class="table-light">
        <tr>
            <th scope="col">ID</th><th scope="col">대상 자원</th><th scope="col">내용</th>
            <th scope="col">상태</th><th scope="col">메모</th><th scope="col">접수일</th>
            <th scope="col">처리 (접수 &rarr; 확인 &rarr; 반영/반려)</th>
        </tr>
        </thead>
        <tbody>
        <c:forEach var="r" items="${reports}">
            <tr>
                <td><c:out value="${r.reportId}"/></td>
                <td><a href="${ctx}/resources/${r.resourceId}" target="_blank" rel="noopener">
                    <c:out value="${r.resourceName}"/></a></td>
                <td style="max-width: 320px"><c:out value="${r.content}"/></td>
                <td>
                    <c:choose>
                        <c:when test="${r.status == 'R'}"><span class="badge text-bg-warning">접수</span></c:when>
                        <c:when test="${r.status == 'C'}"><span class="badge text-bg-info">확인</span></c:when>
                        <c:when test="${r.status == 'D'}"><span class="badge text-bg-success">반영</span></c:when>
                        <c:otherwise><span class="badge text-bg-secondary">반려</span></c:otherwise>
                    </c:choose>
                </td>
                <td><c:out value="${r.adminMemo}"/></td>
                <td class="text-nowrap"><c:out value="${r.createdAt}"/></td>
                <td>
                    <form method="post" class="d-flex flex-wrap gap-1"
                          action="${ctx}/admin/reports/${r.reportId}">
                        <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}">
                        <label class="visually-hidden" for="rst${r.reportId}">상태</label>
                        <select class="form-select form-select-sm w-auto" id="rst${r.reportId}" name="status">
                            <option value="R" ${r.status == 'R' ? 'selected' : ''}>R 접수</option>
                            <option value="C" ${r.status == 'C' ? 'selected' : ''}>C 확인</option>
                            <option value="D" ${r.status == 'D' ? 'selected' : ''}>D 반영</option>
                            <option value="X" ${r.status == 'X' ? 'selected' : ''}>X 반려</option>
                        </select>
                        <label class="visually-hidden" for="rmemo${r.reportId}">메모</label>
                        <input type="text" class="form-control form-control-sm w-auto" id="rmemo${r.reportId}"
                               name="memo" maxlength="500" placeholder="메모" value="<c:out value='${r.adminMemo}'/>">
                        <button type="submit" class="btn btn-sm btn-outline-secondary">변경</button>
                    </form>
                </td>
            </tr>
        </c:forEach>
        <c:if test="${empty reports}">
            <tr><td colspan="7" class="text-center text-secondary py-4">제보가 없습니다.</td></tr>
        </c:if>
        </tbody>
    </table>
</div>

<%@ include file="../common/admin-foot.jspf" %>
