package com.kou.crm.workbench.web.controller;

import com.kou.crm.exception.ActivityException;
import com.kou.crm.settings.domain.User;
import com.kou.crm.settings.service.UserService;
import com.kou.crm.utils.DateTimeUtil;
import com.kou.crm.utils.UUIDUtil;
import com.kou.crm.vo.PaginationVo;
import com.kou.crm.workbench.domain.Activity;
import com.kou.crm.workbench.domain.ActivityRemark;
import com.kou.crm.workbench.service.ActivityService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import javax.servlet.http.HttpServletRequest;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("workbench/activity")
public class ActivityController {

    @Autowired
    private UserService userService;

    @Autowired
    private ActivityService activityService;


    //  获取用户信息
    @RequestMapping("/getUserList.do")
    @ResponseBody
    public List<User> getUserList(){
        //  获取用户信息
        List<User> userList = userService.getUserList();
        return userList;
    }


    //  创建、保存活动
    @RequestMapping("/saveActivity.do")
    @ResponseBody
    public Map<String,Object> saveActivity(HttpServletRequest request, Activity activity) throws ActivityException {

        Map<String,Object> map = new HashMap<>();

        String id = UUIDUtil.getUUID();
        String createTime = DateTimeUtil.getSysTime();
        String createBy = ((User)request.getSession().getAttribute("user")).getName();

        activity.setId(id);
        activity.setCreateTime(createTime);
        activity.setCreateBy(createBy);

        boolean flag = activityService.saveActivity(activity);

        map.put("success",flag);
        map.put("msg","添加成功！");

        return map;
    }


    //  分页查询
    @RequestMapping("/pageList.do")
    @ResponseBody
    public PaginationVo<Activity> pageList(Activity activity, Integer pageNo, Integer pageSize){

        //  计算出掠过的记录数
        Integer skipCount = (pageNo - 1) * pageSize;

        //  条件查询，分页查询
        Map<String,Object> map = new HashMap<>();
        map.put("name",activity.getName());
        map.put("owner",activity.getOwner());
        map.put("startDate",activity.getStartDate());
        map.put("endDate",activity.getEndDate());
        map.put("skipCount",skipCount);
        map.put("pageSize",pageSize);

        /**
         * 前端要:市场活动信息列表
         *      查询的总条数
         *
         * 业务层拿到了以上两项信息之后，如果做返回
         * 业务层拿到了以上两项信息之后，如果做返回
         * map
         *      map. put( "datalist":datalist)
         *      map. put("total ":total)
         *      map --> json
         *      {"total”: 100, "datalist":[{市场活动1}, {2},{3}]}
         *
         * VO
         *      PaginationVO<T>
         *          private int total;
         *          private List<T> datalist;
         *
         *      PaginationVO<Activity> vo = new PaginationV0<>;
         *          *      vo.setTotal(total);
         *          *      vo.setDataList(datalist);
         *          *      vo --> json
         *          *      {"total":100, "datalist":[{市场活动1}, {2}, {3}]}
         *
         *      将来分页查询，每个模块都有，所以我们选择使用一个通用vo，操作起来比较方便
         *
         */
        PaginationVo<Activity> paginationVo = activityService.pageList(map);
        return paginationVo;
    }


    //  删除活动
    @ResponseBody
    @RequestMapping("/deleteActivity.do")
    public Map<String,Object> deleteActivity(String[] id) throws ActivityException {

        Map<String,Object> map = new HashMap<>();

        boolean flag = activityService.deleteActivity(id);
        map.put("success",flag);
        map.put("msg","删除成功");

        return map;
    }


    //  查询用户信息列表和根据市场信息活动id查询单条记录的操作
    @ResponseBody
    @RequestMapping("/getUserListAndActivity.do")
    public Map<String,Object> getUserListAndActivity(String activityId){
        /**
         * 总结:
         * controller调用service的方法，返回值应该是什么
         *      你得想一想前端要什么，就要从service层取什么
         *
         * 前端需要的，管业务层去要
         * data
         *      {"userList":[{用户1},{用户2},{用户3}],"activity":{市场活动}}
         *
         * 以上两项信息，复用率不高，我们选择使用map打包这两项信息即可
         * map
         *
         */
        Map<String,Object> map = activityService.getUserListAndActivity(activityId);
        return map;
    }

    //  修改活动
    @ResponseBody
    @RequestMapping("/updateActivity.do")
    public Map<String,Object> updateActivity(HttpServletRequest request,Activity activity) throws ActivityException {
        Map<String,Object> map = new HashMap<>();

        //  修改时间
        String editTime = DateTimeUtil.getSysTime();
        //  修改人
        String editBy = ((User)request.getSession().getAttribute("user")).getName();

        activity.setEditTime(editTime);
        activity.setEditBy(editBy);

        boolean flag = activityService.updateActivity(activity);

        map.put("success",flag);
        map.put("msg","修改成功！");

        return map;
    }

    //  获取活动详情页
    @RequestMapping("/detail.do")
    @ResponseBody
    public ModelAndView detail(String id){

        ModelAndView modelAndView = new ModelAndView();

        Activity activity = activityService.detail(id);
        modelAndView.addObject("activity",activity);
        modelAndView.setViewName("detail.jsp");

        return modelAndView;
    }

    //  根据市场活动id，获取详情页的备注信息
    @ResponseBody
    @RequestMapping("/getRemarkListByAid.do")
    public List<ActivityRemark> getRemarkListByAid(String activityId){

        List<ActivityRemark> list = activityService.getRemarkListByAid(activityId);

        return list;
    }


    //  根据备注信息id，删除单条备注信息
    @ResponseBody
    @RequestMapping("/deleteRemark.do")
    public Map<String,Object> deleteRemark(String id) throws ActivityException {
        Map<String,Object> map = new HashMap<>();

        boolean success = activityService.deleteRemark(id);
        map.put("success",success);
        map.put("msg","删除成功！");
        return map;
    }


    //  根据备注信息、活动id，添加单条备注信息
    @ResponseBody
    @RequestMapping("/saveRemark.do")
    public Map<String,Object> saveRemark(ActivityRemark activityRemark) throws ActivityException {
        Map<String,Object> map = new HashMap<>();

        String id = UUIDUtil.getUUID();
        String createTime = DateTimeUtil.getSysTime();

        activityRemark.setId(id);
        activityRemark.setCreateTime(createTime);

        boolean success = activityService.saveRemark(activityRemark);
        map.put("success",success);
        map.put("activityRemark",activityRemark);
        return map;
    }

    @ResponseBody
    @RequestMapping("/updateRemark.do")
    public Map<String,Object> updateRemark(ActivityRemark activityRemark) throws ActivityException {
        Map<String,Object> map = new HashMap<>();
        String editTime = DateTimeUtil.getSysTime();
        activityRemark.setEditTime(editTime);

        boolean success = activityService.updateRemark(activityRemark);
        map.put("success",success);
        map.put("activityRemark",activityRemark);

        return map;
    }
}
