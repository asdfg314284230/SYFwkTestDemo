--------------------------------------------------------------------------------------
-- Model管理器
-- @module M
-- @author liuyang
-- @copyright liuyang 2019
-- @date 2019-02-28
--------------------------------------------------------------------------------------
local socket = require "socket.core"
-- model环境 每个model都在该环境下加载
local _env = nil
local model = {}
-- 游戏数据
local _data = {}
-- 缓存加载过的model
local _loaded = {}
local offset_time = 0
local offset_precise_time = 0
-- 数据改变监听器
local _modify_listener = {}

-- 本地数据
local _local_data = {}
-- 运行时数据
local _data_runtime = {}
-- 存储本地数据使用的key值
local _data_key = "_private_wawa_local_storage_"

local function _default_newindex(t, k, v)
    U.log.w(string.format("read only table k = [%s], v = [%s]", tostring(k), tostring(v)))
end

local _index_mt = {
    __index = function (t, k)
        return model.load(k)
    end,
    __newindex = _default_newindex,
}

--------------------------------------------------------------------------------------
-- 初始化 框架调用
-- @param env model环境
-- @function M.init
function model.init(mode, env)
    _env = env
    local export = {
        -- -- 导出接口添加在这里
        -- -- 运行时数据
        rtdata = _data_runtime,
        
        -- 注销接口
        logout = model.logout,

        -- -- 自定义pairs
        -- mipairs = _is_read_only and model.mipairs or ipairs,
        -- mpairs = _is_read_only and model.mpairs or pairs,

        -- add_modify_listener = model.add_modify_listener,
        -- remove_modify_listener = model.remove_modify_listener,
        clear_local_data = model.clear,
        set_local_data = model.set_local_data,
        get_local_data = model.get_local_data,
        get_server_time = model.get_server_time,
        get_precise_server_time = model.get_precise_server_time,
        unload = model.unload,
        add_modify_listener = model.add_modify_listener,
        remove_modify_listener = model.remove_modify_listener,
    }
    -- 加载本地数据
    model.load_local_data()
    return setmetatable(export, _index_mt)
end

--------------------------------------------------------------------------------------
--- 加载model
-- @param name 模块名
-- @return 模块或者nil
-- @local
function model.load(name)
    if type(name) ~= "string" then
        U.log.w(string.format("load model [%s] failed, string is needed but %s", tostring(name), type(name)))
        return
    end

    -- 缓存
    if _loaded[name] then
        return _loaded[name]
    end

    -- 加载
    local mod = U.loader.load("game.model." .. name, _env)
    if type(mod) ~= "table" then
        U.log.w(string.format("load model [%s] failed, model not found", name))
        return
    end

    -- 模块对应数据 data是_data别名 通过M.mod.data访问
    mod._data = _data[name]
    mod.data = mod._data



    _loaded[name] = mod
    -- U.log(string.format("load model [%s] success", name))

    -- 回调
    if type(mod.on_load) == "function" then
        mod:on_load()
    end

    return _loaded[name]
end

function model.unload(name)
    if _loaded[name] then
        if type(_loaded[name].on_unload) == "function" then
            _loaded[name]:on_unload()
        end
        _loaded[name] = nil
    end
end

--------------------------------------------------------------------------------------
-- 卸载所有模块
-- @local
function model.unload_all()
    -- 清除缓存
    for k, _ in pairs(_loaded) do
        model.unload(k)
    end
    -- 清除数据
    _data = {}
end

--------------------------------------------------------------------------------------
-- 注销接口
-- @function M.logout
-- @param clear 是否清除本地aid 这个时候需要重新登录
function model.logout(clear)
    model.unload_all()
    -- 清除运行时数据
    for k, _ in pairs(_data_runtime) do
        _data_runtime[k] = nil
    end
    model.remove_all_modify_listener()
    if clear then
        model.set_local_data("aid", nil)
    end
end

function model.get_data()
    return _data
end


function model.reset_data(data)
    _data = data
end

function model.update_data(op_list, session_data)
    op_list = op_list or {}

    for i = 1, #op_list do
        local k, v = i, op_list[i]
        local value_type = v.value_type
        local value = v.value
        local keys = string.split(v.key, ".")
        local len = #keys
        local temp_tab = _data
        
        

        for i = 2, len - 1 do
            local k = keys[i]
            if not temp_tab[k] then
                temp_tab[k] = {}
            end
            temp_tab = temp_tab[k]
        end

        local oldValue = temp_tab[keys[#keys]]
        
        if value == "inner_remove" then
            temp_tab[keys[#keys]] = nil
        elseif value_type == "number" then
            temp_tab[keys[#keys]] = tonumber(value)
        elseif value_type == "json" then
            temp_tab[keys[#keys]] = U.json.decode(value)
        elseif value_type == "string" then
            temp_tab[keys[#keys]] = tostring(value)
        elseif value_type == "boolean" then
            if value == "false" then
                temp_tab[keys[#keys]] = false
            elseif value == "true" then
                temp_tab[keys[#keys]] = true
            else
                error("type error")
            end
        else
            error("unknow value_type:" .. tostring(value_type))
        end

        local newValue = temp_tab[keys[#keys]]

        model.dispatch_modify(v.key, oldValue, newValue, session_data)
    end
    
    -- U.log.dump(_data)
end


function model.get_server_time()
    return os.time() + offset_time
end

function model.set_offset_time(t)
    offset_time = t or 0
end

function model.get_precise_server_time()
    return socket.gettime() + offset_precise_time
end

function model.set_offset_precise_time(t)
    offset_precise_time = t or 0
end



--------------------------------------------------------------------------------------
-- 监听数据改变
-- @function M.add_modify_listener
-- @param chain 监听的数据段 支持点分
-- @param listener 监听器
-- @return handle
-- @usage
--  -- 监听整个模块数据
--  M.add_modify_listener("mod", function()
--      U.log.mdump(M.mod.data)
--  end)
--  -- 监听模块下字段数据
--  M.add_modify_listener("mod.submod.field", function()
--      print(M.mod.data.submod.field)
--  end)
function model.add_modify_listener(chain, listener)
    _modify_listener[chain] = _modify_listener[chain] or {}
    local listeners = _modify_listener[chain]
    if not listeners[listener] then
        -- U.log.d(string.format("model add_modify_listener chain %s", chain))
        listeners[listener] = true
    end
    return listener
end

--------------------------------------------------------------------------------------
-- 取消监听数据改变
-- @function M.remove_modify_listener
-- @param chain 监听的数据段 支持点分
-- @param handle add_modify_listener返回值
-- @return 是否成功取消
function model.remove_modify_listener(chain, handle)
    local listeners = _modify_listener[chain]
    if listeners and listeners[handle] then
        -- U.log.d(string.format("model remove_modify_listener chain %s", chain))
        listeners[handle] = nil
        return true
    else
        U.log.w(string.format("model remove_modify_listener no chain or no handle, chain %s", chain))
        return false
    end
end

--------------------------------------------------------------------------------------
-- 移除所有数据改变监听器
-- @local
function model.remove_all_modify_listener()
    -- 清除modify listener
    for k, _ in pairs(_modify_listener) do
        _modify_listener[k] = nil
    end
end

--------------------------------------------------------------------------------------
-- 派发数据改变消息
-- @local
function model.dispatch_modify(chain, oldValue, newValue, flag)
    local strs = string.split(chain, ".")
    local chains = {}
    for i, v in ipairs(strs) do
        if i == 1 then
            chains[i] = v
        else
            chains[i] = chains[i - 1] .. "." .. v
        end
    end

    for _, _chain in ipairs(chains) do
        -- U.log.d(string.format("model dispatch_modify chain %s", _chain))
        local listeners = _modify_listener[_chain]
        if listeners then
            for _listener, _ in pairs(listeners) do
                _listener(oldValue, newValue, flag, chain)
            end
        end
    end
end
--------------------------------------------------------------------------------------
-- ****************************** 本地存储接口 ****************************************
--------------------------------------------------------------------------------------


--------------------------------------------------------------------------------------
-- 获取本地存储字段
-- @param key 需要获取的key
-- @return key对应的值
-- @function M.get_local_data
-- @see set_local_data
-- @usage
--  local info = M.get_local_data("info")
--  U.log.dump(info)
--  info.password = "111111"
--  M.set_local_data("info", info)
function model.get_local_data(key)
    local ret = _local_data[key]
    if type(ret) == "table" then
        return table.copy(ret)
    else
        return ret
    end
end

--------------------------------------------------------------------------------------
-- 设置本地存储字段
-- @param key 需要获取的key
-- @param value 需要存储的值
-- @function M.set_local_data
-- @see get_local_data
-- @usage
--  local tmp = "test"
--  local info = {username = "username", password = "123456"}
--  M.set_local_data("tmp", tmp)
--  M.set_local_data("info", info)
function model.set_local_data(key, value)
    if type(value) == "table" then
        value = table.copy(value)
    end
    _local_data[key] = value
    model.save()
end



--------------------------------------------------------------------------------------
-- 设置本地存储字段
-- @local
function model.load_local_data()
    local dataStr = CS.UnityEngine.PlayerPrefs.GetString(_data_key)
    if dataStr and dataStr ~= "" then
        _local_data = U.json.decode(dataStr)
    else
        U.log("no local data")
	end
end
--------------------------------------------------------------------------------------
-- 保存本地数据
-- @local
function model.save()
	CS.UnityEngine.PlayerPrefs.SetString(_data_key, U.json.encode(_local_data))
end

--------------------------------------------------------------------------------------
-- 清除本地数据
-- @local
function model.clear()
	CS.UnityEngine.PlayerPrefs.DeleteKey(_data_key)
end

return {
    init = model.init,
    reset_data = model.reset_data,
    update_data = model.update_data,
    set_offset_time = model.set_offset_time,
    set_offset_precise_time = model.set_offset_precise_time,
}