--------------------------------------------------------------------------------------
-- 配置管理器
-- @module C
-- @author zhixiu fang
-- @copyright zhixiu fang 2018
-- @date 2018-03-26
-- @usage
-- -- 配置结构：
-- -- config
-- --     item.lua
-- --     girl
-- --         girl01.lua
-- --         girl02.lua
--  -- 获取道具配置 位于config根目录
--  local itemCfg = C["item"]
--  -- 获取角色配置 位于config子目录
--  local girlCfg = C["girl.girl01"]

--------------------------------------------------------------------------------------

local config = {}

-- 保存加载过的配置表和版本信息
local _loaded = {}

local _index_mt = {
    __index = function(t, k)
        return config.load(k)
    end,
    __newindex = function(t, k, v)
        U.log.w(string.format("read only table k = [%s], v = [%s]", tostring(k), tostring(v)))
    end,
}

--------------------------------------------------------------------------------------
--- 初始化 框架调用
-- @function C.init
function config.init()
    config.load_all()
    local export = {
        -- 导出接口添加在这里
    }
    return setmetatable(export, _index_mt)
end

--------------------------------------------------------------------------------------
--- 获取配置
-- @param path 相对路径
-- @return 配置表或者nil
-- @local
function config.load(path)
    if type(path) ~= "string" then
        return
    end

    local version  = config.version()
    local loadInfo = _loaded[path]
    -- 已经加载
    if loadInfo then
        -- 版本不符，重新加载
        if loadInfo.version ~= version then
            config.unload(path)
            return config.do_load(path, version)
        -- 版本符合，直接返回
        else
            return loadInfo.config
        end
    -- 未加载，加载对应版本配置
    else
        return config.do_load(path, version)
    end
end

--------------------------------------------------------------------------------------
-- 预加载配置
-- @local
function config.load_all()
    -- TODO：
end

--------------------------------------------------------------------------------------
-- 获取当前配置版本号
-- @local
function config.version()
    -- TODO: 获取配置版本
    return "1.0.0"
end

--------------------------------------------------------------------------------------
-- 加载指定配置
-- @param path 配置路径
-- @param version 配置版本号
-- @local
function config.do_load(path, version)
    
    -- TODO: 加载对应版本的配置 不同版本的配置 路径可能不一样
    local config = U.loader.load("config." .. path)
    if not config then
        U.log.w(string.format("config [%s] load failed, config not found!", tostring(path)))
        return
    end

    -- 保存加载信息
    _loaded[path] = {version = version, config = config}

    return config
end

--------------------------------------------------------------------------------------
-- 卸载指定配置
-- @param path 配置路径
-- @local
function config.unload(path)
    _loaded[path] = nil
end

return {
    init = config.init
}