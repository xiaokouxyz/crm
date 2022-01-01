package com.kou.crm.workbench.service;

import com.kou.crm.exception.ClueException;
import com.kou.crm.vo.PaginationVo;
import com.kou.crm.workbench.domain.Clue;
import com.kou.crm.workbench.domain.ClueRemark;
import com.kou.crm.workbench.domain.Tran;

import java.util.List;
import java.util.Map;

public interface ClueService {
    boolean saveClue(Clue clue) throws ClueException;

    PaginationVo<Clue> pageList(Map<String, Object> map);

    Clue detail(String id);

    boolean unboundByTcarid(String tcarId) throws ClueException;

    Map<String, Object> getUserListAndClue(String clueId);

    boolean updateClue(Clue clue) throws ClueException;

    boolean deleteClue(String[] ids) throws ClueException;

    boolean boundActivity(String clueId, String[] activityId) throws ClueException;

    List<ClueRemark> getRemarkListByCid(String clueId);

    boolean convert(String clueId, Tran tran, String createBy) throws ClueException;
}
