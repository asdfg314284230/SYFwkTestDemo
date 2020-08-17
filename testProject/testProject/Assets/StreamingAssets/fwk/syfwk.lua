--------------------------------------------------------------------------------------
-- 框架入口文件
-- @module fwk
-- @author liuyang
-- @copyright liuyang 2019
-- @date 2019-01-24
-- @local
--------------------------------------------------------------------------------------
local fwk = {}
require "fwk.extend.extend"
local env = require "fwk.env"
local mnetwork = require "fwk.network.network"
local mmodel = require "fwk.model.model"
local mlogic = require "fwk.logic.logic"
local mmgr = require "fwk.mgr.mgr"
local util = require "fwk.util.util"     -- 工具类都放到U里面-- U.json U.xml U.handle U.call .......
-- local localserver 	= require "fwk.network.localserver"

-- short for util
U = util.util

C = {}   --配置表模块
-- LS = {}  --服务器模拟
-- N = {}   --网络模块
NM = {}  --消息定义模块
NMINFO = {} --消息定义模块
EC = {}  --错误代码
M = {}   --数据管理模块
L = {}   --逻辑控制模块
MGR = {}   --逻辑控制模块
UI = {}  --ui管理模块
Game = {}--游戏自定义数据
GU = {}   --游戏内自定义工具

_z__fwk = {}
-- 这里关闭全局变量
-- DISABLE Define Global Var
setmetatable(_G, {
	__newindex = function(_, name, value)
		error(string.format("DON'T DEFINE GLOBAL VARIABLE [%s]", tostring(name)), 2)
	end,
	__index = function (_, name)
		error(string.format("DON'T ACCESS NO DEFINED GLOBAL VARIABLE [%s]", tostring(name)), 2)
	end
})

local mconfig = require "fwk.config.config"
local mui = require "fwk.ui.ui"

local run_mode = nil
fwk.init = function(mode, cfg)
    run_mode = mode
    util.init(mode, cfg)
    C     = mconfig.init()
    -- N     = mnetwork.init(mode, cfg, mmodel)
    -- NM    = N.NM
    -- NMINFO= N.NMINFO
    -- EC    = N.EC
    M     = mmodel.init(mode, env.env["model"])
    L     = mlogic.init(mode, env.env["logic"])
    MGR   = mmgr.init(mode, env.env["mgr"])
    UI    = mui.init(mode, env.env["ui"])
    -- LS    = localserver.init(mode, env.env["ls"])
    env.init()
    -- 最后初始化
    util.late_init(mode, cfg)
    -- localserver.late_init()
end

-- 必须在初始化以后调用
-- 这里主要调用游戏逻辑
fwk.start = function ()
    -- 约定必须能require 到 game.game????
    local game = require ("game.game")    -- 一个函数，返回需要的信息
    local start, gu = game(run_mode)        -- 游戏开始入口，框架需要的一些配置参数
    Game.U = gu
    start(run_mode)
end

-- 更新回调
fwk.update = function (...)
    util.update(...)
    mui.event("update", ...)
    -- mnetwork.update(...)
    -- localserver.update(...)
end

_z__fwk = 
{
    _z__init = function (self, ...)
        fwk.init(...)
    end,

    _z__late_update = function (self, ...)
        --print(...)
        return fwk.update(...)
    end,

    _z__event = function (self, mod, ...)
        -- print(mod, ...)
        if mod == "ui" then
            mui.event(...)
        end
    end,
    _z__res_event = function (self, mod, ...)
        if mod == "res" then
            mui.res_destroy_event(...)
        end
    end,

    _z__start = function (self, ...)
        return fwk.start(...)
    end,

}
return fwk