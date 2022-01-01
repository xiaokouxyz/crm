package com.kou.crm.settings.service;

import com.kou.crm.exception.LoginException;
import com.kou.crm.settings.domain.User;

import java.util.List;

public interface UserService {

    User Login(String loginAct, String loginPwd, String ip) throws LoginException;

    List<User> getUserList();

}
