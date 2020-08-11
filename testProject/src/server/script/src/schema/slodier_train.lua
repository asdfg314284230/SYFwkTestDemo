return {
    base = {},
    data = {
        slodier_list = {
            pk = {'slodierid#tick'}, --士兵初始的职业索引#唯一标识
            col = {
                stage = {1, SCHEMA_TYPE.INT, '当前所处的阶段'},
                profession_id = {0, SCHEMA_TYPE.INT, '当前职业的id'},
                level = {1, SCHEMA_TYPE.INT, '等级'},
                star = {1, SCHEMA_TYPE.INT, '星级'},
                quality_level = {0, SCHEMA_TYPE.INT, '品阶等级(影响等级上限)'},
                genius_exp = {0, SCHEMA_TYPE.INT, '天赋点经验'},
                genius_exp_level = {0, SCHEMA_TYPE.INT, '天赋点经验等级'},
                genius_point = {0, SCHEMA_TYPE.INT, '天赋点'},
                skill_exp = {0, SCHEMA_TYPE.INT, '技能经验'}
            }
        },
        profession = {
            pk = {'sid@pid'}, --士兵唯一id@职业索引
            col = {
                pid = {'', SCHEMA_TYPE.STRING, '职业完整id'}
            }
        },
        genius = {
            pk = {'sid@gid'}, --士兵唯一id@天赋id
            col = {
                level = {1, SCHEMA_TYPE.INT, '等级'}
            }
        },
        skill = {
            pk = {'sid@pid@sid'}, --士兵唯一id@职业id@技能id
            col = {
                level = {1, SCHEMA_TYPE.INT, '技能等级'}
            }
        },
        equip = {
            pk = {'sid@index'}, --士兵唯一id@部位下标
            col = {
                level = {1, SCHEMA_TYPE.INT, '强化等级'},
                step = {1, SCHEMA_TYPE.INT, '进阶等级'}
            }
        }
    }
}
