package com.kou.crm.workbench.service.impl;

import com.kou.crm.exception.ClueException;
import com.kou.crm.settings.dao.UserDao;
import com.kou.crm.settings.domain.User;
import com.kou.crm.utils.DateTimeUtil;
import com.kou.crm.utils.UUIDUtil;
import com.kou.crm.vo.PaginationVo;
import com.kou.crm.workbench.dao.*;
import com.kou.crm.workbench.domain.*;
import com.kou.crm.workbench.service.ClueService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class ClueServiceImpl implements ClueService {

    //  线索相关表
    @Autowired
    private ClueDao clueDao;
    @Autowired
    private ClueActivityRelationDao clueActivityRelationDao;
    @Autowired
    private ClueRemarkDao clueRemarkDao;

    //  用户表
    @Autowired
    private UserDao userDao;

    //  客户相关表
    @Autowired
    private CustomerDao customerDao;
    @Autowired
    private CustomerRemarkDao customerRemarkDao;

    //  联系人
    @Autowired
    private ContactsDao contactsDao;
    @Autowired
    private ContactsRemarkDao contactsRemarkDao;
    @Autowired
    private ContactsActivityRelationDao contactsActivityRelationDao;

    //  交易
    @Autowired
    private TranDao tranDao;
    @Autowired
    private TranHistoryDao tranHistoryDao;

    @Override
    public boolean saveClue(Clue clue) throws ClueException {
        int count = clueDao.saveClue(clue);
        if (count != 1)
            throw new ClueException("保存失败！");

        return true;
    }

    @Override
    public PaginationVo<Clue> pageList(Map<String, Object> map) {
        PaginationVo<Clue> cluePaginationVo = new PaginationVo<>();
        Integer total = clueDao.getTotalByCondition(map);
        List<Clue> dataList = clueDao.getDataListByCondition(map);

        cluePaginationVo.setTotal(total);
        cluePaginationVo.setDataList(dataList);
        return cluePaginationVo;
    }

    @Override
    public Clue detail(String id) {
        Clue clue = clueDao.detail(id);

        return clue;
    }

    @Override
    public boolean unboundByTcarid(String tcarId) throws ClueException {
        int count = clueActivityRelationDao.unboundByTcarid(tcarId);
        if (count != 1){
            throw new ClueException("解除关联失败！");
        }
        return true;
    }

    @Override
    public Map<String, Object> getUserListAndClue(String clueId) {
        //  拿到用户列表
        List<User> userList = userDao.getUserList();
        //  拿到单条线索信息
        Clue clue = clueDao.getClueById(clueId);

        Map<String, Object> map = new HashMap<>();
        map.put("userList",userList);
        map.put("clue",clue);
        return map;
    }

    @Override
    public boolean updateClue(Clue clue) throws ClueException {
        Integer count = clueDao.updateClue(clue);
        if (count != 1)
            throw new ClueException("保存失败！");
        return true;
    }

    @Override
    public boolean deleteClue(String[] ids) throws ClueException {
        Integer count = clueDao.deleteClue(ids);
        if (count != ids.length){
            throw new ClueException("删除失败！");
        }
        return true;
    }

    @Override
    public boolean boundActivity(String clueId, String[] activityId) throws ClueException {

        for (String activityIdItem : activityId) {
            ClueActivityRelation clueActivityRelation = new ClueActivityRelation();
            clueActivityRelation.setId(UUIDUtil.getUUID());
            clueActivityRelation.setClueId(clueId);
            clueActivityRelation.setActivityId(activityIdItem);

            Integer count = clueActivityRelationDao.boundActivity(clueActivityRelation);
            if (count != 1)
                throw new ClueException("添加关联失败！");
        }
        return true;
    }

    @Override
    public List<ClueRemark> getRemarkListByCid(String clueId) {
        List<ClueRemark> list = clueRemarkDao.getRemarkListByCid(clueId);
        return list;
    }

    //  线索转换
    @Override
    public boolean convert(String clueId, Tran tran, String createBy) throws ClueException {
        String createTime = DateTimeUtil.getSysTime();

        //  (1) 获取到线索id，通过线索id获取线索对象（线索对象当中封装了线索的信息）
        Clue clue = clueDao.getClueById(clueId);

        //  (2) 通过线索对象提取客户信息，当该客户不存在的时候，新建客户（根据公司的名称精确匹配，判断该客户是否存在！）
        String companyName = clue.getCompany();
        Customer customer = customerDao.getCustomerByName(companyName);
        if (customer == null){
            //  如果customer为空，说明以前没有这个客户，需要新建一个
            customer = new Customer();
            customer.setId(UUIDUtil.getUUID());
            customer.setAddress(clue.getAddress());
            customer.setWebsite(clue.getWebsite());
            customer.setPhone(clue.getPhone());
            customer.setOwner(clue.getOwner());
            customer.setNextContactTime(clue.getNextContactTime());
            customer.setName(companyName);
            customer.setDescription(clue.getDescription());
            customer.setCreateTime(createTime);
            customer.setCreateBy(createBy);
            customer.setContactSummary(clue.getContactSummary());
            //  添加客户（公司）
            int count1 = customerDao.saveCustomer(customer);
            if (count1 != 1)
                throw new ClueException("添加客户失败！");
        }

        //  (3) 通过线索对象提取联系人信息，保存联系人
        Contacts contacts = new Contacts();
        contacts.setId(UUIDUtil.getUUID());
        contacts.setAddress(clue.getAddress());
        contacts.setSource(clue.getSource());
        contacts.setOwner(clue.getOwner());
        contacts.setNextContactTime(clue.getNextContactTime());
        contacts.setMphone(clue.getMphone());
        contacts.setJob(clue.getJob());
        contacts.setFullname(clue.getFullname());
        contacts.setEmail(clue.getEmail());
        contacts.setDescription(clue.getDescription());
        contacts.setCustomerId(customer.getId());
        contacts.setCreateTime(createTime);
        contacts.setCreateBy(createBy);
        contacts.setContactSummary(clue.getContactSummary());
        contacts.setAppellation(clue.getAppellation());
        //  添加联系人
        int count2 = contactsDao.saveContact(contacts);
        if (count2 != 1)
            throw new ClueException("添加联系人失败！");

        //  (4) 线索备注转换到客户备注以及联系人备注
        //  查询出与该线索关联的备注信息列表
        List<ClueRemark> clueRemarkList = clueRemarkDao.getRemarkListByCid(clueId);
        //  取出每一条线索的备注
        for (ClueRemark clueRemark : clueRemarkList) {
            //  取出备注信息（主要转换到客户备注和联系人备注的就是这个备注信息）
            String noteContent = clueRemark.getNoteContent();

            //  创建客户备注对象，添加客户备注
            CustomerRemark customerRemark = new CustomerRemark();
            customerRemark.setId(UUIDUtil.getUUID());
            customerRemark.setCreateBy(createBy);
            customerRemark.setCreateTime(createTime);
            customerRemark.setCustomerId(customer.getId());
            customerRemark.setEditFlag("0");
            customerRemark.setNoteContent(noteContent);
            //  添加联系人备注
            int count3 = customerRemarkDao.saveCustomerRemark(customerRemark);
            if (count3 != 1)
                throw new ClueException("添加联系人备注失败！");

            //  创建客户备注对象，添加客户备注
            ContactsRemark contactsRemark = new ContactsRemark();
            contactsRemark.setId(UUIDUtil.getUUID());
            contactsRemark.setCreateBy(createBy);
            contactsRemark.setCreateTime(createTime);
            contactsRemark.setContactsId(contacts.getId());
            contactsRemark.setEditFlag("0");
            contactsRemark.setNoteContent(noteContent);
            //  添加联系人备注
            int count4 = contactsRemarkDao.saveContactsRemark(contactsRemark);
            if (count4 != 1)
                throw new ClueException("添加客户备注失败！");
        }


        //  (5) “线索和市场活动”的关系转换到“联系人和市场活动”的关系
        //  查询出与该条线索关联的市场活动，查询与市场活动的关联关系列表
        List<ClueActivityRelation> clueActivityRelationList = clueActivityRelationDao.getClueActivityRelationByClueId(clueId);
        //  遍历出每一条与市场活动关联的关联关系记录
        for (ClueActivityRelation clueActivityRelation : clueActivityRelationList) {
            //  从每一条遍历出来的记录中取出关联的市场活动id
            String activityId = clueActivityRelation.getActivityId();

            //  创建 联系人与市场活动的关联关系对象 让第三步生成的联系人与市场活动做关联
            ContactsActivityRelation contactsActivityRelation = new ContactsActivityRelation();
            contactsActivityRelation.setId(UUIDUtil.getUUID());
            contactsActivityRelation.setContactsId(contacts.getId());
            contactsActivityRelation.setActivityId(activityId);
            //  添加 联系人与市场活动的关联关系
            int count5 = contactsActivityRelationDao.saveContactsActivityRelation(contactsActivityRelation);
            if (count5 != 1)
                throw new ClueException("添加联系人与市场活动的关联关系失败！");
        }


        //  (6) 如果有创建交易需求，创建一条交易
        if (tran != null){
            /*
                tran对象在controller里面已经封装好的信息如下
                    id，money，name，expectedDate，stage，activityId，createBy，createTime

                接下来可以通过第一步生成的 clue 对象，取出一些信息，继续完善对 tran 对象的封装
             */
            tran.setSource(clue.getSource());
            tran.setOwner(clue.getOwner());
            tran.setNextContactTime(clue.getNextContactTime());
            tran.setDescription(clue.getDescription());
            tran.setCustomerId(customer.getId());
            tran.setContactSummary(clue.getContactSummary());
            tran.setContactsId(contacts.getId());
            //  添加交易
            int count6 = tranDao.saveTran(tran);
            if (count6 != 1)
                throw new ClueException("添加交易失败！");

            //  (7) 如果创建了交易，则创建一条该交易下的交易历史
            TranHistory tranHistory = new TranHistory();
            tranHistory.setId(UUIDUtil.getUUID());
            tranHistory.setCreateBy(createBy);
            tranHistory.setCreateTime(createTime);
            tranHistory.setExpectedDate(tran.getExpectedDate());
            tranHistory.setMoney(tran.getMoney());
            tranHistory.setStage(tran.getStage());
            tranHistory.setTranId(tran.getId());
            //  添加交易历史
            int count7 = tranHistoryDao.saveTranHistory(tranHistory);
            if (count7 != 1)
                throw new ClueException("添加交易历史失败！");
        }

        //  (8) 删除线索备注
        for (ClueRemark clueRemark : clueRemarkList) {
            int count8 =  clueRemarkDao.deleteClueRemark(clueRemark);
            if (count8 != 1)
                throw new ClueException("删除线索备注失败！");
        }

        //  (9) 删除线索和市场活动的关系
        for (ClueActivityRelation clueActivityRelation : clueActivityRelationList) {
            int count9 =  clueActivityRelationDao.deleteClueActivityRelation(clueActivityRelation);
            if (count9 != 1)
                throw new ClueException("删除线索和市场活动的关系失败！");
        }

        //  (10) 删除线索
        int count10 = clueDao.deleteOneClue(clueId);
        if (count10 != 1)
            throw new ClueException("删除线索失败！");

        return true;
    }

}
