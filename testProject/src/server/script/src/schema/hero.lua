return {
    base = {},
    data = {
        --英雄
        hero_list = {
            pk = {"heroid#tick"}, --英雄初始的职业索引#唯一标识
            col = {
                role_id = {"", SCHEMA_TYPE.STRING, "英雄ID"},
                level = {1, SCHEMA_TYPE.INT, "等级"},
                star = {1, SCHEMA_TYPE.INT, "当前所处星级"},
                quality_level = {0, SCHEMA_TYPE.INT, "品阶等级(影响等级上限)"}
                -- star_up = {2, SCHEMA_TYPE.INT, "炼体是否升过升星"}
            }
        },
        -- 英雄性格
        hero_character = {
            pk = {"hid@index"},
            col = {
                character_id = {"", SCHEMA_TYPE.STRING, "性格id"}
            }
        },
        -- 魔能烙印(圣痕)
        hero_stigmata = {
            pk = {"heroid@index"},
            col = {
                stigmata_id = {"", SCHEMA_TYPE.STRING, "烙印ID"},
                level = {1, SCHEMA_TYPE.INT, "魔能等级"}
            }
        },
        -- 英雄天赋
        hero_genius = {
            pk = {"heroid@index"},
            col = {
                genius_id = {"", SCHEMA_TYPE.STRING, "装备的天赋ID"}
            }
        },
        --五个部位的装备
        hero_equip = {
            pk = {"hid@index"}, --英雄唯一id@部位索引
            col = {
                equip_id = {"", SCHEMA_TYPE.STRING, "装备id"}
            }
        },
        -- 英雄技能
        hero_skill = {
            pk = {"hid&conf_id"},
            col = {
                red_dot = {false, SCHEMA_TYPE.BOOL, "红点判断"}
            }
        },
        --炼体,四个部位
        hero_refining = {
            pk = {"hid@index"}, --英雄唯一id@部位索引
            col = {
                level = {1, SCHEMA_TYPE.INT, "等级"},
                quality = {1, SCHEMA_TYPE.INT, "品质"}
            }
        }
    }
}
