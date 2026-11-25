package com.ieum.bokji.mapper;

import com.ieum.bokji.dto.StatsDailyRow;
import com.ieum.bokji.dto.StatsDimRow;
import com.ieum.bokji.dto.StatsResourceRow;
import com.ieum.bokji.dto.StatsSummary;
import java.util.List;
import org.apache.ibatis.annotations.Param;

/** 관리자 이용 통계 — match_log·event_log 읽기 전용 집계. days=0이면 전체 기간. */
public interface StatsMapper {

    StatsSummary summary(@Param("days") int days);

    List<StatsResourceRow> popularResources(@Param("days") int days);

    List<StatsDimRow> conditionCounts(@Param("days") int days);

    List<StatsDailyRow> daily(@Param("days") int days);
}