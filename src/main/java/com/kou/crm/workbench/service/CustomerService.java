package com.kou.crm.workbench.service;

import com.kou.crm.exception.CustomerException;
import com.kou.crm.settings.domain.User;
import com.kou.crm.vo.PaginationVo;
import com.kou.crm.workbench.domain.Customer;
import com.kou.crm.workbench.domain.CustomerRemark;
import com.kou.crm.workbench.domain.Tran;

import java.util.List;
import java.util.Map;

public interface CustomerService {
    PaginationVo<Customer> pageList(Customer customer, Integer skipCount, Integer pageSize);

    List<String> getCustomerName(String name);

    List<User> getUserList();

    boolean saveCustomer(Customer customer) throws CustomerException;

    Customer getCustomerById(String id);

    boolean updateCustomer(Customer customer) throws CustomerException;

    boolean deleteCustomer(String[] id) throws CustomerException;

    Customer getCustomer(String id) throws CustomerException;

    List<CustomerRemark> showCustomerRemarkList(String id);

    boolean deleteRemark(String id) throws CustomerException;

    boolean saveCustomerRemark(CustomerRemark customerRemark) throws CustomerException;

    boolean updateRemark(CustomerRemark customerRemark) throws CustomerException;

    Map<String, Object> showTranAndContactList(String id);

    boolean deleteCon(String id) throws CustomerException;

    boolean deleteTran(String id) throws CustomerException;
}
