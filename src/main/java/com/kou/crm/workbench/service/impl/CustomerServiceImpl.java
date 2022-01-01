package com.kou.crm.workbench.service.impl;

import com.kou.crm.vo.PaginationVo;
import com.kou.crm.workbench.dao.CustomerDao;
import com.kou.crm.workbench.domain.Customer;
import com.kou.crm.workbench.service.CustomerService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class CustomerServiceImpl implements CustomerService {

    @Autowired
    private CustomerDao customerDao;


    @Override
    public PaginationVo<Customer> pageList(Customer customer, Integer skipCount, Integer pageSize) {
        PaginationVo<Customer> paginationVo = new PaginationVo<>();

        Integer total = customerDao.getTotalByCondition(customer,skipCount,pageSize);
        List<Customer> dataList = customerDao.getDataListByCondition(customer,skipCount,pageSize);

        paginationVo.setTotal(total);
        paginationVo.setDataList(dataList);

        return paginationVo;
    }

    @Override
    public List<String> getCustomerName(String name) {
        List<String> list = customerDao.getCustomerName(name);
        return list;
    }
}
