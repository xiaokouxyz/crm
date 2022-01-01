package com.kou.crm.settings.dao;

import com.kou.crm.settings.domain.User;

import java.util.List;
import java.util.Map;

public interface UserDao {

    User Login(Map<String, String> map);

    List<User> getUserList();
}
