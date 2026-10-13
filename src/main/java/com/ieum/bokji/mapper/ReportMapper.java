package com.ieum.bokji.mapper;

import com.ieum.bokji.dto.PageParam;
import com.ieum.bokji.dto.Report;
import java.util.List;
import org.apache.ibatis.annotations.Param;

public interface ReportMapper {

    int insert(Report report);

    List<Report> list(PageParam p);

    int count(PageParam p);

    int updateStatus(@Param("id") int id, @Param("status") String status, @Param("memo") String memo);
}
