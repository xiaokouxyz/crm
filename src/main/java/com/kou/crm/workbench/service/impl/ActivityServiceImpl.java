package com.kou.crm.workbench.service.impl;

import com.kou.crm.exception.ActivityException;
import com.kou.crm.settings.dao.UserDao;
import com.kou.crm.settings.domain.User;
import com.kou.crm.vo.PaginationVo;
import com.kou.crm.workbench.dao.ActivityDao;
import com.kou.crm.workbench.dao.ActivityRemarkDao;
import com.kou.crm.workbench.domain.Activity;
import com.kou.crm.workbench.domain.ActivityRemark;
import com.kou.crm.workbench.service.ActivityService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class ActivityServiceImpl implements ActivityService {

    @Autowired
    private ActivityDao activityDao;
    @Autowired
    private ActivityRemarkDao activityRemarkDao;
    @Autowired
    private UserDao userDao;

    //  保存市场活动列表
    @Override
    public boolean saveActivity(Activity activity) throws ActivityException {
        boolean flag = true;
        int count = activityDao.saveActivity(activity);

        if (count != 1)
            throw new ActivityException("保存失败！");

        return flag;
    }

    //  分页查询
    @Override
    public PaginationVo<Activity> pageList(Map<String, Object> map) {
        //  取得total
        Integer total = activityDao.getTotalByCondition(map);

        //  取得dataList
        List<Activity> activityList = activityDao.getActivityByCondition(map);

        //  将total、dataList封装到vo中
        PaginationVo<Activity> activityPaginationVo = new PaginationVo<>();
        activityPaginationVo.setTotal(total);
        activityPaginationVo.setDataList(activityList);

        //  将vo返回
        return activityPaginationVo;
    }

    //  删除市场活动
    @Override
    public boolean deleteActivity(String[] ids) throws ActivityException {
        //  查询出需要删除的备注的数量
        Integer count1 = activityRemarkDao.getCountByAids(ids);

        //  删除备注，返回受到影响的条数（实际删除的数量）
        Integer count2 = activityRemarkDao.deleteByAids(ids);

        if (count1 != count2){
            throw new ActivityException("删除备注失败!");
        }
        //  删除市场活动
        Integer count3 = activityDao.deleteActivity(ids);

        if (count3 != ids.length){
            throw new ActivityException("删除活动失败!");
        }

        return true;
    }


    @Override
    public Map<String, Object> getUserListAndActivity(String activityId) {
        //  取userList
        List<User> userList = userDao.getUserList();

        //  取activity
        Activity activity = activityDao.getActivityById(activityId);

        //  打包成map
        Map<String,Object> map = new HashMap<>();
        map.put("userList",userList);
        map.put("activity",activity);

        //  返回map
        return map;
    }

    @Override
    public boolean updateActivity(Activity activity) throws ActivityException {

        int count = activityDao.updateActivity(activity);

        if (count != 1)
            throw new ActivityException("修改失败");

        return true;
    }

    @Override
    public Activity detail(String id) {

        Activity activity = activityDao.detail(id);
        return activity;
    }

    @Override
    public List<ActivityRemark> getRemarkListByAid(String activityId) {
        List<ActivityRemark> list = activityRemarkDao.getRemarkListByAid(activityId);

        return list;
    }

    @Override
    public boolean deleteRemark(String id) throws ActivityException {
        int count = activityRemarkDao.deleteRemarkById(id);
        if (count != 1)
            throw new ActivityException("删除失败！");
        return true;
    }

    @Override
    public boolean saveRemark(ActivityRemark activityRemark) throws ActivityException {
        int count = activityRemarkDao.saveRemark(activityRemark);
        if (count != 1)
            throw new ActivityException("保存备注失败！");
        return true;
    }

    @Override
    public boolean updateRemark(ActivityRemark activityRemark) throws ActivityException{
        int count = activityRemarkDao.updateRemark(activityRemark);
        if (count != 1)
            throw new ActivityException("更新备注失败！");
        return true;
    }

    @Override
    public List<Activity> getActivityListByClueId(String clueid) {
        List<Activity> list = activityDao.getActivityListByClueId(clueid);
        return list;
    }

    @Override
    public List<Activity> getActivityListByNameAndNotByClueId(Map<String, String> map) {
        List<Activity> list = activityDao.getActivityListByNameAndNotByClueId(map);
        return list;
    }

    @Override
    public List<Activity> getActivityListByName(String activityName) {
        List<Activity> list = activityDao.getActivityListByName(activityName);
        return list;
    }

    @Override
    public Map<String, Object> getCharts() {
        //  取得total
        Integer total = activityDao.getTotal();

        //  取得dataList
        List<Map<String,Object>> dataList = activityDao.getCharts();

        //  将total和list装进map
        Map<String,Object> map = new HashMap<>();
        map.put("total",total);
        map.put("dataList",dataList);

        //  返回map
        return map;
    }
}
