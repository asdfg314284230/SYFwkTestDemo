--------------------------------------------------------------------------------------
-- MGR管理器
-- @module MGR
-- @author liuyang
-- @copyright liuyang 2019
-- @date 2019-02-28
--------------------------------------------------------------------------------------
local _env = nil
local mgr = {}
local _loaded = {}
local _index_mt = {
    __index = function (t, k)
        return mgr.load(k)
    end,
    __newindex = function(t, k, v)
        U.log(string.format("read only table k = [%s], v = [%s]", tostring(k), tostring(v)))
    end,
}

--------------------------------------------------------------------------------------
-- 初始化 框架调用
-- @param env mgr环境
-- @function L.init
function mgr.init(mode, env)
    _env = env
    local export = {
        -- 导出接口添加在这里

        -- 注销接口
        unload = mgr.unload,
        logout = mgr.logout,
    }
    return setmetatable(export, _index_mt)
end

--------------------------------------------------------------------------------------
--- 加载mgr
-- @param name mgr名
-- @return mgr或者nil
-- @local
function mgr.load(name)
    if type(name) ~= "string" then
        U.log(string.format("load mgr [%s] failed, string is needed but %s", tostring(name), type(name)))
        return nil
    end

    -- 缓存
    if _loaded[name] then
        return _loaded[name]
    end

    -- 加载
    local l_mgr = U.loader.load("game.mgr." .. name, _env)
    if not l_mgr then
        U.log(string.format("load mgr [%s] failed, mgr not found", tostring(name)))
        return nil
    end

    U.log(string.format("load mgr [%s] success", tostring(name)))

    _loaded[name] = l_mgr

    if type(l_mgr.on_load) == "function" then
        l_mgr:on_load()
    end

    return l_mgr
end

--------------------------------------------------------------------------------------
--- 卸载mgr
-- @param name mgr名
-- @local
function mgr.unload(name)
    if _loaded[name] then
        if type(_loaded[name].on_unload) == "function" then
            _loaded[name]:on_unload()
        end
        _loaded[name] = nil
    end
end

function mgr.unload_all()
    for name, _ in pairs(_loaded) do
        mgr.unload(name)
    end
end

--------------------------------------------------------------------------------------
-- 注销接口
-- @function L.logout
function mgr.logout()
    mgr.unload_all()
end


return {
    init = mgr.init,
}