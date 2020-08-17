--------------------------------------------------------------------------------------
-- 服务器行为模拟模块
-- @author liuyang
-- @date 2019-03-01
--------------------------------------------------------------------------------------
local _M = {}
local _env = nil
local load_list = {}
local message_list = {}
local server_data = {}
local temp_server_data = {}

local all_data_logic_list = {
    gm = true,
}

local queue = {}
local handle_time = 0.5
local cur_handle_time = handle_time
function _M.send(session_id, mn, md, ud, flag, handle)
    table.insert(queue, function()
        local stateCode = nil
        local message = nil
        if message_list[mn.name] then
            local status, err = pcall(function()
                stateCode, message = message_list[mn.name](md)
            end)
        end

        if stateCode ~= 0 then
            temp_server_data = server_data
        else
            server_data = temp_server_data
        end
        handle.localserver_handel(session_id, mn, stateCode, message, server_data)
    end)
end

function _M.register(msg, func)
    assert(type(msg) == "table", "message define must table")
    assert(type(msg.name) == "string", "msg.name define must string")
    assert(type(func) == "function", "func define must function")
    message_list[msg.name] = func
end

local function init(mode, env)
    _env = env
    return _M
end

local function late_init()
    local load_list = U.loader.load("game.localserver.load_list", _env)
    for k, v in pairs(load_list.logic or {}) do
        local mod = U.loader.load("game.localserver.logic." .. v, _env)
        local data
        if all_data_logic_list[v] then
            data = temp_server_data or {}
        else
            temp_server_data[v] = temp_server_data[v] or {}
            data = temp_server_data[v]
        end

        mod.on_load({
            ctx = LS,
            data = data
        })
        
        mod.on_register()
    end
end

local function update(dt)
    if #queue > 0 then
        cur_handle_time = cur_handle_time - dt
        if cur_handle_time <= 0 then
            local func = table.remove(queue, 1)
            func()
            cur_handle_time = handle_time
        end
    end
end

return {
    init = init,
    late_init = late_init,
    update = update
}