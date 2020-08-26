local loader = {}

local _impl_dev = {}
local _impl_editor = {}
local _impl_runtime = {}

-- these must match with C# LuaLoader
loader.MODE_FWK  = 1
loader.MODE_DEV  = 2
loader.MODE_EDIT = 3
loader.MODE_RUN  = 4
loader.run_mode  = loader.MODE_RUN

local _root = nil
local _mode = nil

-- function _impl_dev.load(name, env)
--     assert(_root)
--     local fun, err = loadfile(_root.. string.gsub(name, "%.", "/") .. ".lua", "bt", env)
--     if not fun then
--         -- if _mode == loader.MODE_DEV then       -- 开发模式下，部分代码在pkg中
--         --     return _do_pkg_load(name, env, err)
--         -- end
--         print(err)
--         return nil, err
--     end
--     return fun()
-- end

-- function _impl_editor.load(name, env)
--     assert(_root)
--     local tab = string.split(name, ".")
--     if tab[1] == "config" then
--         local fun, err = loadfile(_root.. string.gsub(name, "%.", "/") .. ".lua", "bt", env)
--         if not fun then
--             print(err)
--             return nil, err
--         end
--         return fun()
--     else
--         local fun = CS.SYFwk.Core.LuaLoader.loadstring(_root.. string.gsub(name, "%.", "/") .. ".lua", env)
--         if not fun then
--             local err = tostring(_root.. string.gsub(name, "%.", "/") .. ".lua") .. " load fail"
--             print(err)
--             return nil, err
--         end
--         return fun()
--     end

-- end


-- function _impl_runtime.load(name, env)
--     assert(_root)
--     -- local fun, err = loadfile(_root.. string.gsub(name, "%.", "/") .. ".lua", "bt", env)
--     local fun = CS.SYFwk.Core.LuaLoader.loadstring(_root.. string.gsub(name, "%.", "/") .. ".lua", env)
--     if not fun then
--         -- if _mode == loader.MODE_DEV then       -- 开发模式下，部分代码在pkg中
--         --     return _do_pkg_load(name, env, err)
--         -- end
--         local err = tostring(_root.. string.gsub(name, "%.", "/") .. ".lua") .. " load fail"
--         print(err)
--         return nil, err
--     end
--     return fun()
-- end

-- 根据参数，设置成从路径加载，还是从压缩包中加载。
local late_init = function (mode, cfg)
    _root = cfg.root
    _mode = cfg.mode
    if mode == "unity" then
        -- if cfg.mode == loader.MODE_RUN then
        --     loader.load = _impl_runtime.load
        -- elseif cfg.mode == loader.MODE_EDIT then
        --     loader.load = _impl_editor.load
        -- else
        --     loader.load = _impl_dev.load
        -- end
        loader.load = function(name, env)
            local fun = CS.SYFwk.Core.LuaLoader.loadstring(string.gsub(name, "%.", "/") .. ".lua", env)
            if not fun then
                local err = tostring(string.gsub(name, "%.", "/") .. ".lua") .. " load fail"
                print(err)
                return nil, err
            end
            return fun()
        end
    end
end

local function init (mode, cfg)
    loader.mode = cfg.mode
end


-- 框架调用这个函数，函数的返回值为对外导出函数列表
return function (util)
    util.loader = loader
    return {
        init = init,
        late_init = late_init,       -- 这里late初始化，是因为不想让框架启动完毕前，使用load功能
    }
end