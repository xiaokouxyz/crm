package com.kou.crm.web.listener;

import com.kou.crm.settings.domain.DicValue;
import com.kou.crm.settings.service.DicService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationContext;
import org.springframework.web.context.support.WebApplicationContextUtils;

import javax.servlet.ServletContext;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import java.util.*;

public class SysInitListener implements ServletContextListener {
    /**
     * 该方法是用来监听上下文域对象的方法，当服务器启动时，上下文域对象创建
     * 对象创建完毕，马上执行该方法
     *
     * @param event
     *      该参数能够获取监听的对象
     *      监听的是什么对象，就可以通过该参数取得什么对象
     *      例如我们现在监听的是上下文域对象，通过该参数就可以取得上下文域对象
     */
    @Override
    public void contextInitialized(ServletContextEvent event) {
        ApplicationContext context = WebApplicationContextUtils.getWebApplicationContext(event.getServletContext());
        //获取bean
        DicService dicService =  context.getBean(DicService.class);

        ServletContext application = event.getServletContext();

        /**
         * 管业务层要
         *  7个List
         *
         *  可以打包成一个map
         *  业务层应该是这样来保存数据的
         *      map.put("appellation",appellation);
         *      map.put("clueState",clueState);
         *      .....
         *      ...
         */
        Map<String,List<DicValue>> map = dicService.getAllDic();
        Set<String> set = map.keySet();
        for (String key : set) {
            application.setAttribute(key,map.get(key));
        }

        //数据字典处理完毕后，处理Stage2Possibility. properties文件
        /*
            处理Stage2Possibility. properties文件步骤:
                解析该文件，将该属性文件中的键值对关系处理成为java中键值对关系(map)

                Map<String(阶段stage), String(可能性possibility)> pMap = ....
                pMap. put("01资质审查", 10);
                pMap. put("02需求分析", 25);
                pMap. put("07...",...);

                pMap保存值之后，放在服务器缓存中
                application.setAttribute("pMap”, pMap);
         */

        //  解析properties
        ResourceBundle resourceBundle = ResourceBundle.getBundle("Stage2Possibility");

        Map<String,String> pMap = new HashMap<>();

        Enumeration<String> enumeration = resourceBundle.getKeys();
        while (enumeration.hasMoreElements()){
            //  阶段
            String key = enumeration.nextElement();
            //  可能性
            String value = resourceBundle.getString(key);
            pMap.put(key,value);
        }
        application.setAttribute("pMap",pMap);
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {

    }
}
