return {
    base = {},
    data = {
        --士兵
        soldier_list = {
            pk = {'soldierid#tick'}, --英雄初始的职业索引#唯一标识
            col = {
                -- conf_id
                role_id = {'', SCHEMA_TYPE.STRING, '士兵唯一ID'},
                level = {1, SCHEMA_TYPE.INT, '等级'},
                star = {1, SCHEMA_TYPE.INT, '当前所处星级'},
                quality_level = {0, SCHEMA_TYPE.INT, '品阶等级(影响等级上限)'}
            }
        },
        -- 士兵性格
        soldier_character = {
            pk = {'hid@index'},
            col = {
                character_id = {'', SCHEMA_TYPE.STRING, '性格id'}
            }
        },
        -- 魔能烙印(圣痕)
        soldier_stigmata = {
            pk = {'heroid@index'},
            col = {
                stigmata_id = {'', SCHEMA_TYPE.STRING, '烙印ID'},
                level = {1, SCHEMA_TYPE.INT, '魔能等级'}
            }
        },
        -- 士兵天赋
        soldier_genius = {
            pk = {'heroid@index'},
            col = {
                genius_id = {'', SCHEMA_TYPE.STRING, '装备的天赋ID'}
            }
        },
        --五个部位的装备
        soldier_equip = {
            pk = {'sid@index'}, --英雄唯一id@部位索引
            col = {
                equip_id = {'', SCHEMA_TYPE.STRING, '装备id'}
            }
        },
        --炼体,四个部位
        soldier_refining = {
            pk = {'hid@index'},
            col = {
                level = {1, SCHEMA_TYPE.INT, '等级'},
                quality = {1, SCHEMA_TYPE.INT, '品质'}
            }
        }
    }
}
