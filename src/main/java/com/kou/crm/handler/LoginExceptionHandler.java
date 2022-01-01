package com.kou.crm.handler;

import com.kou.crm.exception.LoginException;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.ResponseBody;

import java.util.HashMap;
import java.util.Map;

@ControllerAdvice
public class LoginExceptionHandler {

    //  执行到这个方法，说明未查询到数据，发生异常
    //  并且要给前端发送数据
    @ExceptionHandler(value = LoginException.class)
    @ResponseBody
    public Map<String,Object> doLoginException(Exception e){
        //	{"success":false,"msg":哪错了}
        Map<String,Object> map = new HashMap<>();

        map.put("success",false);
        map.put("msg",e.getMessage());

        return map;
    }
}
