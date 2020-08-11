return {
    base = {
        ex_text = {nil, SCHEMA_TYPE.JSON, "技能1等级"},
        ex_bool = {false, SCHEMA_TYPE.BOOL, "技能1等级"},
        ex_float = {0, SCHEMA_TYPE.FLOAT, "技能1等级"},
        ex_string_big = {nil, SCHEMA_TYPE.STRING_BIG, "技能1等级"},
        ex_float1 = {0, SCHEMA_TYPE.FLOAT, "技能1等级"},
        -- ex_double = {0, SCHEMA_TYPE.DOUBLE, "技能1等级"},
    },
    data = {
        list = {
            pk = {"id"},  --ID
            col = {
                ex_text = {nil, SCHEMA_TYPE.JSON, "技能1等级"},
                ex_bool = {false, SCHEMA_TYPE.BOOL, "技能1等级"},
                ex_float = {0, SCHEMA_TYPE.FLOAT, "技能1等级"},
                xx = {0, SCHEMA_TYPE.FLOAT, "技能1等级"},
            }
        }
    },
}

-- local bag = {
--     level = {1, SCHEMA_TYPE.INT, "背包等级"},
--     equip_list = {

--     }
-- }