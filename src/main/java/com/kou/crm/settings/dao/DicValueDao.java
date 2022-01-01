package com.kou.crm.settings.dao;

import com.kou.crm.settings.domain.DicValue;

import java.util.List;

public interface DicValueDao {
    List<DicValue> getDicValueListByCode(String code);
}
