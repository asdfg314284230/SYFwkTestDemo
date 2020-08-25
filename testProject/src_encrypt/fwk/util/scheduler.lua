--------------------------------------------------------------------------------------
-- 调度器
-- @module U.scheduler
-- @author liuyang
-- @date 2018-03-05

--------------------------------------------------------------------------------------

local scheduler = {}
-- local _task_list = {}
local _task_order_list = {}
local _uiid_2_tid = {}

local scheduler_mode = {
    ["limited"] = true,
    ["forever"] = true,
}
-- 任务id 保证任务唯一
local _task_id = 0
--------------------------------------------------------------------------------------
-- 获取任务id
-- @return 任务id
-- @local
function scheduler.get_task_id()
    _task_id = _task_id + 1
    return _task_id
end

--[[
    util.schedule.add_task(task)
    task = {
        func = function() end, 回调函数
        delay = 0, 延迟
        mode = "limited", forever:无限循环 limited:有限次数
        repeats = 1, 重复次数
        interval = 0，间隔
        uiid = uiid, 依赖ui 若设置,如果此ui被销毁，该任务将被自动移除
        
    }
    retuen tid
]]
function scheduler.add_task(task)
    local tid = scheduler.get_task_id()
    task.tid = tid
    task.func = task.func or function() end

    -- uiid
    if task.uiid then
        _uiid_2_tid[task.uiid] = _uiid_2_tid[task.uiid] or {}
        table.insert(_uiid_2_tid[task.uiid], tid)
    end

    -- 模式
    task.mode = task.mode or "limited"
    assert(scheduler_mode[task.mode], "no find mode " .. tostring(task.mode))

    -- 间隔
    task.interval = task.interval or 0
    task.cur_interval = 0

    -- 延时
    task.delay = task.delay or 0
    task.cur_delay = task.delay

    -- 重复次数
    task.repeats = task.repeats or 1
    task.cur_repeats = task.repeats

    task.dt = 0
    -- _task_list[tid] = task
    table.insert(_task_order_list, task)
    return tid
end

function scheduler.remove_task(tid)
    -- _task_list[tid] = nil
    local remove_index = nil
    for k, task in pairs(_task_order_list) do
        if task.tid == tid then
            remove_index = k
            break
        end
    end
    if remove_index then
        table.remove(_task_order_list, remove_index)
    end
end


function scheduler.update(dt)
    local remove_tab = {}
    for _, task in pairs(_task_order_list) do
        local tid = task.tid
        task.dt = task.dt + dt
        task.cur_delay = task.cur_delay - dt
        if task.cur_delay <= 0 then
            task.cur_interval = task.cur_interval - dt
            if task.cur_interval <= 0 then
                task.cur_interval = task.interval
                task.func(dt, task)
                task.dt = 0
                if task.mode ~= "forever" then
                    task.cur_repeats = task.cur_repeats - 1
                    if task.cur_repeats <= 0 then
                        table.insert(remove_tab, tid)
                    end
                end
            end
        end
    end

    for k, v in pairs(remove_tab) do
        -- _task_list[v] = nil
        scheduler.remove_task(v)
    end
end

function scheduler.remove_task_by_uiid(uiid)
    if uiid and _uiid_2_tid[uiid] then
        for k, v in pairs(_uiid_2_tid[uiid]) do
            scheduler.remove_task(v)
        end
        _uiid_2_tid[uiid] = nil
    end
end


-- 框架调用这个函数，函数的返回值为对外导出函数列表
return function (util)
    -- 用户接口
    util.schedule = scheduler
    return {
        update = scheduler.update
    }
end