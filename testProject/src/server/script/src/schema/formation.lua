return {
    base = {},
    data = {
        pos = {
            col = {
                instid = {"", SCHEMA_TYPE.STRING, "实例id"},
                pos_name = {nil, SCHEMA_TYPE.STRING, "阵位名"},
                role_id = {nil, SCHEMA_TYPE.STRING, "角色id"},
                count = {0, SCHEMA_TYPE.INT, "阵位人数"},
                is_hero = {nil, SCHEMA_TYPE.BOOL, "是否为英雄"},
            }
        }
    }
}