package com.kou.crm.settings.service.impl;

import com.kou.crm.exception.LoginException;
import com.kou.crm.settings.dao.UserDao;
import com.kou.crm.settings.domain.User;
import com.kou.crm.settings.service.UserService;
import com.kou.crm.utils.DateTimeUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class UserServiceImpl implements UserService {

    @Autowired
    private UserDao userDao;

    @Override
    public User Login(String loginAct, String loginPwd, String ip) throws LoginException {
        Map<String,String> map = new HashMap<>();
        map.put("loginAct",loginAct);
        map.put("loginPwd",loginPwd);

        User user = userDao.Login(map);

        if (user == null){
            throw new LoginException("账号密码错误");
        }
        //  如果程序能往下执行，说明账号密码正确
        //  需要验证其他信息

        //  验证失效时间
        String expireTime = user.getExpireTime();
        String currentTime = DateTimeUtil.getSysTime();
        if (expireTime.compareTo(currentTime) < 0){
            throw new LoginException("账号已失效");
        }

        //  判断锁定状态
        if ("0".equals(user.getLockState())){
            throw new LoginException("账号已锁定");
        }

        //  判断IP地址
        String allowIps = user.getAllowIps();
        if ( !allowIps.contains(ip)){
            throw new LoginException("IP地址受限");
        }
        return user;
    }

    @Override
    public List<User> getUserList() {
        List<User> userList =  userDao.getUserList();

        return userList;
    }

}
