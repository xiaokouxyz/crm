package com.kou.crm.workbench.dao;

import com.kou.crm.workbench.domain.CustomerRemark;

import java.util.List;

public interface CustomerRemarkDao {

    int saveCustomerRemark(CustomerRemark customerRemark);

    List<CustomerRemark> showCustomerRemarkList(String id);

    int deleteRemark(String id);

    int updateRemark(CustomerRemark customerRemark);

    Integer getCountByAids(String[] id);

    Integer deleteByAids(String[] id);
}
