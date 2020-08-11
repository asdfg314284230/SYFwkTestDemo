return {
    base = {
        cur_cid = {0, SCHEMA_TYPE.INT, "当前选择的指挥官的id索引"}
    },
    data = {
        --已经解锁的指挥官列表
        c_list = {
            col = {
                cid = {0, SCHEMA_TYPE.INT, "指挥官的id索引"}
            }
        }
    }
}
