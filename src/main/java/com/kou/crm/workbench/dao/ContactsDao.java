package com.kou.crm.workbench.dao;

import com.kou.crm.exception.ContactsException;
import com.kou.crm.workbench.domain.Contacts;
import org.apache.ibatis.annotations.Param;

import java.util.List;

public interface ContactsDao {

    int saveContact(Contacts contacts);

    List<Contacts> getContactList(String id);

    Integer getConCountByAids(String[] id);

    Integer deleteConByAids(String[] id);

    Integer deleteCon(String id);

    List<Contacts> getContactsListByNameAndNotByContactsId(@Param("contactsName") String contactsName,@Param("contactsId") String contactsId);

    Integer getTotalByCondition(Contacts contacts);

    List<Contacts> getContactsByCondition(@Param("contacts") Contacts contacts,@Param("skipCount") Integer skipCount,@Param("pageSize") Integer pageSize);

    Contacts getContactById(String id);

    Integer updateContact(Contacts contacts);

    Integer deleteContacts(String[] id) throws ContactsException;

    Contacts detail(String id);
}
