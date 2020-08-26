--------------------------------工具类,对一些接口的二次封装-------------------

local tools = {}
local GameObject = CS.UnityEngine.GameObject
--[[[
    @des:实例化游戏物体工具
        @model: 源gamobject
            @parent:父节点
                @count:实例化的个数
                    @activate:是否在Hierarchy显示
                        @nama_suffix:名字前缀
                            @start_index:开始实例化时的下标索引
                                @return:返回所有实例化gameobjtable
]]
function tools.ins_factory(model, parent, count, activate, name_suffix, start_index)
    --返回实例化后得所有数据
    local ret_obj = {}
    local parent_ = parent.transform
    local name = name_suffix or "clone"
    local name_index = start_index or 0
    local activate_ = activate or true
    for i = 1, count do
        local obj = GameObject.Instantiate(model, parent_, false).gameObject
        obj:SetActive(activate_)
        obj.name = name .. (i + name_index)
        table.insert(ret_obj, obj)
    end
    return ret_obj
end

--[[
    把时间戳转换成小时、分钟、秒
]]
function tools.get_time_string(time)
    time = math.floor(time)
    if time < 0 then
        time = 0
    end

    local hour = math.floor(time / 60 / 60)
    local min = math.floor(time / 60) % 60
    local second = math.ceil(time) % 60

    local time_str = {}
    time_str.hour = hour
    time_str.min = min
    time_str.second = second

    return time_str
end

local TWEEN_TIME = 0.35
--[[
    方向轴
]]
tools.AXIS = {
    X = "x",
    Y = "y",
    Z = "z"
}

local TWEEN_AXIS_HANDLE = {
    x = UI.CS.LeanTween.moveLocalX,
    y = UI.CS.LeanTween.moveLocalY
}
--[[
    设置某个轴的位置
]]
function tools.set_trans_axis_pos(trans, axis, offset)
    local trans_ = trans.transform
    local x = trans_.localPosition.x
    local y = trans_.localPosition.y
    local z = trans_.localPosition.z
    local temp = {x = x, y = y, z = z}
    temp[axis] = offset
    trans_.localPosition = UI.CS.Vector3(temp.x, temp.y, temp.z)
end

--[[
    物体沿着某个轴做tween动画
    @param obj 目标物体
    @param axis 动画轴
    @param target 目标点
    @param duration 持续时长
    @param delay 延时
    @param complete 完成回掉
    @param easeType 动画曲线类型
]]
function tools.tween_move_axis(obj, axis, target, duration, delay, complete, ease_type)
    local obj_ = obj.gameObject
    UI.CS.LeanTween.cancel(obj_)
    local duration_ = duration or TWEEN_TIME
    local delay_ = delay or 0
    local complete_ = complete or nil
    local ease_type_ = ease_type or UI.CS.LeanTweenType.easeOutCubic
    local handle = TWEEN_AXIS_HANDLE[axis](obj_, target, duration_):setDelay(delay_):setEase(ease_type_)
    if complete_ then
        handle:setOnComplete(complete_)
    end
    return handle.id
end

function tools.tween_move_alpha(obj, axis, target, canvas_group, alpha, duration, delay, complete, ease_type)
    local obj_ = obj.gameObject
    UI.CS.LeanTween.cancel(obj_)
    local duration_ = duration or TWEEN_TIME
    local delay_ = delay or 0
    local complete_ = complete or nil
    local ease_type_ = ease_type or UI.CS.LeanTweenType.easeOutCubic
    local handle = TWEEN_AXIS_HANDLE[axis](obj_, target, duration_):setDelay(delay_):setEase(ease_type_)
    local alpha_ = alpha or 1
    UI.CS.LeanTween.alphaCanvas(canvas_group, alpha_, duration_):setDelay(duration_ * 0.8):setEase(ease_type_)
    if complete_ then
        handle:setOnComplete(complete_)
    end
    return handle.id
end

function tools.tween_move(obj, target, duration, delay, complete, ease_type)
    local obj_ = obj.gameObject
    UI.CS.LeanTween.cancel(obj_)
    local duration_ = duration or TWEEN_TIME
    local delay_ = delay or 0
    local complete_ = complete or nil
    local ease_type_ = ease_type or UI.CS.LeanTweenType.easeOutCubic
    local handle = UI.CS.LeanTween.move(obj_, target, duration_):setDelay(delay_):setEase(ease_type_)
    if complete_ then
        handle:setOnComplete(complete_)
    end
    return handle.id
end

function tools.tween_scale(obj, size, duration, delay, complete, ease_type)
    local obj_ = obj.gameObject
    UI.CS.LeanTween.cancel(obj_)
    local size_ = size or 1
    local duration_ = duration or TWEEN_TIME
    local delay_ = delay or 0
    local complete_ = complete or nil
    local ease_type_ = ease_type or UI.CS.LeanTweenType.easeOutCubic
    local handle = UI.CS.LeanTween.scale(obj_, size, duration_):setDelay(delay_):setEase(ease_type_)
    if complete_ then
        handle:setOnComplete(complete_)
    end
    return handle.id
end

local tips_isinit = false
--[[
    @param 格式要求: style参数是是具体的tips样式,默认是normal类型
    {
        style="normal",
        des="blabla...."
    }
]]
function tools.tips_sys(param)
    if tips_isinit then
        if param then
            UI.send_command_by_name("TipsSys.TipsMgr", {command = "push_tips", param = param})
        end
    else
        tips_isinit = true
        UI.load({name = "TipsSys.TipsMgr"}, param)
    end
end

--导航条统一管理接口
--[[
    @behaviourName: ui脚本名字
]]
function tools.actionbar(behaviourName)
    if type(behaviourName) ~= "string" then
        return
    end

    local cconf = C["actionbar"]
    if not cconf then
        return
    end

    local cline = cconf[behaviourName]
    if not cline then
        cline = cconf["default"]
    end

    if cline.show ~= 1 then
        return
    end
    return cline
end

local army_type = {
    "hero_train",
    "slodier_train"
}
--[[
    获取英雄或者士兵的一个实例
    @param a_type:实例类型1是英雄2是士兵
    @param config:实例配置参数
]]
function tools.new_ins_army(a_type, config)
    if not a_type then
        return
    end
    return M[army_type[a_type]]:new_ins_army(config)
end

function tools.write_file(path, d)
    local file = io.open(path, "a")
    file:write(d)
    file:close()
end

-- 检测是key传值还是reward传值
function tools.parse_table_param(p)
    local reward = {}
    if not p then 
        return reward 
    end
    if p.cid and p.type then
        reward[1] = p.type
        reward[2] = p.cid
        if p.count then
            reward[3] = tonumber(p.count)
        end
    else
        reward = p
    end
    return reward
end

-- reward解析类
function tools.parse_reward_param(...)
    local reward = {}

    -- 获取参数个数
    local len = select("#", ...)

    if len == 1 then
        -- 获取第一个参数
        local param = ...
        if type(param) == "string" then
            local strArr = string.split(param, ";")
            for i, strs in ipairs(strArr) do
                reward[i] = string.split(strs, ":")
            end
        elseif type(param) == "table" then
            -- 两层table
            if type(param[1]) == "table" then
                -- 一层table
                reward = param
            elseif type(param[1]) == "string" then
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

        for k2, v2 in pairs(v) do
            copy[k][k2] = v2
        end
    end

    return copy
end

local core = require "socket.core"
function tools.get_precise_time()
    return core.gettime()
end
return tools
