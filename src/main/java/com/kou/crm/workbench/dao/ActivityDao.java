package com.kou.crm.workbench.dao;

import com.kou.crm.workbench.domain.Activity;
import com.kou.crm.workbench.domain.Contacts;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

public interface ActivityDao {
    int saveActivity(Activity activity);

    List<Activity> getActivityByCondition(Map<String, Object> map);

    Integer getTotalByCondition(Map<String, Object> map);

    Integer deleteActivity(String[] ids);

    Activity getActivityById(String activityId);

    int updateActivity(Activity activity);

    Activity detail(String id);

    List<Activity> getActivityListByClueId(String clueid);

    List<Activity> getActivityListByNameAndNotByClueId(Map<String, String> map);

    List<Activity> getActivityListByName(String activityName);

    List<Activity> getActivityListByNameAndNotByActivityId(@Param("activityName") String activityName,@Param("activityId") String activityId);

    List<Activity> getActivityByContactId(String id);

    List<Activity> getActivityListByNameAndNotByContactsId(@Param("activityName") String activityName,@Param("contactsId") String contactsId);

    Integer getTotal();

    List<Map<String, Object>> getCharts();
}
