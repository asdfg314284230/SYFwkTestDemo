return {
    base = {},
    data = {
        -- 天赋列表
        genius_list = {
            pk = {'genius_id#time@index'},
            col = {
                level = {1, SCHEMA_TYPE.INT, '天赋等级'},
                exp = {0, SCHEMA_TYPE.INT, '天赋经验'},
                role_id = {'', SCHEMA_TYPE.STRING, '角色ID'}
            }
        }
    }
}
