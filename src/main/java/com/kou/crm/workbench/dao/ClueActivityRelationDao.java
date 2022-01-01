package com.kou.crm.workbench.dao;

import com.kou.crm.workbench.domain.ClueActivityRelation;

import java.util.List;

public interface ClueActivityRelationDao {

    int unboundByTcarid(String tcarId);

    Integer boundActivity(ClueActivityRelation clueActivityRelation);

    List<ClueActivityRelation> getClueActivityRelationByClueId(String clueId);

    int deleteClueActivityRelation(ClueActivityRelation clueActivityRelation);
}
