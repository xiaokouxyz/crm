package com.kou.crm.workbench.dao;

import com.kou.crm.workbench.domain.ContactsRemark;

import java.util.List;

public interface ContactsRemarkDao {

    int saveContactsRemark(ContactsRemark contactsRemark);

    Integer getCountByConId(String id);

    Integer deleteByConId(String id);

    Integer getCountByConIds(String[] id);

    Integer deleteByConIds(String[] id);

    List<ContactsRemark> showContactsRemarkList(String id);

    Integer updateRemark(ContactsRemark contactsRemark);

    Integer deleteRemark(String id);

    Integer saveContactRemark(ContactsRemark contactsRemark);
}
