--------------------------------------------------------------------------------------
-- author liuyang
-- date 2019-01-24
-- desc UI 基础模块
--------------------------------------------------------------------------------------

local MOD = {}          -- 供框架使用的 放入这里
local UI = {}           -- 供用户调用的接口放入这里
local mod = nil

function MOD.init(mode, env)
    print("init ui with mode ", mode)
    if mode == "unity" then
        mod = require("fwk.ui.unity_impl")
    end

    if mod then
        mod.init(env)
        setmetatable(UI, {__index = mod.impl})
        setmetatable(MOD, {__index = mod})
    end
    
    return UI
end

    -- 这个函数暂时想到的作用 
    -- 1.给用户编写的UI添加一些额外通用的属性或者方法
    -- 2.检查用户定义的UI是否符合规范
function UI.export(def)        
    if not def.get_ui_id then
        def.get_ui_id = function()
            return def._base_data._ui_id
        end
    end

    if not def.on_navigate then
        def.on_navigate = function()
            UI.go_last_base()
        end
    end
    mod.export(def)

    return def
end

--------------------------------------------------------------------------------------
-- 获取UI运行需要的env
function MOD.env()
    return _env
end



return MOD