package com.kou.crm.workbench.dao;

import com.kou.crm.workbench.domain.TranHistory;

import java.util.List;

public interface TranHistoryDao {

    int saveTranHistory(TranHistory tranHistory);

    List<TranHistory> getTranHistoryListByTranId(String tranId);
}
