<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%-- 등록·수정 공용. 태깅 7필드는 드롭다운·체크박스만(자유 텍스트 금지). name은 Resource 필드와 1:1. --%>
<!DOCTYPE html>
<html lang="ko">
<head><meta charset="UTF-8"><title>자원 등록·수정 — 복지이음</title></head>
<body>
<h1>자원 <c:choose><c:when test="${resource.resourceId != null}">수정 #<c:out value="${resource.resourceId}"/></c:when><c:otherwise>신규 등록</c:otherwise></c:choose></h1>
<p><a href="${pageContext.request.contextPath}/admin/resources">목록으로</a></p>
<c:set var="dongCsv" value=",${resource.dongCodes},"/>
<c:set var="hhCsv" value=",${resource.householdTypes},"/>
<c:set var="ewCsv" value=",${resource.eduWork},"/>
<form method="post" action="${pageContext.request.contextPath}${formAction}">
    <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}">
    <p>자원명* <input type="text" name="name" required size="60" value="<c:out value='${resource.name}'/>"></p>
    <p>분야*
        <select name="category" required>
            <c:forTokens items="JOB,HOUSE,DAILY,HEALTH,MIND,CARE,EDU,CULTURE,RIGHTS" delims="," var="cat">
                <option value="${cat}" ${resource.category == cat ? 'selected' : ''}>${cat}</option>
            </c:forTokens>
        </select>
        중분류 <input type="text" name="subCategory" value="<c:out value='${resource.subCategory}'/>">
        서비스유형 <input type="text" name="serviceType" value="<c:out value='${resource.serviceType}'/>">
    </p>
    <p>제공주체*
        <select name="providerType">
            <option value="PUB" ${resource.providerType == 'PUB' ? 'selected' : ''}>PUB 공공</option>
            <option value="PRV" ${resource.providerType == 'PRV' ? 'selected' : ''}>PRV 민간</option>
        </select>
        기관명* <input type="text" name="orgName" required value="<c:out value='${resource.orgName}'/>">
        부서 <input type="text" name="deptName" value="<c:out value='${resource.deptName}'/>">
    </p>
    <p>연락처 <input type="text" name="phone" size="50" value="<c:out value='${resource.phone}'/>">
        주소 <input type="text" name="address" size="50" value="<c:out value='${resource.address}'/>"></p>
    <p>지원 내용*<br><textarea name="supportContent" rows="4" cols="80" required><c:out value="${resource.supportContent}"/></textarea></p>
    <p>신청 방법<br><textarea name="applyMethod" rows="2" cols="80"><c:out value="${resource.applyMethod}"/></textarea></p>
    <p>준비 서류<br><textarea name="documents" rows="2" cols="80"><c:out value="${resource.documents}"/></textarea></p>
    <p>신청 URL <input type="url" name="applyUrl" size="60" value="<c:out value='${resource.applyUrl}'/>"></p>

    <fieldset><legend>자격조건 태깅 (비우면 해당 조건 무관)</legend>
        <p>연령 min <input type="number" name="ageMin" value="<c:out value='${resource.ageMin}'/>">
            max <input type="number" name="ageMax" value="<c:out value='${resource.ageMax}'/>"></p>
        <p>거주 동 (복수):
            <c:forTokens items="GJ,WG,BG1,BG2,JWB,JW1,JW2,JW3,JW4,JG,EH,DY,SC,SH,GL,MG,MH,NG,YS" delims="," var="code">
                <label><input type="checkbox" name="dongCodes" value="${code}"
                    ${fn:contains(dongCsv, ','.concat(code).concat(',')) ? 'checked' : ''}> ${code}</label>
            </c:forTokens>
        </p>
        <p>가구형태 (복수):
            <c:forTokens items="ONE,SPAR,MCHD,MCUL,NKOR,PREG" delims="," var="hh">
                <label><input type="checkbox" name="householdTypes" value="${hh}"
                    ${fn:contains(hhCsv, ','.concat(hh).concat(',')) ? 'checked' : ''}> ${hh}</label>
            </c:forTokens>
        </p>
        <p>소득 랭크
            <select name="incomeRank">
                <option value="">무관</option>
                <option value="1" ${resource.incomeRank == 1 ? 'selected' : ''}>1 수급만</option>
                <option value="2" ${resource.incomeRank == 2 ? 'selected' : ''}>2 차상위까지</option>
                <option value="3" ${resource.incomeRank == 3 ? 'selected' : ''}>3 중위100까지</option>
                <option value="4" ${resource.incomeRank == 4 ? 'selected' : ''}>4 중위150까지</option>
            </select>
            <label><input type="checkbox" name="incomeUncertain" value="Y"
                ${resource.incomeUncertain == 'Y' ? 'checked' : ''}> 세부 소득기준 존재(일치여도 확인 필요)</label>
        </p>
        <p>장애 대상
            <select name="disability"><option value="">무관</option>
                <option value="Y" ${resource.disability == 'Y' ? 'selected' : ''}>Y 장애인 대상</option></select>
            국적
            <select name="nationality"><option value="">무관</option>
                <option value="K" ${resource.nationality == 'K' ? 'selected' : ''}>K 내국인 한정</option>
                <option value="F" ${resource.nationality == 'F' ? 'selected' : ''}>F 외국인 대상</option></select>
        </p>
        <p>학업·취업 (복수):
            <c:forTokens items="STU,UNIV,SEEK,WORK" delims="," var="ew">
                <label><input type="checkbox" name="eduWork" value="${ew}"
                    ${fn:contains(ewCsv, ','.concat(ew).concat(',')) ? 'checked' : ''}> ${ew}</label>
            </c:forTokens>
        </p>
        <p>서술형 조건 요약(항상 확인필요 노출)
            <input type="text" name="uncertainNote" size="60" value="<c:out value='${resource.uncertainNote}'/>"></p>
    </fieldset>

    <p>지원 기준 원문<br><textarea name="eligibilityRaw" rows="3" cols="80"><c:out value="${resource.eligibilityRaw}"/></textarea></p>
    <p>선정 소요기간 <input type="text" name="decisionPeriod" value="<c:out value='${resource.decisionPeriod}'/>">
        제공시기 <input type="text" name="serviceCycle" value="<c:out value='${resource.serviceCycle}'/>">
        신청권자 <input type="text" name="applicant" value="<c:out value='${resource.applicant}'/>"></p>
    <p>비용
        <select name="costFlag"><option value="">미기재</option>
            <option value="X" ${resource.costFlag == 'X' ? 'selected' : ''}>X 무료</option>
            <option value="O" ${resource.costFlag == 'O' ? 'selected' : ''}>O 본인부담</option></select>
        부담금 설명 <input type="text" name="costAmount" size="40" value="<c:out value='${resource.costAmount}'/>"></p>
    <p>출처명 <input type="text" name="sourceName" value="<c:out value='${resource.sourceName}'/>">
        출처 URL <input type="text" name="sourceUrl" size="40" value="<c:out value='${resource.sourceUrl}'/>"></p>
    <p>자료 기준일* <input type="date" name="dataBaseDate" value="<c:out value='${resource.dataBaseDate}'/>">
        최근 확인일 <input type="date" name="lastVerifiedDate" value="<c:out value='${resource.lastVerifiedDate}'/>"></p>
    <p>상태
        <select name="status">
            <option value="A" ${resource.status == 'A' or empty resource.status ? 'selected' : ''}>A 노출</option>
            <option value="H" ${resource.status == 'H' ? 'selected' : ''}>H 숨김</option>
            <option value="E" ${resource.status == 'E' ? 'selected' : ''}>E 종료</option>
        </select>
    </p>
    <p><button type="submit">저장</button></p>
</form>
</body>
</html>
