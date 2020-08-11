return {
    base = {
    },
    data = {
        role = {
            pk = {"id"},  --ID
            col = {
                level = {1, SCHEMA_TYPE.INT, "等级"},
                exp = {0, SCHEMA_TYPE.INT, "经验"},
                equip_1 = {nil, SCHEMA_TYPE.STRING, "装备1"},
                equip_2 = {nil, SCHEMA_TYPE.STRING, "装备2"},
                equip_3 = {nil, SCHEMA_TYPE.STRING, "装备3"},
                equip_4 = {nil, SCHEMA_TYPE.STRING, "装备4"},
                equip_5 = {nil, SCHEMA_TYPE.STRING, "装备5"},
                equip_6 = {nil, SCHEMA_TYPE.STRING, "装备6"},
                skill_1_lv = {1, SCHEMA_TYPE.INT, "技能1等级"},
                skill_2_lv = {1, SCHEMA_TYPE.INT, "技能2等级"},
                skill_3_lv = {1, SCHEMA_TYPE.INT, "技能3等级"},
                skill_4_lv = {1, SCHEMA_TYPE.INT, "技能4等级"},
            }
        }
    },
}