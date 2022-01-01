package com.kou.crm.workbench.service.impl;

import com.kou.crm.exception.TransactionException;
import com.kou.crm.utils.DateTimeUtil;
import com.kou.crm.utils.UUIDUtil;
import com.kou.crm.vo.PaginationVo;
import com.kou.crm.workbench.dao.CustomerDao;
import com.kou.crm.workbench.dao.TranDao;
import com.kou.crm.workbench.dao.TranHistoryDao;
import com.kou.crm.workbench.domain.Customer;
import com.kou.crm.workbench.domain.Tran;
import com.kou.crm.workbench.domain.TranHistory;
import com.kou.crm.workbench.service.TranService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class TranServiceImpl implements TranService {
    @Autowired
    private TranDao tranDao;
    @Autowired
    private TranHistoryDao tranHistoryDao;
    @Autowired
    private CustomerDao customerDao;

    @Override
    public boolean saveTransaction(Tran tran, String customerName) throws TransactionException {
        /*
            交易添加业务：

                在做添加之前，参数t里面就少了一项信息，就是客户的主键，customerId
                先处理客户相关的需求

                (1)判断customerName， 根据客户名称在客户表进行精确查询
                    如果有这个客户，则取出这个客户的id,封装到tran对象中
                    如果没有这个客户，则再客户表新建一条客户信息， 然后将新建的客户的id取出，封装到tran对象中
                (2)经过以上操作后，t对象中的信息就全了，需要执行添加交易的操作
                (3)添加交易完毕后，需要创建一条交易历史

         */
        Customer customer = customerDao.getCustomerByName(customerName);
        if (customer == null){
            //  如果customer为空，则创建一个用户
            customer = new Customer();
            customer.setId(UUIDUtil.getUUID());
            customer.setName(customerName);
            customer.setCreateBy(tran.getCreateBy());
            customer.setCreateTime(DateTimeUtil.getSysTime());
            customer.setContactSummary(tran.getContactSummary());
            customer.setNextContactTime(tran.getNextContactTime());
            customer.setOwner(tran.getOwner());
            //  添加客户
            Integer count1 = customerDao.saveCustomer(customer);
            if (count1 != 1)
                throw new TransactionException("添加客户失败！");
        }

        //通过以上对于客户的处理，不论是查询出来已有的客户，还是以前没有我们新增的客户，总之客户已经有了，客户的id就有了
        //将客户id封装到tran对象中
        tran.setCustomerId(customer.getId());

        //  添加交易
        Integer count2 = tranDao.saveTran(tran);
        if (count2 != 1)
            throw new TransactionException("添加交易失败！");

        //  添加交易历史
        TranHistory tranHistory = new TranHistory();
        tranHistory.setId(UUIDUtil.getUUID());
        tranHistory.setTranId(tran.getId());
        tranHistory.setStage(tran.getStage());
        tranHistory.setCreateBy(tran.getCreateBy());
        tranHistory.setCreateTime(DateTimeUtil.getSysTime());
        tranHistory.setMoney(tran.getMoney());
        tranHistory.setExpectedDate(tran.getExpectedDate());
        //  添加交易历史
        Integer count3 = tranHistoryDao.saveTranHistory(tranHistory);
        if (count3 != 1)
            throw new TransactionException("添加交易历史失败！");

        return true;
    }

    @Override
    public PaginationVo<Tran> pageList(Tran tran, Integer skipCount, Integer pageSize) {
        PaginationVo<Tran> paginationVo = new PaginationVo<>();

        Integer total = tranDao.getTotalByCondition(tran, skipCount, pageSize);

        List<Tran> dataList = tranDao.getDataListByCondition(tran, skipCount, pageSize);
        paginationVo.setTotal(total);
        paginationVo.setDataList(dataList);

        return paginationVo;
    }

    @Override
    public Tran detail(String tranId) {
        Tran tran = tranDao.detail(tranId);

        return tran;
    }

    @Override
    public List<TranHistory> getTranHistoryListByTranId(String tranId) {
        List<TranHistory> tranHistoryList = tranHistoryDao.getTranHistoryListByTranId(tranId);

        return tranHistoryList;
    }

    @Override
    public boolean changeState(Tran tran) throws TransactionException {
        //  改变交易阶段
        Integer count1 = tranDao.changeState(tran);
        if (count1 != 1)
            throw new TransactionException("改变交易状态失败！");

        //  交易阶段改变后，生成一段交易历史
        TranHistory tranHistory = new TranHistory();
        tranHistory.setId(UUIDUtil.getUUID());
        tranHistory.setCreateBy(tran.getEditBy());
        tranHistory.setCreateTime(DateTimeUtil.getSysTime());
        tranHistory.setExpectedDate(tran.getExpectedDate());
        tranHistory.setMoney(tran.getMoney());
        tranHistory.setTranId(tran.getId());
        tranHistory.setStage(tran.getStage());

        Integer count2 = tranHistoryDao.saveTranHistory(tranHistory);
        if (count2 != 1)
            throw new TransactionException("生成交易历史失败！");
        return true;
    }

    @Override
    public Map<String, Object> getCharts() {
        //  取得total
        Integer total = tranDao.getTotal();

        //  取得dataList
        List<Map<String,Object>> dataList = tranDao.getCharts();

        //  将total和list装进map
        Map<String,Object> map = new HashMap<>();
        map.put("total",total);
        map.put("dataList",dataList);

        //  返回map
        return map;
    }
}
