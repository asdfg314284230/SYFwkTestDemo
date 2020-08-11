return {
    base = {
        refresh_time = {0, SCHEMA_TYPE.INT, "刷新时间"}
    },
    data = {
        -- 神秘商店——黑市
        mystical_magic = {
            pk = {"item_id"},
            col = {
                conf_id = {"",SCHEMA_TYPE.STRING,"配置表ID"},
                count = {0, SCHEMA_TYPE.INT, "道具数量"},
            }
        },
        -- 神秘商店——军攻
        mystical_guild = {
            pk = {"item_id"},
            col = {
                conf_id = {"",SCHEMA_TYPE.STRING,"配置表ID"},
                count = {0, SCHEMA_TYPE.INT, "道具数量"},
            }
        },
        -- 神秘商店——竞技
        mystical_arena = {
            pk = {"item_id"},
            col = {
                conf_id = {"",SCHEMA_TYPE.STRING,"配置表ID"},
                count = {0, SCHEMA_TYPE.INT, "道具数量"},
            }
        }
    }
}
