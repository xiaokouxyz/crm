package com.kou.crm.workbench.service;

import com.kou.crm.exception.TransactionException;
import com.kou.crm.vo.PaginationVo;
import com.kou.crm.workbench.domain.Tran;
import com.kou.crm.workbench.domain.TranHistory;

import java.util.List;
import java.util.Map;

public interface TranService {
    boolean saveTransaction(Tran tran, String customerName) throws TransactionException;

    PaginationVo<Tran> pageList(Tran tran,Integer skipCount,Integer pageSize);

    Tran detail(String tranId);

    List<TranHistory> getTranHistoryListByTranId(String tranId);

    boolean changeState(Tran tran) throws TransactionException;

    Map<String,Object> getCharts();
}
