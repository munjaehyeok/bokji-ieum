<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="pageTitle" value="이용 통계"/>
<%@ include file="../common/admin-top.jspf" %>

<div class="d-flex flex-wrap align-items-center gap-2 mb-2">
    <h1 class="fs-4 fw-bold mb-0">이용 통계</h1>
    <span class="text-secondary"><c:out value="${periodLabel}"/></span>
</div>

<div class="btn-group mb-2" role="group" aria-label="기간 선택">
    <c:forEach var="opt" items="7,30,90,0">
        <a href="${ctx}/admin/stats?days=${opt}"
           class="btn btn-sm ${days == opt ? 'btn-dark' : 'btn-outline-secondary'}"
           <c:if test="${days == opt}">aria-current="page"</c:if>>
            <c:choose>
                <c:when test="${opt == '0'}">전체</c:when>
                <c:otherwise>최근 ${opt}일</c:otherwise>
            </c:choose>
        </a>
    </c:forEach>
</div>

<p class="small text-secondary mb-4">
    익명 로그(세션 해시·10세 연령대) 기준이며 개인을 식별하지 않습니다.
    같은 세션에서 같은 조건으로 결과를 다시 본 것은 검색 1건으로 셉니다.
    개발·시연용 DB에는 테스트 클릭이 섞여 있으니 실제 이용자 수로 쓰지 마세요.
</p>

<%-- ① 요약 --%>
<div class="row g-3 mb-4">
    <div class="col-6 col-lg">
        <div class="card h-100"><div class="card-body">
            <div class="small text-secondary">조건 검색</div>
            <div class="fs-3 fw-bold">${summary.searches}</div>
        </div></div>
    </div>
    <div class="col-6 col-lg">
        <div class="card h-100"><div class="card-body">
            <div class="small text-secondary">결과를 본 세션</div>
            <div class="fs-3 fw-bold">${summary.matchedSessions}</div>
        </div></div>
    </div>
    <div class="col-6 col-lg">
        <div class="card h-100"><div class="card-body">
            <div class="small text-secondary">상세 조회</div>
            <div class="fs-3 fw-bold">${summary.detailViews}</div>
        </div></div>
    </div>
    <div class="col-6 col-lg">
        <div class="card h-100"><div class="card-body">
            <div class="small text-secondary">신청 안내 확인</div>
            <div class="fs-3 fw-bold">${summary.applyClicks}</div>
        </div></div>
    </div>
    <div class="col-6 col-lg">
        <div class="card h-100"><div class="card-body">
            <div class="small text-secondary">오류 제보</div>
            <div class="fs-3 fw-bold">${summary.reports}</div>
        </div></div>
    </div>
</div>

<%-- ② 이용 흐름 (퍼널) --%>
<section class="card mb-4">
    <div class="card-body">
        <h2 class="fs-5 fw-bold mb-1">이용 흐름 (세션 기준)</h2>
        <p class="small text-secondary mb-3">
            조건을 넣고 결과를 본 세션 중 몇 %가 상세 화면과 신청 안내(전화·신청 링크·인쇄)까지 갔는지 보여 줍니다.
        </p>
        <c:choose>
            <c:when test="${summary.matchedSessions == 0}">
                <p class="text-secondary mb-0">선택한 기간에 결과를 본 세션이 없습니다.</p>
            </c:when>
            <c:otherwise>
                <div class="d-flex justify-content-between small">
                    <span>① 결과를 본 세션</span><span>${summary.matchedSessions} (100%)</span>
                </div>
                <div class="progress mb-3" role="progressbar" aria-label="결과를 본 세션 100%"
                     aria-valuenow="100" aria-valuemin="0" aria-valuemax="100">
                    <div class="progress-bar" style="width: 100%"></div>
                </div>
                <div class="d-flex justify-content-between small">
                    <span>② 그중 상세를 본 세션</span>
                    <span>${summary.viewedSessions} (${summary.viewedPct}%)</span>
                </div>
                <div class="progress mb-3" role="progressbar" aria-label="상세를 본 세션 ${summary.viewedPct}%"
                     aria-valuenow="${summary.viewedPct}" aria-valuemin="0" aria-valuemax="100">
                    <div class="progress-bar" style="width: ${summary.viewedPct}%"></div>
                </div>
                <div class="d-flex justify-content-between small">
                    <span>③ 그중 신청 안내까지 누른 세션</span>
                    <span>${summary.appliedSessions} (${summary.appliedPct}%)</span>
                </div>
                <div class="progress" role="progressbar" aria-label="신청 안내까지 누른 세션 ${summary.appliedPct}%"
                     aria-valuenow="${summary.appliedPct}" aria-valuemin="0" aria-valuemax="100">
                    <div class="progress-bar" style="width: ${summary.appliedPct}%"></div>
                </div>
            </c:otherwise>
        </c:choose>
        <p class="small text-secondary mt-3 mb-0">
            조건 검색 없이 둘러보기에서 상세만 본 세션: ${summary.browseOnlySessions}
        </p>
    </div>
</section>

<%-- ③ 많이 본 자원 --%>
<section class="mb-4">
    <h2 class="fs-5 fw-bold mb-2">많이 본 자원 TOP 10</h2>
    <div class="table-responsive">
        <table class="table bk-admin-table align-middle bg-white">
            <thead class="table-light">
            <tr>
                <th scope="col">순위</th>
                <th scope="col">자원</th>
                <th scope="col">분야</th>
                <th scope="col" style="min-width: 200px">상세 조회</th>
                <th scope="col">신청 안내 확인</th>
            </tr>
            </thead>
            <tbody>
            <c:forEach var="r" items="${popular}" varStatus="st">
                <tr>
                    <td>${st.count}</td>
                    <td>
                        <a href="${ctx}/admin/resources/${r.resourceId}/edit">
                            <c:out value="${empty r.name ? '(삭제된 자원)' : r.name}"/></a>
                        <c:if test="${not empty r.status and r.status != 'A'}">
                            <span class="badge text-bg-secondary ms-1">비노출</span>
                        </c:if>
                        <div class="small text-secondary"><c:out value="${r.orgName}"/></div>
                    </td>
                    <td><c:out value="${r.categoryLabel}"/></td>
                    <td>
                        <div class="d-flex align-items-center gap-2">
                            <div class="progress flex-grow-1" role="progressbar" aria-label="상세 조회 ${r.views}회"
                                 aria-valuenow="${r.barPct}" aria-valuemin="0" aria-valuemax="100">
                                <div class="progress-bar" style="width: ${r.barPct}%"></div>
                            </div>
                            <span class="text-nowrap">${r.views}회</span>
                        </div>
                    </td>
                    <td>${r.applies}회</td>
                </tr>
            </c:forEach>
            <c:if test="${empty popular}">
                <tr><td colspan="5" class="text-center text-secondary py-4">선택한 기간에 상세 조회 기록이 없습니다.</td></tr>
            </c:if>
            </tbody>
        </table>
    </div>
    <p class="small text-secondary mb-0">
        자원 이름을 누르면 관리자 수정 화면으로 갑니다. (공개 상세 화면을 열면 조회 기록이 늘어나서 수정 화면으로 연결)
    </p>
</section>

<%-- ④ 조건 분포 --%>
<section class="mb-4">
    <h2 class="fs-5 fw-bold mb-1">조건 분포</h2>
    <p class="small text-secondary mb-3">
        조건 검색 ${summary.searches}건 기준입니다. 복수 선택 항목은 합계가 100%를 넘을 수 있습니다.
    </p>
    <div class="row g-3">
        <c:forEach var="entry" items="${bars}">
            <div class="col-md-6 col-xl-4">
                <div class="card h-100"><div class="card-body">
                    <h3 class="fs-6 fw-bold mb-1"><c:out value="${dimTitles[entry.key]}"/></h3>
                    <c:forEach var="b" items="${entry.value}">
                        <div class="d-flex justify-content-between small mt-2">
                            <span><c:out value="${b.label}"/></span>
                            <span class="text-secondary">${b.cnt}건 · ${b.pct}%</span>
                        </div>
                        <div class="progress" style="height: 8px" role="progressbar"
                             aria-label="<c:out value='${b.label}'/> ${b.pct}%"
                             aria-valuenow="${b.pct}" aria-valuemin="0" aria-valuemax="100">
                            <div class="progress-bar" style="width: ${b.pct}%"></div>
                        </div>
                    </c:forEach>
                    <c:if test="${empty entry.value}">
                        <p class="small text-secondary mt-2 mb-0">기록 없음</p>
                    </c:if>
                </div></div>
            </div>
        </c:forEach>
    </div>
</section>

<%-- ⑤ 결과 수 --%>
<section class="card mb-4">
    <div class="card-body">
        <h2 class="fs-5 fw-bold mb-1">결과 수</h2>
        <p class="small text-secondary mb-2">결과 화면 한 번에 나온 자원 수(본인 기준)입니다.</p>
        <c:choose>
            <c:when test="${summary.avgResults == null}">
                <p class="text-secondary mb-0">기록 없음</p>
            </c:when>
            <c:otherwise>
                <p class="mb-0">평균 <strong>${summary.avgResults}건</strong>
                    · 최소 ${summary.minResults}건 · 최대 ${summary.maxResults}건</p>
            </c:otherwise>
        </c:choose>
    </div>
</section>

<%-- ⑥ 날짜별 --%>
<section class="mb-4">
    <h2 class="fs-5 fw-bold mb-2">날짜별 <span class="fs-6 fw-normal text-secondary">(한국 시간, 기록이 있는 날만 최근 31일)</span></h2>
    <div class="table-responsive">
        <table class="table bk-admin-table align-middle bg-white">
            <thead class="table-light">
            <tr>
                <th scope="col">날짜</th><th scope="col">조건 검색</th><th scope="col">상세 조회</th>
                <th scope="col">신청 안내 확인</th><th scope="col">오류 제보</th>
            </tr>
            </thead>
            <tbody>
            <c:forEach var="row" items="${daily}">
                <tr>
                    <td class="text-nowrap"><c:out value="${row.logDay}"/></td>
                    <td>${row.searches}</td><td>${row.views}</td><td>${row.applies}</td><td>${row.reports}</td>
                </tr>
            </c:forEach>
            <c:if test="${empty daily}">
                <tr><td colspan="5" class="text-center text-secondary py-4">선택한 기간에 기록이 없습니다.</td></tr>
            </c:if>
            </tbody>
        </table>
    </div>
</section>

<%@ include file="../common/admin-foot.jspf" %>