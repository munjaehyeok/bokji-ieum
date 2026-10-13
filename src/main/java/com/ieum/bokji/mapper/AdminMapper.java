package com.ieum.bokji.mapper;

import com.ieum.bokji.dto.AdminUser;
import org.apache.ibatis.annotations.Param;

/** admin_user + resource_history. */
public interface AdminMapper {

    AdminUser findByLoginId(@Param("loginId") String loginId);

    int count();

    int insert(@Param("loginId") String loginId, @Param("pwHash") String pwHash, @Param("name") String name);

    int insertHistory(@Param("resourceId") int resourceId,
                      @Param("adminId") int adminId,
                      @Param("action") String action,
                      @Param("summary") String summary);
}
