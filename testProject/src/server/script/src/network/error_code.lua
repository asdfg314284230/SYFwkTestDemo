--------------------------------------------------------------------------------------
-- author liuyang
-- data 2017-05-11
-- copyright 2017 -- 2017 liuyang
-- desc  错误代码
--------------------------------------------------------------------------------------

local ERROR_CODE_AUTH = 100
local ERROR_CODE_PAY = 200
local ERROR_CODE_BASE = 10000
local _M = {
    OK = {id = 0, dec = "正常"}, -- 正常返回码
    AUTH_ACCOUNT_DUPLICATE = {
        id = ERROR_CODE_AUTH + 0,
        dec = "帐号已经存在"
    },
    AUTH_ACCOUNT_PASSWORD_WRONG = {
        id = ERROR_CODE_AUTH + 1,
        dec = "帐号或密码错误"
    },
    AUTH_TOKEN_INVALID = {
        id = ERROR_CODE_AUTH + 2,
        dec = "TOKEN 失效" --使用帐号密码在其他设备登录，token会失效
    },
    AUTH_INTERNAL_ERROR = {
        id = ERROR_CODE_AUTH + 3,
        dec = "验证模块内部错误" -- 这个错误比较欠揍
    },
    AUTH_NO_ACCOUNT = {
        id = ERROR_CODE_AUTH + 4,
        dec = "帐号不存在"
    },
    AUTH_ACCOUNT_ALREADY_MEMBER = {
        id = ERROR_CODE_AUTH + 5,
        dec = "已经是正式用户"
    },
    INTERNAL_SERVER_LUA = {
        id = 998998,
        dec = "Lua 语法错误"
    },
    INTERNAL_SERVER_UNAVAILABLE = {
        id = ERROR_CODE_AUTH + 6,
        dec = "SERVER UNAVAILABLE 连接服务器失败"
    },
    PAY_ORDER_NOT_EXIST = {
        id = ERROR_CODE_PAY + 1,
        dec = "订单不存在"
    },
    PAY_ORDER_STATUS_WRONG = {
        id = ERROR_CODE_PAY + 2,
        dec = "订单状态错误"
    },
    INTERNAL_UNREGISTER_MSG = {
        id = 1000,
        dec = "发送了未注册消息"
    },
    ------------------------base-------------------------------
    PARAM_ERROR = {id = ERROR_CODE_BASE + 1, dec = "参数错误"}, --参数错误
    CONF_ERROR = {id = ERROR_CODE_BASE + 2, dec = "配置不存在"}, --配置不存在
    UNKNOWN_TYPE_ERROR = {id = ERROR_CODE_BASE + 3, dec = "未知类型"},
    REWARD_FORMAT_ERROR = {id = ERROR_CODE_BASE + 4, dec = "奖励格式错误"},
    INVALID_CMD = {id = ERROR_CODE_BASE + 5, dec = "无效的GM cmd命令"},
    INVALID_GM_PARAM = {id = ERROR_CODE_BASE + 6, dec = "无效的GM 参数"},
    -------------------------------------------公用-------------------------------------------
}

-- TODO :检查一下，是否有ID定义重复了
local function _check()
    local index = {}
    for _, v in pairs(_M) do
        if index[v.id] ~= nil then
            error("")
        end
        index[v.id] = true
    end
end
_check()

local result = {}
local id_to_desc = {}
for k, v in pairs(_M) do
    result[k] = v.id
    id_to_desc[tostring(v.id)] = v.dec
    if (not v.id) or (not v.dec) then
        print("====================id或者描述未定义 ", tostring(v.id), tostring(v.dec))
    end
end

function result:toString(id)
    return id_to_desc[tostring(id)] or "未定义错误码" .. tostring(id)
end

return result
