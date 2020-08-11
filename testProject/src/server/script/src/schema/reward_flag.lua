return {
    base = {},
    data = {
        blist = {
            pk = {"id"},
            col = {
                flag = {false,  SCHEMA_TYPE.BOOL, "指定id阶段的奖励是否领取过"},
            },
        },
        ilist = {
            pk = {"id"},
            col = {
                flag = {0,  SCHEMA_TYPE.INT, "已领取了第几阶段的奖励"},
            },
        }
    }
}
