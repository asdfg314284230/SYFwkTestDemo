--[[ 
    1.创建排行榜数据 _jctx.rank.create(rank_name,veidoo)

    2.设置排行榜内数据 methods:set(id,score,data)
      score 分数
      data 额外保存的数据

    3.删除排行榜内的排行数据 methods:unset(...)
      ... => id1,id2,id3等

    4.删除排行榜数据 methods:delete()

    5.查询指定id对应的排名 methods:query_ex(id)

    6.查询范围排名 methods:range_ex(start,stop)
      start 按照lua习惯，从1开始

    7.查询前N个数据 methods:top_ex(num,with_score,with_data)
 ]]

-- 排行榜列表
local _rank_list = {}
--榜单数据缓存表
local rank_cache_table = {}
--榜单数据是否过期时间
local cache_space = {
    time = 10,
}

-- 常驻排行榜
local resident_rank = {
    rank_level_prog = {name = "rank_level_prog", veidoo = {-1,1}}, --关卡进度排行榜
    rank_fight_cap = {name = "rank_fight_cap", veidoo = {-1,1}}, --战力排行榜
    rank_infantry_force = {name = "rank_infantry_force", veidoo = {-1,1}}, --步兵排行榜
    rank_bowman_force = {name = "rank_bowman_force", veidoo = {-1,1}}, --战力排行榜
    rank_cavalry_force = {name = "rank_cavalry_force", veidoo = {-1,1}}, --战力排行榜
}


--外部调用
local _command = {}
--
local function on_init(all_data)
    local list = {}
    -- 插入常驻排行榜
    for _, info in pairs(resident_rank) do
        table.insert(list, info)
    end

    -- 创建排行榜
    for _, info in pairs(list) do
        _rank_list[info.name] = _jctx.rank.create(info.name, info.veidoo)
    end
    
end

--加载完成后回调方法
local function on_finish()
end


-- 统计
-- @param pcid
-- @param name 排行榜名字
-- @param score 分数table {score1, score2, score3} (元素个数需要和排行榜的维度对应)
-- @param data 额外数据
function _command.analytics(pcid,name,score,data)
    local code = EC.OK
    local msg = {}

    local rank = _rank_list[name]
    if table.length(rank._veidoo) ~= table.length(score) then 
        code = EC.RANK_REPORT_ERROR
        return code,msg
    end
    if rank then 
        rank:set(pcid,score,data)
    end
    return code,msg
end

-- 查询单个id
function _command.query(pcid,name)
    local code = EC.OK
    local msg = {}
    local rank = _rank_list[name]
    if rank then 
        msg = rank:query_ex(pcid)
    end
    return code,msg
end

-- 范围查询
function _command.range_ex(pcid,name,start,stop) 
    local code = EC.OK
    local msg = {}
    local rank = _rank_list[name]
    if rank then 
        msg = rank:range_ex(start,stop)
    end
    return code, msg
end

-- 查询前n名
function _command.top(pcid,name,num)
    local code = EC.OK
    local msg = {}
    local rank = _rank_list[name]
    if not rank then 
        code = EC.RANK_QUERY_DATA_ERROR
        return code,msg
    end
    local rank_name = name
    if not rank_cache_table[rank_name] or (_jctx.sytime.time() - rank_cache_table[rank_name].time > cache_space.time) then 
        local tb = rank:top_ex(num)
        for i=1 ,#tb do 
            local play_info = _jctx.query_player(tb[i].id)
            tb[i].info = {
                _jctx.log.dump(play_info.data.info.name),
                icon = play_info.data.player_info.current_icon_id,
                name = play_info.data.info.name,
            }
            tb[i].data.name = play_info.data.info.name
            tb[i].data.icon = play_info.data.player_info.current_icon_id
        end
        rank_cache_table[rank_name] = {
            rank = tb,
            time = _jctx.sytime.time(),
        }      
        _jctx.log.dump(rank_cache_table)
    end
    msg.rank = rank_cache_table[rank_name].rank
    return code,msg
end

-- 删除排行榜
function _command.delete(pcid,name)
    local code = EC.OK
    local msg = {}
    local rank = _rank_list[name]
    if rank then 
        msg = rank:delete()
    end
    return code,msg
end

-- 从排行榜中移除id
function _command.unset(pcid,name,id)
    local code = EC.OK
    local msg = {}
    local rank = _rank_list[name]
    if rank then 
        msg = rank:unset(id)
    end
    return code,msg
end

--[[
    新一天执行的方法
]]
local function _new_day()
end

return{
    init = on_init,
    command = _command,
    finish = on_finish,
    new_day = _new_day,
}
