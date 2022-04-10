package com.kou.crm.workbench.service.impl;

import com.kou.crm.exception.ClueException;
import com.kou.crm.exception.ContactsException;
import com.kou.crm.exception.CustomerException;
import com.kou.crm.exception.TransactionException;
import com.kou.crm.settings.dao.UserDao;
import com.kou.crm.utils.DateTimeUtil;
import com.kou.crm.utils.UUIDUtil;
import com.kou.crm.vo.PaginationVo;
import com.kou.crm.workbench.dao.*;
import com.kou.crm.workbench.domain.*;
import com.kou.crm.workbench.service.ContactsService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Created by MiManchi
 * Date: 2022/1/11 22:14
 * Package: com.kou.crm.workbench.service.impl
 */
@Service
public class ContactsServiceImpl implements ContactsService {

    //  市场活动表
    @Autowired
    private ActivityDao activityDao;

    //  用户表
    @Autowired
    private UserDao userDao;

    //  交易
    @Autowired
    private TranDao tranDao;
    @Autowired
    private TranHistoryDao tranHistoryDao;

    @Autowired
    private ContactsDao contactsDao;
    @Autowired
    private CustomerDao customerDao;
    @Autowired
    private ContactsRemarkDao contactsRemarkDao;
    @Autowired
    private ContactsActivityRelationDao contactsActivityRelationDao;

    @Override
    public List<Contacts> getContactsListByNameAndNotByContactsId(String contactsName, String contactsId) {
        List<Contacts> list = contactsDao.getContactsListByNameAndNotByContactsId(contactsName,contactsId);
        return list;
    }

    @Override
    public PaginationVo<Contacts> pageList(Contacts contacts, Integer skipCount, Integer pageSize) {
        Integer total = contactsDao.getTotalByCondition(contacts);

        List<Contacts> contactsList = contactsDao.getContactsByCondition(contacts,skipCount,pageSize);
        PaginationVo<Contacts> paginationVo = new PaginationVo<>();
        paginationVo.setTotal(total);
        paginationVo.setDataList(contactsList);
        return paginationVo;
    }

    @Override
    public boolean saveContact(Contacts contacts, String customerName) throws ContactsException {

        Customer customer = customerDao.getCustomerByName(customerName);
        if (customer == null){
            //  如果customer为空，则创建一个用户
            customer = new Customer();
            customer.setId(UUIDUtil.getUUID());
            customer.setName(customerName);
            customer.setCreateBy(contacts.getCreateBy());
            customer.setCreateTime(DateTimeUtil.getSysTime());
            customer.setContactSummary(contacts.getContactSummary());
            customer.setNextContactTime(contacts.getNextContactTime());
            customer.setOwner(contacts.getOwner());
            //  添加客户
            Integer count1 = customerDao.saveCustomer(customer);
            if (count1 != 1)
                throw new ContactsException("添加客户失败！");
        }

        //通过以上对于客户的处理，不论是查询出来已有的客户，还是以前没有我们新增的客户，总之客户已经有了，客户的id就有了
        //将客户id封装到tran对象中
        contacts.setCustomerId(customer.getId());

        //  添加联系人
        Integer count2 = contactsDao.saveContact(contacts);
        if (count2 != 1)
            throw new ContactsException("添加联系人失败！");

        return true;
    }

    @Override
    public Contacts getContactById(String id) {
        Contacts contacts = contactsDao.getContactById(id);
        return contacts;
    }

    @Override
    public boolean updateContact(Contacts contacts, String customerName) throws ContactsException {

        Customer customer = customerDao.getCustomerByName(customerName);
        if (customer == null){
            //  如果customer为空，则创建一个用户
            customer = new Customer();
            customer.setId(UUIDUtil.getUUID());
            customer.setName(customerName);
            customer.setCreateBy(contacts.getEditBy());
            customer.setCreateTime(DateTimeUtil.getSysTime());
            customer.setContactSummary(contacts.getContactSummary());
            customer.setNextContactTime(contacts.getNextContactTime());
            customer.setOwner(contacts.getOwner());
            //  添加客户
            Integer count1 = customerDao.saveCustomer(customer);
            if (count1 != 1)
                throw new ContactsException("添加客户失败！");
        }

        //通过以上对于客户的处理，不论是查询出来已有的客户，还是以前没有我们新增的客户，总之客户已经有了，客户的id就有了
        //将客户id封装到tran对象中
        contacts.setCustomerId(customer.getId());

        //  添加联系人
        Integer count2 = contactsDao.updateContact(contacts);
        if (count2 != 1)
            throw new ContactsException("修改联系人失败！");

        return true;
    }

    @Override
    public boolean deleteContacts(String[] id) throws ContactsException {

        //  查询出需要删除的备注的数量
        Integer count1 = contactsRemarkDao.getCountByConIds(id);

        //  删除备注，返回受到影响的条数（实际删除的数量）
        Integer count2 = contactsRemarkDao.deleteByConIds(id);

        if (count1 != count2){
            throw new ContactsException("删除备注失败!");
        }

        //  查询出需要删除的关联活动的数量
        Integer count3 = contactsActivityRelationDao.getCountByConIds(id);

        //  删除备注，返回受到影响的条数（实际删除的数量）
        Integer count4 = contactsActivityRelationDao.deleteByConIds(id);

        if (count3 != count4){
            throw new ContactsException("删除市场活动关联失败!");
        }

        Integer count = contactsDao.deleteContacts(id);
        if (count != id.length)
            throw new ContactsException("删除失败！");
        return true;
    }

    @Override
    public Contacts detail(String id) {
        Contacts contacts = contactsDao.detail(id);
        return contacts;
    }

    @Override
    public List<ContactsRemark> showContactsRemarkList(String id) {
        List<ContactsRemark> list = contactsRemarkDao.showContactsRemarkList(id);
        return list;
    }

    @Override
    public boolean updateRemark(ContactsRemark contactsRemark) throws ContactsException {
        Integer count = contactsRemarkDao.updateRemark(contactsRemark);
        if (count != 1)
            throw new ContactsException("修改备注失败！");
        return true;
    }

    @Override
    public boolean deleteRemark(String id) throws ContactsException {
        Integer count = contactsRemarkDao.deleteRemark(id);
        if (count != 1)
            throw new ContactsException("删除备注失败！");
        return true;
    }

    @Override
    public boolean saveContactRemark(ContactsRemark contactsRemark) throws ContactsException {
        Integer count = contactsRemarkDao.saveContactRemark(contactsRemark);
        if (count != 1)
            throw new ContactsException("删除备注失败！");
        return true;
    }

    @Override
    public Map<String, Object> showTranAndActivityList(String id) {
        Map<String, Object> map = new HashMap<>();
        List<Tran> tranList = tranDao.getTranListByContactId(id);
        List<Activity> activityList = activityDao.getActivityByContactId(id);

        map.put("tranList",tranList);
        map.put("activityList",activityList);
        return map;
    }

    @Override
    public boolean deleteTran(String id) throws ContactsException {
        //  查询出需要删除的历史的数量
        Integer count1 = tranHistoryDao.getCountByTranId(id);

        //  删除历史，返回受到影响的条数（实际删除的数量）
        Integer count2 = tranHistoryDao.deleteByTranId(id);

        if (count1 != count2){
            throw new ContactsException("删除交易历史失败!");
        }

        Integer count = tranDao.deleteTran(id);

        if (count != 1)
            throw new ContactsException("删除交易失败");
        return true;
    }

    @Override
    public boolean unboundByTcarid(String tcarId) throws ContactsException {
        int count = contactsActivityRelationDao.unboundByTcarid(tcarId);
        if (count != 1){
            throw new ContactsException("解除关联失败！");
        }
        return true;
    }

    @Override
    public List<Activity> getActivityListByNameAndNotByContactsId(String activityName, String contactsId) {
        List<Activity> list = activityDao.getActivityListByNameAndNotByContactsId(activityName,contactsId);
        return list;
    }

    @Override
    public boolean boundActivity(String contactsId, String[] activityId) throws ContactsException {
        for (String activityIdItem : activityId) {
            ContactsActivityRelation contactsActivityRelation = new ContactsActivityRelation();
            contactsActivityRelation.setId(UUIDUtil.getUUID());
            contactsActivityRelation.setContactsId(contactsId);
            contactsActivityRelation.setActivityId(activityIdItem);

            Integer count = contactsActivityRelationDao.boundActivity(contactsActivityRelation);
            if (count != 1)
                throw new ContactsException("添加关联失败！");
        }
        return true;
    }
}
