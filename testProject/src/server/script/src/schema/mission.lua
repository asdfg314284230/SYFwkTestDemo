return {
    base = {
        daily_active = {0, SCHEMA_TYPE.INT, "每日活跃度"},
        weeks_active = {0, SCHEMA_TYPE.INT, "周常活跃度"},
        weeks_day = {0,SCHEMA_TYPE.INT,"记录玩家天数"}
    },
    data = {
        -- 每日任务列表
        daily_task = {
            pk = {"id"},
            col = {
                state = {"", SCHEMA_TYPE.STRING, "任务完成状态"} -- get : 领取 or unread : 未完成 
            }
        },
        -- 每日任务活跃礼包
        daily_box = {
            pk = {"id"},
            col = {
                state = {"", SCHEMA_TYPE.STRING, "礼包状态"} -- get:领取 or unread： 未领取
            }
        },
        -- 每周活跃礼包
        weeks_box = {
            pk = {"id"},
            col = {
                state = {"", SCHEMA_TYPE.STRING, "礼包状态"} -- get:领取 or unread： 未领取
            }
        }
    }
}
