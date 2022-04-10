package com.kou.crm.workbench.web.controller;

import com.kou.crm.exception.ClueException;
import com.kou.crm.exception.ContactsException;
import com.kou.crm.exception.CustomerException;
import com.kou.crm.settings.domain.User;
import com.kou.crm.settings.service.UserService;
import com.kou.crm.utils.DateTimeUtil;
import com.kou.crm.utils.UUIDUtil;
import com.kou.crm.vo.PaginationVo;
import com.kou.crm.workbench.domain.Activity;
import com.kou.crm.workbench.domain.Contacts;
import com.kou.crm.workbench.domain.ContactsRemark;
import com.kou.crm.workbench.domain.Tran;
import com.kou.crm.workbench.service.ContactsService;
import com.kou.crm.workbench.service.CustomerService;
import com.kou.crm.workbench.service.TranService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.crypto.interfaces.PBEKey;
import javax.xml.ws.RequestWrapper;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Created by MiManchi
 * Date: 2022/1/11 22:12
 * Package: com.kou.crm.workbench.web.controller
 */
@Controller
@RequestMapping("workbench/contacts")
public class ContactsController {
    @Autowired
    private TranService tranService;
    @Autowired
    private UserService userService;
    @Autowired
    private CustomerService customerService;
    @Autowired
    private ContactsService contactsService;


    @RequestMapping("/getContactsListByNameAndNotByContactsId.do")
    @ResponseBody
    public List<Contacts> getContactsListByNameAndNotByContactsId(String contactsName,String contactsId){

        List<Contacts> list = contactsService.getContactsListByNameAndNotByContactsId(contactsName,contactsId);
        return list;
    }

    @RequestMapping("/getUserList.do")
    @ResponseBody
    public List<User> getUserList(String id){
        List<User> userList = userService.getUserList();
        return userList;
    }

    @RequestMapping("/getUserListAndContact.do")
    @ResponseBody
    public Map<String,Object> getUserListAndContact(String id){
        Map<String,Object> map = new HashMap<>();
        Contacts contacts = contactsService.getContactById(id);
        List<User> userList = userService.getUserList();

        map.put("contact",contacts);
        map.put("userList",userList);
        return map;
    }

    @RequestMapping("/pageList.do")
    @ResponseBody
    public PaginationVo<Contacts> pageList(Contacts contacts,Integer pageNo,Integer pageSize){

        Integer skipCount = (pageNo - 1) * pageSize;
        PaginationVo<Contacts> paginationVo =  contactsService.pageList(contacts,skipCount,pageSize);
        return paginationVo;
    }

    @RequestMapping("/saveContact.do")
    @ResponseBody
    public Map<String,Object> saveContact(Contacts contacts,String customerName) throws ContactsException {
        String id = UUIDUtil.getUUID();
        String createTime = DateTimeUtil.getSysTime();
        contacts.setId(id);
        contacts.setCreateTime(createTime);

        boolean success = contactsService.saveContact(contacts,customerName);
        Map<String,Object> map = new HashMap<>();
        map.put("success",success);
        return map;
    }

    @RequestMapping("/updateContact.do")
    @ResponseBody
    public Map<String,Object> updateContact(Contacts contacts,String customerName) throws ContactsException {

        String editTime = DateTimeUtil.getSysTime();
        contacts.setCreateTime(editTime);

        boolean success = contactsService.updateContact(contacts,customerName);
        Map<String,Object> map = new HashMap<>();
        map.put("success",success);
        return map;
    }

    @RequestMapping("/deleteContacts.do")
    @ResponseBody
    public Map<String,Object> deleteContacts(String[] id) throws ContactsException {
        Map<String,Object> map = new HashMap<>();
        boolean success = contactsService.deleteContacts(id);
        map.put("success",success);
        return map;
    }

    @RequestMapping("/detail.do")
    public String detail(Model model,String id){
        Contacts contacts = contactsService.detail(id);
        model.addAttribute("contacts",contacts);
        return "detail.jsp";
    }

    @RequestMapping("/showContactsRemarkList.do")
    @ResponseBody
    public List<ContactsRemark> showContactsRemarkList(String id){

        List<ContactsRemark> list = contactsService.showContactsRemarkList(id);
        return list;
    }

    @RequestMapping("/updateRemark.do")
    @ResponseBody
    public Map<String,Object> updateRemark(ContactsRemark contactsRemark) throws ContactsException {
        Map<String,Object> map = new HashMap<>();
        String editTime = DateTimeUtil.getSysTime();
        contactsRemark.setEditTime(editTime);

        boolean success = contactsService.updateRemark(contactsRemark);

        map.put("contactsRemark",contactsRemark);
        map.put("success",success);
        return map;
    }

    @RequestMapping("/deleteRemark.do")
    @ResponseBody
    public Map<String,Object> deleteRemark(String id) throws ContactsException {
        Map<String,Object> map = new HashMap<>();
        boolean success = contactsService.deleteRemark(id);
        map.put("success",success);
        return map;
    }

    @RequestMapping("/saveContactRemark.do")
    @ResponseBody
    public Map<String,Object> saveContactRemark(ContactsRemark contactsRemark) throws ContactsException{
        Map<String,Object> map = new HashMap<>();
        String id = UUIDUtil.getUUID();
        String createTime = DateTimeUtil.getSysTime();

        contactsRemark.setId(id);
        contactsRemark.setCreateTime(createTime);

        boolean success = contactsService.saveContactRemark(contactsRemark);
        map.put("success",success);
        return map;
    }

    @RequestMapping("/showTranAndActivityList.do")
    @ResponseBody
    public Map<String,Object> showTranAndActivityList(String id){
        Map<String,Object> map = contactsService.showTranAndActivityList(id);

        return map;
    }

    @RequestMapping("/deleteTran.do")
    @ResponseBody
    public Map<String,Object> deleteTran(String id) throws CustomerException, ContactsException {

        Map<String,Object> map = new HashMap<>();
        boolean success = contactsService.deleteTran(id);

        map.put("success",success);
        return map;
    }

    //  通过线索和市场活动关系表的id解除关联
    @RequestMapping("/unboundByTcarId.do")
    @ResponseBody
    public Map<String,Object> unboundByTcarid(String tcarId) throws ContactsException {
        Map<String,Object> map = new HashMap<>();

        boolean success = contactsService.unboundByTcarid(tcarId);
        map.put("success",success);
        return map;
    }


    //  通过活动名字和未关联的线索id获取活动列表
    @RequestMapping("/getActivityListByNameAndNotByClueId.do")
    @ResponseBody
    public List<Activity> getActivityListByNameAndNotByClueId(String activityName,String contactsId){

        List<Activity> list = contactsService.getActivityListByNameAndNotByContactsId(activityName,contactsId);
        return list;
    }

    //  执行关联市场活动
    @RequestMapping("/boundActivity.do")
    @ResponseBody
    public Map<String,Object> boundActivity(String contactsId,String[] activityId) throws ClueException, ContactsException {
        Map<String,Object> map = new HashMap<>();

        boolean success = contactsService.boundActivity(contactsId,activityId);
        map.put("success",success);
        return map;
    }
}
