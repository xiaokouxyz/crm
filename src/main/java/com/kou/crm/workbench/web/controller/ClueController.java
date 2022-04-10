package com.kou.crm.workbench.web.controller;

import com.kou.crm.exception.ClueException;
import com.kou.crm.settings.domain.User;
import com.kou.crm.settings.service.UserService;
import com.kou.crm.utils.DateTimeUtil;
import com.kou.crm.utils.UUIDUtil;
import com.kou.crm.vo.PaginationVo;
import com.kou.crm.workbench.domain.Activity;
import com.kou.crm.workbench.domain.Clue;
import com.kou.crm.workbench.domain.ClueRemark;
import com.kou.crm.workbench.domain.Tran;
import com.kou.crm.workbench.service.ActivityService;
import com.kou.crm.workbench.service.ClueService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import javax.servlet.http.HttpServletRequest;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("workbench/clue")
public class ClueController {
    @Autowired
    private ClueService clueService;
    @Autowired
    private UserService userService;
    @Autowired
    private ActivityService activityService;

    //  获取用户列表
    @RequestMapping("/getUserList.do")
    @ResponseBody
    public List<User> getUserList(){
        List<User> userList = userService.getUserList();
        return userList;
    }

    //  分页查询
    @RequestMapping("/pageList.do")
    @ResponseBody
    public PaginationVo<Clue> pageList(Clue clue,Integer pageNo,Integer pageSize){
        //  掠过的线索条数
        Integer skipCount = (pageNo - 1) * pageSize;

        Map<String,Object> map = new HashMap<>();
        map.put("fullname",clue.getFullname());
        map.put("company", clue.getCompany());
        map.put("phone",clue.getAddress());
        map.put("source",clue.getSource());
        map.put("owner",clue.getOwner());
        map.put("mphone",clue.getMphone());
        map.put("state",clue.getState());
        map.put("skipCount",skipCount);
        map.put("pageSize",pageSize);

        PaginationVo<Clue> cluePaginationVo = clueService.pageList(map);
        return cluePaginationVo;
    }

    //  修改按钮,获取用户列表和线索详细信息
    @RequestMapping("/getUserListAndClue.do")
    @ResponseBody
    public Map<String,Object> getUserListAndClue(String clueId){
        //  拿到 userList 和 clue
        Map<String,Object> map = clueService.getUserListAndClue(clueId);

        return map;
    }

    //  修改线索
    @RequestMapping("/updateClue.do")
    @ResponseBody
    public Map<String,Object> updateClue(Clue clue) throws ClueException {
        Map<String,Object> map = new HashMap<>();
        boolean success = clueService.updateClue(clue);
        map.put("success",success);
        return map;
    }

    //  删除线索
    @RequestMapping("/deleteClue.do")
    @ResponseBody
    public Map<String,Object> deleteClue(String[] id) throws ClueException {
        Map<String,Object> map = new HashMap<>();
        boolean success = clueService.deleteClue(id);
        map.put("success",success);
        return map;
    }

    //  保存线索
    @ResponseBody
    @RequestMapping("/saveClue.do")
    public Map<String,Object> saveClue(Clue clue) throws ClueException {
        Map<String,Object> map = new HashMap<>();
        String id = UUIDUtil.getUUID();
        String createTime = DateTimeUtil.getSysTime();
        clue.setId(id);
        clue.setCreateTime(createTime);

        boolean success = clueService.saveClue(clue);
        map.put("success",success);

        return map;
    }

    //  转发到详情页
    @ResponseBody
    @RequestMapping("/detail.do")
    public ModelAndView detail(String id){
        ModelAndView modelAndView = new ModelAndView();

        Clue clue = clueService.detail(id);
        modelAndView.addObject("clue",clue);
        modelAndView.setViewName("detail.jsp");
        return modelAndView;
    }

    //  通过线索Id获取市场活动信息
    @RequestMapping("/getActivityListByClueId.do")
    @ResponseBody
    public List<Activity> getActivityListByClueId(String clueid){
        List<Activity> list = activityService.getActivityListByClueId(clueid);

        return list;
    }

    //  通过线索和市场活动关系表的id解除关联
    @RequestMapping("/unboundByTcarId.do")
    @ResponseBody
    public Map<String,Object> unboundByTcarid(String tcarId) throws ClueException {
        Map<String,Object> map = new HashMap<>();

        boolean success = clueService.unboundByTcarid(tcarId);
        map.put("success",success);
        return map;
    }

    //  通过活动名字和未关联的线索id获取活动列表
    @RequestMapping("/getActivityListByNameAndNotByClueId.do")
    @ResponseBody
    public List<Activity> getActivityListByNameAndNotByClueId(String activityName,String clueId){
        Map<String,String> map = new HashMap<>();
        map.put("activityName",activityName);
        map.put("clueId",clueId);

        List<Activity> list = activityService.getActivityListByNameAndNotByClueId(map);
        return list;
    }

    //  执行关联市场活动
    @RequestMapping("/boundActivity.do")
    @ResponseBody
    public Map<String,Object> boundActivity(String clueId,String[] activityId) throws ClueException {
        Map<String,Object> map = new HashMap<>();

        boolean success = clueService.boundActivity(clueId,activityId);
        map.put("success",success);
        return map;
    }

    //  查找备注
    @RequestMapping("/getRemarkListByCid.do")
    @ResponseBody
    public List<ClueRemark> getRemarkListByCid(String clueId){
        List<ClueRemark> list = clueService.getRemarkListByCid(clueId);
        return list;
    }

    //  根据名称模糊 查询市场活动列表
    @RequestMapping("/getActivityListByName.do")
    @ResponseBody
    public List<Activity> getActivityListByName(String activityName){
        List<Activity> list = activityService.getActivityListByName(activityName);
        return list;
    }

    //  转换操作
    @RequestMapping("/convert.do")
    @ResponseBody
    public ModelAndView convert(String clueId, Tran tran, HttpServletRequest request) throws ClueException {
        ModelAndView modelAndView = new ModelAndView();

        String createBy = ((User)request.getSession().getAttribute("user")).getName();
        String id = UUIDUtil.getUUID();
        String createTime = DateTimeUtil.getSysTime();
        if (tran != null) {
            tran.setId(id);
            tran.setCreateBy(createBy);
            tran.setCreateTime(createTime);
        }

        boolean flag = clueService.convert(clueId,tran,createBy);
        if (flag){
            modelAndView.setViewName("redirect:index.jsp");
        }

        return modelAndView;
    }

    //  保存线索备注
    @RequestMapping("/saveClueRemark.do")
    @ResponseBody
    public Map<String,Object> saveClueRemark(ClueRemark clueRemark) throws ClueException{
        Map<String,Object> map = new HashMap<>();
        boolean success = false;
        if (clueRemark != null){

            String id = UUIDUtil.getUUID();
            String createTime = DateTimeUtil.getSysTime();

            clueRemark.setId(id);
            clueRemark.setCreateTime(createTime);

            success = clueService.saveClueRemark(clueRemark);
        }
        map.put("success",success);
        return map;
    }

    //  删除线索备注
    @RequestMapping("/deleteRemark.do")
    @ResponseBody
    public Map<String,Object> deleteRemark(String id) throws ClueException {

        Map<String,Object> map = new HashMap<>();
        boolean success = clueService.deleteRemark(id);

        map.put("success",success);
        return map;
    }

    //  更新备注
    @RequestMapping("/updateRemark.do")
    @ResponseBody
    public Map<String,Object> updateRemark(ClueRemark clueRemark) throws ClueException{

        Map<String,Object> map = new HashMap<>();
        String editTime = DateTimeUtil.getSysTime();
        clueRemark.setEditTime(editTime);
        boolean success = clueService.updateRemark(clueRemark);

        map.put("clueRemark",clueRemark);
        map.put("success",success);

        return map;
    }
}
