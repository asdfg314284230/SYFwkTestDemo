
--------------------------------------------------------------------------------------
-- 工具类
-- @module U
-- @author Yang Zhang
-- @copyright yang zhang 2018
-- @date 2018-03-15
-- @local
--------------------------------------------------------------------------------------
local util = {}

local mod = {}
local list = {"loader", "handle", "log", "sensitivity", "scheduler", "http"}
for _, mn in ipairs(list) do 
    mod[mn] = require("fwk.util." .. mn)(util)
end

local _method_list = {"init", "late_init", "update"}
local _method = {}

for _, name in ipairs(_method_list) do 
    _method[name] = function (...)
        for _, mn in ipairs(list) do 
            if mod[mn] and mod[mn][name] then
                mod[mn][name](...)
            end
        end 
    end
end

util.json = require "json"
-- util.json = require "fwk.lib.json"
_method.util = util
return _method
