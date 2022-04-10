package com.kou.crm.workbench.service;

import com.kou.crm.exception.ContactsException;
import com.kou.crm.vo.PaginationVo;
import com.kou.crm.workbench.domain.Activity;
import com.kou.crm.workbench.domain.Contacts;
import com.kou.crm.workbench.domain.ContactsRemark;

import java.util.List;
import java.util.Map;

public interface ContactsService {

    List<Contacts> getContactsListByNameAndNotByContactsId(String contactsName, String contactsId);

    PaginationVo<Contacts> pageList(Contacts contacts, Integer skipCount, Integer pageSize);

    boolean saveContact(Contacts contacts, String customerName) throws ContactsException;

    Contacts getContactById(String id);

    boolean updateContact(Contacts contacts, String customerName) throws ContactsException;

    boolean deleteContacts(String[] id) throws ContactsException;

    Contacts detail(String id);

    List<ContactsRemark> showContactsRemarkList(String id);

    boolean updateRemark(ContactsRemark contactsRemark) throws ContactsException;

    boolean deleteRemark(String id) throws ContactsException;

    boolean saveContactRemark(ContactsRemark contactsRemark) throws ContactsException;

    Map<String, Object> showTranAndActivityList(String id);

    boolean deleteTran(String id) throws ContactsException;

    boolean unboundByTcarid(String tcarId) throws ContactsException;

    List<Activity> getActivityListByNameAndNotByContactsId(String activityName, String contactsId);

    boolean boundActivity(String contactsId, String[] activityId) throws ContactsException;
}
