package com.kou.crm.handler;

import com.kou.crm.exception.ActivityException;
import com.kou.crm.exception.TransactionException;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.ResponseBody;

import java.util.HashMap;
import java.util.Map;

@ControllerAdvice
public class TransactionExceptionHandler {

    //  执行到这个方法，说明市场活动失败
    @ResponseBody
    @ExceptionHandler(value = TransactionException.class)
    public Map<String,Object> transactionExceptionHandler(Exception e){
        //	{"success":false,"msg":哪错了}
        Map<String,Object> map = new HashMap<>();

        map.put("success",false);
        map.put("msg",e.getMessage());

        return map;
    }

}
