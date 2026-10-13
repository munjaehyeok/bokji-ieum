<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%-- 등록·수정 공용. 태깅 7필드는 드롭다운·체크박스만(자유 텍스트 금지). name은 Resource 필드와 1:1. --%>
<c:set var="pageTitle" value="자원 등록·수정"/>
<%@ include file="../common/admin-top.jspf" %>
<c:set var="dongCsv" value=",${resource.dongCodes},"/>
<c:set var="hhCsv" value=",${resource.householdTypes},"/>
<c:set var="ewCsv" value=",${resource.eduWork},"/>

<div class="d-flex align-items-center gap-2 mb-3">
    <h1 class="fs-4 fw-bold mb-0">
        자원
        <c:choose>
            <c:when test="${resource.resourceId != null}">수정 #<c:out value="${resource.resourceId}"/></c:when>
            <c:otherwise>신규 등록</c:otherwise>
        </c:choose>
    </h1>
    <a class="btn btn-bk-outline ms-auto" href="${ctx}/admin/resources">목록으로</a>
</div>

<form method="post" action="${ctx}${formAction}" style="max-width: 980px">
    <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}">

    <section class="bk-section">
        <h2>기본 정보</h2>
        <div class="row g-3">
            <div class="col-12">
                <label class="form-label" for="name">자원명 *</label>
                <input type="text" class="form-control" id="name" name="name" required
                       value="<c:out value='${resource.name}'/>">
            </div>
            <div class="col-sm-4">
                <label class="form-label" for="category">분야 *</label>
                <select class="form-select" id="category" name="category" required>
                    <c:forTokens items="JOB:일자리,HOUSE:주거,DAILY:일상생활,HEALTH:건강·의료,MIND:마음·심리,CARE:돌봄·요양,EDU:보육·교육,CULTURE:문화·여가,RIGHTS:안전·권익"
                                 delims="," var="pair">
                        <c:set var="cat" value="${fn:split(pair, ':')[0]}"/>
                        <option value="${cat}" ${resource.category == cat ? 'selected' : ''}>${cat} ${fn:split(pair, ':')[1]}</option>
                    </c:forTokens>
                </select>
            </div>
            <div class="col-sm-4">
                <label class="form-label" for="subCategory">중분류</label>
                <input type="text" class="form-control" id="subCategory" name="subCategory"
                       value="<c:out value='${resource.subCategory}'/>">
            </div>
            <div class="col-sm-4">
                <label class="form-label" for="serviceType">서비스 유형</label>
                <input type="text" class="form-control" id="serviceType" name="serviceType"
                       value="<c:out value='${resource.serviceType}'/>">
            </div>
            <div class="col-sm-4">
                <label class="form-label" for="providerType">제공주체 *</label>
                <select class="form-select" id="providerType" name="providerType">
                    <option value="PUB" ${resource.providerType == 'PUB' ? 'selected' : ''}>PUB 공공</option>
                    <option value="PRV" ${resource.providerType == 'PRV' ? 'selected' : ''}>PRV 민간</option>
                </select>
            </div>
            <div class="col-sm-4">
                <label class="form-label" for="orgName">기관명 *</label>
                <input type="text" class="form-control" id="orgName" name="orgName" required
                       value="<c:out value='${resource.orgName}'/>">
            </div>
            <div class="col-sm-4">
                <label class="form-label" for="deptName">부서</label>
                <input type="text" class="form-control" id="deptName" name="deptName"
                       value="<c:out value='${resource.deptName}'/>">
            </div>
            <div class="col-sm-6">
                <label class="form-label" for="phone">연락처</label>
                <input type="text" class="form-control" id="phone" name="phone"
                       value="<c:out value='${resource.phone}'/>">
            </div>
            <div class="col-sm-6">
                <label class="form-label" for="address">주소</label>
                <input type="text" class="form-control" id="address" name="address"
                       value="<c:out value='${resource.address}'/>">
            </div>
            <div class="col-12">
                <label class="form-label" for="supportContent">지원 내용 *</label>
                <textarea class="form-control" id="supportContent" name="supportContent" rows="4" required><c:out value="${resource.supportContent}"/></textarea>
            </div>
            <div class="col-12">
                <label class="form-label" for="applyMethod">신청 방법</label>
                <textarea class="form-control" id="applyMethod" name="applyMethod" rows="2"><c:out value="${resource.applyMethod}"/></textarea>
            </div>
            <div class="col-12">
                <label class="form-label" for="documents">준비 서류</label>
                <textarea class="form-control" id="documents" name="documents" rows="2"><c:out value="${resource.documents}"/></textarea>
            </div>
            <div class="col-12">
                <label class="form-label" for="applyUrl">신청 URL</label>
                <input type="url" class="form-control" id="applyUrl" name="applyUrl"
                       value="<c:out value='${resource.applyUrl}'/>">
            </div>
        </div>
    </section>

    <section class="bk-section">
        <h2>자격조건 태깅 (비우면 해당 조건 무관)</h2>
        <div class="row g-3">
            <div class="col-sm-3">
                <label class="form-label" for="ageMin">연령 최소</label>
                <input type="number" class="form-control" id="ageMin" name="ageMin"
                       value="<c:out value='${resource.ageMin}'/>">
            </div>
            <div class="col-sm-3">
                <label class="form-label" for="ageMax">연령 최대</label>
                <input type="number" class="form-control" id="ageMax" name="ageMax"
                       value="<c:out value='${resource.ageMax}'/>">
            </div>
            <div class="col-12">
                <span class="form-label d-block">거주 동 (복수)</span>
                <div class="d-flex flex-wrap gap-1">
                    <c:forTokens items="GJ:군자,WG:월곶,BG1:배곧1,BG2:배곧2,JWB:정왕본,JW1:정왕1,JW2:정왕2,JW3:정왕3,JW4:정왕4,JG:장곡,EH:은행,DY:대야,SC:신천,SH:신현,GL:과림,MG:목감,MH:매화,NG:능곡,YS:연성"
                                 delims="," var="pair">
                        <c:set var="code" value="${fn:split(pair, ':')[0]}"/>
                        <label class="bk-choice" style="min-height:40px; padding:.35rem .6rem">
                            <input type="checkbox" name="dongCodes" value="${code}"
                                   ${fn:contains(dongCsv, ','.concat(code).concat(',')) ? 'checked' : ''}>
                            ${fn:split(pair, ':')[1]}
                        </label>
                    </c:forTokens>
                </div>
            </div>
            <div class="col-12">
                <span class="form-label d-block">가구형태 (복수)</span>
                <div class="d-flex flex-wrap gap-1">
                    <c:forTokens items="ONE:1인가구,SPAR:한부모·조손,MCHD:다자녀,MCUL:다문화,NKOR:북한이탈,PREG:임신·출산"
                                 delims="," var="pair">
                        <c:set var="hh" value="${fn:split(pair, ':')[0]}"/>
                        <label class="bk-choice" style="min-height:40px; padding:.35rem .6rem">
                            <input type="checkbox" name="householdTypes" value="${hh}"
                                   ${fn:contains(hhCsv, ','.concat(hh).concat(',')) ? 'checked' : ''}>
                            ${fn:split(pair, ':')[1]}
                        </label>
                    </c:forTokens>
                </div>
            </div>
            <div class="col-sm-4">
                <label class="form-label" for="incomeRank">소득 랭크</label>
                <select class="form-select" id="incomeRank" name="incomeRank">
                    <option value="">무관</option>
                    <option value="1" ${resource.incomeRank == 1 ? 'selected' : ''}>1 수급만</option>
                    <option value="2" ${resource.incomeRank == 2 ? 'selected' : ''}>2 차상위까지</option>
                    <option value="3" ${resource.incomeRank == 3 ? 'selected' : ''}>3 중위100까지</option>
                    <option value="4" ${resource.incomeRank == 4 ? 'selected' : ''}>4 중위150까지</option>
                </select>
            </div>
            <div class="col-sm-8 d-flex align-items-end">
                <div class="form-check">
                    <input type="checkbox" class="form-check-input" id="incomeUncertain" name="incomeUncertain" value="Y"
                           ${resource.incomeUncertain == 'Y' ? 'checked' : ''}>
                    <label class="form-check-label" for="incomeUncertain">세부 소득기준 존재 (일치여도 확인 필요)</label>
                </div>
            </div>
            <div class="col-sm-4">
                <label class="form-label" for="disability">장애 대상</label>
                <select class="form-select" id="disability" name="disability">
                    <option value="">무관</option>
                    <option value="Y" ${resource.disability == 'Y' ? 'selected' : ''}>Y 장애인 대상</option>
                </select>
            </div>
            <div class="col-sm-4">
                <label class="form-label" for="nationality">국적</label>
                <select class="form-select" id="nationality" name="nationality">
                    <option value="">무관</option>
                    <option value="K" ${resource.nationality == 'K' ? 'selected' : ''}>K 내국인 한정</option>
                    <option value="F" ${resource.nationality == 'F' ? 'selected' : ''}>F 외국인 대상</option>
                </select>
            </div>
            <div class="col-12">
                <span class="form-label d-block">학업·취업 (복수)</span>
                <div class="d-flex flex-wrap gap-1">
                    <c:forTokens items="STU:초중고,UNIV:대학(원),SEEK:구직,WORK:재직" delims="," var="pair">
                        <c:set var="ew" value="${fn:split(pair, ':')[0]}"/>
                        <label class="bk-choice" style="min-height:40px; padding:.35rem .6rem">
                            <input type="checkbox" name="eduWork" value="${ew}"
                                   ${fn:contains(ewCsv, ','.concat(ew).concat(',')) ? 'checked' : ''}>
                            ${fn:split(pair, ':')[1]}
                        </label>
                    </c:forTokens>
                </div>
            </div>
            <div class="col-12">
                <label class="form-label" for="uncertainNote">서술형 조건 요약 (항상 '확인 필요'로 노출)</label>
                <input type="text" class="form-control" id="uncertainNote" name="uncertainNote"
                       value="<c:out value='${resource.uncertainNote}'/>">
            </div>
        </div>
    </section>

    <section class="bk-section">
        <h2>원문·출처·관리</h2>
        <div class="row g-3">
            <div class="col-12">
                <label class="form-label" for="eligibilityRaw">지원 기준 원문</label>
                <textarea class="form-control" id="eligibilityRaw" name="eligibilityRaw" rows="3"><c:out value="${resource.eligibilityRaw}"/></textarea>
            </div>
            <div class="col-sm-4">
                <label class="form-label" for="decisionPeriod">선정 소요기간</label>
                <input type="text" class="form-control" id="decisionPeriod" name="decisionPeriod"
                       value="<c:out value='${resource.decisionPeriod}'/>">
            </div>
            <div class="col-sm-4">
                <label class="form-label" for="serviceCycle">제공 시기</label>
                <input type="text" class="form-control" id="serviceCycle" name="serviceCycle"
                       value="<c:out value='${resource.serviceCycle}'/>">
            </div>
            <div class="col-sm-4">
                <label class="form-label" for="applicant">신청권자</label>
                <input type="text" class="form-control" id="applicant" name="applicant"
                       value="<c:out value='${resource.applicant}'/>">
            </div>
            <div class="col-sm-4">
                <label class="form-label" for="costFlag">비용</label>
                <select class="form-select" id="costFlag" name="costFlag">
                    <option value="">미기재</option>
                    <option value="X" ${resource.costFlag == 'X' ? 'selected' : ''}>X 무료</option>
                    <option value="O" ${resource.costFlag == 'O' ? 'selected' : ''}>O 본인부담</option>
                </select>
            </div>
            <div class="col-sm-8">
                <label class="form-label" for="costAmount">부담금 설명</label>
                <input type="text" class="form-control" id="costAmount" name="costAmount"
                       value="<c:out value='${resource.costAmount}'/>">
            </div>
            <div class="col-sm-6">
                <label class="form-label" for="sourceName">출처명</label>
                <input type="text" class="form-control" id="sourceName" name="sourceName"
                       value="<c:out value='${resource.sourceName}'/>">
            </div>
            <div class="col-sm-6">
                <label class="form-label" for="sourceUrl">출처 URL</label>
                <input type="text" class="form-control" id="sourceUrl" name="sourceUrl"
                       value="<c:out value='${resource.sourceUrl}'/>">
            </div>
            <div class="col-sm-4">
                <label class="form-label" for="dataBaseDate">자료 기준일 *</label>
                <input type="date" class="form-control" id="dataBaseDate" name="dataBaseDate"
                       value="<c:out value='${resource.dataBaseDate}'/>">
            </div>
            <div class="col-sm-4">
                <label class="form-label" for="lastVerifiedDate">최근 확인일</label>
                <input type="date" class="form-control" id="lastVerifiedDate" name="lastVerifiedDate"
                       value="<c:out value='${resource.lastVerifiedDate}'/>">
            </div>
            <div class="col-sm-4">
                <label class="form-label" for="status">상태</label>
                <select class="form-select" id="status" name="status">
                    <option value="A" ${resource.status == 'A' or empty resource.status ? 'selected' : ''}>A 노출</option>
                    <option value="H" ${resource.status == 'H' ? 'selected' : ''}>H 숨김</option>
                    <option value="E" ${resource.status == 'E' ? 'selected' : ''}>E 종료</option>
                </select>
            </div>
        </div>
    </section>

    <button type="submit" class="btn btn-bk btn-lg">저장</button>
</form>

<%@ include file="../common/admin-foot.jspf" %>
