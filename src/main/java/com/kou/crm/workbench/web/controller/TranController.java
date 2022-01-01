package com.kou.crm.workbench.web.controller;

import com.kou.crm.exception.TransactionException;
import com.kou.crm.settings.domain.User;
import com.kou.crm.settings.service.UserService;
import com.kou.crm.utils.DateTimeUtil;
import com.kou.crm.utils.UUIDUtil;
import com.kou.crm.vo.PaginationVo;
import com.kou.crm.workbench.domain.Tran;
import com.kou.crm.workbench.domain.TranHistory;
import com.kou.crm.workbench.service.CustomerService;
import com.kou.crm.workbench.service.TranService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

import javax.servlet.http.HttpServletRequest;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("workbench/transaction")
public class TranController {
    @Autowired
    private TranService tranService;
    @Autowired
    private UserService userService;
    @Autowired
    private CustomerService customerService;

    //  跳转到添加交易页面
    @RequestMapping("/add.do")
    public ModelAndView addTran(){
        ModelAndView modelAndView = new ModelAndView();

        List<User> userList = userService.getUserList();
        modelAndView.addObject("userList",userList);
        modelAndView.setViewName("save.jsp");

        return modelAndView;
    }

    //  取得客户名称列表(按照客户名称进行模糊查询)
    @RequestMapping("/getCustomerName.do")
    @ResponseBody
    public List<String> getCustomerName(String name){
        List<String> list = customerService.getCustomerName(name);
        return list;
    }

    //  创建交易，点击保存
    @RequestMapping("/saveTransaction.do")
    public ModelAndView saveTransaction(Tran tran, String customerName) throws TransactionException {
        ModelAndView modelAndView = new ModelAndView();
        String id = UUIDUtil.getUUID();
        String createTime = DateTimeUtil.getSysTime();
        tran.setId(id);
        tran.setCreateTime(createTime);

        boolean flag = tranService.saveTransaction(tran,customerName);
        if (flag){
            modelAndView.setViewName("redirect:index.jsp");
        }
        return modelAndView;
    }

    //  分页查询
    @RequestMapping("/pageList.do")
    @ResponseBody
    public PaginationVo<Tran> pageList(Tran tran,Integer pageNo,Integer pageSize){
        Integer skipCount = (pageNo - 1) * pageSize;

        PaginationVo<Tran> paginationVo = tranService.pageList(tran,skipCount,pageSize);

        return paginationVo;
    }

    //  跳转到详细信息页
    @RequestMapping("/detail.do")
    public ModelAndView detail(String tranId){
        ModelAndView modelAndView = new ModelAndView();

        Tran tran = tranService.detail(tranId);
        modelAndView.addObject("tran",tran);
        modelAndView.setViewName("detail.jsp");

        return modelAndView;
    }

    //  展现交易历史
    @RequestMapping("/getTranHistoryListByTranId.do")
    @ResponseBody
    public List<TranHistory> getTranHistoryListByTranId(String tranId){
        List<TranHistory> tranHistoryList = tranService.getTranHistoryListByTranId(tranId);
        return tranHistoryList;
    }

    //  改变阶段
    @RequestMapping("/changeState.do")
    @ResponseBody
    public Map<String,Object> changeState(Tran tran, HttpServletRequest request) throws TransactionException {
        String editBy = ((User)request.getSession().getAttribute("user")).getName();
        String editTime = DateTimeUtil.getSysTime();
        tran.setEditBy(editBy);
        tran.setEditTime(editTime);

        boolean flag = tranService.changeState(tran);

        Map<String,Object> map = new HashMap<>();
        map.put("success",flag);
        map.put("tran",tran);
        return map;
    }

    //  交易统计图
    @RequestMapping("/getCharts.do")
    @ResponseBody
    public Map<String,Object> getCharts(){
        Map<String,Object> map = tranService.getCharts();

        return map;
    }
}
