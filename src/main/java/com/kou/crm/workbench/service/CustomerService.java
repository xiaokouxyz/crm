package com.kou.crm.workbench.service;

import com.kou.crm.vo.PaginationVo;
import com.kou.crm.workbench.domain.Customer;

import java.util.List;

public interface CustomerService {
    PaginationVo<Customer> pageList(Customer customer, Integer skipCount, Integer pageSize);

    List<String> getCustomerName(String name);
}
