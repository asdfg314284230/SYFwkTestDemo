local _public = {}
local _private = {}
local _command = {}
local _data

----------------------------------本地局部方法----------------------------------
local function _h_on_load_all(d)
    local code = 0
    local msg = {}

    local cid = d.cid
    if type(cid) ~= 'string' then
        code = 1
        return code, msg
    end

    _ctx.load_data_by_cid(cid)
    -- _ctx.log.w("cid = " .. cid)
    local d = _data
    -- _ctx.log.dump(d)

    msg = {
        d = d
    }
    --_ctx.log.dump(msg)
    return code, msg
end

-- 全部需要初始化数据的操作都放在这里
local function _h_init_data()
    -- 调用shop初始化操作
    _ctx.ctrl.shop.init_shop_data()

    -- 调用任务初始化
    _ctx.ctrl.mission.init_mission_data()

    -- -- 登录时候调用
    -- _ctx.ctrl.legion.init_legion()

    _ctx.ctrl.player_info.init_player_info()

    -- -- 初始化酒馆
    -- _ctx.ctrl.recruit_bar.init_recruit_bar()

    -- 矿洞刷新时间初始化
    _ctx.ctrl.dungeons.refresh_time()

    return EC.OK
end

-- 创建角色
local function _h_creation_role(data)
    -- 设置名称
    _data.info.name = data
    -- 设置创建时间
    _data.info.found_time = _ctx.sytime.time()
    -- 根据配置表初始化
    local conf = _conf['initialize'][1]
    for k, v in pairs(conf) do
        if k == 'hero' then
            for i, j in pairs(v) do
                _ctx.ctrl.hero.add_hero(j[2], j[3])
            end
        elseif k == 'army' then
            for i, j in pairs(v) do
                _ctx.ctrl.soldier.add_soldier(j[2], j[3])
            end
        elseif k == 'coin' then
            _ctx.ctrl.user.inc(v)
        elseif k == 'items' then
            _ctx.ctrl.user.inc(v)
        elseif k == 'chip' then
            _ctx.ctrl.user.inc(v)
        elseif k == 'equip' then
            _ctx.ctrl.equip.add_equip(v)
        end
    end
    return EC.OK
end

----------------------------------对外方法----------------------------------

--[[ 
     获取玩家指定ID的货币数量
  ]]
function _public.get_info_coin(id)
    local data = _data.info.coin[id]
    if not data then
        return 0
    end
    return data.count
end
--[[ 
    获取玩家等级
 ]]
function _public.get_info_level()
    _ctx.log.dump(_data.info)
    return _data.info.level
end
--[[ 
    多倍奖励格式化
 ]]
function _public.format_multi_reward(rewards, times)
    if type(rewards) ~= 'table' then
        return
    end

    if not times or type(times) ~= 'number' then
        return rewards
    end

    local ret = {}
    for k, reward in pairs(rewards) do
        local max = #reward
        local count = tonumber(reward[max]) or 0
        count = count * times

        ret[k] = {}
        for i, j in pairs(reward) do
            ret[k][i] = j
        end

        ret[k][max] = count
    end

    return ret
end

--[[
    统一获取接口（走统计）
    参数形式：
    1 二维数组（一般是配置表通过奖励字符串转换而来）：
        dec({{"coin1", 100}, {"coin2", 100}, {"item", "100001", 1}})
    2 奖励字符串（原始的奖励字符串，冒号，分号分割）：
        dec("coin1:100;coin2:100;item:100001:1")
    3 单独传递
        dec("coin1", 100)
        dec("item", "100001", 1)
    返回值：返回EC.OK，说明操作成功，否则失败
]]
function _public.inc(...)
    local reward = _private.parse_reward_param(...)
    local code = EC.OK
    for _, v in ipairs(reward) do
        code = _private.inc(v, true)
        if code ~= EC.OK then
            return code
        end
    end
    for _, v in ipairs(reward) do
        _private.inc(v)
    end

    return code
end

--[[
    统一消耗接口（走统计）
    参数形式：
    1 二维数组（一般是配置表通过奖励字符串转换而来）：
        dec({{"coin1", 100}, {"coin2", 100}, {"item", "100001", 1}})
    2 奖励字符串（原始的奖励字符串，冒号，分号分割）：
        dec("coin1:100;coin2:100;item:100001:1")
    3 单独传递
        dec("coin1", 100)
        dec("item", "100001", 1)
    返回值：返回EC.OK，说明操作成功，否则失败
]]
function _public.dec(...)
    local reward = _private.parse_reward_param(...)
    local code = EC.OK
    for _, v in ipairs(reward) do
        code = _private.dec(v, true)
        if code ~= EC.OK then
            return code
        end
    end
    for _, v in ipairs(reward) do
        _private.dec(v)
    end
    return code
end
--[[ 
    属性增加检查,基本reward格式检查
    返回值：
    1.EC码
    2.格式化后的rewards
 ]]
function _public.inc_check(...)
    local code = EC.OK

    -- 奖励统一格式
    local rewards = _private.parse_reward_param(...)
    if not rewards then
        return EC.PARAM_ERROR
    end

    -- 奖励格式检查
    for _, reward in ipairs(rewards) do
        local pass = _private.check_reward_format(reward)
        if not pass then
            return EC.PARAM_ERROR
        end
    end

    return code, rewards
end

--[[ 
    属性减少检查,基本reward格式检查
    返回值：
    1.EC码
    2.格式化后的rewards
 ]]
function _public.dec_check(...)
    local code = EC.OK

    -- 奖励统一格式
    local rewards = _private.parse_reward_param(...)
    if not rewards then
        return EC.PARAM_ERROR
    end

    -- 奖励格式检查
    for _, reward in ipairs(rewards) do
        local pass = _private.check_reward_format(reward)
        if not pass then
            return EC.PARAM_ERROR
        end
    end

    return code, rewards
end

----------------------------------私有方法----------------------------------

--[[
    获取单个
    param：奖励格式
    try：检测是否可以增加，如果该参数为true，只做检测，不要做真实的增加操作
    返回值：只有在try为true的时候返回值才有意义
]]
function _private.inc(param, try)
    if not _private.check_reward_format(param) then
        return EC.REWARD_FORMAT_ERROR
    end

    local tp = param[1]

    local cline = _conf['items.coin'][tp]
    -- 是货币
    if cline then
        local num = tonumber(param[2])

        if try and type(num) == 'number' then
            return EC.OK
        end

        -- 先把统计走了
        _ctx.ctrl.analytics.set_by_cid(cline.aid_get, num)

        if not _data.info.coin[tp] then
            _data.info.coin[tp] = {cid = param[2], count = num}
            return EC.OK
        end

        _data.info.coin[tp].count = _data.info.coin[tp].count + num

        return EC.OK
    end

    -- 是背包中物品(item,chip,incription)
    local bag_line = _conf['items.' .. tp]
    if bag_line then
        if try then
            return EC.OK
        end

        _ctx.ctrl.bag.inc(param)

        _ctx.ctrl.analytics.set_by_cid(string.format('%s_get', tp), tonumber(param[3]), param[2], param[2])
        return EC.OK
    end

    -- 是其他类型
    if tp == 'equip' then
        _ctx.ctrl.equip.add_equip(param)
    elseif tp == 'hero' then
        local num = param[2]
        local id = param[3]
        _ctx.ctrl.hero.add_hero(id, num)
        return EC.OK
    elseif tp == 'army' then
        local num = param[2]
        local id = param[3]
        _ctx.ctrl.slodier_train.add_slodier(id, num)
        return EC.OK
    end

    return EC.UNKNOWN_TYPE_ERROR
end

--[[
    消耗单个
    param：奖励格式
    try：检测是否可以减少，如果该参数为true，只做检测，不要做真实的减少操作
    返回值：只有在try为true的时候返回值才有意义
]]
function _private.dec(param, try)
    if not _private.check_reward_format(param) then
        return EC.REWARD_FORMAT_ERROR
    end

    local tp = param[1]

    local cline = _conf['items.coin'][tp]
    -- 是货币
    if cline then
        local cost = tonumber(param[2])
        local coin = _data.info.coin[tp]

        -- 没有怎么扣除
        if not coin then
            return EC.PARAM_ERROR
        end

        if try then
            if coin.count >= cost then
                return EC.OK
            end

            -- 数量不足，无法扣除
            return EC.PARAM_ERROR
        end

        -- 先把统计走了
        _ctx.ctrl.analytics.set_by_cid(cline.aid_use, cost)

        _data.info.coin[tp].count = _data.info.coin[tp].count - cost

        return EC.OK
    end

    -- 是背包中物品(item,chip,incription)
    local bag_line = _conf['items.' .. tp]
    if bag_line then
        local own = _ctx.ctrl.bag.get_data(tp, param[2])
        if not own then
            return EC.PARAM_ERROR
        end

        if try then
            if own.count >= (tonumber(param[3]) or 0) then
                return EC.OK
            end
            -- 数量不足，无法扣除
            return EC.PARAM_ERROR
        end

        _ctx.ctrl.bag.dec(param)

        -- _ctx.ctrl.analytics.set_by_cid(string.format('%s_use', tp), tonumber(param[3]), param[2], param[2])
        return EC.OK
    end

    -- 是其他类型
    if tp == 'genius' then
        -- 天赋类型
        local code = _ctx.ctrl.genius.dec(param)
        return code
    elseif tp == 'equip' then
    end

    return EC.UNKNOWN_TYPE_ERROR
end

--[[
    解析奖励格式参数
    三种形式：
        二维数组
        奖励字符串
        单独传递
]]
function _private.parse_reward_param(...)
    local reward = {}

    -- 获取参数个数
    local len = select('#', ...)
    if len == 1 then
        -- 获取第一个参数
        local param = ...
        if type(param) == 'string' then
            local strArr = string.split(param, ';')
            for i, strs in ipairs(strArr) do
                reward[i] = string.split(strs, ':')
            end
        elseif type(param) == 'table' then
            -- 两层table
            if type(param[1]) == 'table' then
                -- 一层table
                reward = param
            elseif type(param[1]) == 'string' then
                reward = {param}
            end
        end
    elseif len > 1 then
        -- 构造一个二维数组
        reward = {{...}}
    end

    local copy = {}
    for k, v in pairs(reward) do
        copy[k] = {}

        -- 货币类型特殊处理，把3段式变成2段式
        if v[1] == 'coin' then
            copy[k] = {v[2], v[3]}
        else
            for k2, v2 in pairs(v) do
                copy[k][k2] = v2
            end
        end
    end

    return copy
end

--[[
    检查奖励格式：
    长度，类型
]]
function _private.check_reward_format(param)
    if type(param) ~= 'table' then
        return false
    end

    local tp = param[1]

    local cline = _conf['items.coin'][tp]
    -- 是货币
    if cline then
        return type(tonumber(param[2])) == 'number'
    else
        local conf = _conf['items.' .. tp]
        -- 属于物品分类
        if conf then
            return type(param[2]) == 'string' and type(tonumber(param[3])) == 'number'
        elseif tp == 'equip' then
            return true
        elseif tp == 'genius' then
            return true
        end
    end

    return false
end

----------------------------------框架相关----------------------------------

local function on_load()
    _ctx.log.i('on_load111')
    _ctx.ctrl.user = _public
end

local function on_register()
    -- _ctx.log.i("on_register")
    _ctx.register(NM.LOAD, _h_on_load_all)
    _ctx.register(NM.INIT_DATA, _h_init_data)
    _ctx.register(NM.CREATION_ROLE, _h_creation_role)
end

local function on_data(data)
    _data = data
end

local function on_command(pcid, command, param)
    _ctx.log.i('user on_command')

    if not command then
        return
    end

    local cfunc = _command[command]
    if type(cfunc) ~= 'function' then
        return
    end

    cfunc(pcid, param)
end

return {
    command = on_command,
    register = on_register, -- 模块消息注册
    load = on_load, -- 模块加载时调用
    unload = on_unload, -- 模块卸载时调用
    on_data = on_data
}
