--------------------------------------------------------------------------------------
-- Logic管理器
-- @module L
-- @author liuyang
-- @copyright liuyang 2019
-- @date 2019-02-28
--------------------------------------------------------------------------------------
local _env = nil
local logic = {}
local _loaded = {}
local _index_mt = {
    __index = function (t, k)
        return logic.load(k)
    end,
    __newindex = function(t, k, v)
        U.log(string.format("read only table k = [%s], v = [%s]", tostring(k), tostring(v)))
    end,
}

--------------------------------------------------------------------------------------
-- 初始化 框架调用
-- @param env logic环境
-- @function L.init
function logic.init(mode, env)
    _env = env
    local export = {
        -- 导出接口添加在这里

        -- 注销接口
        logout = logic.logout,
    }
    return setmetatable(export, _index_mt)
end

--------------------------------------------------------------------------------------
--- 加载logic
-- @param name logic名
-- @return logic或者nil
-- @local
function logic.load(name)
    if type(name) ~= "string" then
        U.log(string.format("load logic [%s] failed, string is needed but %s", tostring(name), type(name)))
        return nil
    end

    -- 缓存
    if _loaded[name] then
        return _loaded[name]
    end

    -- 加载
    local lgc = U.loader.load("game.logic." .. name, _env)
    if not lgc then
        U.log(string.format("load logic [%s] failed, logic not found", tostring(name)))
        return nil
    end

    -- U.log(string.format("load logic [%s] success", tostring(name)))

    _loaded[name] = lgc

    if type(lgc.on_load) == "function" then
        lgc:on_load()
    end

    return lgc
end

--------------------------------------------------------------------------------------
--- 卸载logic
-- @param name logic名
-- @local
function logic.unload(name)
    if _loaded[name] then
        if type(_loaded[name].on_unload) == "function" then
            _loaded[name]:on_unload()
        end
        _loaded[name] = nil
    end
end

function logic.unload_all()
    for name, _ in pairs(_loaded) do
        logic.unload(name)
    end
end

--------------------------------------------------------------------------------------
-- 注销接口
-- @function L.logout
function logic.logout()
    logic.unload_all()
end

return {
    init = logic.init
}