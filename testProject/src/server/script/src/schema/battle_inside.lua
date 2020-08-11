return {
    base = {
        tp = {0, SCHEMA_TYPE.INT, "战役类型"},
        dif = {0, SCHEMA_TYPE.INT, "难度"},
        chapter = {0, SCHEMA_TYPE.INT, "章节"},
        x = {0, SCHEMA_TYPE.INT, "最后完成的列"},
        y = {0, SCHEMA_TYPE.INT, "最后完成的行"},

        battle_x = {0, SCHEMA_TYPE.INT, "正在打的列"},
        battle_y = {0, SCHEMA_TYPE.INT, "正在打的行"},

        inst_count = {0, SCHEMA_TYPE.INT, "军营实例化数量"},

        hero = {nil,SCHEMA_TYPE.STRING_BIG,"英雄数据独立出来"},
        soldier = {nil,SCHEMA_TYPE.STRING_BIG,"士兵数据独立出来"},
        -- 军营和阵容只存储关键key，具体数据还是再hero和soldier中
        camp = {nil,SCHEMA_TYPE.STRING_BIG,"军营数据"},
        formation = {nil,SCHEMA_TYPE.STRING_BIG,"阵容数据"},
    },
    data = {
        -- 节点数据，类似于二维数组了
        -- 根据长度，直接可以判断出最大列数  n_1不存在， 那最大列就是n-1
        -- id = column_row
        nodes = {
            col = {
                eid = {0, SCHEMA_TYPE.INT, "事件类型配置ID"},
                pass = {-1, SCHEMA_TYPE.INT, "该节点通过的话，记录他的上一行"},
                -- eg:  1_4_14_17
                -- 若没有后续节点，意味着是最后一个节点了
                rows = {"", SCHEMA_TYPE.STRING, "后续连接的节点row"},
            }
        },
        box1 = {
            col = {
                index = {0, SCHEMA_TYPE.INT, "已经获得的宝箱1索引"},
            }
        },
        box2 = {
            col = {
                index = {0, SCHEMA_TYPE.INT, "已经获得的宝箱2索引"},
            }
        }
    }
}