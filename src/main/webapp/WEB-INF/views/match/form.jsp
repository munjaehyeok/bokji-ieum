<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%-- 기능 검증용 최소 폼 — 디자인 금지(프론트 교체 예정). 폼 name은 MatchCondition 필드와 1:1. --%>
<!DOCTYPE html>
<html lang="ko">
<head><meta charset="UTF-8"><title>조건 입력 — 복지이음</title></head>
<body>
<h1>내 복지 찾기 — 조건 입력</h1>
<c:if test="${not empty param.error}">
    <p style="color:red">입력값을 확인해 주세요: <c:out value="${param.error}"/></p>
</c:if>
<form method="post" action="${pageContext.request.contextPath}/match">
    <p>1. 출생연도 (모름이면 비워두기)<br>
        <input type="number" name="birthYear" min="1900" max="2026"
               value="<c:out value='${condition.birthYear}'/>">
    </p>
    <p>2. 거주 동<br>
        <select name="dong">
            <option value="">모름 / 선택 안 함</option>
            <c:forTokens items="GJ,WG,BG1,BG2,JWB,JW1,JW2,JW3,JW4,JG,EH,DY,SC,SH,GL,MG,MH,NG,YS"
                         delims="," var="code">
                <option value="${code}" ${condition.dong == code ? 'selected' : ''}>${code}</option>
            </c:forTokens>
        </select>
    </p>
    <p>3. 가구 상황 (복수 선택 / 전부 미선택 = 모름)<br>
        <c:forTokens items="ONE,SPAR,MCHD,MCUL,NKOR,PREG" delims="," var="hh">
            <label><input type="checkbox" name="householdTypes" value="${hh}"
                ${condition.householdTypes.contains(hh) ? 'checked' : ''}> ${hh}</label>
        </c:forTokens>
        <label><input type="checkbox" name="householdTypes" value="NONE"
            ${condition.householdTypes.contains('NONE') ? 'checked' : ''}> 해당 없음</label>
    </p>
    <p>4. 소득 수준<br>
        <label><input type="radio" name="incomeRank" value="0" ${condition.incomeRank == 0 ? 'checked' : ''}> 모름</label>
        <label><input type="radio" name="incomeRank" value="1" ${condition.incomeRank == 1 ? 'checked' : ''}> 기초생활수급</label>
        <label><input type="radio" name="incomeRank" value="2" ${condition.incomeRank == 2 ? 'checked' : ''}> 차상위</label>
        <label><input type="radio" name="incomeRank" value="3" ${condition.incomeRank == 3 ? 'checked' : ''}> 중위 100% 이하</label>
        <label><input type="radio" name="incomeRank" value="4" ${condition.incomeRank == 4 ? 'checked' : ''}> 그 이상</label>
    </p>
    <p>5. 장애 여부<br>
        <label><input type="radio" name="disability" value="Y" ${condition.disability == 'Y' ? 'checked' : ''}> 예</label>
        <label><input type="radio" name="disability" value="N" ${condition.disability == 'N' ? 'checked' : ''}> 아니오</label>
        <label><input type="radio" name="disability" value="U" ${condition.disability == 'U' ? 'checked' : ''}> 모름</label>
    </p>
    <p>6. 국적·체류 (필수, 기본 내국인)<br>
        <label><input type="radio" name="nationality" value="K" ${condition.nationality != 'F' ? 'checked' : ''}> 내국인</label>
        <label><input type="radio" name="nationality" value="F" ${condition.nationality == 'F' ? 'checked' : ''}> 외국인·귀화·체류</label>
    </p>
    <p>7. 학업·취업 상태 (복수 선택 / 전부 미선택 = 모름)<br>
        <c:forTokens items="STU,UNIV,SEEK,WORK" delims="," var="ew">
            <label><input type="checkbox" name="eduWork" value="${ew}"
                ${condition.eduWork.contains(ew) ? 'checked' : ''}> ${ew}</label>
        </c:forTokens>
        <label><input type="checkbox" name="eduWork" value="NONE"
            ${condition.eduWork.contains('NONE') ? 'checked' : ''}> 해당 없음</label>
    </p>
    <fieldset>
        <legend>가구원 추가 (선택 — 동·소득·가구형태는 본인 조건을 따라감)</legend>
        <p>관계 <input type="text" name="members[0].relation" placeholder="예: 자녀1"></p>
        <p>출생연도 <input type="number" name="members[0].birthYear" min="1900" max="2026"></p>
        <p>장애 여부
            <select name="members[0].disability">
                <option value="U">모름</option><option value="Y">예</option><option value="N">아니오</option>
            </select>
        </p>
        <p>학업·취업
            <c:forTokens items="STU,UNIV,SEEK,WORK,NONE" delims="," var="ew">
                <label><input type="checkbox" name="members[0].eduWork" value="${ew}"> ${ew}</label>
            </c:forTokens>
        </p>
    </fieldset>
    <p><button type="submit">결과 보기</button></p>
</form>
<p>입력하신 정보는 저장되지 않습니다.</p>
</body>
</html>
