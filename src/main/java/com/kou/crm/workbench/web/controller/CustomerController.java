package com.kou.crm.workbench.web.controller;

import com.kou.crm.exception.CustomerException;
import com.kou.crm.settings.domain.User;
import com.kou.crm.utils.DateTimeUtil;
import com.kou.crm.utils.UUIDUtil;
import com.kou.crm.vo.PaginationVo;
import com.kou.crm.workbench.dao.CustomerDao;
import com.kou.crm.workbench.domain.Contacts;
import com.kou.crm.workbench.domain.Customer;
import com.kou.crm.workbench.domain.CustomerRemark;
import com.kou.crm.workbench.domain.Tran;
import com.kou.crm.workbench.service.CustomerService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("workbench/customer")
public class CustomerController {
    @Autowired
    private CustomerService customerService;

    @RequestMapping("/pageList.do")
    @ResponseBody
    public PaginationVo<Customer> pageList(Customer customer,Integer pageNo,Integer pageSize){
        //  掠过的线索条数
        Integer skipCount = (pageNo - 1) * pageSize;

        PaginationVo<Customer> paginationVo = customerService.pageList(customer,skipCount,pageSize);

        return paginationVo;
    }

    @RequestMapping("/getUserList.do")
    @ResponseBody
    public List<User> getUserList(){

        List<User> list = customerService.getUserList();

        return list;
    }

    @RequestMapping("/saveCustomer.do")
    @ResponseBody
    public Map<String,Object> saveCustomer(Customer customer) throws CustomerException {

        Map<String,Object> map = new HashMap<>();
        String id = UUIDUtil.getUUID();
        String createTime = DateTimeUtil.getSysTime();
        customer.setId(id);
        customer.setCreateTime(createTime);

        boolean success = customerService.saveCustomer(customer);
        map.put("success",success);
        return map;
    }

    @RequestMapping("/getCustomer.do")
    @ResponseBody
    public Map<String,Object> getCustomer(String id){

        Map<String,Object> map = new HashMap<>();
        Customer customer = customerService.getCustomerById(id);
        List<User> list = customerService.getUserList();

        map.put("userList",list);
        map.put("customer",customer);
        return map;
    }

    @RequestMapping("/updateCustomer.do")
    @ResponseBody
    public Map<String,Object> updateCustomer(Customer customer) throws CustomerException {

        String editTime = DateTimeUtil.getSysTime();
        customer.setEditTime(editTime);

        boolean success = customerService.updateCustomer(customer);
        Map<String,Object> map = new HashMap<>();
        map.put("success",success);
        return map;
    }

    @RequestMapping("/deleteCustomer.do")
    @ResponseBody
    public Map<String,Object> deleteCustomer(String[] id) throws CustomerException {

        Map<String,Object> map = new HashMap<>();
        boolean success = customerService.deleteCustomer(id);
        map.put("success",success);
        return map;
    }

    @RequestMapping("/detail.do")
    public String detail(Model model,String id) throws CustomerException {

        Customer customer = customerService.getCustomer(id);
        model.addAttribute("customer",customer);
        return "detail.jsp";
    }

    @RequestMapping("/showCustomerRemarkList.do")
    @ResponseBody
    public List<CustomerRemark> showCustomerRemarkList(String id){

        List<CustomerRemark> list = customerService.showCustomerRemarkList(id);
        return list;
    }

    @RequestMapping("/deleteRemark.do")
    @ResponseBody
    public Map<String,Object> deleteRemark(String id) throws CustomerException {

        Map<String,Object> map = new HashMap<>();
        boolean success = customerService.deleteRemark(id);
        map.put("success",success);
        return map;
    }

    @RequestMapping("/saveCustomerRemark.do")
    @ResponseBody
    public Map<String,Object> saveCustomerRemark(CustomerRemark customerRemark) throws CustomerException {

        Map<String,Object> map = new HashMap<>();
        String id = UUIDUtil.getUUID();
        String createTime = DateTimeUtil.getSysTime();

        customerRemark.setId(id);
        customerRemark.setCreateTime(createTime);

        boolean success = customerService.saveCustomerRemark(customerRemark);
        map.put("success",success);
        return map;
    }

    @RequestMapping("/updateRemark.do")
    @ResponseBody
    public Map<String,Object> updateRemark(CustomerRemark customerRemark) throws CustomerException{

        Map<String,Object> map = new HashMap<>();
        String editTime = DateTimeUtil.getSysTime();
        customerRemark.setEditTime(editTime);

        boolean success = customerService.updateRemark(customerRemark);

        map.put("customerRemark",customerRemark);
        map.put("success",success);
        return map;
    }

    @RequestMapping("/showTranAndContactList.do")
    @ResponseBody
    public Map<String,Object> showTranAndContactList(String id){

        Map<String,Object> map = customerService.showTranAndContactList(id);

        return map;
    }

    @RequestMapping("/deleteCon.do")
    @ResponseBody
    public Map<String,Object> deleteCon(String id) throws CustomerException {

        Map<String,Object> map = new HashMap<>();
        boolean success = customerService.deleteCon(id);

        map.put("success",success);
        return map;
    }

    @RequestMapping("/deleteTran.do")
    @ResponseBody
    public Map<String,Object> deleteTran(String id) throws CustomerException {

        Map<String,Object> map = new HashMap<>();
        boolean success = customerService.deleteTran(id);

        map.put("success",success);
        return map;
    }
}
