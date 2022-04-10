package com.kou.crm.workbench.service.impl;

import com.kou.crm.exception.ClueException;
import com.kou.crm.exception.CustomerException;
import com.kou.crm.settings.dao.UserDao;
import com.kou.crm.settings.domain.User;
import com.kou.crm.vo.PaginationVo;
import com.kou.crm.workbench.dao.*;
import com.kou.crm.workbench.domain.*;
import com.kou.crm.workbench.service.CustomerService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import javax.crypto.interfaces.PBEKey;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class CustomerServiceImpl implements CustomerService {

    @Autowired
    private CustomerDao customerDao;
    @Autowired
    private UserDao userDao;
    @Autowired
    private CustomerRemarkDao customerRemarkDao;
    @Autowired
    private TranDao tranDao;
    @Autowired
    private ContactsDao contactsDao;
    @Autowired
    private TranHistoryDao tranHistoryDao;
    @Autowired
    private ContactsRemarkDao contactsRemarkDao;
    @Autowired
    private ContactsActivityRelationDao contactsActivityRelationDao;


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

    @Override
    public List<User> getUserList() {

        List<User> list = userDao.getUserList();
        return list;
    }

    @Override
    public boolean saveCustomer(Customer customer) throws CustomerException {

        int count = customerDao.saveCustomer(customer);
        if (count != 1)
            throw new CustomerException("保存失败");
        return true;
    }

    @Override
    public Customer getCustomerById(String id) {

        Customer customer = customerDao.getCustomerById(id);
        return customer;
    }

    @Override
    public boolean updateCustomer(Customer customer) throws CustomerException {

        int count = customerDao.updateCustomer(customer);
        if (count != 1)
            throw new CustomerException("更新失败");
        return true;
    }

    @Override
    public boolean deleteCustomer(String[] id) throws CustomerException {
        //  查询出需要删除的备注的数量
        Integer count1 = customerRemarkDao.getCountByAids(id);

        //  删除备注，返回受到影响的条数（实际删除的数量）
        Integer count2 = customerRemarkDao.deleteByAids(id);

        //  查询出需要删除的交易的数量
        Integer count3 = tranDao.getTranCountByAids(id);

        //  删除交易，返回受到影响的条数（实际删除的数量）
        Integer count4 = tranDao.deleteTranByAids(id);

        //  查询出需要删除的联系人的数量
        Integer count5 = contactsDao.getConCountByAids(id);

        //  删除交易，返回受到联系人的条数（实际删除的数量）
        Integer count6 = contactsDao.deleteConByAids(id);

        if (count1 != count2){
            throw new CustomerException("删除备注失败!");
        }
        if (count3 != count4){
            throw new CustomerException("删除交易失败!");
        }
        if (count5 != count6){
            throw new CustomerException("删除联系人失败!");
        }

        int count = customerDao.deleteCustomer(id);
        if (count != id.length)
            throw new CustomerException("亲亲，删除失败哦！");
        return true;
    }

    @Override
    public Customer getCustomer(String id) throws CustomerException {

        Customer customer = customerDao.getCustomer(id);
        if (customer == null){
            throw new CustomerException("查无此人！");
        }
        return customer;
    }

    @Override
    public List<CustomerRemark> showCustomerRemarkList(String id) {

        List<CustomerRemark> list = customerRemarkDao.showCustomerRemarkList(id);
        return list;
    }

    @Override
    public boolean deleteRemark(String id) throws CustomerException {

        int count = customerRemarkDao.deleteRemark(id);
        if (count != 1)
            throw new CustomerException("删除失败！");
        return true;
    }

    @Override
    public boolean saveCustomerRemark(CustomerRemark customerRemark) throws CustomerException {
        int count = customerRemarkDao.saveCustomerRemark(customerRemark);
        if (count != 1)
            throw new CustomerException("保存失败！");
        return true;
    }

    @Override
    public boolean updateRemark(CustomerRemark customerRemark) throws CustomerException {
        int count = customerRemarkDao.updateRemark(customerRemark);
        if (count != 1)
            throw new CustomerException("更新失败！");
        return true;
    }

    @Override
    public Map<String, Object> showTranAndContactList(String id) {
        Map<String, Object> map = new HashMap<>();
        List<Tran> tranList = tranDao.getTranList(id);
        List<Contacts> contactList = contactsDao.getContactList(id);

        map.put("tranList",tranList);
        map.put("contactList",contactList);
        return map;
    }

    @Override
    public boolean deleteCon(String id) throws CustomerException {

        //  查询出需要删除的联系人备注的数量
        Integer count1 = contactsRemarkDao.getCountByConId(id);

        //  删除联系人备注，返回受到影响的条数（实际删除的数量）
        Integer count2 = contactsRemarkDao.deleteByConId(id);

        //  查询出需要删除的联系人与活动关联数据的数量
        Integer count3 = contactsActivityRelationDao.getCountByConId(id);

        //  删除联系人与活动关联数据，返回受到影响的条数（实际删除的数量）
        Integer count4 = contactsActivityRelationDao.deleteByConId(id);

        if (count1 != count2){
            throw new CustomerException("删除交易历史失败!");
        }
        if (count3 != count4){
            throw new CustomerException("删除联系人与活动关联数据失败!");
        }

        Integer count = contactsDao.deleteCon(id);
        if (count != 1)
            throw new CustomerException("删除联系人失败");
        return true;
    }

    @Override
    public boolean deleteTran(String id) throws CustomerException {
        //  查询出需要删除的历史的数量
        Integer count1 = tranHistoryDao.getCountByTranId(id);

        //  删除历史，返回受到影响的条数（实际删除的数量）
        Integer count2 = tranHistoryDao.deleteByTranId(id);

        if (count1 != count2){
            throw new CustomerException("删除交易历史失败!");
        }

        Integer count = tranDao.deleteTran(id);

        if (count != 1)
            throw new CustomerException("删除交易失败");
        return true;
    }
}
