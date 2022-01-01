package com.kou.crm.exception;

/**
 * 处理登录异常
 */
public class LoginException extends MyException{

    public LoginException() {
    }

    public LoginException(String message) {
        super(message);
    }
}
