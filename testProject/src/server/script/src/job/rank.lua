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

-- 常驻排行榜
local resident_rank = {
    test = {name = "test", veidoo = {-1, 1}}, -- 估值排行榜
    rank_test = {name = "rank_test", veidoo = {-1, 1}}, -- 测试排行榜
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

--加载完成后方法
local function on_finish()

end

-- 测试排行榜
function _command.analytics_test(pcid, name, score, data)
    local code = EC.OK
    local msg = {}
    local rank = _rank_list[name]
    if rank then
        
        for i = 1, 200 do
            rank:set(pcid .. "_" .. i, {math.random(1,10), _jctx.sytime.time() + math.random(-100,100)}, {
                pcid = pcid .. "_" .. i,
            })
        end
    end
    return code, msg
end

-- 统计
-- @param pcid
-- @param name 排行榜名字
-- @param score 分数table {score1, score2, score3} (元素个数需要和排行榜的维度对应)
-- @param data 额外数据
function _command.analytics(pcid, name, score, data)
    local code = EC.OK
    local msg = {}
    local rank = _rank_list[name]
    if rank then
        rank:set(pcid, score, data)
    end
    return code, msg
end


-- 查询带个id
function _command.query(pcid, name)
    local code = EC.OK
    local msg = {}
    local rank = _rank_list[name]
    if rank then
        msg = rank:query_ex(pcid)
    end
    return code, msg
end

-- 范围查询
function _command.range_ex(pcid, name, start, stop)
    local code = EC.OK
    local msg = {}
    local rank = _rank_list[name]
    if rank then
        msg = rank:range_ex(2,30)
    end
    return code, msg
end

-- 查询前n名
function _command.top(pcid, name, num)
    local code = EC.OK
    local msg = {}
    local rank = _rank_list[name]
    
    if rank then
        msg = rank:top_ex(num)
    end
    return code, msg
end

-- 删除排行榜
function _command.delete(pcid, name)
    local code = EC.OK
    local msg = {}
    local rank = _rank_list[name]
    if rank then
        msg = rank:delete()
    end
    return code, msg
end

-- 从排行榜中移除id
function _command.unset(pcid, name, id)
    local code = EC.OK
    local msg = {}
    local rank = _rank_list[name]
    if rank then
        msg = rank:unset(id)
    end
    return code, msg
end
--[[    
    新一天执行的方法
]]
local function _new_day(...)

end

return {
    init = on_init, -- 模块初始化完毕后，会调用这个函数
    -- schema = "job_aoi", -- 指定模块数据的schema文件名称
    command = _command, -- logic模块可以通过call/send调用本模块接口
    finish = on_finish, -- 所有job加载完成之后的回调
    new_day = _new_day --新一天执行的方法
}
