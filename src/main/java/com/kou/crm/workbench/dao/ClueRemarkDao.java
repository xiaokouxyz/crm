package com.kou.crm.workbench.dao;

import com.kou.crm.workbench.domain.ClueRemark;

import java.util.List;

public interface ClueRemarkDao {

    List<ClueRemark> getRemarkListByCid(String clueId);

    int deleteClueRemark(ClueRemark clueRemark);

    int saveClueRemark(ClueRemark clueRemark);

    int deleteRemark(String id);

    int updateRemark(ClueRemark clueRemark);

    Integer getCountByAids(String[] ids);

    Integer deleteByAids(String[] ids);
}
