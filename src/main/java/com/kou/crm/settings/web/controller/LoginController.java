package com.kou.crm.settings.web.controller;

import com.kou.crm.exception.MyException;
import com.kou.crm.settings.domain.User;
import com.kou.crm.settings.service.UserService;
import com.kou.crm.settings.service.impl.UserServiceImpl;
import com.kou.crm.utils.MD5Util;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.servlet.http.HttpServletRequest;
import java.util.HashMap;
import java.util.Map;

@Controller
@RequestMapping("settings/user")
public class LoginController {

    @Autowired
    private UserService userService;

    @RequestMapping("/login.do")
    @ResponseBody
    public Map<String, Object> Login(HttpServletRequest request, String loginAct, String loginPwd) throws MyException {
        //  将密码的明文形式转换为MD5的密文形式
        loginPwd = MD5Util.getMD5(loginPwd);

        //  获取浏览器端的IP地址
        String ip = request.getRemoteAddr();

        //  调用userService的方法
        User user = userService.Login(loginAct,loginPwd,ip);
        Map<String,Object> map = new HashMap<>();

        //  如果不为空，则存储到session中
        //	{"success":true}
        //  程序执行到这，说明业务层没有为controller抛出任何异常，表示登陆成功
        request.getSession().setAttribute("user",user);
        map.put("success",true);

        return map;
    }
}
