package com.ieum.bokji.mapper;

import org.apache.ibatis.annotations.Param;

/** match_log / event_log 익명 로그 (FK 없음, 집계 전용). */
public interface LogMapper {

    void insertEvent(@Param("sessionHash") String sessionHash,
                     @Param("event") String event,
                     @Param("resourceId") Integer resourceId);

    void insertMatch(@Param("sessionHash") String sessionHash,
                     @Param("ageBand") String ageBand,
                     @Param("dong") String dong,
                     @Param("householdTypes") String householdTypes,
                     @Param("incomeRank") Integer incomeRank,
                     @Param("disability") String disability,
                     @Param("nationality") String nationality,
                     @Param("eduWork") String eduWork,
                     @Param("resultCount") int resultCount);
}
