package com.ieum.bokji.mapper;

import com.ieum.bokji.dto.MatchCondition;
import com.ieum.bokji.dto.MatchResultRow;
import com.ieum.bokji.dto.PageParam;
import com.ieum.bokji.dto.Resource;
import java.util.List;
import org.apache.ibatis.annotations.Param;

public interface ResourceMapper {

    /** 매칭 엔진 — 판정·점수·태그 전부 SQL 산출 (resource-mapper.xml). */
    List<MatchResultRow> findMatches(@Param("cond") MatchCondition cond,
                                     @Param("category") String category,
                                     @Param("lang") String lang,
                                     @Param("sort") String sort);

    /** 단일 자원 판정 — WHERE 제외 없이 1건에 동일 판정 적용(불일치 태그 포함). */
    MatchResultRow findOneWithJudge(@Param("id") int id,
                                    @Param("cond") MatchCondition cond,
                                    @Param("lang") String lang);

    /** 판정 없는 단순 조회 (i18n 폴백 포함). */
    MatchResultRow findById(@Param("id") int id, @Param("lang") String lang);

    List<Resource> adminList(PageParam p);

    int adminCount(PageParam p);

    /** 랜딩 문구용 활성 자원 수. */
    int activeCount();

    int insert(Resource r);

    int update(Resource r);

    int updateStatus(@Param("id") int id, @Param("status") String status);
}
