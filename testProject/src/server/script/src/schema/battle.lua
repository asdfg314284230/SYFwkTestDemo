return {
    base = {
    },
    data = {
        -- 主线战役,只有通过了之后才会存储,正在打的话，还不会有数据
        main = {
            col = {
                chapter = {1, SCHEMA_TYPE.INT, "章节数"},
                dif = {0, SCHEMA_TYPE.INT, "历史最高难度"},-- 只增不减
            }
        },
        -- 主线战役银箱子
        main_box1 = {
            -- id = chatper_boxIndex
            col = {
                flag = {true, SCHEMA_TYPE.BOOL, "已领取到的箱子"},
            }
        },
        -- 主线战役金箱子
        main_box2 = {
            -- id = chatper_boxIndex
            col = {
                flag = {true, SCHEMA_TYPE.BOOL, "已领取到的箱子"},
            }
        },


        -- 每日战役
        daily = {
            col = {
                chapter = {1, SCHEMA_TYPE.INT, "章节数"},
                dif = {0, SCHEMA_TYPE.INT, "历史最高难度"},-- 只增不减
            }
        },
        -- 每日战役银箱子
        daily_box1 = {
            -- id = chatper_boxIndex
            col = {
                flag = {true, SCHEMA_TYPE.BOOL, "已领取到的箱子"},
            }
        },
        -- 每日战役金箱子
        daily_box2 = {
            -- id = chatper_boxIndex
            col = {
                flag = {true, SCHEMA_TYPE.BOOL, "已领取到的箱子"},
            }
        },
    }
}