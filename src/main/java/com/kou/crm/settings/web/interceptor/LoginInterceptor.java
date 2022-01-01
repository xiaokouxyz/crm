package com.kou.crm.settings.web.interceptor;

import org.springframework.web.servlet.HandlerInterceptor;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.net.URL;

//  拦截用户恶意登录
public class LoginInterceptor implements HandlerInterceptor {

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        System.out.println("拦截器执行......");

        if (request.getSession().getAttribute("user") != null){
            //  证明已经登陆过，放行
            return true;
        }else {


            response.sendRedirect(request.getContextPath() + "/login.html");
            //  没有登陆，重定向
        }
        return false;
    }
}

