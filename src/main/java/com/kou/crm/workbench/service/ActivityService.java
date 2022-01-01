package com.kou.crm.workbench.service;

import com.kou.crm.exception.ActivityException;
import com.kou.crm.vo.PaginationVo;
import com.kou.crm.workbench.domain.Activity;
import com.kou.crm.workbench.domain.ActivityRemark;

import java.util.List;
import java.util.Map;

public interface ActivityService {
    boolean saveActivity(Activity activity) throws ActivityException;

    PaginationVo<Activity> pageList(Map<String, Object> map);

    boolean deleteActivity(String[] ids) throws ActivityException;

    Map<String, Object> getUserListAndActivity(String activityId);

    boolean updateActivity(Activity activity) throws ActivityException;

    Activity detail(String id);

    List<ActivityRemark> getRemarkListByAid(String activityId);

    boolean deleteRemark(String id) throws ActivityException;

    boolean saveRemark(ActivityRemark activityRemark) throws ActivityException;

    boolean updateRemark(ActivityRemark activityRemark) throws ActivityException;

    List<Activity> getActivityListByClueId(String clueid);

    List<Activity> getActivityListByNameAndNotByClueId(Map<String, String> map);

    List<Activity> getActivityListByName(String activityName);
}
