return {
    base = {},
    data = {
        equip = {
            --装备的唯一id,格式为: 配置表中装备id#装备的index
            pk = {"item_id"},
            col = {
                quality = {0, SCHEMA_TYPE.INT, "装备的品质"},
                level = {0, SCHEMA_TYPE.INT, "装备强化等级"},
                exp = {0, SCHEMA_TYPE.INT, "经验值"},
                apparel = {"",SCHEMA_TYPE.STRING,"是否佩戴"},
                main_intensify = {0,SCHEMA_TYPE.INT,"装备主属性"},
                enchant_num = {0,SCHEMA_TYPE.INT,"附魔次数"}
            }
        },
        --装备的附加属性
        equip_intensify = {
            --装备的唯一id_属性槽index
            pk = {"item_id@index"},
            col = {
                key_id = {0, SCHEMA_TYPE.INT, "属性的id"},
                value = {0, SCHEMA_TYPE.FLOAT, "属性值"}
            }
        },
        --装备镶嵌数据
        equip_inlay = {
            --装备唯一id_插槽index
            pk = {"item_id@index"},
            col = {
                key_id = {0, SCHEMA_TYPE.INT, "属性的id"},
                value = {0, SCHEMA_TYPE.FLOAT, "属性值"}
            }
        }
    }
}
 