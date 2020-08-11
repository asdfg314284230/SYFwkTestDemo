return {
    base = {
        airship_lv = {1, SCHEMA_TYPE.INT, '军团飞艇等级'},
        single_value = {0, SCHEMA_TYPE.INT, '单人冒险进度值'},
        adventure_time = {0, SCHEMA_TYPE.INT, '单人探险刷新时间戳'}
    },
    data = {
        -- 单人冒险探险箱子列表
        single_box = {
            pk = {'id'},
            col = {
                state = {'', SCHEMA_TYPE.STRING, '领取状态'} -- get : 领取 or unread : 未完成
            }
        },
        -- 单人冒险任务生成节点
        single_task = {
            pk = {'id'}, -- "task_id#index"
            col = {
                state = {'', SCHEMA_TYPE.STRING, '任务状态'}, -- start:开启 or unread：未开启
                time = {0, SCHEMA_TYPE.INT, '任务时间戳'},
                task_quality = {0, SCHEMA_TYPE.INT, '任务品质'},
                task_icon_reward = {'', SCHEMA_TYPE.STRING, '一阶任务显示的Icon'}, -- "coin#coin1#item_0001"
                task_lv_icon_rwead = {'', SCHEMA_TYPE.STRING, '二阶任务显示的Icon'}, -- "coin#coin1#item_0001"
                task_reward = {'', SCHEMA_TYPE.STRING, '一阶任务总奖励池子'}, -- "!coin#coin1#item_0001!coin#coin1#item_0001"  这是两层table
                task_lv_reward = {'', SCHEMA_TYPE.STRING, '二阶任务总奖励池子'},
                task_hero = {0, SCHEMA_TYPE.INT, '需要的英雄数量'},
                task_hero_quality = {0, SCHEMA_TYPE.INT, '需要的英雄品质'},
                task_soldier = {0, SCHEMA_TYPE.INT, '需要的士兵数量'},
                task_soldier_quality = {0, SCHEMA_TYPE.INT, '需要的士兵品质'},
                task_battle = {'', SCHEMA_TYPE.STRING, '上阵列表'}, -- hero_0001#hero_0002 ....
                task_keep = {false, SCHEMA_TYPE.BOOL, '保留状态'},
                tag = {false, SCHEMA_TYPE.BOOL, '是否开启二级状态'},
                lv_state = {'', SCHEMA_TYPE.STRING, '二级任务状态'} -- start:领取 or unread: 未完成
            }
        },
        -- 已经存在任务列表中的ID
        task_perform = {
            pk = {'id'},
            col = {
                perform_id = {'', SCHEMA_TYPE.STRING, 'ID'}
            }
        },
        -- 今日所有被移除的任务ID
        task_remove = {
            pk = {'id'},
            col = {
                task_id = {'', SCHEMA_TYPE.STRING, '被移除的任务ID'}
            }
        }
    }
}
