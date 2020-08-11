return {
    base = {
        lv = {1, SCHEMA_TYPE.INT, '地下城等级'},
        exp = {1, SCHEMA_TYPE.INT, '地下城经验'},
        refresh_time = {0, SCHEMA_TYPE.INT, '刷新时间'},
        cur_open_time = {0, SCHEMA_TYPE.INT, "记录当前正在挖掘的矿洞开矿时间"},
        cur_build_id = {"", SCHEMA_TYPE.STRING, "id"},
    },
    data = {
        build_list = {
            col = {
                build_id = {"", SCHEMA_TYPE.STRING, "id"},
                lv = {0, SCHEMA_TYPE.INT, "等级"},
                quality = {0, SCHEMA_TYPE.INT, "品质"},
                state = {"none", SCHEMA_TYPE.STRING, "状态"},
                open_time = {0, SCHEMA_TYPE.INT, "记录矿洞开矿时间"},
                layer = {1, SCHEMA_TYPE.INT, "记录矿洞当前层数"},
                tag = {nil, SCHEMA_TYPE.STRING, "所属标签"},
                pos = {0, SCHEMA_TYPE.INT, "矿洞所属位置"},
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
                ore_id = {"", SCHEMA_TYPE.STRING, "矿产id"},
                monster = {"", SCHEMA_TYPE.STRING, "敌人id"},
                produce = {nil, SCHEMA_TYPE.JSON, "矿物产出"},
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
        -- event_list = {
        --     col = {
        --         event_time = {0, SCHEMA_TYPE.INT, "事件记录时间"},
        --         type = {"none", SCHEMA_TYPE.STRING, "事件的类型"},
        --         role_id = {"", SCHEMA_TYPE.STRING, "事件变化的角色id"},
        --         conf_id = {"", SCHEMA_TYPE.STRING, "事件变化的角色id"},
        --         state = {nil, SCHEMA_TYPE.STRING, "状态"},
        --         target = {nil, SCHEMA_TYPE.STRING, "目标"},
        --         pos_x = {nil, SCHEMA_TYPE.FLOAT, "y坐标"},
        --         pos_y = {nil, SCHEMA_TYPE.FLOAT, "x坐标"},
        --         atk = {0, SCHEMA_TYPE.FLOAT, "攻击力"},
        --         speed = {0, SCHEMA_TYPE.FLOAT, "速度"},
        --         max_carry = {0, SCHEMA_TYPE.FLOAT, "最大携带量"},
        --         cur_carry = {0, SCHEMA_TYPE.FLOAT, "当前携带量"},
        --         idle_time = {0, SCHEMA_TYPE.INT, "闲置事件"},
        --     }
        -- },
        op_list = {
            col = {
                op_time = {0, SCHEMA_TYPE.INT, "操作记录时间"},
                op_type = {nil, SCHEMA_TYPE.STRING, "操作类型"},
                op_data = {nil, SCHEMA_TYPE.JSON, "操作数据"},
            }
        },
    }
}