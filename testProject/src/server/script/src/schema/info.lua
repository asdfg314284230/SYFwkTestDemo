return {
    base = {
        name = {"unknown", SCHEMA_TYPE.STRING, "玩家名字"},
        gold = {0, SCHEMA_TYPE.INT, "金币"},
        gem = {0, SCHEMA_TYPE.INT, "钻石"},
        level = {0,SCHEMA_TYPE.INT,"玩家等级"},
        found_time = {"",SCHEMA_TYPE.STRING,"创建时间戳"} 
    },
    data = {
        coin = {
            col = {
                cid = {"", SCHEMA_TYPE.STRING, "货币id"},
                count = {0, SCHEMA_TYPE.INT, "货币数量"},
            }
        }
    }
}