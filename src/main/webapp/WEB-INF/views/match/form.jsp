<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<c:set var="pageTitle"><spring:message code="form.title"/></c:set>
<%@ include file="../common/top.jspf" %>

<c:if test="${not empty param.error}">
    <div class="alert alert-danger" role="alert" id="bkFormError"
         data-error="<c:out value='${param.error}'/>">
        <c:choose>
            <c:when test="${param.error == 'memberBirthYear'}"><spring:message code="form.error.memberBirthYear"/></c:when>
            <c:otherwise><spring:message code="form.error.birthYear"/></c:otherwise>
        </c:choose>
    </div>
</c:if>

<div class="bk-progress" aria-hidden="true" id="bkDots">
    <span class="bk-dot"></span><span class="bk-dot"></span><span class="bk-dot"></span>
    <span class="bk-dot"></span><span class="bk-dot"></span><span class="bk-dot"></span>
    <span class="bk-dot"></span>
    <span class="bk-progress-text" id="bkStepText"></span>
</div>
<p class="visually-hidden" aria-live="polite" id="bkStepLive"></p>

<form id="bkMatchForm" method="post" action="${ctx}/match">

    <%-- Q1 출생연도 --%>
    <section class="bk-step" data-step="1" data-q="1">
        <h2 tabindex="-1"><spring:message code="form.q1"/></h2>
        <p class="hint"><spring:message code="form.q1.hint"/></p>
        <label for="birthYear" class="form-label"><spring:message code="form.q1.label"/></label>
        <input type="number" class="form-control form-control-lg" style="max-width: 240px"
               id="birthYear" name="birthYear" inputmode="numeric" min="1900" max="2026"
               value="<c:out value='${condition.birthYear}'/>">
    </section>

    <%-- Q2 거주 동 --%>
    <section class="bk-step" data-step="2" data-q="2">
        <h2 tabindex="-1"><spring:message code="form.q2"/></h2>
        <label for="dong" class="form-label"><spring:message code="form.q2.label"/></label>
        <select class="form-select form-select-lg" style="max-width: 320px" id="dong" name="dong">
            <option value=""><spring:message code="form.q2.unknown"/></option>
            <c:forTokens items="GJ,WG,BG1,BG2,JWB,JW1,JW2,JW3,JW4,JG,EH,DY,SC,SH,GL,MG,MH,NG,YS"
                         delims="," var="code">
                <option value="${code}" ${condition.dong == code ? 'selected' : ''}>
                    <spring:message code="dong.${code}"/>
                </option>
            </c:forTokens>
        </select>
    </section>

    <%-- Q3 가구 상황 --%>
    <section class="bk-step" data-step="3" data-q="3">
        <h2 tabindex="-1"><spring:message code="form.q3"/></h2>
        <p class="hint"><spring:message code="form.q3.why"/></p>
        <div class="bk-choice-grid" data-none-group>
            <c:forTokens items="ONE,SPAR,MCHD,MCUL,NKOR,PREG,NONE" delims="," var="hh">
                <label class="bk-choice">
                    <input type="checkbox" name="householdTypes" value="${hh}"
                           ${condition.householdTypes.contains(hh) ? 'checked' : ''}>
                    <spring:message code="hh.${hh}"/>
                </label>
            </c:forTokens>
        </div>
    </section>

    <%-- Q4 소득 --%>
    <section class="bk-step" data-step="4" data-q="4">
        <h2 tabindex="-1"><spring:message code="form.q4"/></h2>
        <p class="hint"><spring:message code="form.q4.why"/></p>
        <div class="bk-choice-grid flex-column align-items-stretch" style="max-width: 420px">
            <c:forEach var="r" begin="0" end="4">
                <label class="bk-choice">
                    <input type="radio" name="incomeRank" value="${r}"
                           ${condition.incomeRank == r ? 'checked' : ''}>
                    <spring:message code="income.${r}"/>
                </label>
            </c:forEach>
        </div>
        <details class="mt-3">
            <summary class="text-primary" style="min-height:44px; display:flex; align-items:center">
                <spring:message code="form.q4.help"/>
            </summary>
            <p class="hint mt-2"><spring:message code="form.q4.helpText"/></p>
        </details>
    </section>

    <%-- Q5 장애 --%>
    <section class="bk-step" data-step="5" data-q="5">
        <h2 tabindex="-1"><spring:message code="form.q5"/></h2>
        <div class="bk-choice-grid">
            <c:forTokens items="Y,N,U" delims="," var="d">
                <label class="bk-choice">
                    <input type="radio" name="disability" value="${d}"
                           ${condition.disability == d ? 'checked' : ''}>
                    <spring:message code="dis.${d}"/>
                </label>
            </c:forTokens>
        </div>
    </section>

    <%-- Q6 국적 --%>
    <section class="bk-step" data-step="6" data-q="6">
        <h2 tabindex="-1"><spring:message code="form.q6"/></h2>
        <div class="bk-choice-grid">
            <label class="bk-choice">
                <input type="radio" name="nationality" value="K"
                       ${condition.nationality != 'F' ? 'checked' : ''}>
                <spring:message code="nat.K"/>
            </label>
            <label class="bk-choice">
                <input type="radio" name="nationality" value="F"
                       ${condition.nationality == 'F' ? 'checked' : ''}>
                <spring:message code="nat.F"/>
            </label>
        </div>
    </section>

    <%-- Q7 학업·취업 + 가구원 추가 --%>
    <section class="bk-step" data-step="7" data-q="7">
        <h2 tabindex="-1"><spring:message code="form.q7"/></h2>
        <div class="bk-choice-grid" data-none-group>
            <c:forTokens items="STU,UNIV,SEEK,WORK,NONE" delims="," var="ew">
                <label class="bk-choice">
                    <input type="checkbox" name="eduWork" value="${ew}"
                           ${condition.eduWork.contains(ew) ? 'checked' : ''}>
                    <spring:message code="ew.${ew}"/>
                </label>
            </c:forTokens>
        </div>

        <hr class="my-4">
        <h3 class="fs-5 fw-bold"><spring:message code="member.title"/></h3>
        <p class="hint"><spring:message code="member.desc"/></p>
        <div id="bkMembers">
            <c:forEach var="m" items="${condition.members}" varStatus="st">
                <fieldset class="bk-member-card">
                    <legend class="fs-6 fw-bold d-flex justify-content-between">
                        <span><spring:message code="member.label"/> ${st.index + 1}</span>
                    </legend>
                    <div class="row g-2">
                        <div class="col-sm-6">
                            <label class="form-label" for="mRel${st.index}"><spring:message code="member.relation"/></label>
                            <input type="text" class="form-control" id="mRel${st.index}"
                                   name="members[${st.index}].relation" maxlength="20"
                                   placeholder="<spring:message code='member.relation.ph'/>"
                                   value="<c:out value='${m.relation}'/>">
                        </div>
                        <div class="col-sm-6">
                            <label class="form-label" for="mBy${st.index}"><spring:message code="member.birthYear"/></label>
                            <input type="number" class="form-control" id="mBy${st.index}"
                                   name="members[${st.index}].birthYear" inputmode="numeric"
                                   min="1900" max="2026" value="<c:out value='${m.birthYear}'/>">
                        </div>
                        <div class="col-sm-6">
                            <label class="form-label" for="mDis${st.index}"><spring:message code="member.disability"/></label>
                            <select class="form-select" id="mDis${st.index}" name="members[${st.index}].disability">
                                <option value="U" ${m.disability == 'U' ? 'selected' : ''}><spring:message code="dis.U"/></option>
                                <option value="Y" ${m.disability == 'Y' ? 'selected' : ''}><spring:message code="dis.Y"/></option>
                                <option value="N" ${m.disability == 'N' ? 'selected' : ''}><spring:message code="dis.N"/></option>
                            </select>
                        </div>
                        <div class="col-12">
                            <span class="form-label d-block"><spring:message code="member.eduWork"/></span>
                            <div class="bk-choice-grid" data-none-group>
                                <c:forTokens items="STU,UNIV,SEEK,WORK,NONE" delims="," var="ew">
                                    <label class="bk-choice">
                                        <input type="checkbox" name="members[${st.index}].eduWork" value="${ew}"
                                               ${m.eduWork.contains(ew) ? 'checked' : ''}>
                                        <spring:message code="ew.${ew}"/>
                                    </label>
                                </c:forTokens>
                            </div>
                        </div>
                    </div>
                    <button type="button" class="btn btn-outline-danger btn-sm mt-2" data-remove-member>
                        <spring:message code="member.remove"/>
                    </button>
                </fieldset>
            </c:forEach>
        </div>
        <button type="button" class="btn btn-bk-outline" id="bkAddMember"
                data-next-index="${fn:length(condition.members)}">
            <spring:message code="member.add"/>
        </button>
    </section>

    <div class="bk-step-nav">
        <button type="button" class="btn btn-bk-outline" id="bkPrev"><spring:message code="form.prev"/></button>
        <div class="d-flex gap-2 flex-wrap justify-content-end">
            <button type="button" class="btn btn-outline-secondary" id="bkSkip"><spring:message code="form.skip"/></button>
            <button type="button" class="btn btn-bk" id="bkNext"><spring:message code="form.next"/></button>
            <button type="submit" class="btn btn-bk" id="bkSubmit"><spring:message code="form.submit"/></button>
        </div>
    </div>
    <p class="bk-now-row"><button type="submit" class="bk-now" id="bkNow"><spring:message code="form.now"/></button></p>
    <p class="text-secondary mt-3"><spring:message code="landing.privacy"/></p>
</form>

<%-- 가구원 카드 템플릿 (IDX 치환) --%>
<template id="bkMemberTpl">
    <fieldset class="bk-member-card">
        <legend class="fs-6 fw-bold">
            <span><spring:message code="member.label"/> <span data-member-no></span></span>
        </legend>
        <div class="row g-2">
            <div class="col-sm-6">
                <label class="form-label" for="mRelIDX"><spring:message code="member.relation"/></label>
                <input type="text" class="form-control" id="mRelIDX" name="members[IDX].relation"
                       maxlength="20" placeholder="<spring:message code='member.relation.ph'/>">
            </div>
            <div class="col-sm-6">
                <label class="form-label" for="mByIDX"><spring:message code="member.birthYear"/></label>
                <input type="number" class="form-control" id="mByIDX" name="members[IDX].birthYear"
                       inputmode="numeric" min="1900" max="2026">
            </div>
            <div class="col-sm-6">
                <label class="form-label" for="mDisIDX"><spring:message code="member.disability"/></label>
                <select class="form-select" id="mDisIDX" name="members[IDX].disability">
                    <option value="U"><spring:message code="dis.U"/></option>
                    <option value="Y"><spring:message code="dis.Y"/></option>
                    <option value="N"><spring:message code="dis.N"/></option>
                </select>
            </div>
            <div class="col-12">
                <span class="form-label d-block"><spring:message code="member.eduWork"/></span>
                <div class="bk-choice-grid" data-none-group>
                    <c:forTokens items="STU,UNIV,SEEK,WORK,NONE" delims="," var="ew">
                        <label class="bk-choice">
                            <input type="checkbox" name="members[IDX].eduWork" value="${ew}">
                            <spring:message code="ew.${ew}"/>
                        </label>
                    </c:forTokens>
                </div>
            </div>
        </div>
        <button type="button" class="btn btn-outline-danger btn-sm mt-2" data-remove-member>
            <spring:message code="member.remove"/>
        </button>
    </fieldset>
</template>

<%@ include file="../common/foot.jspf" %>
