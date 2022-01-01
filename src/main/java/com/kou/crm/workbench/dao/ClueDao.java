package com.kou.crm.workbench.dao;

import com.kou.crm.workbench.domain.Clue;

import java.util.List;
import java.util.Map;

public interface ClueDao {

    int saveClue(Clue clue);

    Integer getTotalByCondition(Map<String, Object> map);

    List<Clue> getDataListByCondition(Map<String, Object> map);

    Clue detail(String id);

    Clue getClueById(String clueId);

    Integer updateClue(Clue clue);

    Integer deleteClue(String[] ids);

    int deleteOneClue(String clueId);
}
