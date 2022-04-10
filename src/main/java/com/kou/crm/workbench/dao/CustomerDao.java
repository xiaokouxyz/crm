package com.kou.crm.workbench.dao;

import com.kou.crm.settings.domain.User;
import com.kou.crm.workbench.domain.Customer;
import org.apache.ibatis.annotations.Param;

import java.util.List;

public interface CustomerDao {

    Customer getCustomerByName(String companyName);

    int saveCustomer(Customer customer);

    Integer getTotalByCondition(@Param("customer") Customer customer,@Param("skipCount") Integer pageNo,@Param("pageSize") Integer pageSize);

    List<Customer> getDataListByCondition(@Param("customer") Customer customer,@Param("skipCount") Integer skipCount,@Param("pageSize") Integer pageSize);

    List<String> getCustomerName(String name);

    Customer getCustomerById(String id);

    int updateCustomer(Customer customer);

    int deleteCustomer(String[] id);

    Customer getCustomer(String id);
}
