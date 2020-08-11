return {
    base = {
        record_time = {0, SCHEMA_TYPE.INT, "记录时间"},
    },
    data = {
        grids = {
            col = {
                grid_id = {"", SCHEMA_TYPE.STRING, "id"},
                col = {0, SCHEMA_TYPE.INT, "列"},
                row = {0, SCHEMA_TYPE.INT, "行"},
                tp = {0, SCHEMA_TYPE.INT, "格子类型"},
                obstacle = {false, SCHEMA_TYPE.BOOL, "是否为障碍物"},
                hp = {0, SCHEMA_TYPE.FLOAT, "血量"},
                weight = {0, SCHEMA_TYPE.INT, "权重"},
            }
        },
        role_list = {
            col = {
                role_id = {"", SCHEMA_TYPE.STRING, "id"},
                conf_id = {"", SCHEMA_TYPE.STRING, "conf_id"},
                pos_x = {nil, SCHEMA_TYPE.FLOAT, "x坐标"},
                pos_y = {nil, SCHEMA_TYPE.FLOAT, "y坐标"},
                state = {nil, SCHEMA_TYPE.STRING, "状态"},
                pos_target = {nil, SCHEMA_TYPE.STRING, "目标"},
            }
        },
        repertory_list = {
            col = {
                ore_id = {"", SCHEMA_TYPE.STRING, "资源类型id"},
                num = {0, SCHEMA_TYPE.FLOAT, "数量"},
            }
        },

        -- plan_list = {
        --     col = {
        --         xxxtime = {"", SCHEMA_TYPE.INT, "操作时间"},
        --         event = {"", SCHEMA_TYPE.STRING, "事件"},
        --     }
        -- },
    }
}