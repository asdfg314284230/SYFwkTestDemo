--------------------------------------------------------------------------------------
-- 模块环境
-- 为了方便修改，这些单独放入一个文件中，没有放入各个组件模块中
-- @module flz.env
-- @author liuyang
-- @date 2019-01-24
-- @local
--------------------------------------------------------------------------------------

---
-- @table evn
local env = {}

-- 通用, 所有模块共享
env.common = {
    print = print,
    math = math,
    type = type,
    table = table,
    string = string,
    pairs = pairs,
    ipairs = ipairs,
    tostring = tostring,
    tonumber = tonumber,
    os = os,
    io = io,
    debug = debug,
    pcall = pcall,
}
setmetatable(env.common, {
    __index = function (obj, key)
        error(string.format("DON'T ACCESS NO DEFINED GLOBAL VALUE %s", tostring(key)), 2)
    end,
})
-- UI模块
env.ui = {}
--
env.model = {}
--
env.logic = {}

env.mgr = {}

env.ls = {}

local _mt_common = {
    __index = env.common,
    __newindex = function (obj, key, value)
        error(string.format("DON'T DEFINE GLOBAL VALUE %s", tostring(key)), 2)
    end,
}

-- 这里会延后调用，require这个模块时，部分全局变量还没有赋值
local function init()
    env.common.U    = assert(U)
    env.common.GU    = assert(GU)
    env.common.Game = assert(Game)

    env.mgr.UI = assert(UI)
    env.mgr.M = assert(M)
    env.mgr.MGR = assert(MGR)
    env.mgr.C = assert(C)
    env.mgr.L = assert(L)

    env.logic.UI       = assert(UI)
    env.logic.N = assert(N)
    env.logic.NM = assert(NM)
    env.logic.M = assert(M)
    env.logic.C = assert(C)
    env.logic.MGR        = assert(MGR)

    env.ui.UI       = assert(UI)
    env.ui.M        = assert(M)
    env.ui.C       = assert(C)
    env.ui.L        = assert(L)
    env.ui.MGR        = assert(MGR)
    env.ui.N        = assert(N)

    env.model.C       = assert(C)
    env.model.M       = assert(M)
    -- env.model.UI       = assert(UI)
    -- env.ui.NM        = assert(NM)
    -- env.ls.LS       = assert(LS)
    -- env.ls.NM       = assert(NM)
    -- env.ls.M       = assert(M)
    
    setmetatable(env.ui,    _mt_common)
    setmetatable(env.model, _mt_common)
    setmetatable(env.logic, _mt_common)
    setmetatable(env.mgr, _mt_common)
    -- setmetatable(env.ls, _mt_common)
    
end

return {
    init = init,
    env = env,
}