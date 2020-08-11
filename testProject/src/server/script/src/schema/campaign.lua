return {
    base = {
        cur_fort = {"", SCHEMA_TYPE.STRING, "当前关卡id"},
        patrol_id = {"", SCHEMA_TYPE.STRING, "挂机关卡id"},
        patrol_record = {0, SCHEMA_TYPE.INT, "记录时间"},
        patrol_reward = {nil, SCHEMA_TYPE.STRING_BIG, "挂机奖励池"}
    },
    data = {
        conquer_fort_list = {
            col = {
                fort_id = {"", SCHEMA_TYPE.STRING, "关卡id"},
                t = {0, SCHEMA_TYPE.INT, "操作记录时间"}
            }
        }
    }
}
