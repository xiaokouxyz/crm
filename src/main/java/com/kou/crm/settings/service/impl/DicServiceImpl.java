package com.kou.crm.settings.service.impl;

import com.kou.crm.settings.dao.DicTypeDao;
import com.kou.crm.settings.dao.DicValueDao;
import com.kou.crm.settings.domain.DicType;
import com.kou.crm.settings.domain.DicValue;
import com.kou.crm.settings.service.DicService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class DicServiceImpl implements DicService {
    @Autowired
    private DicTypeDao dicTypeDao;
    @Autowired
    private DicValueDao dicValueDao;

    @Override
    public Map<String, List<DicValue>> getAllDic() {
        Map<String, List<DicValue>> map = new HashMap<>();

        //  将字典类型列表取出
        List<DicType> dicTypeList = dicTypeDao.getDicTypeList();

        for (DicType dicType : dicTypeList) {
            //  取得每一种类型的字典类型编码
            String code = dicType.getCode();

            //  通过字典类型编码来取得字典值列表
            List<DicValue> dicValueList = dicValueDao.getDicValueListByCode(code);

            map.put(code,dicValueList);
        }
        return map;
    }
}
