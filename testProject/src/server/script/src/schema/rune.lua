return {
    base = {
        ins_index = {1, SCHEMA_TYPE.INT, '实例索引'},
    },
    data = {
        rune_list = {
            col = {
                ins_id = {"", SCHEMA_TYPE.STRING, "实例id"},
                rune_id = {"", SCHEMA_TYPE.STRING, "符文id"},
                exp = {0, SCHEMA_TYPE.INT, '符文经验'},
                lv = {0, SCHEMA_TYPE.INT, "符文等级"},
                quality = {0, SCHEMA_TYPE.INT, "品质"},
                array_order = {0, SCHEMA_TYPE.INT, "阵容中所处位置"},
            }
        },
        prop_list = {
            col = {
                prop_id = {"", SCHEMA_TYPE.STRING, "道具id"},
                lv = {0, SCHEMA_TYPE.INT, "道具等级"},
                quality = {0, SCHEMA_TYPE.INT, "品质"},
                array_order = {0, SCHEMA_TYPE.INT, "阵容中所处位置"},
            }
        }
    },
}
