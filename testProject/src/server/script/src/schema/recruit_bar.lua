return {
    base = {
        level = {1, SCHEMA_TYPE.INT, '吧主等级'},
        bar_exp = {0, SCHEMA_TYPE.INT, '吧主经验'},
        gift_value = {0, SCHEMA_TYPE.INT, '业绩当前值'},
        gift_level = {1, SCHEMA_TYPE.INT, '礼包阶段'},
        recruit_tag = {1, SCHEMA_TYPE.INT, '当前兵种招募标识'} -- (右侧列表兵种招募的选择框)
    },
    data = {
        -- 今天随机生成的四个小卡组
        today_group = {
            pk = {'id'},
            col = {
                quality = {0, SCHEMA_TYPE.INT, '抽中的品质'},
                conf_id = {'', SCHEMA_TYPE.STRING, '抽中的配置ID'},
                price = {0, SCHEMA_TYPE.INT, '抽中的价格'}
            }
        },
        -- 给随机生成的卡牌生成对应的性格表(单独一套)
        character_list = {
            pk = {'group_id@index'},
            col = {
                character_id = {'', SCHEMA_TYPE.STRING, '性格id'}
            }
        }
    }
}
