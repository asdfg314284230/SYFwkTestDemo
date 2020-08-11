-- name, pb, nm_type, desc
--[[
    nm_type:SYSTEM(系统) COMMON（通用）
]]
local SYSTEM = 0

local COMMON = 200
local message = {
    {"PINE", "NULL", "SYSTEM", "PING", SYSTEM + 1},
    {"PUSH", "NULL", "SYSTEM", "请求推送", SYSTEM + 2},
    {"LOAD", "NULL", "INITDATA", "获取角色信息", COMMON + 1},
    {"CREATION_ROLE", "NULL", "COMMON", "创建角色", COMMON + 7},
    {"INIT_DATA", "NULL", "COMMON", "初始化消息", COMMON + 8},
    {"GMJSON", "NULL", "COMMON", "GM命令", COMMON + 9},
    {"GM", "GM", "COMMON", "GM命令", COMMON + 10},
    {"PUSH_TEST", "NULL", "COMMON", "推送测试", COMMON + 11},
}
return message
