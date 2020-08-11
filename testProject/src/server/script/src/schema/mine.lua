return {
    base = {
        record_time = {0, SCHEMA_TYPE.INT, "记录时间"},
        build_id = {0, SCHEMA_TYPE.INT, "记录当前矿洞id"},
        level = {1,  SCHEMA_TYPE.INT, "玩家地下城等级"},
        exp = {0, SCHEMA_TYPE.INT, "玩家地下城经验"},
        mine_roll = {0, SCHEMA_TYPE.INT, "玩家矿洞探索卷"},
    },
    data = {
        dungeon_list = {
            col = {
            }
        },
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
        build_list = {
            col = {
                build_id = {0, SCHEMA_TYPE.INT, "id"},
                state = {"none", SCHEMA_TYPE.STRING, "状态"},
                open_time = {0, SCHEMA_TYPE.INT, "记录矿洞开矿时间"},
                layer = {1, SCHEMA_TYPE.INT, "记录矿洞当前层数"},
            }
        },
    }
}