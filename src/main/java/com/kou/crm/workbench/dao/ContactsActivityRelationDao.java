package com.kou.crm.workbench.dao;

import com.kou.crm.workbench.domain.ContactsActivityRelation;

public interface ContactsActivityRelationDao {

    int saveContactsActivityRelation(ContactsActivityRelation contactsActivityRelation);

    Integer getCountByConId(String id);

    Integer deleteByConId(String id);

    Integer getCountByConIds(String[] id);

    Integer deleteByConIds(String[] id);

    int unboundByTcarid(String tcarId);

    Integer boundActivity(ContactsActivityRelation contactsActivityRelation);
}
