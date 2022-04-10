package com.kou.crm.workbench.dao;

import com.kou.crm.workbench.domain.Tran;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

public interface TranDao {

    int saveTran(Tran tran);

    Integer getTotalByCondition(@Param("tran")Tran tran,@Param("skipCount") Integer skipCount,@Param("pageSize") Integer pageSize);

    List<Tran> getDataListByCondition(@Param("tran")Tran tran,@Param("skipCount") Integer skipCount,@Param("pageSize") Integer pageSize);

    Tran detail(String tranId);

    Integer changeState(Tran tran);

    Integer getTotal();

    List<Map<String, Object>> getCharts();

    List<Tran> getTranList(String id);

    Integer getTranCountByAids(String[] id);

    Integer deleteTranByAids(String[] id);

    Integer deleteTran(String id);

    Integer updateTran(Tran tran);

    Map<String, String> getSomeIds(String tranId);

    Integer getTranCountByTranIds(String[] id);

    Integer deleteTranByTranIds(String[] id);

    List<Tran> getTranListByContactId(String id);
}
