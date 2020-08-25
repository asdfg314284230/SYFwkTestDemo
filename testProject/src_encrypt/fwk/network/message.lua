--------------------------------------------------------------------------------------
-- 消息定义
-- @module NM
-- @author liuyang
-- @date 2019-02-28
--------------------------------------------------------------------------------------
-- local msg = require("ga")
local NM = {}
local NMINFO = {}
local EC = {}
local index = 0
function define(name, pb, nm_type, desc, index)
    assert(type(name) == "string", "message define name must string")
    assert(type(pb) == "string", "message define desc must string")
    assert(type(nm_type) == "string", "message define desc must string")
    assert(type(desc) == "string", "message define desc must string")
    assert(type(index) == "number", "message define desc must number")
    assert(not NM[name], tostring(name) .. " is defined")

    NM[name] = {
        id = index,
        name = name,
        pb = pb,
        nm_type = nm_type,
        desc = desc,
    }

    NMINFO[index] = {
        id = index,
        name = name,
        pb = pb,
        nm_type = nm_type,
        desc = desc,
    }
end


local init = function()
    local msg = require("network.message")
    local ec = require("network.error_code")


    for k, v in pairs(msg) do
        define(v[1], v[2], v[3], v[4], v[5])
    end
    for k, v in pairs(ec) do
        EC[k] = v
    end
end

return {
    init = init,
    NM = NM,
    NMINFO = NMINFO,
    EC = EC,
}