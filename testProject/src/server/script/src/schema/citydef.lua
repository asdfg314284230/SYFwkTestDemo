return {
    base = {
        lounge_lv = {1, SCHEMA_TYPE.INT, '休息室等级'},
    },
    data = {
        --已经任命任务的士兵
        list = {
            col = {
                role_id = {"", SCHEMA_TYPE.STRING, "士兵的ID"},
                conf_id = {"", SCHEMA_TYPE.STRING, "士兵的配置ID"},
                build = {nil, SCHEMA_TYPE.STRING, "当前所在建筑"},
                enter_time = {0, SCHEMA_TYPE.INT, "记录角色进入建筑时间"},
                work_time = {0, SCHEMA_TYPE.INT, "记录角色工作开始时间"},
                power = {0, SCHEMA_TYPE.INT, "角色体力"},
                power_limit = {100, SCHEMA_TYPE.INT, "角色体力上限"},
            }
        },
        build_list = {
            col = {
                build_id = {nil, SCHEMA_TYPE.STRING, "建筑ID"},
                build_lv = {1, SCHEMA_TYPE.INT, '建筑等级'},
            }
        },
    }
}