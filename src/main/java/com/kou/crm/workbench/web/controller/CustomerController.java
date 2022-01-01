package com.kou.crm.workbench.web.controller;

import com.kou.crm.vo.PaginationVo;
import com.kou.crm.workbench.dao.CustomerDao;
import com.kou.crm.workbench.domain.Customer;
import com.kou.crm.workbench.service.CustomerService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

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
}
